[CmdletBinding()]
Param(
	[Parameter(Mandatory=$false)]
	[ValidateRange(1,[Int16]::MaxValue)]
	[Int16]
	$MinimumAge = 60,
	
	[Parameter(Mandatory=$false)]
	[Boolean]
	$FixActiveDirectoryFlag = $true
)

$mailboxesWithMobileDevices = @(Get-CASMailbox -Resultsize Unlimited | Where {$_.HasActiveSyncDevicePartnership})
ForEach ($mailbox in $mailboxesWithMobileDevices) {
	$devices = Get-MobileDeviceStatistics -Mailbox:$mailbox.Identity
	If ($devices.Count -gt 0) {
		#--------------------------------------------------------------------------------
		# Purge Mobile Devices...
		#--------------------------------------------------------------------------------
		$staleDevices = $devices | Where { $_.LastSuccessSync -lt ((Get-Date).AddDays(-$MinimumAge)) }
		ForEach ($device in $staleDevices) {
			$deviceName = $device.DeviceFriendlyName
			If ([String]::IsNullOrEmpty($deviceName)) {
				$deviceName = $device.DeviceModel
			}

			Write "$($mailbox.Name): Remove ""$($deviceName)"" ($($device.DeviceType)) with last success sync on $($device.LastSuccessSync)"
			Remove-MobileDevice -Id "$($device.Guid)" -Confirm:$false
		}
	}
	else {
		If ($FixActiveDirectoryFlag) {
			#--------------------------------------------------------------------------------
			# Fix Active Directory Flag (msExchMobileMailboxFlags)...
			#--------------------------------------------------------------------------------
			$adObject = Get-ADObject -Identity $mailbox.DistinguishedName -Properties msExchMobileMailboxFlags
			$adObject.msExchMobileMailboxFlags = "0"

			Write "$($mailbox.Name): Fix Active Directory Flag (msExchMobileMailboxFlags)"
			Set-ADObject -Instance $adObject
		}
	}
}