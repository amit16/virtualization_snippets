# Connects VPN and start a multi-threaded download of test builds
# It is 10 times faster than wget

function get-filenames($vmdkurl){
	$start = $vmdkurl.tostring().indexof("a href=")
	$end = $vmdkurl.tostring().indexof("</a></td><td align=")
	$vmdkurl = $vmdkurl.tostring().substring($start,55)
	$returl = $vmdkurl.tostring().split("`"")[1]
	return $returl
}

function download($downfiles){
	#download the build
	$axelcmd = "c:\Project\Scripts\axel.exe -a -n 20"
	foreach ($file in $downfiles){
		$webclient = New-Object System.Net.WebClient
		$filetodownload = "`"" + $mainurl + $file + "`""
		$axelexec = $axelcmd +" "+ $filetodownload
		Invoke-Expression -Command $axelexec
	}
}

function disconnectvpn(){
	set-location -Path 'c:\Program Files\Cisco Systems\VPN Client'
	Invoke-Expression -Command ".\vpnclient.exe disconnect"

}


$buildlocation = "C:\Project\Builds\"

Set-Location $buildlocation

# Check Latest Build.

if ((Get-ChildItem -Name "Latest" -ErrorAction SilentlyContinue) -ne ""){
	Remove-Item Latest -Confirm:$false -ErrorAction SilentlyContinue -Force -Recurse
}

$files = @()
New-Item -Name "Latest" -type Directory | Out-Null
Set-Location "Latest"

$storageDir = $pwd
$webclient = New-Object System.Net.WebClient

#$mainurl = "http://build2.build.Project.com/HTA/3.6.0Master/latest/HTA/ovf_hta/"
$mainurl = Read-Host 'Enter URL. example: http://build2.build.Project.com/HTA/3.6.0Master/latest/HTA/ovf_hta/'


$file = "$storageDir\index.html"
$wc = $webclient.DownloadFile($mainurl,$file) 

$webindex = Get-Content -Path "index.html"

$url = ""
$vmdkurls = ""
$vmdkurls = $webindex | Select-String -AllMatches -Pattern "vmdk"

foreach ($url in $vmdkurls){ 
	$files += get-filenames ($url)
}

$url = ""
$vmdkurls = ""
$vmdkurls = $webindex | Select-String -AllMatches -Pattern "pdf"
foreach ($url in $vmdkurls){
	$pdffile = ""
	$pdffile = (get-filenames ($url)) -replace "%20"," "
	$files += $pdffile
}

$url = ""
$vmdkurls = ""
$vmdkurls = $webindex | Select-String -Pattern "vsphere.ovf"
foreach ($url in $vmdkurls){
$files += get-filenames ($url)
}

$url = ""
$vmdkurls = ""
$vmdkurls = $webindex | Select-String -AllMatches -Pattern "txt"
foreach ($url in $vmdkurls){
	$files += get-filenames ($url)
}

$ovf = $files | Select-String -AllMatches -Pattern ".ovf"
$split = $ovf.tostring().split("-")
$branch = $split[2]
$split = $split[3]
$build = $split.tostring().split(".")

$buildno = $branch+"-"+$build[0]

if ((Get-ChildItem -Path .. | Select-Object name | Select-String $buildno)){
	Write-Host "$($buildno) already exists... exiting..."
	Set-Location ".."
	Remove-Item "Latest" -Confirm:$false -Recurse:$true
	disconnectvpn
	return
}


download ($files)

### md5sum
$md5sum = Invoke-Expression -Command "md5sum -c md5sums.txt"
foreach ($md in $md5sum){
	if ($m -eq "Failed"){
		write-host "Build failed, Please reinitate again"
		return
	}
}



Set-Location ..

Move-Item -Path .\Latest $buildno -Confirm:$false

# Disconnect VPN
#Set-Location -Path "c:\Program Files\Cisco Systems\VPN Client\"
#Invoke-Expression -Command "vpnclient.exe disconnect"

# Copy Build to filer.
#
# disconnectvpn

#Email Notification
#Send-MailMessage -From "build server<FROM@DOMAIN.com>" -To "TO@DOMAIN.COM", "TO@DOMAIN.COM" -Subject "Build $buildno download complete" -Body "Build $buildno download complete" -SmtpServer "SMTP SERVER"
