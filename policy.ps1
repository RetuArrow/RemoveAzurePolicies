# Remove "Default Azure Policy" from subscriptions in subscriptions in an Azure tenant
$Tenant="azure-tenant-id-here"

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

	write-output $Policy.Name
	write-output $Policy.Displayname

	if ( $Policy.PolicyDefinitionID -ne "") {
		write-output "Would remove " +  $Policy.Name
		# Remove the comment from the following statement to actually try and remove the policy assignment
		#removeme  Remove-AzPolicyAssignment -Name $Policy.Name -Confirm:$false
	}
}

