<#

.Synopsis

   Test a CSV from FakeNameGenerator.com for required fields.

.DESCRIPTION

  Test a CSV from FakeNameGenerator.com for required fields.

.EXAMPLE

   Test-LabADUserList -Path .\FakeNameGenerator.com_b58aa6a5.csv

#>

function Test-LabADUserList

{

    [CmdletBinding()]

    [OutputType([Bool])]

    Param

    (

        [Parameter(Mandatory=$true,

                   Position=0,

                   ValueFromPipeline=$true,

                   ValueFromPipelineByPropertyName=$true,

                   HelpMessage="Path to CSV generated from fakenamegenerator.com.")]

        [Alias("PSPath")]

        [ValidateNotNullOrEmpty()]

        [string]

        $Path

    )

    Begin {}

    Process

    {

        # Test if the file exists.

        if (Test-Path -Path $Path -PathType Leaf)

        {

            Write-Verbose -Message "Testing file $($Path)"

        }

        else

        {

            Write-Error -Message "File $($Path) was not found or not a file."

            $false

            return

        }

        # Get CSV header info.

        $fileinfo = Import-Csv -Path $Path | Get-Member | Select-Object -ExpandProperty Name

        $valid = $true

        

            

        if ('City' -notin $fileinfo) {

            Write-Warning -Message 'City field is missing'

            $valid =  $false

        }

        if ('Country' -notin $fileinfo) {

            Write-Warning -Message 'Country field is missing'

            $valid =  $false

        }

        if ('GivenName' -notin $fileinfo) {

            Write-Warning -Message 'GivenName field is missing'

            $valid =  $false

        }

        if ('Occupation' -notin $fileinfo) {

            Write-Warning -Message 'Occupation field is missing'

            $valid =  $false

        }

        if ('Password' -notin $fileinfo) {

            Write-Warning -Message 'Password field is missing'

            $valid =  $false

        }

        if ('StreetAddress' -notin $fileinfo) {

            Write-Warning -Message 'StreetAddress field is missing'

            $valid =  $false

        }

        if ('Surname' -notin $fileinfo) {

            Write-Warning -Message 'Surname field is missing'

            $valid =  $false

        }

        if ('TelephoneNumber' -notin $fileinfo) {

            Write-Warning -Message 'TelephoneNumber field is missing'

            $valid =  $false

        }

        if ('Username' -notin $fileinfo) {

            Write-Warning -Message 'Username field is missing'

            $valid =  $false

        }

        $valid

    }

    End {}

}

