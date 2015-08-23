#!/bin/bash
#
# Unattended/SemiAutomatted OpenStack Installer
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# OpenStack KILO for Ubuntu 14.04lts
#
#
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "Can't Access my config file. Aborting !"
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

if [ -f /etc/openstack-control-script-config/keystone-extra-idents ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

source $keystone_fulladmin_rc_file

echo ""
echo "Creating NEUTRON Identities"
echo ""

echo "Neutron User:"
openstack user create --password  $neutronpass --email $neutronemail $neutronuser

echo "Neutron Role:"
openstack role add --project $keystoneservicestenant --user $neutronuser $keystoneadminuser

echo "Neutron Service:"
openstack service create \
        --name $neutronsvce \
        --description "OpenStack Networking" \
        network

echo "Neutron Endpoint:"
openstack endpoint create \
        --publicurl "http://$neutronhost:9696" \
        --adminurl "http://$neutronhost:9696" \
        --internalurl "http://$neutronhost:9696" \
        --region $endpointsregion \
        network

echo "Listo"

echo ""
echo "NEUTRON Identities Created"
echo ""

