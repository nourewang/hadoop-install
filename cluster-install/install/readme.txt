
1.安装edh
install_manager.sh

2.添加集群节点，待考虑ip或者hostname的解析方式，并设置无密码登陆
expect ssh_nopassword.exp cdh1 redhat
expect ssh_nopassword.exp cdh2 redhat
expect ssh_nopassword.exp cdh3 redhat
expect ssh_nopassword.exp cdh4 redhat

3.设置节点角色
install_namenode.sh
install_client.sh
