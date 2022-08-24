cls

try {
  $myScript = $MyInvocation.MyCommand.Path                                       						
  $Scriptpath = Split-Path $myScript -Parent -ErrorAction Stop
} catch {
  Write-Host "No dir acess! Skript wird abgebrochen. " -ForegroundColor Red
  break
}

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




$XMLData = Get-NodeData
$Source = $XMLData.Item(0)
$Rollback = $XMLData.Item(1)

$xmlElements = inputXML
$TargetsFromXML = Get-NodeData ($xmlElements.ChildNodes)


foreach ($Target in  ($TargetsFromXML | Select -skip 0))
{
  $Target 
}
