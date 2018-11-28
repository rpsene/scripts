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

ARRAY_ERRORS=()
IPS=($(openstack ip floating list | awk -F " " '{print $4}'))

if [ ${#IPS[@]} -eq 0 ]; then
        echo "No floating IPs to be pinged, hooray"
else
        for ip in "${IPS[@]:1}"; do
        echo '-------------------------------------------------------'
		ping -c 4 -q $ip
		if [ "$?" -eq 0 ]; then
        		echo "[ CONNECTION AVAILABLE ]"
        	else
            	echo "[ HOST DISCONNECTED ]"
			    ARRAY_ERRORS+=("$ip")
        	fi
            (( i+=1 ))
        done
	    if [ ${#ARRAY_ERRORS[@]} -gt 0 ]; then
            echo
            echo '**************************************************'
        	echo "There are floating IPs that cannot be accessible."
		    printf '%s\n' "${ARRAY_ERRORS[@]}"
            echo '**************************************************'
            echo
		    exit 1
	   fi
fi