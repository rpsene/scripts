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

function containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

SERVERS=($(openstack server list -c ID -c Name -c Image -f value | \
grep -E "sardonyx-*|travis-201[0-9]*|*icp-(worker|master)-[0-9]" | \
sed 's/ / /' | awk '{print $1}'))

for server in ${SERVERS[@]}; do
	echo $server
done

USER_IDS_TO_KEEP=(<list of users ids which VMs will not be deleted>)
IFS=$'\n' read -d '' -r -a VMS_TO_KEEP < ./<file with the name of the VMs to keep>

# If we do not have any services, exit.
if [ ${#SERVERS[@]} -eq 0 ]; then
	echo "There are no VMs to delete."
    exit 0
else
    for server in ${SERVERS[@]}; do
        # Get raw information about the server
        RAW_DATA=$(openstack server show -f=shell $server)
        ARR=($RAW_DATA)

        # Get information about when the server was created
        SERVER_CREATION=$(printf "%s\n" "${ARR[@]}" | \
        grep created | awk -F "=" '{print $2}' | tr -d '\"' | tr -d 'Z')

        # Get the user id that created the server
		USER_ID=$(printf "%s\n" "${ARR[@]}" | \
        grep user_id | awk -F "=" '{print $2}' | tr -d '\"')

        # Get the date when server was created
        DATE_CREATION=$(date -u --date "$SERVER_CREATION" +%s)

        # Get the current date
        CURRENT=$(date -u --iso-8601=ns | cut -d',' -f1)
        DATE_CURRENT=$(date -u --date "$CURRENT" +%s)

        # Calculate the time difference in seconds
        SECONDS=$(( DATE_CURRENT - DATE_CREATION ))

        # Get the name of the server
        NAME=$(printf "%s\n" "${ARR[@]}" | grep -w -m 1 name | \
        awk -F "=" '{print $2}' | tr -d '\"')

        # Format the time, from seconds to hours, minutes and seconds.
        TIME=$(printf '%dh:%dm:%ds\n' $(($SECONDS/3600)) \
        $(($SECONDS%3600/60)) $(($SECONDS%60)))

        echo "The server $NAME ($server), which belongs to $USER_ID is running for $TIME."

        if [ $(($SECONDS/3600)) -ge 12 ]; then
            containsElement $NAME "${VMS_TO_KEEP[@]}"
            keep_vm="$?"
            containsElement $USER_ID "${USER_IDS_TO_KEEP[@]}"
            keep_userid="$?"
            if [ "$keep_vm" -ne 0 ] || [ "$keep_userid" -ne 0 ]; then
            	echo "The server $NAME ($server) is running for $TIME and should be deleted! "
            	echo -ne "deleting $NAME ..."
        		openstack server delete --wait $server
        	    echo "done!"
        	fi
        fi
        (( i+=1 ))
    done
fi