Push-Location P01:\
$Source = @(
'AT305271V01'
'AT305271V02'
'AT305271V03'
'AT305271V04'
'AT305271V05'
'AT305271V06'
)

$CollectionID = ( Get-CMCollection -Name 'AT - Test - User Profile Cleanup CB' ).CollectionId
$Failed = @()
    ForEach ( $Computer in $Source ) {
        $ResourceID = ( Get-CMDevice -CollectionName 'AT - ALL - Computers' -Name $Computer ).ResourceID
            try {
                Add-CMDeviceCollectionDirectMembershipRule -CollectionId $CollectionID -ResourceId $ResourceID -Verbose
                }
            catch {
                Write-Warning "Failed to add '$Computer' to colllection"
                $Failed += $Computer
            }
        }#Close ForEach
Pop-Location

        