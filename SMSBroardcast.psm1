<#	
	===========================================================================
	 Created on:   	2018-12-04 4:42 PM
	 Created by:   	Nillth
	 Filename:     	SMSBroardcast.psm1
	-------------------------------------------------------------------------
	 Module Name: SMSBroardcast
	===========================================================================
#>
$Script:URI = "https://api.smsbroadcast.com.au/api-adv.php"

<#
	.SYNOPSIS
		Get-SMSBroadcastBalance gets the remaining SMS credit balance for the account used
	
	.DESCRIPTION
		Connects via the APIs and returns the number of remaining credits
		the Switch Paramater -WebResponse returns the RAW response
	
	.PARAMETER SMSUsername
		Your SMS Broadcast username. This is the same username that you would use to login to the SMS Broadcast website. 
	
	.PARAMETER SMSPassword
		Your SMS Broadcast password. This is the same password that you would use to login to the SMS Broadcast website.

	.EXAMPLE
				PS C:\> Get-SMSBroadcastBalance -SMSUsername 'YourUsername' -SMSPassword 'Password123'
#>
function Get-SMSBroadcastBalance
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		$SMSUsername,
		[Parameter(Mandatory = $true)]
		$SMSPassword,
		[switch]$WebResponse
	)
	
	$PostParasCheck = @{
		username = $SMSUsername;
		password = $SMSPassword;
		action   = 'balance'
	}
	$response = Invoke-WebRequest -Body $PostParasCheck -Uri $URI -DisableKeepAlive
	$responsecontent = $response.Content.Split(":")
	if ($responsecontent[0] -eq "OK")
	{
		Write-verbose "SMS Broadcast balance is $($responsecontent[1])"
	}
	else
	{
		Write-verbose "There was an error with this request. Reason: $($responsecontent[1])"
	}
	if ($WebResponse -eq $true)
	{
		return $response
	}
	else
	{
		return $responsecontent[1].trim()
	}
}

<#
	.SYNOPSIS
		Send-SMSBroadcast sends a SMS Message via the SMSBroadcast APIs
	
	.DESCRIPTION
		Connects to the SMSBroadcast APIs to send Messages.
	
	.PARAMETER SMSUsername
		Your SMS Broadcast username. This is the same username that you would use to login to the SMS Broadcast website. 
	
	.PARAMETER SMSPassword
		Your SMS Broadcast password. This is the same password that you would use to login to the SMS Broadcast website.

	.PARAMETER To
		The receiving mobile number(s). The numbers can be in the format:
		04xxxxxxxx (Australian format)
		614xxxxxxxx (International format without a preceding +)
		4xxxxxxxx (missing leading 0)
		We recommend using the international format, but your messages will be accepted in any of the above formats.
		To send the same message to multiple recipients, the numbers should be separated by a comma. The numbers should contain only numbers, with no spaces or other characters
	
	.PARAMETER Message
		The content of the SMS message. Must not be longer than 160 characters unless the maxsplit parameter is used. Must be URL encoded.
	
	.PARAMETER From
		The sender ID for the messages. Can be a mobile number or letters, up to 11 characters and should not contain punctuation or spaces.
		Leave blank to use SMS Broadcast's 2-way number.

	.PARAMETER ReferenceNum
		Your reference number for the message to help you track the message status. This parameter is optional and can be up to 20 characters.
	
	.PARAMETER Delay
		Number of minutes to delay the message. Use this to schedule messages for later delivery.
	
	.EXAMPLE
		PS C:\> Send-SMSBroadcast -SMSUsername "YourUserName' -SMSPassword 'Password123' -To 04xxxxxxxx -Message "Hello World"
	
#>
function Send-SMSBroadcast
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		$SMSUsername,
		[Parameter(Mandatory = $true)]
		$SMSPassword,
		[Parameter(Mandatory = $true)]
		$To,
		[Parameter(Mandatory = $true)]
		$Message,
		$From,
		$ReferenceNum,
		[int]$Delay,
		[switch]$WebResponse
	)
	
	if ($Message.Length -gt 160)
	{
		$SplitMessageCount = [int][Math]::Ceiling($Message.Length/153)
		if ($SplitMessageCount -le 5)
		{
			$MaxSplit = $SplitMessageCount
		}
		else
		{
			"Message is too Long"
			return $False
			break
		}
	}
	
	$postParams = @{
		username = $SMSUsername
		password = $SMSPassword
		to	     = $To
		message  = $Message
		maxsplit = $MaxSplit
	}
	
	if ($PSBoundParameters.ContainsKey("From"))
	{
		$postParams.from = $From
	}
	
	if ($PSBoundParameters.ContainsKey("ReferenceNum"))
	{
		$postParams.ref = $ReferenceNum
	}
	if ($PSBoundParameters.ContainsKey("Delay"))
	{
		$postParams.delay = $Delay
	}

	$paramInvokeRestMethod = @{
		Uri			     = $Uri
		Method		     = 'Post'
		WebSession	     = $WebSession
		DisableKeepAlive = $true
		Body			 = $postParams
	}
	
	$response = Invoke-RestMethod @paramInvokeRestMethod
	
	$SMSResponse = $response.Split(":")
	
	$Status = [PSCustomObject]@{
		Date = $((get-date).ToString("s"))
		To   = $SMSResponse[1].trim()
		Response = $SMSResponse[0].trim()
		SMSReference = $SMSResponse[2].trim()
		Reference = $ReferenceNum
		Message = $Message
	}
	if ($WebResponse -eq $true)
	{
		return $response
	}
	else
	{
		return $Status
	}
}