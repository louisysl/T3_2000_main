######################################################### 
# 
# Name: GPO.ps1 
# Author: Louis Löhr
# Version: 1.0 
# Date: 09/03/2022 
# Comment: PowerShell 2.0 script to copy GPO links from 
# one OU to another 
# 
######################################################### 
cls

# Import  
Import-Module GroupPolicy
Import-Module ActiveDirectory


### Set global variables 

#-------------------------------- General Functions ----------------------------------------------

try {
  $myScript = $MyInvocation.MyCommand.Path                                       						
  $Scriptpath = Split-Path $myScript -Parent -ErrorAction Stop
} catch {
  Write-Host "No dir acess! Skript wird abgebrochen. " -ForegroundColor Red
  break
}

#----------------------------------- XML Parsing -------------------------------------------------

function inputXML
{
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
  try 
  {
    [xml]$xmlFile = Get-Content -Path $Scriptpath\Parser.xml -ErrorAction Stop
  }
  catch 
  {
    $_.Exception.GetType().FullName
    Write-Host -Object 'XML-File not Found!' -ForegroundColor Red
  }
  $xmlElements = $xmlFile.Path                                       					
  if (!$xmlElements)
  {
    Write-Host -Object "XML NoValueError `nCheck if XML-Path is correct" -ForegroundColor Red
  }
  return $xmlElements
}#End Function inputXML


Function Get-NodeData{ 
  param(
  $xmlElements  
  )
  if ($xmlElements -eq $null)
  {
    $xmlElements = inputXML
  }

  $returnValue = @()
  for($a = 0;$a -le $xmlElements.ChildNodes.Count-1;$a++)
  {
    $returnValue += $xmlElements.ChildNodes.Item($a)
  }
  return $returnValue.'#text'
}#End Function Get-NodeData


Function CreateOutputFolder{
  param(
    $Folderpath
  )
  #foreach ($OutputFoldername in $OutputFolders)            
  #{
  if(!(Test-Path -Path $Folderpath ))
  {
    New-Item -ItemType directory -Path $Folderpath
    #  "New folder $OutputFoldername created..." | LogMe -display
  }
} #end Function - CreateOutputFolder

#-------------------------------- Function for SWITCH 1 and 5 ------------------------------------

function ExistingGPO
{
    param
    (
        $searcher,
        $OutputPath,
        $type
    )

    $GPOArray = Get-GPO -All | Where-Object {$_.displayname -like $searcher}
    
    $ActualProgressCount = 0

    foreach($GPO in $GPOArray){
        
        $totalProgressCount = $GPOArray.count
        $ActualProgressCount++
        

        Write-Progress -Activity "Process GPO : GPO Status" -status "$ActualProgressCount" -percentComplete ($ActualProgressCount / $totalProgressCount*100)

        
        if ($type -eq "Backup")
        {
            # Create OutputFolder
            CreateOutputFolder "$OutputPath\$type\$($GPO.DisplayName)"
            Start-Sleep -s 2
            # Backup the GPO, HTML report and saving the GPO details to text file are optional.
            Backup-GPO -Name $($GPO.DisplayName) -Path "$OutputPath\$type\$($GPO.DisplayName)"

            Get-GPOReport -Name $($GPO.DisplayName) -ReportType Html -Path "$OutputPath\$type\$($GPO.DisplayName)\$($GPO.DisplayName).html"
        }
        elseif ($type -eq "Reports")
        {
            # Create OutputFolder
            CreateOutputFolder "$OutputPath\$type"
            Start-Sleep -s 2
            Get-GPOReport -Name $($GPO.DisplayName) -ReportType Html -Path "$OutputPath\$type\$($GPO.DisplayName).html"
        }
  }
} # end Function - Existing GPO

#---------------------------------------------------------------------------------------------------

#---------------------------------Function for SWITCH 2 ---------------------------------------------


function Read-JsonFile {
    param (
        $FolderPath
    )
  
    try
      {
        $content = Get-Content -Raw -Encoding UTF8 "$FolderPath\*.json" | ConvertFrom-Json
        return $content
    
      }
      catch
      {
        #####
        #
        "Error was $_"
        $line = $_.InvocationInfo.ScriptLineNumber
        "Error was in Line $line"
      }
    }

#---------------------------------------------------------------------------------------------------




#---------------------------------Function for SWITCH 2,3 ---------------------------------------------

Function SplitTextString {

  param (
    $InputTextString
    )

  $EditedTextstrings = ""
  $EditedTextstrings = $InputTextString.Replace(",OU=Autobahn,DC=dom1,DC=c-ssi,DC=de", "")
  $EditedTextstrings = $EditedTextstrings.Replace("OU=", "")
  $EditedTextstrings = $EditedTextstrings.Replace('"', "")
  $EditedTextstrings = $EditedTextstrings.TrimStart("")

  $EditedTextstrings = $EditedTextstrings.Split(',')
  $ArrayNumber = $EditedTextstrings.count

  
  for ($i=0; $i -lt $EditedTextstrings.length; $i++)
  {
  
  $ArrayNumber = $ArrayNumber - 1 
  
  $Outputstring = $Outputstring + $EditedTextstrings[$ArrayNumber] + "-"
    
  }
  $Outputstring = $Outputstring.TrimEnd("-")
  return $Outputstring

} #end Function - SplitTextString 


Function RemoveString {

param (
        $InputString     
    )

    $EditString = $InputString
    $EditString = $EditString.trimStart('"')
    $EditString = $EditString.trimEnd('"')

    return $EditString


}#end Function - RemoveString



Function Get-GPOLinks {

    param (
        $InputOU        
    )
    $OUName = RemoveString $InputOU
     
  $linkedPolicies = (Get-GPInheritance -Target $OUName).gpolinks
        
        if($linkedPolicies.count -eq $null -or $linkedPolicies.count -eq 0)
        
        { 

        write-host "No GPO`s found"
        
        }        
        return $linkedPolicies
} #end Function - Get-GPOLinks


Function RemoveGPOLinks {
    
     param (
        $linkedPolicies,
        $InputOU
    )

    $OUName = RemoveString $InputOU
    foreach($Link in $linkedPolicies){

        Remove-GPLink -Name $Link -Target $OUName
    }
} #end Function - RemoveGPOLinks


Function linkGPO {
        param (
        $inputOU,
        $LinkedPolicies
    )

          $TargetOU = RemoveString $InputOU
          # Loop through each GPO and link it to the target 
          foreach ($link in $linkedPolicies) 
          { 
            $guid = $link.GPOId 
            $order = $link.Order 
            $enabled = $link.Enabled 
            if ($enabled) 
            { 
              $enabled = "Yes" 
            } 
            else 
            { 
              $enabled = "No" 
            } 
            # Create the link on the target 
            New-GPLink -Guid $guid -Target $TargetOU -LinkEnabled $enabled -confirm:$false 
            # Set the link order on the target 
            Set-GPLink -Guid $guid -Target $TargetOU -Order $order -confirm:$false
            }

} #end Function - linkGPO


#---------------------------------------------------------------------------------------------------

#---------------------------------Function for SWITCH 6 ---------------------------------------------

Function CompareLinkedGPO 
{
  param (
        $SourceLinkedPolicies,
        $TargetLinkedPolicies      
    )

  $CompareLinkedGPOLists = @()
  
  class CompareLinkedGPOList {
      [string]$Name
      [string]$OrderId
      [string]$Enabled
      [string]$Enforced
      [string]$guid
      [string]$IsInbothOU
  }



  ForEach ($sLinkedPolicies in $SourceLinkedPolicies)
  {
  $IsInbothOU = ""
  
            $DisplayName = $sLinkedPolicies.displayname
            $orderID = $sLinkedPolicies.Order
            $enabled = $sLinkedPolicies.Enabled
            $Enforced    = $sLinkedPolicies.Enforced
            $guid = $sLinkedPolicies.GPOId 
            
            
             
      if ($TargetLinkedPolicies.GPOID -contains $sLinkedPolicies.GPOID -and $TargetLinkedPolicies.Enabled -eq $sLinkedPolicies.Enabled) 
      {
       
      $IsInbothOU = "True"
      $order = $sLinkedPolicies.Order
      }
      else
      {
      $IsInbothOU = "False"
      $order = ""
      }

    $CompareLinkedGPOList = @([CompareLinkedGPOList]@{Name=$sLinkedPolicies.Displayname;OrderId=$order;Enabled=$sLinkedPolicies.Enabled;Enforced=$sLinkedPolicies.Enforced;IsInbothOU=$IsInbothOU})
    
    $CompareLinkedGPOLists += $CompareLinkedGPOList
  }
   $CompareLinkedGPOLists | format-table -AutoSize


 }


 #---------------------------------------------------------------------------------------------------




function Menu{
  param(
    $consoleInput
  )
  switch ($consoleInput)
  {
    '1' {
            #Backup GPO
            
            $FilterSearcher = Read-Host "Enter the Name to GPO Beispiel: Dom1-p-CTX*"
            ExistingGPO $FilterSearcher $Scriptpath "Backup"
       
        } 
        #-------------------------------

    '2' {
          foreach ($Target in $TargetsFromXML)
          {          
          
                $ReturnString = SplitTextString $Rollback
                
                $GPOArray = Read-JsonFile "$scriptpath\$ReturnString"

                $date = Get-Date -Format yyyyMMdd

                
    
                CreateOutputFolder $Scriptpath\$ReturnString

                $ReturnLinkedPolicies = ""

                $ReturnLinkedPolicies = Get-GPOLinks $Rollback

                $ReturnLinkedPolicies | ConvertTo-Json | Out-File "$Scriptpath\$ReturnString\$date-Rollback-GPOLinks.json"


                $RollbackOUName = RemoveString $Rollback
                (Get-GPInheritance -Target $RollbackOUName).GpoLinks | Remove-GPLink

                 LinkGPO $Target $GPOArray
          }
        }
     
        #-------------------------------
    '3' {
          
        
        foreach ($Target in  ($TargetsFromXML | Select -skip 0))
        {

             
            $ReturnLinkedPolicies = Get-GPOLinks $Source
            
            $ReturnLinkedPolicies = ""

            $ReturnLinkedPolicies = Get-GPOLinks $Target

            if($ReturnLinkedPolicies.count -eq $null -or $ReturnLinkedPolicies.count -eq 0) 
            { 
            #"datei einlesen"
                
                $ReturnLinkedPolicies = ""

                $ReturnLinkedPolicies = Get-GPOLinks $Source

                LinkGPO $Target $ReturnLinkedPolicies  
           
            } 

            else

            {

                $date = Get-Date -Format yyyyMMdd
        
                $ReturnString = SplitTextString $Target
    
                CreateOutputFolder $Scriptpath\$ReturnString
    
                $ReturnLinkedPolicies | ConvertTo-Json | Out-File "$Scriptpath\$ReturnString\$date-Linked-GPOLinks.json"

                $TargetOUName = RemoveString $Target
                (Get-GPInheritance -Target $TargetOUName).GpoLinks | Remove-GPLink

                $ReturnLinkedPolicies = ""

                $ReturnLinkedPolicies = Get-GPOLinks $Source

                LinkGPO $Target $ReturnLinkedPolicies

            }


          }  
        }
        #-------------------------------
    '4' {
            
        }
        #-------------------------------
    '5' {
            #Report GPO
            $FilterSearcher = Read-Host "Enter the Name to GPO Beispiel: Dom1-p-CTX*"
            ExistingGPO $FilterSearcher $Scriptpath "Reports"
       } 
       #-------------------------------
    '6'{
        foreach ($Target in  ($TargetsFromXML | Select -skip 0))
        {
           $Source
           $SourceOUName = RemoveString $Source
           $ReturnLinkedPoliciesSource = Get-GPOLinks $SourceOUName
           
           
           $TargeteOUName = RemoveString $Target 
           $ReturnLinkedPoliciesTarget = Get-GPOLinks $TargeteOUName

           CompareLinkedGPO $ReturnLinkedPoliciesSource $ReturnLinkedPoliciesTarget
        }
       }
    #'7' {RemoveUnlinkedGPOs} #eventuell Entfernen beschränken auf bestimmte GPO 
  }
}

             
##### Main

#---XML Parsed Variables
$XMLData = Get-NodeData
$Source = $XMLData.Item(0)



$Rollback = $XMLData.Item(1)

$xmlElements = inputXML
$TargetsFromXML = Get-NodeData ($xmlElements.ChildNodes) 

$consoleInput = 0
do{
  $consoleInput = Read-Host "(1) Backup GPO`n(2) Rollback GPO from JSON File`n(3) Transfer all GPO´s from OU's to other OU´s `n(4) Transfer single GPO to OU´s `n(5) Report GPO to HTML`n(6) Compare List of linked GPO´s from OU to a nother OU`n(7) Remove unlinked GPOs`n Quit (q) `n`nEnter"

  $validInput = @("1", "2", "3", "4", "5", "6", "7", "q")
  if ($validInput.Contains($consoleInput))
  {
    Menu $consoleInput
  }
  else{
    cls
    Write-Host "Enter valid number (1-7)"
    $consoleInput = Read-Host "(1) Backup GPO`n(2) Rollback GPO from JSON File`n(3) Transfer all GPO´s from OU's to other OU´s `n(4) Transfer single GPO to OU´s `n(5) Report GPO to HTML`n(6) Compare List of linked GPO´s from OU to a nother OU`n(7) Remove unlinked GPOs`n Quit (q) `n`nEnter"
    Menu $consoleInput
   }
   pause
}until ($consoleInput -eq 'q')  