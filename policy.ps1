# Remove "Default Azure Policy" from subscriptions in subscriptions in an Azure tenant
# Use parameter -Tenant to define the customer tenant for the subscriptions
# e.g. policy.ps1 -Tenant aaa-bbb-ccc-ddd-eee
param (
[Parameter(Mandatory=$true)][string]$Tenant
)


# connect to Partner Center tenant account
Write-Output "Connect with Azure account with sufficient RBAC access rights to subscription(s) in tenant"
Connect-AzAccount

Set-AzContext -tenant $Tenant 
$Subscriptions=Get-AzSubscription -tenant $Tenant|select-object Id,TenantId 

foreach ($Sub in $Subscriptions) {
	$Subscription=$Sub.Id
	$Tenant=$Sub.TenantId

	# Set AZ context to subscription at tenant
	Set-AzContext -Subscription $Subscription -tenant $Tenant

	# Get-AzPolicyAssignment with name 'Default Azure Policy'
	$Policy=Get-AzPolicyAssignment | Select-Object -Property Name -ExpandProperty properties | Select-Object -Property Name, PolicyDefinitionID, DisplayName | Where-Object { $_.DisplayName -eq "Default Azure Policy" }

	if ( $Policy.PolicyDefinitionID -and $Policy.PolicyDefinitionID -ne "") {
        write-output $Policy.Displayname
		write-output "Asking to remove the policy: " $Policy.Name
		# Ask the user to confirm before trying to remove the policy assignment
		# Note! Will remove only the policy assignment, not the policy definition
		Remove-AzPolicyAssignment -Name $Policy.Name -Confirm:$true
	}
}

