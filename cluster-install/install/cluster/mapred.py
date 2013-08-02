'''
 MapReduce detailed phase timing collection module.
 See http://sourceforge.net/apps/trac/ganglia/wiki/ganglia_gmond_python_modules for Gmond python module reference 
 '''

import os, sys, re, threading, time

PHASES = ['map', 'spill', 'shuffle', 'sort', 'reduce', 'copier', 'fsMerge', 'memMerge']

JOBID_PATTERN = re.compile('job_(\d+)_(\d+)')
LOGFILE_PATTERN = re.compile('(\w+)_(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)_(\d+)_(\w+)_(\d+)_(\d+).log')

AGENT_OUT_DIR = '/tmp/agent.out'



def logError(msg):
    sys.stdout.write('Mapred ERROR: ' + msg + '\n')
    sys.stdout.flush()

def logInfo(msg):
    sys.stdout.write('Mapred: ' + msg + '\n')
    sys.stdout.flush()


class Counter:
    ''' Simple accumulating counter '''
    def __init__(self):        
        self.reset()
                
    def reset(self):
        self.sum = 0
        self.samples = 0
    
    def inc(self, value, samples):
        self.sum += value
        self.samples += samples
        
    def getSum(self):
        return self.sum
    
    def getSamples(self):
        return self.samples
    
    def getValue(self):
        return 0 if self.samples == 0 else self.sum / self.samples
    
    def toString(self):
        return "{0}:{1}".format(self.sum, self.samples) 

class CounterMap:
    def __init__(self):        
        self.counters = dict()
        self.lock = threading.Lock() 
    
    def inc(self, phase, value, samples):
        if phase not in self.counters:
                self.counters[phase] = Counter()
        self.counters[phase].inc(value, samples)   
    
    def getValue(self, phase):
        if phase in self.counters:
            return self.counters[phase].getValue()
        else:
            logError("Counter does not exist for phase : " + phase)
            return 0
    
    def reset(self, phase):
        if phase in self.counters:
              self.counters[phase].reset()
        
    def add(self, counterMap):
        for phase in counterMap.counters:
            self.inc(phase, counterMap.counters[phase].getSum(), counterMap.counters[phase].getSamples())

    def toString(self):
        str ='';
        for phase in self.counters:
            if len(str) > 0:
                str += ","
            str += phase + ":" + self.counters[phase].toString()
        return '[' + str + ']'    


class PollerThread(threading.Thread):
    '''Accumulates the numbers from agent logs into global counters, one counter per each phase'''

    def __init__(self, refreshPeriod):
        threading.Thread.__init__(self)
        self.refreshPeriod = refreshPeriod
        self.stopRequest = False
        self.stopCondition = threading.Condition()

    def stop(self):
        # signal running thread it must exit wait loop
        self.stopCondition.acquire()        
        self.stopRequest = True
        self.stopCondition.notify()
        self.stopCondition.release()

    def run(self):
        global globalStatCounters
        quit = False;
        while not quit:
            # first, get statistics locally
            try:   
                localStats = getStats();        
                globalStatCountersLock.acquire()
                try:
                    # merge to global stat counters under lock - add local stat numbers to global globalStatCounters
                    globalStatCounters.add(localStats)
                finally:
                    globalStatCountersLock.release()
                logInfo('Mapred statistics updated : ' + localStats.toString())
                self.stopCondition.acquire()
                try:
                    self.stopCondition.wait(self.refreshPeriod)
                    # read stop request to local thread variable 
                    quit = self.stopRequest
                finally:
                    self.stopCondition.release();
            except Exception as e:
                logError('Exception {0}'.format(str(e)))

# Global statistic values structured as : hash[phaseName]{'sum': XXX, 'sampleCount' : YYY }
globalStatCounters = CounterMap()
globalStatCountersLock = threading.Lock()
pollerThread = None


def getMetricDescription(name):    
    d = {'name': name,
        'call_back': getMetricValue,
        'time_max': 90,
        'value_type': 'uint',
        'units': 'msec',
        'slope': 'both',
        'format': '%u',
        'description': 'MapReduce {0}'.format(name),
        'groups': 'Hadoop'}    
    return d 


def aggregate(lines, counterMap):
    ''' Aggregates a list of records with phase durations, calculating total time spent in each phase. 
    Expects the list of record in form like:  spill,1353093497985,40 '''
    for line in lines:   
        parts = line.strip(' \n').split(',')
        if len(parts) >= 3:
            phase = parts[0]
            duration = long(parts[2])
            counterMap.inc(phase, duration, 1)    
    pass
                                    

 
def getStats():
    '''Reads all statistics recorded since the last '''    
    localStats = CounterMap()
    global AGENT_OUT_DIR
    if os.path.exists(AGENT_OUT_DIR) and os.path.isdir(AGENT_OUT_DIR):
        for f in os.listdir(AGENT_OUT_DIR):
            m = JOBID_PATTERN.match(f)
            if m:
                readJobDir(os.path.join(AGENT_OUT_DIR, f), localStats)             
            else:
                logError('Invalid job directory : ' + f)
            #TODO:  remove old JOB directories (e.g. keep X most recent job ID's)
    return localStats


def readJobDir(jobDir, counterMap):
    '''Read all records from the given log directory '''
    
    lastAttempt = -1;
    
    lines = list()   
    logfiles = dict()   
    # collect all logs with highest attempt number
    toremove = list();
    for f in os.listdir(jobDir):
        # look files like attempt_201209120043_0001_m_000019_0.log
        m = LOGFILE_PATTERN.match(f)
        if m:
            toremove.append(f);
            taskid = m.group(9)
            attempt = int(m.group(10))
            if attempt > lastAttempt:
                logfiles[taskid] = f
    # read all log files now
    for taskid in logfiles.keys():
        try:
            readLog(os.path.join(jobDir, logfiles[taskid]), counterMap)
        except Exception as e:
            logError('Exception {0}'.format(str(e)))    
    
    # remove all log files in this dir once we've read them  
    for f in toremove:
        try:
            os.remove(os.path.join(jobDir, f))
            pass
        except Exception as e:
            logError('Exception {0}'.format(str(e)))            
    return lines

'''Reads a single log file with mapred stat records'''
def readLog(logFile, counterMap):
    f = open(logFile, 'r')
    lines = f.readlines()
    f.close()
    aggregate(lines, counterMap)
    

def getMetricValue(name):
    m = re.match('resmon.mapred.(\w+)', name);
    value = long(0)
    if m:
        phase = m.group(1)
        globalStatCountersLock.acquire()
        try:
            value = globalStatCounters.getValue(phase)
            globalStatCounters.reset(phase)
        finally:
            globalStatCountersLock.release()
    else:
        logError('Invalid metric name : ' + name)        
    logInfo('Value for {0} is {1}'.format(name, value))          
    return value


def metric_init(params):
    '''Initialize the random number generator and create the
    metric definition dictionary object for each metric.'''
    global AGENT_OUT_DIR, pollerThread
    
    if 'outDir' in params:
         AGENT_OUT_DIR = params['outDir']
         
    updateInterval = 30
    if 'updateInterval' in params:
        updateInterval = int(params['updateInterval'])

    pollerThread = PollerThread(updateInterval)
    pollerThread.start()
    
    logInfo('Initializing mapred collector with parameters:')
    print params
    
    descriptors = list()
    for phase in PHASES:
        metricName = 'resmon.mapred.' + phase 
        descriptors.append(getMetricDescription(metricName))
    return descriptors

def metric_cleanup():
    '''Clean up the metric module.'''
    logInfo('Shutting down mapred collector')
    pollerThread.stop()
    pollerThread.join(1000);
    pass

#This code is for debugging and unit testing    
if __name__ == '__main__':
    params = {'outDir': '/tmp/resmon/agent',
        'updateInterval': '1'}
    descriptors = metric_init(params)
    time.sleep(3)
    for d in descriptors:
        v = d['call_back'](d['name'])
        logInfo('value for %s is %u' % (d['name'], v))
    metric_cleanup()

