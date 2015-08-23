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

if [ -f /etc/openstack-control-script-config/trove-installed ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

#
# We do some preseeding. Anyway, we are going to install everything non interactivelly
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
echo "glance-common glance/admin-user   string $keystoneadminuser" >> /tmp/glance-seed.txt
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

echo "trove-common trove/configure_db boolean false" >> /tmp/trove-seed.txt
echo "trove-common trove/admin-tenant-name string $troveuser" >> /tmp/trove-seed.txt
echo "trove-common trove/admin-user string admin" >> /tmp/trove-seed.txt
echo "trove-common trove/auth-host string $keystonehost" >> /tmp/trove-seed.txt
echo "trove-api trove/register-endpoint boolean false" >> /tmp/trove-seed.txt
echo "trove-common trove/admin-password password $trovepass" >> /tmp/trove-seed.txt

debconf-set-selections /tmp/trove-seed.txt

#
# We proceed to install all trove packages and dependencies, non-interactivelly
#

echo ""
echo "Installing TROVE Packages"

export DEBIAN_FRONTEND=noninteractive

DEBIAN_FRONTEND=noninteractive aptitude -y install python-trove python-troveclient python-glanceclient \
	trove-common trove-api trove-taskmanager trove-conductor

echo "Done"
echo ""

rm -f /tmp/*.seed.txt

#
# Silently stops strove
#

stop trove-taskmanager >/dev/null 2>&1
stop trove-taskmanager >/dev/null 2>&1
stop trove-api >/dev/null 2>&1
stop trove-api >/dev/null 2>&1
stop trove-conductor >/dev/null 2>&1
stop trove-conductor >/dev/null 2>&1

rm -f /var/lib/trove/trovedb

source $keystone_admin_rc_file

#
# By using a python based "ini" config tool, we proceed to configure trove services
#

echo ""
echo "Configuring Trove"
echo ""

sync
sleep 5
sync

 
commonfile='
	/etc/trove/trove.conf
	/etc/trove/trove-taskmanager.conf
	/etc/trove/trove-conductor.conf
'
for myconffile in $commonfile
do
	echo "Configuring file $myconffile"
	sleep 3
	echo "#" >> $myconffile
 
	case $dbflavor in
	"mysql")
		crudini --set $myconffile database connection mysql://$trovedbuser:$trovedbpass@$dbbackendhost:$mysqldbport/$trovedbname
		;;
	"postgres")
		crudini --set $myconffile database connection postgresql://$trovedbuser:$trovedbpass@$dbbackendhost:$psqldbport/$trovedbname
	;;
	esac
 
	crudini --set $myconffile DEFAULT log_dir /var/log/trove
	crudini --set $myconffile DEFAULT verbose False
	crudini --set $myconffile DEFAULT debug False
	crudini --set $myconffile DEFAULT control_exchange trove
	crudini --set $myconffile DEFAULT trove_auth_url http://$keystonehost:5000/v2.0
	crudini --set $myconffile DEFAULT nova_compute_url http://$novahost:8774/v2
	crudini --set $myconffile DEFAULT cinder_url http://$cinderhost:8776/v2
	crudini --set $myconffile DEFAULT swift_url http://$swifthost:8080/v1/AUTH_
	crudini --set $myconffile DEFAULT notifier_queue_hostname $messagebrokerhost
 
	case $brokerflavor in
	"qpid")
		crudini --set $myconffile DEFAULT rpc_backend trove.openstack.common.rpc.impl_qpid
		# Deprecated
		# crudini --set $myconffile DEFAULT qpid_reconnect_interval_min 0
		# crudini --set $myconffile DEFAULT qpid_username $brokeruser
		# crudini --set $myconffile DEFAULT qpid_tcp_nodelay True
		# crudini --set $myconffile DEFAULT qpid_protocol tcp
		# crudini --set $myconffile DEFAULT qpid_hostname $messagebrokerhost
		# crudini --set $myconffile DEFAULT qpid_password $brokerpass
		# crudini --set $myconffile DEFAULT qpid_port 5672
		# crudini --set $myconffile DEFAULT qpid_topology_version 1
		crudini --set $myconffile oslo_messaging_qpid qpid_hostname $messagebrokerhost
		crudini --set $myconffile oslo_messaging_qpid qpid_port 5672
		crudini --set $myconffile oslo_messaging_qpid qpid_username $brokeruser
		crudini --set $myconffile oslo_messaging_qpid qpid_password $brokerpass
		crudini --set $myconffile oslo_messaging_qpid qpid_heartbeat 60
		crudini --set $myconffile oslo_messaging_qpid qpid_protocol tcp
		crudini --set $myconffile oslo_messaging_qpid qpid_tcp_nodelay True
		;;
	"rabbitmq")
		crudini --set $myconffile DEFAULT rpc_backend trove.openstack.common.rpc.impl_kombu
		# Deprecated
		# crudini --set $myconffile DEFAULT rabbit_host $messagebrokerhost
		# crudini --set $myconffile DEFAULT rabbit_userid $brokeruser
		# crudini --set $myconffile DEFAULT rabbit_password $brokerpass
		# crudini --set $myconffile DEFAULT rabbit_port 5672
		# crudini --set $myconffile DEFAULT rabbit_use_ssl false
		# crudini --set $myconffile DEFAULT rabbit_virtual_host $brokervhost
		# crudini --set $myconffile DEFAULT notifier_queue_userid $brokeruser
		# crudini --set $myconffile DEFAULT notifier_queue_password $brokerpass
		# crudini --set $myconffile DEFAULT notifier_queue_ssl false
		# crudini --set $myconffile DEFAULT notifier_queue_port 5672
		# crudini --set $myconffile DEFAULT notifier_queue_virtual_host $brokervhost
		# crudini --set $myconffile DEFAULT notifier_queue_transport memory
		crudini --set $myconffile oslo_messaging_rabbit rabbit_host $messagebrokerhost
		crudini --set $myconffile oslo_messaging_rabbit rabbit_password $brokerpass
		crudini --set $myconffile oslo_messaging_rabbit rabbit_userid $brokeruser
		crudini --set $myconffile oslo_messaging_rabbit rabbit_port 5672
		crudini --set $myconffile oslo_messaging_rabbit rabbit_use_ssl false
		crudini --set $myconffile oslo_messaging_rabbit rabbit_virtual_host $brokervhost
		crudini --set $myconffile oslo_messaging_rabbit rabbit_max_retries 0
		crudini --set $myconffile oslo_messaging_rabbit rabbit_retry_interval 1
		crudini --set $myconffile oslo_messaging_rabbit rabbit_ha_queues false
	;;
	esac
done
 
 
crudini --set /etc/trove/trove-taskmanager.conf DEFAULT nova_proxy_admin_user $keystoneadminuser
crudini --set /etc/trove/trove-taskmanager.conf DEFAULT nova_proxy_admin_pass $keystoneadminpass
crudini --set /etc/trove/trove-taskmanager.conf DEFAULT nova_proxy_admin_tenant_name $keystoneadmintenant

#
# We set our default datastore by using our database flavor selected into our main config file
#
 
case $dbflavor in
"mysql")
	crudini --set /etc/trove/trove.conf DEFAULT default_datastore mysql
	;;
"postgres")
	crudini --set /etc/trove/trove.conf DEFAULT default_datastore postgresql
	;;
esac

crudini --set /etc/trove/trove.conf DEFAULT add_addresses True
crudini --set /etc/trove/trove.conf DEFAULT network_label_regex "^NETWORK_LABEL$"
crudini --set /etc/trove/trove.conf DEFAULT api_paste_config /etc/trove/api-paste.ini
crudini --set /etc/trove/trove.conf DEFAULT bind_host 0.0.0.0
crudini --set /etc/trove/trove.conf DEFAULT bind_port 8779
crudini --set /etc/trove/trove.conf DEFAULT taskmanager_manager trove.taskmanager.manager.Manager
 
troveworkers=`grep processor.\*: /proc/cpuinfo |wc -l`
 
crudini --set /etc/trove/trove.conf DEFAULT trove_api_workers $troveworkers
 
# Deprecated
# crudini --set /etc/trove/trove.conf keystone_authtoken admin_tenant_name $troveuser
# crudini --set /etc/trove/trove.conf keystone_authtoken admin_user $troveuser
# crudini --set /etc/trove/trove.conf keystone_authtoken admin_password $trovepass
# crudini --set /etc/trove/trove.conf keystone_authtoken auth_host $keystonehost
# crudini --set /etc/trove/trove.conf keystone_authtoken auth_port 35357
# crudini --set /etc/trove/trove.conf keystone_authtoken auth_protocol http
crudini --set /etc/trove/trove.conf keystone_authtoken signing_dir /var/cache/trove
crudini --set /etc/trove/trove.conf keystone_authtoken auth_uri http://$keystonehost:5000
crudini --set /etc/trove/trove.conf keystone_authtoken auth_url http://$keystonehost:35357
crudini --set /etc/trove/trove.conf keystone_authtoken auth_plugin password
crudini --set /etc/trove/trove.conf keystone_authtoken project_domain_id default
crudini --set /etc/trove/trove.conf keystone_authtoken user_domain_id default
crudini --set /etc/trove/trove.conf keystone_authtoken project_name $keystoneservicestenant
crudini --set /etc/trove/trove.conf keystone_authtoken username $troveuser
crudini --set /etc/trove/trove.conf keystone_authtoken password $trovepass


mkdir -p /var/cache/trove
chown -R trove.trove /var/cache/trove
chown trove.trove /etc/trove/*
chmod 700 /var/cache/trove
chmod 700 /var/log/trove

touch /var/log/trove/trove-manage.log
chown trove.trove /var/log/trove/*

echo ""
echo "Trove Configured"
echo ""

#
# We provision/update Trove database
#

echo ""
echo "Provisioning Trove DB"
echo ""

su -s /bin/sh -c "trove-manage db_sync" trove

#
# And we create the datastore
#

case $dbflavor in
"mysql")
	echo ""
	echo "Creating Trove MYSQL Datastore"
	echo ""
	su -s /bin/sh -c "trove-manage datastore_update mysql ''" trove
	;;
"postgres")
	echo ""
	echo "Creating Trove POSTGRESQL Datastore"
	echo ""
	su -s /bin/sh -c "trove-manage datastore_update postgresql ''" trove
	;;
esac

echo ""
echo "Done"
echo ""

#
# Here we apply IPTABLES rules and start/enable trove services
#

echo ""
echo "Applying IPTABLES rules"

iptables -A INPUT -p tcp -m multiport --dports 8779 -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Done"

echo ""
echo "Starting Services"
echo ""

start trove-api
start trove-taskmanager
start trove-conductor

#
# And finally, we do a little test to ensure our trove packages are installed. If we
# fail this test, we stop the installer from this point.
#

testtrove=`dpkg -l trove-api 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testtrove == "0" ]
then
        echo ""
        echo "TROVE Installation Failed. Aborting !"
        echo ""
        exit 0
else
        date > /etc/openstack-control-script-config/trove-installed
        date > /etc/openstack-control-script-config/trove
fi

echo ""
echo "Trove Installed and Configured"
echo ""

