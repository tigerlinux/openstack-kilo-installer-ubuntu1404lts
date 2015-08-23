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
	echo "This module was already installed. Exiting !"
	echo ""
	exit 0
fi

source $keystone_fulladmin_rc_file

echo ""
echo "Creating TROVE Identities"
echo ""

echo "Trove User:"
openstack user create --password $trovepass --email $troveemail $troveuser

echo "Trove Tenant:"
openstack project create $troveuser

echo "Adding Roles on tenants: $troveuser and $keystoneservicestenant"
openstack role add --project $keystoneservicestenant --user $troveuser $keystoneadminuser
openstack role add --project $troveuser --user $troveuser $keystoneadminuser

echo "Trove Services:"
openstack service create \
        --name $trovesvce \
        --description "Database Service" \
        database

echo "Trove Endpoint"
openstack endpoint create \
        --publicurl "http://$trovehost:8779/v1.0/\$(tenant_id)s" \
        --internalurl "http://$trovehost:8779/v1.0/\$(tenant_id)s" \
        --adminurl "http://$trovehost:8779/v1.0/\$(tenant_id)s" \
        --region $endpointsregion \
         database

echo "Ready"

echo ""
echo "TROVE Identities Created"
echo ""

