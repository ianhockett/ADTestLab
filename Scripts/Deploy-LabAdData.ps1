#$MyInvocation.MyCommand.Name
Get-ChildItem -Path "$($PSScriptRoot)\*" -File -Include *.ps1 |
    ForEach-Object {
        if (!($_.Name -eq $MyInvocation.MyCommand.Name)) {
            . $_
        }
    }

$TestDataPath = "..\Data\fakeuserdata.csv"
try {
    if ((Test-LabAdUserList -Path $TestDataPath) -eq $True) {
        Write-Host "All Good"
        Remove-LabAdUserDuplicate -Path $TestDataPath
        New-ADOrganizationalUnit -Name "PigPen-Users"
        Import-LabAdUser -OrganizationlUnit "PigPen-Users"
    } else {
        throw
    }
} catch {
    break
}