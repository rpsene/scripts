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

FILE=./all_vms

ALL_VMS=($(openstack server list -c ID -f value | \
sed 's/ / /' | awk '{print $1}'))

echo "Amount of VMs: ${#ALL_VMS[@]}"

if [ ${#ALL_VMS[@]} -eq 0 ]; then
        echo "Thre is no VM to count."
else
        for vm in ${ALL_VMS[@]}; do
            if grep -q "$vm" "$FILE"; then
                echo "VM already registered."
            else
                echo "Colleting the date when the server $vm was created..."
                DATE=$(openstack server show -f=shell $vm | grep created \
                | awk -F= '{print $NF}' | tr -d "\"")
                echo "$vm, $DATE" >> all_vms
            fi
            (( i+=1 ))
        done
        NUMOFLINES=$(wc -l < "$FILE")
        echo "The current number of VMs created is $NUMOFLINES."
fi