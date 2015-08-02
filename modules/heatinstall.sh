#!/bin/bash
#
# Unattended/SemiAutomatted OpenStack Installer
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# OpenStack KILO for Ubuntu 14.04lts
#
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#
# First, we source our config file and verify that some important proccess are 
# already completed.
#

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "Can't access my config file. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "DB Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "DB Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Keystone Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "Keystone Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/heat-installed ]
then
	echo ""
	echo "This module was already installed. Exiting !"
	echo ""
	exit 0
fi

#
# Some preseeding first. Anyway, we are installing all non interactivelly
#

echo "keystone keystone/auth-token password $SERVICE_TOKEN" > /tmp/keystone-seed.txt
echo "keystone keystone/admin-password password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-password-confirm password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-user string admin" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-tenant-name string $keystoneadminuser" >> /tmp/keystone-seed.txt
echo "keystone keystone/region-name string $endpointsregion" >> /tmp/keystone-seed.txt
echo "keystone keystone/endpoint-ip string $keystonehost" >> /tmp/keystone-seed.txt
echo "keystone keystone/register-endpoint boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-email string $keystoneadminuseremail" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-role-name string $keystoneadmintenant" >> /tmp/keystone-seed.txt
echo "keystone keystone/configure_db boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/create-admin-tenant boolean false" >> /tmp/keystone-seed.txt

debconf-set-selections /tmp/keystone-seed.txt

echo "glance-common glance/admin-password password $glancepass" > /tmp/glance-seed.txt
echo "glance-common glance/auth-host string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-api glance/keystone-ip string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-common glance/paste-flavor select keystone" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-tenant-name string $keystoneadmintenant" >> /tmp/glance-seed.txt
echo "glance-api glance/endpoint-ip string $glancehost" >> /tmp/glance-seed.txt
echo "glance-api glance/region-name string $endpointsregion" >> /tmp/glance-seed.txt
echo "glance-api glance/register-endpoint boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-user	string $keystoneadminuser" >> /tmp/glance-seed.txt
echo "glance-common glance/configure_db boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_host string $messagebrokerhost" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_password password $brokerpass" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_userid string $brokeruser" >> /tmp/glance-seed.txt

debconf-set-selections /tmp/glance-seed.txt

echo "cinder-common cinder/admin-password password $cinderpass" > /tmp/cinder-seed.txt
echo "cinder-api cinder/region-name string $endpointsregion" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/configure_db boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-tenant-name string $keystoneadmintenant" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/register-endpoint boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/auth-host string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/start_services boolean false" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/endpoint-ip string $cinderhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/volume_group string cinder-volumes" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/keystone-ip string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-user string $keystoneadminuser" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_password password $brokerpass" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_host string $messagebrokerhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_userid string $brokeruser" >> /tmp/cinder-seed.txt

debconf-set-selections /tmp/cinder-seed.txt

echo "neutron-common neutron/admin-password password $keystoneadminpass" > /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-password password $keystoneadminpass" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/keystone-ip string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/local_ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/register-endpoint boolean false" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tunnel_id_ranges string 0" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/endpoint-ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "openswan openswan/install_x509_certificate boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_password password $brokerpass" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_userid string $brokeruser" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_host string $messagebrokerhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tunnel_id_ranges string 1" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/plugin-select select OpenVSwitch" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/local_ip string $neutronhost" >> /tmp/neutron-seed.txt

debconf-set-selections /tmp/neutron-seed.txt

echo "nova-common nova/admin-password password $keystoneadminpass" > /tmp/nova-seed.txt
echo "nova-common nova/configure_db boolean false" >> /tmp/nova-seed.txt
echo "nova-consoleproxy nova-consoleproxy/daemon_type select spicehtml5" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit-host string 127.0.0.1" >> /tmp/nova-seed.txt
echo "nova-api nova/register-endpoint boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/my-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-common nova/start_services boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-user string $keystoneadminuser" >> /tmp/nova-seed.txt
echo "nova-api nova/region-name string $endpointsregion" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-tenant-name string $keystoneadmintenant" >> /tmp/nova-seed.txt
echo "nova-api nova/endpoint-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-api nova/keystone-ip string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/active-api multiselect ec2, osapi_compute, metadata" >> /tmp/nova-seed.txt
echo "nova-common nova/auth-host string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_host string $messagebrokerhost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_password password $brokerpass" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_userid string $brokeruser" >> /tmp/nova-seed.txt
echo "nova-common nova/neutron_url string http://$neutronhost:9696" >> /tmp/nova-seed.txt
echo "nova-common nova/neutron_admin_password password $neutronpass" >> /tmp/nova-seed.txt

debconf-set-selections /tmp/nova-seed.txt

echo "heat-common heat-common/internal/skip-preseed boolean true" > /tmp/heat-seed.txt
echo "heat-common heat/rabbit_password password $brokerpass" >> /tmp/heat-seed.txt
echo "heat-common heat/rabbit_userid string $brokeruser" >> /tmp/heat-seed.txt
echo "heat-common heat/admin-password password $heatpass" >> /tmp/heat-seed.txt
echo "heat-common heat/rabbit_userid string openstack" >> /tmp/heat-seed.txt
echo "heat-common heat-common/dbconfig-upgrade boolean true" >> /tmp/heat-seed.txt
echo "heat-common heat/auth-host string $keystonehost" >> /tmp/heat-seed.txt
echo "heat-common heat/configure_db boolean true" >> /tmp/heat-seed.txt
echo "heat-common heat/rabbit_host string $messagebrokerhost" >> /tmp/heat-seed.txt
echo "heat-common heat-common/dbconfig-install boolean true" >> /tmp/heat-seed.txt
echo "heat-common heat-common/upgrade-backup boolean true" >> /tmp/heat-seed.txt
echo "heat-common heat-common/database-type select sqlite3" >> /tmp/heat-seed.txt
echo "heat-common heat-common/dbconfig-reinstall boolean false" >> /tmp/heat-seed.txt
echo "heat-common heat/register-endpoint boolean false" >> /tmp/heat-seed.txt

debconf-set-selections /tmp/heat-seed.txt

echo ""
echo "Installing HEAT Packages"

#
# We proceed to install HEAT Packages non interactivelly
#

export DEBIAN_FRONTEND=noninteractive

DEBIAN_FRONTEND=noninteractive aptitude -y install heat-api heat-api-cfn heat-engine python-heatclient
DEBIAN_FRONTEND=noninteractive aptitude -y install heat-cfntools

echo "Done"
echo ""

rm -f /tmp/*.seed.txt

source $keystone_admin_rc_file

echo ""
echo "Configuring Heat"
echo ""

#
# We silentlly stop heat services
#

stop heat-api >/dev/null 2>&1
stop heat-api-cfn >/dev/null 2>&1
stop heat-engine >/dev/null 2>&1

#
# By using python based tools, we proceed to configure heat.
#

if [ ! -f /etc/heat/api-paste.ini ]
then
	cat ./libs/heat/api-paste.ini > /etc/heat/api-paste.ini
fi

chown -R heat.heat /etc/heat

echo "# Heat Main Config" >> /etc/heat/heat.conf

case $dbflavor in
"mysql")
	crudini --set /etc/heat/heat.conf database connection mysql://$heatdbuser:$heatdbpass@$dbbackendhost:$mysqldbport/$heatdbname
	;;
"postgres")
	crudini --set /etc/heat/heat.conf database connection postgresql://$heatdbuser:$heatdbpass@$dbbackendhost:$psqldbport/$heatdbname
	;;
esac

crudini --set /etc/heat/heat.conf database retry_interval 10
crudini --set /etc/heat/heat.conf database idle_timeout 3600
crudini --set /etc/heat/heat.conf database min_pool_size 1
crudini --set /etc/heat/heat.conf database max_pool_size 10
crudini --set /etc/heat/heat.conf database max_retries 100
crudini --set /etc/heat/heat.conf database pool_timeout 10
crudini --set /etc/heat/heat.conf database backend heat.db.sqlalchemy.api
 
crudini --set /etc/heat/heat.conf DEFAULT host $heathost
crudini --set /etc/heat/heat.conf DEFAULT debug false
crudini --set /etc/heat/heat.conf DEFAULT verbose false
crudini --set /etc/heat/heat.conf DEFAULT log_dir /var/log/heat

crudini --set /etc/heat/heat.conf DEFAULT heat_metadata_server_url http://$heathost:8000
crudini --set /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url http://$heathost:8000/v1/waitcondition
crudini --set /etc/heat/heat.conf DEFAULT heat_watch_server_url http://$heathost:8003
crudini --set /etc/heat/heat.conf DEFAULT heat_stack_user_role $heat_stack_user_role
crudini --set /etc/heat/heat.conf DEFAULT auth_encryption_key $heatencriptionkey
crudini --set /etc/heat/heat.conf DEFAULT use_syslog False
crudini --set /etc/heat/heat.conf DEFAULT heat_api_cloudwatch bind_host 0.0.0.0
crudini --set /etc/heat/heat.conf DEFAULT heat_api_cloudwatch bind_port 8003
 
crudini --set /etc/heat/heat.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
crudini --set /etc/heat/heat.conf keystone_authtoken admin_user $heatuser
crudini --set /etc/heat/heat.conf keystone_authtoken admin_password $heatpass
crudini --set /etc/heat/heat.conf keystone_authtoken auth_host $keystonehost
crudini --set /etc/heat/heat.conf keystone_authtoken auth_port 35357
crudini --set /etc/heat/heat.conf keystone_authtoken auth_protocol http
crudini --set /etc/heat/heat.conf keystone_authtoken auth_uri http://$keystonehost:5000/v2.0/
crudini --set /etc/heat/heat.conf keystone_authtoken identity_uri http://$keystonehost:35357
crudini --set /etc/heat/heat.conf keystone_authtoken signing_dir /tmp/keystone-signing-heat
 
crudini --set /etc/heat/heat.conf ec2authtoken auth_uri http://$keystonehost:5000/v2.0/
 
crudini --set /etc/heat/heat.conf DEFAULT control_exchange openstack
 
case $brokerflavor in
"qpid")
	crudini --set /etc/heat/heat.conf DEFAULT rpc_backend qpid
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_hostname $messagebrokerhost
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_port 5672
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_username $brokeruser
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_password $brokerpass
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_heartbeat 60
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_protocol tcp
	crudini --set /etc/heat/heat.conf oslo_messaging_qpid qpid_tcp_nodelay True
	;;
 
"rabbitmq")
	crudini --set /etc/heat/heat.conf DEFAULT rpc_backend rabbit
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_host $messagebrokerhost
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_password $brokerpass
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_userid $brokeruser
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_port 5672
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_use_ssl false
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_virtual_host $brokervhost
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_max_retries 0
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_retry_interval 1
	crudini --set /etc/heat/heat.conf oslo_messaging_rabbit rabbit_ha_queues false
	;;
esac

crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin $stack_domain_admin
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password $stack_domain_admin_password
crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name $stack_user_domain_name

echo ""
echo "Heat Configured"
echo ""

echo ""
echo "Create the heat domain in Identity service"
echo ""

source $keystone_admin_rc_file

#
# PATCH !!
# Package not found in Ubuntu HEAT - not at least af of May 26 2015
#

if [ ! -f /usr/bin/heat-keystone-setup-domain ]
then
	echo ""
	echo "Copying FILE heat-keystone-setup-domain"
	cat ./libs/heat/heat-keystone-setup-domain > /usr/bin/heat-keystone-setup-domain
	chmod 755 /usr/bin/heat-keystone-setup-domain
	echo ""
fi

heat-keystone-setup-domain \
        --stack-user-domain-name $stack_user_domain_name \
        --stack-domain-admin $stack_domain_admin \
        --stack-domain-admin-password $stack_domain_admin_password


#
# We proceed to provision/update HEAT Database
#

echo ""
echo "Provisioning HEAT Database"
echo ""
chown -R heat.heat /var/log/heat /etc/heat
heat-manage db_sync
chown -R heat.heat /var/log/heat /etc/heat

echo ""
echo "Done"
echo ""

#
# We proceed to apply IPTABLES rules and start/enable Heat services
#

echo ""
echo "Applying IPTABLES rules"

iptables -A INPUT -p tcp -m multiport --dports 8000,8004 -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Done"

echo ""
echo "Starting Services"
echo ""

start heat-api
start heat-api-cfn
start heat-engine

#
# Finally, we proceed to verify if HEAT was properlly installed. If not, we stop further procedings.
#

testheat=`dpkg -l heat-api 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testheat == "0" ]
then
	echo ""
	echo "HEAT Installatio FAILED. Aborting !"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/heat-installed
	date > /etc/openstack-control-script-config/heat
fi


echo ""
echo "Heat Installed and Configured"
echo ""



