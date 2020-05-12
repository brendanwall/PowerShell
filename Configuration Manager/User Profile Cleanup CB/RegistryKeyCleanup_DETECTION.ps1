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

    "<--- Starting User Registry Key Cleanup - DETECTION --->" | Log
    
    # Declare starting count variables
    $RegKeysToRemove = 0

    # Remove registry keys with '.bak' to prevent temp profiles
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    $RegistryKeys = Get-ChildItem $RegistryPath
    ForEach ( $Key in $RegistryKeys ) {
        if ( $Key.Name -like "*.bak") {
            "Found registry key at '$($Key.Name)' for removal" | Log
            $RegKeysToRemove ++
        }
    }

    # Log close of script and return compliance check
    "Need to remove '$RegKeysToRemove' registry key(s)" | Log
    "<--- Ending User Registry Cleanup - DETECTION --->" | Log
    if ( $RegKeysRemoved -ge 1 ) {
        return $True
    }
    else {
        return $False
    }

}
catch {
    throw $_
}