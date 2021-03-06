# Connects to a VM in vCenter and copies specific files to local machine

Connect-VIServer 10.3.3.3

Invoke-VMScript -VM "BR_ROUTER2" -HostUser root -HostPassword cloudgs$123 -GuestUser vyos -GuestPassword vyos -ScriptText "cp /config/config.boot /config/config_backup.boot"

Copy-VMGuestFile -VM "BR_ROUTER2" -HostUser root -HostPassword cloudgs$123 -GuestUser vyos -GuestPassword vyos -Source "E:\End_toEnd Setup\ps_scripts\branchrouter\config.boot" -Destination "/config/" -LocalToGuest

Invoke-VMScript -VM "BR_ROUTER2" -HostUser root -HostPassword cloudgs$123 -GuestUser vyos -GuestPassword vyos -ScriptText "/etc/init.d/vyatta-router restart"


Disconnect-VIServer -Confirm:$false
