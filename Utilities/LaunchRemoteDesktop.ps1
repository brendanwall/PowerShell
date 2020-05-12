function Remote {
    param(
        [String]$ComputerName
    )
    if ( $null -eq $ComputerName ) {
        throw 'No computer specified'
    }
    else {
        Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/f /admin /v:$ComputerName"
    }
}
