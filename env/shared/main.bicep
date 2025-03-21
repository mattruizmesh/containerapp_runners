targetScope = 'subscription'

@description('Name of the resource group')
param rgName string

@description('Location of the resource group')
param location string

@description('Name of the project')
param project string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module shrResources './shrResources.bicep' = {
  scope: rg
  name: 'shrResources'
  params: {
    location: location
    project: project
    tags: {
      'environment': 'shr'
      'project': project
      'owner': 'Matt Ruiz'
    }
  }
}

output acrName string = shrResources.outputs.acrName
output acaManagedIDName string = shrResources.outputs.acaManagedIDName
output acaEnvName string = shrResources.outputs.acaEnvName
