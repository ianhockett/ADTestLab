#$MyInvocation.MyCommand.Name
Get-ChildItem -Path "$($PSScriptRoot)\*" -File -Include *.ps1 |
    ForEach-Object {
        if (!($_.Name -eq $MyInvocation.MyCommand.Name)) {
            . $_
        }
    }

$TestDataPath = "..\Data"
$OldTestData = "$TestDataPath\fakeuserdata.csv"
$NewTestData = "$TestDataPath\newfakeuserdata.csv"

$OUs = "PigPen-Users","PigPen-Admins","PigPen-ServiceAccounts"

if ((Test-LabAdUserList -Path $OldTestData) -eq $True) {
    Remove-LabAdUserDuplicate -Path $OldTestData -Outpath $NewTestData

    ForEach ($OU in $OUs) {
        try {
            Get-ADOrganizationalUnit -Identity "OU=$OU,DC=contoso,DC=com" >> $null
        } catch {
            New-ADOrganizationalUnit -Name $OU -ProtectedFromAccidentalDeletion $False
        }
    }

    # Create Test Users
    Import-LabAdUser -OU "PigPen-Users" -Path $NewTestData

    # Create Service Accounts
    New-ADGroup -Name "Service Accounts" -GroupScope "DomainLocal" -Description "Service Account Security Group"

    1..5 | ForEach-Object {
        $Params = @{
            Path            = "OU=PigPen-ServiceAccounts,DC=contoso,DC=com"
            samaccountname  = "Service-$($_)"
            name            = "Service-$($_)"
            description     = "A service account"
            enabled         = $true
        }
        New-ADUser @Params
        Add-ADGroupMember -Identity "Service Accounts" -Member "Service-$($_)"
    }

    # Create Admin Accounts
    1..3 | ForEach-Object {
        $Params = @{
            Path            = "OU=PigPen-Admins,DC=contoso,DC=com"
            samaccountname  = "Admin-$($_)"
            name            = "Admin-$($_)"
            description     = "A Domain Admin account"
            enabled         = $true
        }
        New-ADUser @Params
        Add-ADGroupMember -Identity "Domain Admins" -Member "Admin-$($_)"
    }
}