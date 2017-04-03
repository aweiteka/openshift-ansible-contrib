#!/bin/bash

###
#
# This is a wrapper script for `oc observe ...` which allows the passing of
# positional parameters since we cannot call ansible-playbook directly.
# It also allow us to quickly fail if the object is not annotated for sync.
#   $1 project name
#   $2 object name
#   $3 value of sync annotation
#
###
if [[ $3 == "me" ]]; then
  ansible-playbook watch.yml --extra-vars=project=$1 --extra-vars=object=$2
else
  echo "Update ignored: object not annotated 'sync: me'"
fi
