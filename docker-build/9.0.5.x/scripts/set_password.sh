#!/bin/bash
#####################################################################################
#                                                                                   #
#  Script to set the wsadmin password. There are three ways to obtain the value:    #
#   - Docker secret (preferred).                                                    #
#   - Content of /tmp/PASSWORD (defined in the previous runtime).                   #
#   - Random value (fallback).                                                      #
#                                                                                   #
#  Usage : set_password                                                             #
#                                                                                   #
#####################################################################################

ADMIN_USER_NAME=${ADMIN_USER_NAME:-"wsadmin"}
SECRET_ROOT='/run/secrets'
SECRET_NAME=${SECRET_NAME:-"wsadmin_password"}
WAS_PASSWD_FILE='/tmp/PASSWORD'
WAS_UPD_PASSWD_FILE='/tmp/passwordupdated'

if [ -f ${SECRET_ROOT}/${SECRET_NAME} ]; then
  password="$(cat ${SECRET_ROOT}/${SECRET_NAME})"

elif [ -f $WAS_PASSWD_FILE ]; then
  password="$(cat $WAS_PASSWD_FILE)"

else
  password="$(openssl rand -base64 6)"
  echo "$password" > $WAS_PASSWD_FILE
fi

/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE -f /work/updatePassword.py "$ADMIN_USER_NAME" "$password" > /dev/null 2>&1
echo "$password" > $WAS_UPD_PASSWD_FILE