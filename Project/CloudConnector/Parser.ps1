# ==============================================================================================
# Function: Automatic Cloud Connector deployment 
#
# Paramters: not in Use
#
# Author: Louis Löhr , Frankfurt
#         All my Functions and Script are provided "AS IS" with no warranties, and confer no rights. 
#
# Date  : 08.02.2022
#
# Comment: The Script download the Citrix Cloud Connector and install it on the lokal system by getting all parameters from
#	   from an external xml file
#
# History: created , 10.09.2020, vl
#
# ==============================================================================================

cls
Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)

#---------------------------- Install-Reader Funktionen Start ------------#

#---------------------------- Path setter --------------------------------#
try {
  $myScript = $MyInvocation.MyCommand.Path                                       						#get dir where script is launched from
  $mypath = Split-Path $myScript -Parent -ErrorAction Stop
} catch {
  Write-Host "No dir acess! Skript wird abgebrochen. " -ForegroundColor Red
  break
}

try {
  Start-Transcript $mypath\log.txt | Out-Null -ErrorAction Stop                  						#start writing log 
} catch {
  Write-Host "Writing Log in executing dir is not allowed!" -ForegroundColor Red
  break
}

##############----XML-Parsing----##############

Function LesenDerEingabeDatei{
  <#
      .SYNOPSIS
      Setup.xml gets read
      .DESCRIPTION
      Setup.xml gets read, has to be in the current folder from which the script is executed
      .INPUTS
      Inputs to this cmdlet (if any)
      .OUTPUTS
      All elements which are read from the selected node are outputted.
      .NOTES
      The selected data path has to be adjusted by the prefered data. 
  #>  
  try {
    [xml]$xmlFile = Get-Content -Path $mypath\Setup.xml -ErrorAction Stop                                                     
  } catch {
    $_.Exception.GetType().FullName
    Write-Host "XML-File not Found!" -ForegroundColor Red
  }
  $xmlElements = $xmlFile.Parameter                                       					
  if (!$xmlElements)
  {
    Write-Host "XML NoValueError `nCheck if XML-Path is correct" -ForegroundColor Red
  }
  return $xmlElements
}#End Function LesenDerEingabeDatei

Function Get-Nodes{
  <#
      .SYNOPSIS
      Specific Child Elements get read.  
      .DESCRIPTION
      All Nodes are saved into a variable and outputed.
  #>
  $xmlEingabe = LesenDerEingabeDatei                                                                			
  $returnElemente = @()
  foreach($Element in $xmlEingabe){    
    for($i=0; $i -le $Element.ChildNodes.Count-1; $i++) {
      $ElementName = $Element.ChildNodes.name[$i]
      if($Element.$ElementName -ne $null){
        $returnElemente += $ElementName
      }
      $returnElemente[$i]
    }
  }
  return $returnElemente
}#End Function Get-Nodes

Function AusgebenVonNullwerten{   
  $check = Get-Nodes                                                    							
  if($check -eq $null){
    Write-Host "Check Parameters for:" $check
    Stop-Transcript                                                                   
    break
  }
  return $true
}#End Function AusgebenVonNullwerten

Function Get-NodeData{
  $xmlElements = LesenDerEingabeDatei
  $returnValue = @()
  for($a=0;$a -le $xmlElements.ChildNodes.Count-1;$a++){
    $returnValue += $xmlElements.ChildNodes.Item($a)
  }
  return $returnValue.'#text'
}#End Function Get-NodeData

function Install{
  param(
    $PackageName,
    $PackageParameter
  )
  $InstallFileLoc = "$mypath\InstallFiles\$PackageName"
  
  Write-Host "Install"$PackageName
  $status = (Start-Process $InstallFileLoc $PackageParameter -Wait -Passthru).ExitCode
  
  if ($status -eq 0){
    Write-Host "Installation war erfolgreich!"
  }else{
    Write-Host "Installation fehlerhaft Exit code:" $status
  }
}#End Function Install

function ConfigurationFiles{
  param(
    $ConfigZip,
    $HostBaseURL
  )
  ##Imports
  $env:PSModulePath = [Environment]::GetEnvironmentVariable('PSModulePath','Machine')
  $SDKModules = 'C:\Program Files\Citrix\Receiver StoreFront\PowerShellSDK\Modules\Citrix.StoreFront'
  Import-Module "$SDKModules\Citrix.StoreFront.psd1" -verbose
  Import-Module "$SDKModules.Authentication\Citrix.StoreFront.Authentication.psd1" -verbose
  Import-Module "$SDKModules.Roaming\Citrix.StoreFront.Roaming.psd1" -verbose
  Import-Module "$SDKModules.Stores\Citrix.StoreFront.Stores.psd1" -verbose
  Import-Module "$SDKModules.WebReceiver\Citrix.StoreFront.WebReceiver.psd1" -verbose

  Import-STFConfiguration -configurationZip "$mypath\InstallFiles\$ConfigZip.zip" -HostBaseURL $HostBaseURL
}#End Function ConfigurationFiles


################
# Main section #
################

$returnEingabe = LesenDerEingabeDatei   
if ($returnEingabe -ne $null){
  $returnObjekt = Get-Nodes
  if ($returnObjekt -ne $null){
    $nullData = AusgebenVonNullwerten
    if($nullData -eq $true){
      $ObjektData = Get-NodeData
      if($ObjektData -ne $null){      
#############Checking which Parser is selected and executing the accordingly script part
        if($ObjektData.Item(0) -eq "Install"){
          Install $ObjektData.Item(3) $ObjektData.Item(4)
        }
        elseif($ObjektData.Item(0) -eq "Config"){
          ConfigurationFiles $ObjektData.Item(1) $ObjektData.Item(2)
        }
        elseif($ObjektData.Item(0) -like "*C*C*"){
          $CTXCloudCustomerID = $ObjektData.Item(5)
          $CTXCloudClientId = $ObjektData.Item(6)
          $CTXCloudClientSecret =  $ObjektData.Item(7)
          $CTXCloudResourceID = $ObjektData.Item(8)
          
          $Arguments = "/q /customername:$CTXCloudCustomerID /clientid:$CTXCloudClientid /clientsecret:$CTXCloudClientSecret /location:$CTXCloudResourceID /acceptTermsofservice:true"
          $DownloadLocCloudConnector = "https://downloads.cloud.com/" + $CTXCloudCustomerID + "/connector/cwcconnector.exe"
          $TargetLocCloudConnector = "${env:SystemRoot}" + "\Temp\cwcconnector.exe"
      
            # Download Citrix Cloud Connector
            if (!(Test-Path -Path $TargetLocCloudConnector)) {
            Write-Host "Download Citrix Cloud Connector" -ForegroundColor Yellow
            $StartTimeDownloadCloudConnector = Get-Date
		
            #Force the Invoke-RestMethod PowerShell cmdlet to use TLS 1.2
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
            Invoke-WebRequest -Uri $DownloadLocCloudConnector -OutFile $TargetLocCloudConnector -UseBasicParsing
            Write-Host "Time taken: $((Get-Date).Subtract($StartTimeDownloadCloudConnector).Seconds) second(s)"
            }
            Else
            {
            Write-Verbose "File exists. Skipping Download." -Verbose
            }

            # Install Citrix Cloud Connector
            $Arguments = "/q /customername:$CTXCloudCustomerID /clientid:$CTXCloudClientid /clientsecret:$CTXCloudClientSecret /location:$CTXCloudResourceID /acceptTermsofservice:true"
       
            Write-Host "Install Cloud Connector"
            $status = (Start-Process $TargetLocCloudConnector $Arguments -Wait -Passthru).ExitCode
            
            if ($status -eq 0){
              Write-Host "Installation war erfolgreich!"
            }else{
              Write-Host "Installation fehlerhaft Exit code:" $status
            }
        }
        <#
            #-------------------------------------------Parameter Übergabe aus XML----------------------#


            $Vendor = $ObjektData.Item(4)
            $Product = $ObjektData.Item(5)
            $PackageName = $ObjektData.Item(6)
            $InstallerType = $ObjektData.Item(7)
            #-------------------------------------------------------------------------------------------#
       
       
       
            <#
            $LogPS = "${env:SystemRoot}" + "\Temp\$Vendor $Product PS Wrapper.log"
            $LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
            $Destination = "${env:ChocoRepository}" + "\$Vendor\$Product\$packageName.$installerType"


        #>
      }
    }
  }
}
Stop-Transcript