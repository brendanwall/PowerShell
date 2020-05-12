try {
    # Silence any output that will cause the script to exit early
    function Write-Host {}
    function Write-Verbose {}
    function Write-Error {}
    function Write-Debug {}
    
    # Load helper function
    Function Get-LoggedInUser {
    # Taken from https://community.spiceworks.com/scripts/show/4408-get-logged-in-users-remote-computers-or-local
       $stringOutput = quser
          ForEach ($line in $stringOutput){
             If ($line -match "logon time") 
             {Continue}

             [PSCustomObject]@{
              Username        = $line.SubString(1, 20).Trim()
              SessionName     = $line.SubString(23, 17).Trim()
              ID             = $line.SubString(42, 2).Trim()
              State           = $line.SubString(46, 6).Trim()
              Idle           = $line.SubString(54, 9).Trim().Replace('+', '.')
              LogonTime      = [datetime]$line.SubString(65)
              }
          
        } 
    } 

    # Logfile creation and cleanup
    $LogFile = "$env:windir\TEMP\UserProfileCleaupCI.LOG"
    if (Test-Path -Path $LogFile) {
        $SizeMb = (Get-Item -Path $LogFile).Length/1MB
        if ($SizeMb -gt 10) {
            $NewName = $LogFile.Replace('.LOG','.LO_')
            Remove-Item -Path $NewName -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            Rename-Item -Path $LogFile -NewName $NewName -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }
    filter Log { "$([DateTime]::Now.ToString('s')) $_" | Add-Content -Path $LogFile } # Pipe things to log to add them to the log file. Example: "String" | Log

    "<--- Starting User Registry Key Cleanup - REMEDIATION --->" | Log
    
    # Declare starting count variables
    $RegKeysRemoved = 0
    $UsersLoggedOff = 0

    # Logoff any inactive users on device
    $InactiveUsers = Get-LoggedInUser | Where-Object { $_.State -match 'Disc' } 
    ForEach ( $User in $InactiveUsers ) {
        "Logging off '$($User.username)' due to inactivity" | Log
        Start-Process logoff.exe -ArgumentList "$($User.ID)"
        $UsersLoggedOff ++
    }

    # Remove registry keys with '.bak' to prevent temp profiles
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    $RegistryKeys = Get-ChildItem $RegistryPath
    ForEach ( $Key in $RegistryKeys ) {
        if ( $Key.Name -like "*.bak") {
            "Removing registry key at '$($Key.Name)'" | Log
            Remove-Item $Key.PSPath -Force -Recurse
            $RegKeysRemoved ++
        }
    }

    # Log close of script and return compliance check    
    "Logged off '$UsersLoggedOff' user(s)" | Log
    "Removed '$RegKeysRemoved' registry key(s)" | Log
    "<--- Ending User Registry Key Cleanup - REMEDIATION --->" | Log


}
catch {
    throw $_
}