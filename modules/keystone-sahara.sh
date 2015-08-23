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
	echo "Keystone Proccess OK. Let's Continue"
	echo ""
else
	echo ""
	echo "Keystone Proccess not complete. Aborting !"
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
echo "Creating SAHARA Identities"
echo ""

echo "Sahara User:"
openstack user create --password $saharapass --email $saharaemail $saharauser

echo "Sahara Tenant:"
openstack project create $saharauser

echo "Sahara Tenants Role: $saharauser and $keystoneservicestenant"
openstack role add --project $keystoneservicestenant --user $saharauser $keystoneadminuser
openstack role add --project $saharauser --user $saharauser $keystoneadminuser

echo "Sahara Service:"
openstack service create \
        --name $saharasvce \
        --description "Data Processing Service" \
        data_processing

echo "Sahara Endpoint:"
openstack endpoint create \
        --publicurl "http://$saharahost:8386/v1.1/\$(tenant_id)s" \
        --internalurl "http://$saharahost:8386/v1.1/\$(tenant_id)s" \
        --adminurl "http://$saharahost:8386/v1.1/\$(tenant_id)s" \
        --region $endpointsregion \
        data_processing

echo "Ready"

echo ""
echo "SAHARA Identities Created"
echo ""

