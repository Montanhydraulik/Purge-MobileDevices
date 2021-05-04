# Exchange: Purge MobileDevices

This PowerShell script purge old Exchange ActiveSync devices from an Exchange server.

```powershell
.\Purge-MobileDevices.ps1 -MinimumAge:90 -FixActiveDirectoryFlag:$false
```

## Parameters

The script supports the following parameters:

### MinimumAge

Sets the minimum age from the device. Default value is `60` days.

### FixActiveDirectoryFlag

Fix the `msExchMobileMailboxFlags` property from a Active Directory user. Default value is `$true`.

I a user has no ActiveSync device partnerships anymore, it will set the AD property to `0`.