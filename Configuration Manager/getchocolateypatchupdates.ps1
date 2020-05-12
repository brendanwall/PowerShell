# Install choco.exe for use
if ( !( Test-Path $env:ProgramData\chocolatey\choco.exe ) ) {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    catch {
        Write-Error "Unable to install Chocolatey required runtime. Exiting..."
        throw
    }
}

# Get Chocolately applications and search for updates
$Applications = @('GoogleChrome','Firefox','jre8'<#Java#>,'flashplayeractivex','flashplayerplugin',<#Adobe Reader when we move to 2020 'adobereader',#>'zoom-client') #These are the exact chocolatey package names it will search for
$ApplicationInfo = [System.Collections.Generic.List[PSCustomObject]]::New()
ForEach ( $Application in $Applications ) {
    $Output = choco search $Application --limitoutput --exact --approved-only
    $Split = $Output.split('|')
    $ApplicationName = $Split[0]
    $ApplicationVersion = $Split[1]
    $ApplicationInfo += [PSCustomObject]@{
        ApplicationName = $Split[0]
        ApplicationVersion = $Split[1]
    }
}


