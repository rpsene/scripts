#!/bin/bash

: '
Copyright (C) 2018 Rafael Peria de Sene
Licensed under the Apache License, Version 2.0 (the “License”);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
    Contributors:
        * Rafael Sene <rpsene@gmail.com>
'

#Check if openstack-cli is installed
if ! [ -x "$(command -v openstack)" ]; then
   echo 'Error: openstack is not installed.' >&2
   exit 1
fi

source <your script that unlocks access to your openstack>

ERROR_VMS=($(openstack server list -c ID -c Name -c Status -f value | \
grep 'ERROR' | sed 's/ / /' | awk '{print $1}'))

echo "Amount of VM in ERROR state: ${#ERROR_VMS[@]}"

if [ ${#ERROR_VMS[@]} -eq 0 ]; then
        echo "No VM to be deleted!"
else
        printf '%s\n' "${ERROR_VMS[@]}"
        for vm in ${ERROR_VMS[@]}; do
            echo "Deleting $vm..."
            openstack server delete $vm
            (( i+=1 ))
        done
fi