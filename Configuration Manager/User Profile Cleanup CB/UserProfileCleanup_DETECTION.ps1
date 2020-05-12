try {
    # Silence any output that will cause the script to exit early
    function Write-Host {}
    function Write-Verbose {}
    function Write-Error {}
    function Write-Debug {}
    
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

    "<--- Starting User Profile Cleanup - DETECTION --->" | Log
    
    # Declare starting count variables
    [int32]$UsersToRemove = 0

    # Remove user profiles older than specified amount of days
    $Users = Get-CimInstance -Class Win32_UserProfile
    ForEach ( $User in $Users ) {
        if ( $User.SID -like "S-1-5-21-*" ) {
            "Removal needed for profile at '$($User.LocalPath)' ($($User.SID))" | Log
            $UsersToRemove ++
        }
        else {
            "Skipping profile at '$($User.LocalPath)' ($($User.SID))" | Log
        }
    }

    # Log close of script and return compliance check
    "Need to remove '$UsersToRemove' user profile(s)" | Log
    "<--- Ending User Profile Cleanup - DETECTION --->" | Log
    if ( $UsersToRemove -ge 1 ) {
        return $True
    }
    else {
        return $False
    }

}
catch {
    throw $_
}