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
	echo "Kesytone Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/sahara-installed ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

#
# We do some preseeding first. Anyway, we are going to install non-interactivelly
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

echo "sahara-common sahara/rabbit_password password $brokerpass" > /tmp/sahara-seed.txt
echo "sahara-common sahara/admin-password password $saharapass" >> /tmp/sahara-seed.txt
echo "sahara sahara/register-endpoint boolean false" >> /tmp/sahara-seed.txt
echo "sahara sahara/region-name string $endpointsregion" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/admin-tenant-name string $keystoneservicestenant" >> /tmp/sahara-seed.txt
echo "sahara sahara/keystone-ip string $saharahost" >> /tmp/sahara-seed.txt
echo "sahara sahara/endpoint-ip string $keystonehost" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/admin-user string $saharauser" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/auth-host string $keystonehost" >> /tmp/sahara-seed.txt
# echo "sahara-common sahara/configure_db boolean false" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/configure_db boolean true" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/rabbit_userid string $brokeruser" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/rabbit_host string $messagebrokerhost" >> /tmp/sahara-seed.txt

debconf-set-selections /tmp/sahara-seed.txt


echo ""
echo "Installing SAHARA Packages"

#
# We install sahara related packages and dependencies, non interactivelly of course
#

export DEBIAN_FRONTEND=noninteractive

#
# We have to do a very nasty patch here... first try fails, so we send errors to /dev/null...
# A partially installation is done, then after we correctly configure the database, we retry
# the installation. This retry should go OK !.
#

DEBIAN_FRONTEND=noninteractive aptitude -y install python-sahara sahara-common sahara > /dev/null 2>&1

echo "Done"
echo ""

rm -f /tmp/*.seed.txt

source $keystone_admin_rc_file

#
# By using python based "ini" config tools, we proceed to configure Sahara
#

echo ""
echo "Configuring SAHARA"
echo ""

#
# We silentlly stops sahara
#

stop sahara >/dev/null 2>&1

echo "#" >> /etc/sahara/sahara.conf

#
# This seems overkill, but we had found more than once of this setting repeated inside sahara.conf
#

crudini --del /etc/sahara/sahara.conf database connection >/dev/null 2>&1
crudini --del /etc/sahara/sahara.conf database connection >/dev/null 2>&1
crudini --del /etc/sahara/sahara.conf database connection >/dev/null 2>&1
crudini --del /etc/sahara/sahara.conf database connection >/dev/null 2>&1
crudini --del /etc/sahara/sahara.conf database connection >/dev/null 2>&1

#
# Database flavor configuration based on our selection inside the installer main config file
#

case $dbflavor in
"mysql")
        crudini --set /etc/sahara/sahara.conf database connection mysql://$saharadbuser:$saharadbpass@$dbbackendhost:$mysqldbport/$saharadbname
        ;;
"postgres")
        crudini --set /etc/sahara/sahara.conf database connection postgresql://$saharadbuser:$saharadbpass@$dbbackendhost:$psqldbport/$saharadbname
        ;;
esac

#
# Main config
#

crudini --set /etc/sahara/sahara.conf DEFAULT debug false
crudini --set /etc/sahara/sahara.conf DEFAULT verbose false
crudini --set /etc/sahara/sahara.conf DEFAULT log_dir /var/log/sahara
crudini --set /etc/sahara/sahara.conf DEFAULT log_file sahara.log
crudini --set /etc/sahara/sahara.conf DEFAULT host $saharahost
crudini --set /etc/sahara/sahara.conf DEFAULT port 8386
crudini --set /etc/sahara/sahara.conf DEFAULT use_neutron true
crudini --set /etc/sahara/sahara.conf DEFAULT use_namespaces true
crudini --set /etc/sahara/sahara.conf DEFAULT os_region_name $endpointsregion
crudini --set /etc/sahara/sahara.conf DEFAULT control_exchange openstack

#
# Keystone Sahara Config
#

# Deprecated
# crudini --set /etc/sahara/sahara.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
# crudini --set /etc/sahara/sahara.conf keystone_authtoken admin_user $saharauser
# crudini --set /etc/sahara/sahara.conf keystone_authtoken admin_password $saharapass
# crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_host $keystonehost
# crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_port 35357
# crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_protocol http
crudini --set /etc/sahara/sahara.conf keystone_authtoken signing_dir /tmp/keystone-signing-sahara
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_uri http://$keystonehost:5000
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_url http://$keystonehost:35357
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_plugin password
crudini --set /etc/sahara/sahara.conf keystone_authtoken project_domain_id default
crudini --set /etc/sahara/sahara.conf keystone_authtoken user_domain_id default
crudini --set /etc/sahara/sahara.conf keystone_authtoken project_name $keystoneservicestenant
crudini --set /etc/sahara/sahara.conf keystone_authtoken username $saharauser
crudini --set /etc/sahara/sahara.conf keystone_authtoken password $saharapass

crudini --set /etc/sahara/sahara.conf oslo_concurrency lock_path "/var/oslock/sahara"

mkdir -p /var/oslock/sahara
chown -R sahara.sahara /var/oslock/sahara

#
# Message Broker config for sahara. Again, based on our flavor selected inside the installer config file
#

case $brokerflavor in
"qpid")
        crudini --set /etc/sahara/sahara.conf DEFAULT rpc_backend qpid
	# Deprecated
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_reconnect_interval_min 0
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_username $brokeruser
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_tcp_nodelay True
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_protocol tcp
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_hostname $messagebrokerhost
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_password $brokerpass
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_port 5672
        # crudini --set /etc/sahara/sahara.conf DEFAULT qpid_topology_version 1
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_hostname $messagebrokerhost
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_port 5672
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_username $brokeruser
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_password $brokerpass
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_heartbeat 60
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_protocol tcp
	crudini --set /etc/sahara/sahara.conf oslo_messaging_qpid qpid_tcp_nodelay True
        ;;

"rabbitmq")
        crudini --set /etc/sahara/sahara.conf DEFAULT rpc_backend rabbit
	# Deprecated
        # crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_host $messagebrokerhost
        # crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_userid $brokeruser
        # crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_password $brokerpass
        # crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_port 5672
        # crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_use_ssl false
        # crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_virtual_host $brokervhost
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_host $messagebrokerhost
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_password $brokerpass
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_userid $brokeruser
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_port 5672
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_use_ssl false
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_virtual_host $brokervhost
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_max_retries 0
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_retry_interval 1
	crudini --set /etc/sahara/sahara.conf oslo_messaging_rabbit rabbit_ha_queues false
        ;;
esac

mkdir -p /var/log/sahara
echo "" > /var/log/sahara/sahara.log
chown -R sahara.sahara /var/log/sahara /etc/sahara

echo ""
echo "Sahara Configured"
echo ""

#
# With the configuration done, we proceed to provision/update Sahara database
#

echo ""
echo "Provisioning SAHARA database"
echo ""

sahara-db-manage --config-file /etc/sahara/sahara.conf upgrade head

chown -R sahara.sahara /var/log/sahara /etc/sahara /var/oslock/sahara

echo "Done"
echo ""

#
# Then we apply IPTABLES rules and start/enable Sahara services
#

echo ""
echo "Applying IPTABLES rules"

iptables -A INPUT -p tcp -m multiport --dports 8386 -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Done"

echo ""
echo "Starting Services"
echo ""

#
# Part of the nasty patch !!
#

DEBIAN_FRONTEND=noninteractive aptitude -y install python-sahara sahara-common sahara > /dev/null 2>&1
stop sahara > /dev/null 2>&1

start sahara

#
# Finally, we perform a package installation check. If we fail this, we stop the main installer
# from this point.
#

testsahara=`dpkg -l sahara-common 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testsahara == "0" ]
then
	echo ""
	echo "SAHARA Installation FAILED. Aborting !"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/sahara-installed
	date > /etc/openstack-control-script-config/sahara
fi


echo ""
echo "Sahara Installed and Configured"
echo ""


