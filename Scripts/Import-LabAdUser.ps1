<#

.SYNOPSIS

    Imports a CSV from Fake Name Generator to create test AD User accounts.

.DESCRIPTION

    Imports a CSV from Fake Name Generator to create test AD User accounts.

    It will create OUs per country under the OU specified. Bulk

   generated accounts from fakenamegenerator.com must have as fields:

   * GivenName

   * Surname

   * StreetAddress

   * City

   * Title

   * Username

   * Password

   * Country

   * TelephoneNumber

   * Occupation

.EXAMPLE

    C:\PS> Import-LabADUser -Path .\unique.csv -OU DemoUsers

#>

function Import-LabADUser

{

    [CmdletBinding()]

    param(

        [Parameter(Mandatory=$true,

                   Position=0,

                   ValueFromPipeline=$true,

                   ValueFromPipelineByPropertyName=$true,

                   HelpMessage="Path to one or more locations.")]

        [Alias("PSPath")]

        [ValidateNotNullOrEmpty()]

        [string[]]

        $Path,

        [Parameter(Mandatory=$true,

                   position=1,

                   ValueFromPipeline=$true,

                   ValueFromPipelineByPropertyName=$true,

                   HelpMessage="Organizational Unit to save users.")]

        [String]

        [Alias('OU')]

        $OrganizationalUnit

    )

    

    begin {

        

    }

    

    process {

        Import-Module ActiveDirectory

        if (-not (Get-Module -Name 'ActiveDirectory')) {

            return

        }

        $DomDN = (Get-ADDomain).DistinguishedName

        $forest = (Get-ADDomain).Forest

        $ou = Get-ADOrganizationalUnit -Filter "name -eq '$($OrganizationalUnit)'"

        if($ou -eq $null) {

            New-ADOrganizationalUnit -Name "$($OrganizationalUnit)" -Path $DomDN

            $ou = Get-ADOrganizationalUnit -Filter "name -eq '$($OrganizationalUnit)'"

        }

        $data =

        Import-Csv -Path $Path | select  @{Name="Name";Expression={$_.Surname + ", " + $_.GivenName}},

                @{Name="SamAccountName"; Expression={$_.Username}},

                @{Name="UserPrincipalName"; Expression={$_.Username +"@" + $forest}},

                @{Name="GivenName"; Expression={$_.GivenName}},

                @{Name="Surname"; Expression={$_.Surname}},

                @{Name="DisplayName"; Expression={$_.Surname + ", " + $_.GivenName}},

                @{Name="City"; Expression={$_.City}},

                @{Name="StreetAddress"; Expression={$_.StreetAddress}},

                @{Name="State"; Expression={$_.State}},

                @{Name="Country"; Expression={$_.Country}},

                @{Name="PostalCode"; Expression={$_.ZipCode}},

                @{Name="EmailAddress"; Expression={$_.Username +"@" + $forest}},

                @{Name="AccountPassword"; Expression={ (Convertto-SecureString -Force -AsPlainText $_.password)}},

                @{Name="OfficePhone"; Expression={$_.TelephoneNumber}},

                @{Name="Title"; Expression={$_.Occupation}},

                @{Name="Enabled"; Expression={$true}},

                @{Name="PasswordNeverExpires"; Expression={$true}} | ForEach-Object -Process {

            

                    $subou = Get-ADOrganizationalUnit -Filter "name -eq ""$($_.Country)""" -SearchBase $ou.DistinguishedName        

                    if($subou -eq $null) {

                        New-ADOrganizationalUnit -Name $_.Country -Path $ou.DistinguishedName

                        $subou = Get-ADOrganizationalUnit -Filter "name -eq ""$($_.Country)""" -SearchBase $ou.DistinguishedName        

                    }

                    $_ | Select @{Name="Path"; Expression={$subou.DistinguishedName}},* | New-ADUser  

                }

    }    

    end {}

}