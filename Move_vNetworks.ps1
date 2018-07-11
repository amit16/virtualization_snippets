# Completely Replicates the Virtual Network Data from One source ESXi host to another.
# The move includes - vSwitches, vPortgroups,Physical Uplink needed to be done manually


$VISRV = Connect-VIServer (Read-Host "Please enter the name of your VI SERVER")
$BASEHost = Get-VMHost -Name (Read-Host "Please enter the name of your existing server as seen in the VI Client:")
$NEWHost = Get-VMHost -Name (Read-Host "Please enter the name of the server to configure as seen in the VI Client:")

$BASEHost |Get-VirtualSwitch |Foreach {
   If (($NEWHost |Get-VirtualSwitch -Name $_.Name -ErrorAction SilentlyContinue)-eq $null){
       Write-Host "Creating Virtual Switch $($_.Name)"
       $NewSwitch = $NEWHost |New-VirtualSwitch -Name $_.Name
       $vSwitch = $_
    }
   $_ |Get-VirtualPortGroup |Foreach {
       If (($NEWHost |Get-VirtualPortGroup -Name $_.Name -ErrorAction SilentlyContinue)-eq $null){
           Write-Host "Creating Portgroup $($_.Name)"
           $NewPortGroup = $NEWHost |Get-VirtualSwitch -Name $vSwitch | New-VirtualPortGroup -Name $_.Name -VLanId $_.VLanID
        }
    }
}


