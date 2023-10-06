#!/usr/bin/bash

logfile=/tmp/user_data.log
echo START `date '+%Y-%m-%d %H:%M:%S'`

#
# Export user data, which is defined with the "UserData" attribute
# in the template
#
%EXPORT_USER_DATA%

#input parameters
custom_file_shares="${custom_file_shares}"
list_of_filesets="${list_of_filesets}"
client_nodes="${client_nodes}"
protocol_instance_names="${protocol_instance_names}"
