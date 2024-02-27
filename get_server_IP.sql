SELECT  
   CONNECTIONPROPERTY('local_net_address') AS Server_net_address,
   CONNECTIONPROPERTY('local_tcp_port') AS local_tcp_port,
   CONNECTIONPROPERTY('client_net_address') AS myclient_net_address 