. "$($PSScriptRoot)\Test-LabAdUserList.ps1"
. "$($PSScriptRoot)\Remove-LabAdUserDuplicate.ps1"
. "$($PSScriptRoot)\Import-LabAdUser.ps1"


$TestDataPath = "..\Data"
$OldTestData = "$TestDataPath\fakeuserdata.csv"
$NewTestData = "$TestDataPath\newfakeuserdata.csv"

$Domain = Get-ADDomain
$OUs = "PigPen-Users","PigPen-Admins","PigPen-ServiceAccounts","PigPen-IT"
$Groups = "Service Accounts","IT Admins"

if ((Test-LabAdUserList -Path $OldTestData) -eq $True) {
    Remove-LabAdUserDuplicate -Path $OldTestData -Outpath $NewTestData
}

ForEach ($OU in $OUs) {
    try {
        Get-ADOrganizationalUnit -Identity "OU=$OU,$($Domain.DistinguishedName)" >> $null
    } catch {
        New-ADOrganizationalUnit -Name $OU -ProtectedFromAccidentalDeletion $False
    }
}

# Create Groups
foreach ($Group in $Groups) {
    try {
        Get-ADGroup -Identity $Group > $null
    } catch {
       if ($Group -eq "Service Accounts") {
            New-ADGroup -Name $Group -GroupScope "DomainLocal" -Description "$Group Security Group"
        } else {
            New-ADGroup -Name $Group -GroupScope "Global" -Description "$Group Security Group"
        }
    }
}

# Create User Accounts
Import-LabAdUser -OU "PigPen-Users" -Path $NewTestData -ErrorAction SilentlyContinue

# Create Service Accounts
1..5 | ForEach-Object {
    $Params = @{
        Path            = "OU=PigPen-ServiceAccounts,$($Domain.DistinguishedName)"
        samaccountname  = "Service-$($_)"
        name            = "Service-$($_)"
        description     = "A service account"
        enabled         = $true
        passwordnotrequired = $true
    }

    try {
        Get-AdUser -Identity $Params.samaccountname > $null
    } catch {
        New-ADUser @Params
    }

    if (!((Get-ADGroupMember -Identity "Service Accounts" |
            select -ExpandProperty samaccountname) -contains $Params.samaccountname)) {
        Add-ADGroupMember -Identity "Service Accounts" -Member (Get-ADUser -Identity $Params.samaccountname)
    }
}

# Create Domain Admin Accounts
1..5 | ForEach-Object {
    $Params = @{
        Path            = "OU=PigPen-Admins,$($Domain.DistinguishedName)"
        samaccountname  = "Admin-$($_)"
        name            = "Admin-$($_)"
        description     = "A Domain Admin account"
        enabled         = $true
        passwordnotrequired = $true
    }

    try {
        Get-AdUser -Identity $Params.samaccountname > $null
    } catch {
        New-ADUser @Params
    }

    if (!((Get-ADGroupMember -Identity "Domain Admins" |
            select -ExpandProperty samaccountname) -contains $Params.samaccountname)) {
        Add-ADGroupMember -Identity "Domain Admins" -Member (Get-ADUser -Identity $Params.samaccountname)
    }
}

# Create IT Admin Accounts
1..5 | ForEach-Object {
    $Params = @{
        Path            = "OU=PigPen-IT,$($Domain.DistinguishedName)"
        samaccountname  = "ITAdmin-$($_)"
        name            = "ITAdmin-$($_)"
        description     = "An IT Admin account"
        enabled         = $true
        passwordnotrequired = $true
    }

    try {
        Get-AdUser -Identity $Params.samaccountname > $null
    } catch {
        New-ADUser @Params
    }

    if (!((Get-ADGroupMember -Identity "IT Admins" |
            select -ExpandProperty samaccountname) -contains $Params.samaccountname)) {
        Add-ADGroupMember -Identity "IT Admins" -Member (Get-ADUser -Identity $Params.samaccountname)
    }
}

# Add IT Admins group to Domain Admins group (results in nested Domain Admin membership for IT Admins)
Add-ADGroupMember -Identity "Domain Admins" -Member (Get-ADGroup -Identity "IT Admins")