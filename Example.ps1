<#	
	.NOTES
	===========================================================================
	 Created on:   	2018-12-05 12:34 AM
	 Created by:   	Nillth
	 Filename:     	Example.ps1
	===========================================================================
	.DESCRIPTION
		A detailed example on how to use the SMSBroadcast PowerShell Module.
#>
Import-Module 'SMSBroardcast'

#Reference number is optional, but will use for the example
$ReferenceNum = New-Guid

#Set your to and from details here
$From = "PWSH_Nillth"
$To = "04xxxxxxxx"
#Set the message to send here, we will include the Reference number so its dynamic
$Message = "PWSH - Test SMS $($ReferenceNum)"

#and uncomment and set a value here if you want to include a delay
#$Delay = 1

#If you want to log the response to a text file i have included the code in this example
#feel free to change the path
$Logfile = "C:\Temp\SMSBroadcastLog.csv"

#Set the Environment Variables to use for the message
#so we dont have to enter the credentials each time we will use the native function
#Import-CliXML / Export-CliXML to store the credentials.
#You will need to enter them the first time
$CredentialsPath = "C:\temp\SMSBroadcastCreds"
if ($null -eq $SMSCredentials)
{
	If (Test-Path $CredentialsPath)
	{
		$SMSCredentials = Import-Clixml $CredentialsPath
	}
	else
	{
		$SMSCredentials = Get-Credential
		$SMSCredentials = Export-Clixml $CredentialsPath
	}
}

#populate the Variable we will use to check our balance
$SMSServiceParameters = @{
	SMSUsername = $SMSCredentials.GetNetworkCredential().UserName
	SMSPassword = $SMSCredentials.GetNetworkCredential().Password
}

#populate the Variable we will use to sned our message
$paramSendSMS = @{
	SMSUsername = $SMSServiceParameters.SMSUsername
	SMSPassword = $SMSServiceParameters.SMSPassword
	To		    = $To
	From	    = $From
	Message	    = $Message
	ReferenceNum = $ReferenceNum
	Delay	    = $Delay
}

#Send the Message
$SMSResponse = Send-SMSBroadcast @paramSendSMS
#Write the Response to Screen
$SMSResponse

#Log the Response to the Logfile
$SMSResponse | Export-Csv $Logfile -UseCulture -NoTypeInformation -Append

#Check the Account Balance
Get-SMSBroadcastBalance @SMSServiceParameters

