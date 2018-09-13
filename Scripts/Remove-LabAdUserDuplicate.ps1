<#

.Synopsis

   Removes duplicate username entries from Fake Name Generator generated accounts.

.DESCRIPTION

   Removes duplicate username entries from Fake Name Generator generated accounts. Bulk

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

    Remove-LabADUsertDuplicate -Path .\FakeNameGenerator.com_b58aa6a5.csv -OutPath .\unique_users.csv

#>

function Remove-LabADUserDuplicate

{

    [CmdletBinding()]

    Param

    (

        [Parameter(Mandatory=$true,

                   Position=0,

                   ParameterSetName="Path",

                   ValueFromPipeline=$true,

                   ValueFromPipelineByPropertyName=$true,

                   HelpMessage="Path to CSV to remove duplicates from.")]

        [Alias("PSPath")]

        [ValidateNotNullOrEmpty()]

        [string]

        $Path,

        [Parameter(Mandatory=$true,

                   Position=1,

                   ParameterSetName="Path",

                   ValueFromPipeline=$true,

                   ValueFromPipelineByPropertyName=$true,

                   HelpMessage="Path to CSV to remove duplicates from.")]

        [ValidateNotNullOrEmpty()]

        [string]

        $OutPath

    )

    Begin {}

    Process

    {

        Write-Verbose -Message "Processing $($Path)"

        if (Test-LabADUserList -Path $Path) {

            Import-Csv -Path $Path | Group-Object Username | Foreach-Object {

                $_.group | Select-Object -Last 1} | Export-Csv -Path $OutPath -Encoding UTF8

        } else {

            Write-Error -Message "File $($Path) is not valid."

        }

        

    }

    End {}

}

