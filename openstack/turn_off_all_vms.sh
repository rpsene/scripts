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

# Check if openstack-cli is installed
if ! [ -x "$(command -v openstack)" ]; then
   echo 'Error: openstack is not installed.' >&2
   exit 1
fi

source <your script that unlocks access to your openstack>

ALL_VMS=($(openstack server list -c ID -c Name -c Status -f value | \
sed 's/ / /' | awk '{print $1}'))

echo "Amount of VMs: ${#ALL_VMS[@]}"

if [ ${#ALL_VMS[@]} -eq 0 ]; then
        echo "There is no VM to be turned off."
else
        printf '%s\n' "${ALL_VMS[@]}"
        for vm in ${ALL_VMS[@]}; do
            echo "Turning off $vm..."
            openstack server stop $vm
            (( i+=1 ))
        done
fi