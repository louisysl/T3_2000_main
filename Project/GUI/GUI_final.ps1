cls
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Citrix CC Install'
$main_form.Width = 300
$main_form.Height = 300
$main_form.AutoSize = $true


#--------------Label----------------#
$data = @('CTXCloudCustomerID','CTX','CTX123','','')
for($i=0; $i -le $data.Length; $i++){
    $current = $data[$i] 
    $value = New-Object System.Windows.Forms.Label
    $value.Text = $current
    $y_Label = 10
    $value.Location = New-Object System.Drawing.Point(10,$y_Label)
    $value.AutoSize = $true
    $y_Label+30 | out-null
    $main_form.Controls.Add($value)
    $value = 0 | out-null
}



#--------------TextBox----------------#
#CTXCloudCustomerID
$CustomerID_Text = New-Object System.Windows.Forms.TextBox
$CustomerID_Text.Location  = New-Object System.Drawing.Point(170,10)
$CustomerID_Text.AutoSize = $true

#CTXCloudClientId
$ClientId_Text = New-Object System.Windows.Forms.TextBox
$ClientId_Text.Location  = New-Object System.Drawing.Point(170,40)
$ClientId_Text.AutoSize = $true





#--------------Button----------------#
$SaveButton = New-Object System.Windows.Forms.Button
$SaveButton.Location = New-Object System.Drawing.Point(200,235)
$SaveButton.Size = New-Object System.Drawing.Size(100,23)
$SaveButton.AutoSize = $true
$SaveButton.Text = "Save"
$SaveButton.Add_Click({$main_form.Close()})

#--------------Generating Form----------------#


$main_form.Controls.Add($CustomerID_Text)

$main_form.Controls.Add($ClientId_Text)
$main_form.Controls.Add($SaveButton)

$main_form.ShowDialog()

return $CustomerID_Text.Text


#watermark
# http://vcloud-lab.com/entries/powershell/powershell-wpf-gui-toolbox-control-textbox-watermark-placeholder-demo