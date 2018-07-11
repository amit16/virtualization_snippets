# Once connected to vCenter, this script can get VM Information from the given MAC Address

$mac = Read-Host "What mac address do you want to lookup (format:11:22:33:44:55:66 )"
get-vm | Get-NetworkAdapter | where {$_.macaddress -eq "$mac"} | select parent,macaddress
