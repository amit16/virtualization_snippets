#!/usr/bin/python
import logging
import getpass

from time import sleep
from zeus.common import exceptions
from zeus.common import constants
from zeus.utils.collections.command import Command
from zeus.hosts.host import Host
from zeus.services.process.reporting.result.result_container \
import ResultContainer

LOGGER = logging.getLogger()

TARGET = "10.3.3.3"
VC_USER = "AAA@AAAA.com"
#VC_PASSWORD = "TATATATAT"
VC_PASSWORD = getpass.getpass(prompt='vCenter Password :')
ESXI_IP = "172.20.75.42"
CONTROLLER_IP = "172.20.75.152"
CONTROLLER_NETWORK_NAME = "VM Network"
PORT_NETWORK_NAME = "Dummy_network"
DATASTORE_NAME = 'DS42'
MyOVA_NAME = "'SKU-qa62'"


class HostConf:
    """
        Host Configuration
    """
    def __init__(self, field_name, ip, name):
        self.field_name = field_name
        self.ip = ip
        self.name = name

    def __str__(self):
        return " --prop:\"{0}.ip\"=\"{1}\" --prop:\"{0}.name\"=\"{2}\""\
               .format(self.field_name, self.ip, self.name)


class PortConf:
    """
        Port configuration
    """
    def __init__(self, port):
        self.port   = port
        self.ip     = "0.0.0.0"
        self.subnet = "0"
        self.dns1 = "0.0.0.0"
        self.dns2 = "0.0.0.0"
        self.type   = "DHCP"
        self.gateway = "0.0.0.0"
        self.role = 'Disable'

    def __str__(self):
        return " --prop:\"{0}.dns1\"=\"{1}\" --prop:\"{0}.dns2\"=\"{2}\" --prop:\"{0}.gateway\"=\"{3}\" --prop:\"{0}.ip\"=\"{4}\" --prop:\"{0}.role\"=\"{7}\" --prop:\"{0}.subnet\"=\"{5}\" --prop:\"{0}.type\"=\"{6}\"".format(self.port, self.dns1, self.dns2, self.gateway, \
                        self.ip, self.subnet, self.type, self.role)

class MyOVATokenConf:
    """
        MyOVA Token cnfiguration
    """
    def __init__(self, ion_key, secret_key):
        self.ion_key     = ion_key
        self.secret_key  = secret_key

    def __str__(self):
        return " --prop:\"token.key\"=\"{}\" --prop:\"token.secret\"=\"{}\"".format(self.ion_key, self.secret_key)

class NetworkConf:
    """
        Network cnfiguration
    """
    def __init__(self, port, network_name):
        self.port          = port
        self.network_name  = network_name

    def __str__(self):
        return " --net:\"{}\"=\"{}\"".format(self.port, self.network_name)


     
hostConf_vmfg = HostConf("host2", CONTROLLER_IP, "mylab.org.net")
#print hostConf_vmfg
hostConf_cntrl = HostConf("host1", CONTROLLER_IP, "mylab2.org.net")
#print hostConf_cntrl

controller_port = ' --prop:"port1.dns1"="0.0.0.0" --prop:"port1.dns2"="0.0.0.0" --prop:"port1.gateway"="0.0.0.0" --prop:"port1.ip"="0.0.0.0" --prop:"port1.subnet"="0" --prop:"port1.type"="DHCP"'
port_data = controller_port

for port_count in xrange(2, 11): 
    port = 'port' + str(port_count)
    port =  PortConf(port)
    port_data = port_data + port.__str__()
    
#print port_data

#MyOVAtoken_data = MyOVATokenConf(args['ion_key'], args['secret_key'])

#print MyOVAtoken_data

network_data = ''
for net_count in xrange(1, 11):
    net = 'Port' + str(net_count)
    if net != 'Port1':
        net = NetworkConf(net, PORT_NETWORK_NAME)
    else:
        net = NetworkConf(net, CONTROLLER_NETWORK_NAME)
    network_data = network_data + net.__str__()
     
#print network_data
   
def MyOVA_ova_deploy(model_name, ion_key, secret_key):
    """Executed the ovftool command to deploy a MyOVA model OVA
       to the targeted ESXI server
       Args :
       MyOVA token ion key and secret key
    """
    try:
       MyOVA_MODEL_NAME = model_name
       SOURCE = "'/home/amit/comp/pacers/states/controller/MyOVA/helper/MyOVA_ova_files/" + MyOVA_MODEL_NAME + ".ova'"

       MyOVAtoken_data = MyOVATokenConf(ion_key, secret_key)
       LOGGER.info("Deploy MyOVA OVA model : {0}".format(model_name))
       ova_deploy_cmd = 'ovftool --acceptAllEulas --skipManifestCheck --X:injectOvfEnv --powerOn ' + hostConf_cntrl.__str__()  + hostConf_vmfg.__str__() + port_data + MyOVAtoken_data.__str__() + ' --datastore="'+ DATASTORE_NAME + '" ' + network_data + ' --diskMode=thin --name=' + MyOVA_NAME + ' ' + SOURCE + ' vi://{}:{}@{}/?ip={}'.format(VC_USER, VC_PASSWORD, TARGET, ESXI_IP)
       LOGGER.info("ova_deploy_cmd : {0}".format(ova_deploy_cmd))
       command_o = Command(ova_deploy_cmd)
       cmd_rc = command_o.execute()
       LOGGER.info("ova-deploy result data {0}".\
                format(cmd_rc.get_result_data()))
       return cmd_rc
     
    except Exception as e:
       raise exceptions.\
           ServerPcError("MyOVA_ova_deploy failed {0}".format(e))


