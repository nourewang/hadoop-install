require "hbase"
require "hbase/admin"

class Hbase::Admin
  
  def ext_list_all_tables()
    tables = @admin.listTables.to_a
    
    tables.each do |tab|
      print tab.getNameAsString, ':'
      tab.getFamilies.each { |cf| print cf.getNameAsString, ' ' }
      print "\n"
    end
  end
  
  def ext_list_column_families(table_name)
    tables = @admin.listTables.to_a
    tables << org.apache.hadoop.hbase.HTableDescriptor::META_TABLEDESC
    tables << org.apache.hadoop.hbase.HTableDescriptor::ROOT_TABLEDESC
    
    tables.each do |tab|
      # Found the table
      if tab.getNameAsString == table_name.strip
        tab.getFamilies.each { |cf| puts cf.getNameAsString }
        return
      end
    end

    raise(ArgumentError, "Failed to find table named #{table_name}")
  end
  
end


def list_all_tables()
  @shell.hbase_admin.ext_list_all_tables
end

def list_column_families(table_name)
  @shell.hbase_admin.ext_list_column_families table_name
end