function Add-ESCMDeviceCollectionDirectMembers {
    [CmdletBinding(SupportsShouldProcess=$true)]
        Param (
            # Parameter CollectionName
            [Parameter(Mandatory=$true,
                       Position=0,
                       HelpMessage="Name of the collection")]
            [ValidateNotNull()]
            [System.String] $CollectionName,

            # Parameter Path
            [Parameter(Mandatory=$true,
                       Position=1,
                       HelpMessage="Path to list of computers to add"
                       )]
            [System.String] $Path
            )

        Begin {

            # Load a helper function to test
            function TestCMComputer ( [String]$Name ) {
                $CMDevice = Get-CMDevice -Name $Name -CollectionName 'AT Endpoint Systems Master Device Collection' -Fast
                if ( $null -ne $CMDevice ) {
                    return $true
                }
                else {
                    return $false
                }
            }

            # Test if parameters for Path and ComputerName
            Write-Verbose "Validating if values were specified for ComputerName or Path parameters"
            if ( $null -eq $Path ) {
                throw "Missing parameters, no computer(s) specified."
            } 

            # Test if parameter Path to computer list exists, and if it does get the computers and add them to $Computers
            if ( $null -ne $Path ) {
                Write-Verbose "Testing Path to computer listing at $Path"
                $PathTest = Test-Path -Path $Path
            } 
            if ( $PathTest -eq $True ) {
                Write-Verbose "Path to computer listing exists, getting content from $Path"
                $Computers = Get-Content -LiteralPath $Path
            } 

            # Validate that all computers in $Computers have a CM device, if they do not, ignore them and return to console later
            $ComputersValid   = New-Object -TypeName System.Collections.Generic.List[System.Object]
            $ComputersInvalid = New-Object -TypeName System.Collections.Generic.List[System.Object]
            ForEach ( $Computer in $Computers ) {
                if ( TestCMComputer $Computer ) {
                    $ComputersValid.Add( $Computer )
                }
                else {
                    $ComputersInvalid.Add( $Computer )
                }
            }
        }

        Process {
            # Add validated computers to the CMCollection as direct members
            ForEach ( $Computer in $ComputersValid ) {
                Add-CMDeviceCollectionDirectMembershipRule -CollectionName $CollectionName -ResourceId ( Get-CMDevice -Name $Computer -CollectionName 'AT Endpoint Systems Master Device Collection' ).ResourceId
            }
        }
        End {}
}