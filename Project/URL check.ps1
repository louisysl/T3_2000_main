cls
# request
$url = 'http://google.com/'

$HTTP_Request = [System.Net.WebRequest]::Create($url)

#response from the site
$HTTP_Response = $HTTP_Request.GetResponse()

#HTTP code as an integer
$HTTP_Status = [int]$HTTP_Response.StatusCode

$TimeStart = Get-Date
$TimeEnd = $timeStart.addseconds(5)


  Do { 
    $TimeNow = Get-Date
    if ($TimeNow -ge $TimeEnd) {
    if ($HTTP_Response -eq $null) {
      Write-host "The Site may be down, please check!(5 sec Timeout)"
    }
    else {
    $HTTP_Response.Close()}
    }
  }
 Until ($TimeNow -ge $TimeEnd)
 

If ($HTTP_Status -eq 200) {
  Write-Host "Site is OK!"
  $HTTP_Response.Close()
}

Do { 
    $TimeNow = Get-Date
    if ($TimeNow -ge $TimeEnd) {
    if ($HTTP_Response -eq $null) {
      Write-host "The Site may be down, please check!(5 sec Timeout)"
    }
    else {
    $HTTP_Response.Close()}
    }
    }
Until ($TimeNow -ge $TimeEnd)


If ($HTTP_Response -eq $null) { } 
Else { $HTTP_Response.Close() }