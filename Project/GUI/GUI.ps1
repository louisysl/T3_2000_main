cls
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Citrix CC Install'
$main_form.Width = 300
$main_form.Height = 300
$main_form.AutoSize = $true
$data = @()


#--------------Label----------------#
#CTXCloudCustomerID
$CustomerID_Label = New-Object System.Windows.Forms.Label
$CustomerID_Label.Text = "CTXCloudCustomerID: "
$CustomerID_Label.Location  = New-Object System.Drawing.Point(10,10)
$CustomerID_Label.AutoSize = $true

#CTXCloudClientId
$ClientId_Label = New-Object System.Windows.Forms.Label
$ClientId_Label.Text = "CTXCloudClientID: "
$ClientId_Label.Location  = New-Object System.Drawing.Point(10,40)
$ClientId_Label.AutoSize = $true

$CTXCloudClientSecret_Label = New-Object System.Windows.Forms.Label
$CTXCloudClientSecret_Label.Text = "CTXCloudClientSecret: "
$CTXCloudClientSecret_Label.Location  = New-Object System.Drawing.Point(10,70)
$CTXCloudClientSecret_Label.AutoSize = $true

#--------------TextBox----------------#
#CTXCloudCustomerID
$CustomerID_Text = New-Object System.Windows.Forms.TextBox
$CustomerID_Text.Location  = New-Object System.Drawing.Point(170,10)
$CustomerID_Text.AutoSize = $true

#CTXCloudClientId
$ClientId_Text = New-Object System.Windows.Forms.TextBox
$ClientId_Text.Location  = New-Object System.Drawing.Point(170,40)
$ClientId_Text.AutoSize = $true

$CTXCloudClientSecret_Text = New-Object System.Windows.Forms.TextBox
$CTXCloudClientSecret_Text.Location  = New-Object System.Drawing.Point(170,70)
$CTXCloudClientSecret_Text.AutoSize = $true




#--------------Button----------------#
$SaveButton = New-Object System.Windows.Forms.Button
$SaveButton.Location = New-Object System.Drawing.Point(200,235)
$SaveButton.Size = New-Object System.Drawing.Size(100,23)
$SaveButton.AutoSize = $true
$SaveButton.Text = "Save"
$SaveButton.Add_Click({$main_form.Close()})

#--------------Generating Form----------------#

$main_form.Controls.Add($CustomerID_Label)
$main_form.Controls.Add($CustomerID_Text)
$main_form.Controls.Add($ClientId_Label)
$main_form.Controls.Add($ClientId_Text)
$main_form.Controls.Add($CTXCloudClientSecret_Label)
$main_form.Controls.Add($CTXCloudClientSecret_Text)
$main_form.Controls.Add($SaveButton)

$main_form.ShowDialog()

$data 


#return $CustomerID_Text.Text

#watermark
# http://vcloud-lab.com/entTestries/powershell/powershell-wpf-gui-toolbox-control-textbox-watermark-placeholder-demo