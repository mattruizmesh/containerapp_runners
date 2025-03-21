param location string
param project string

param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource acaUserIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${project}'
  location: location
}

var acrPullId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
resource acaAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acaUserIdentity.id, acr.id, acrPullId)
  scope: acr
  properties: {
    principalId: acaUserIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullId)
    principalType: 'ServicePrincipal'
  }
}

output acaManagedIDName string = acaUserIdentity.name
