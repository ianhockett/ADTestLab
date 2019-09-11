$Domain = Get-ADDomain
$OUs = "PigPen-Users","PigPen-Admins","PigPen-ServiceAccounts","PigPen-IT"
$TestDataPath = "..\Data"
$NewTestData = "$TestDataPath\newfakeuserdata.csv"


# Remove Users
Import-Csv $NewTestData | ForEach-Object {
    Get-ADUser -Identity $_.username | Remove-ADUser -Confirm:$false
}

1..5 | ForEach-Object {
    Get-ADUser -Identity "Service-$_" | Remove-ADUser -Confirm:$false
    Get-ADUser -Identity "Admin-$_"   | Remove-ADUser -Confirm:$false
    Get-ADUser -Identity "ITAdmin-$_" | Remove-ADUser -Confirm:$false
}

# Remove Groups
"Service Accounts","IT Admins" | Remove-ADGroup -Confirm:$false

# Remove OUs
foreach ($OU in $OUs) {
    Get-ADOrganizationalUnit -Identity "OU=$OU,$($Domain.DistinguishedName)" |
        Remove-ADOrganizationalUnit -Recursive -Confirm:$false
}