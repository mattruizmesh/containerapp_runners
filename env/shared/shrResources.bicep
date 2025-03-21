param location string
param project string
param tags {
  *: string
}

var uniqueSuffix = uniqueString(subscription().id, location, project)

module appEnvironment '../module/appenvironment.bicep' = {
  name: 'appEnvironment'
  params: {
    location: location
    project: project
    tags: tags
  }
}

module acr '../module/acr.bicep' = {
  name: 'acr'
  params: {
    location: location
    project: project
    tags: tags
    uniqueSuffix: uniqueSuffix
  }
}

module managedIdentity '../module/caidentity.bicep' = {
  name: 'managedIdentity'
  params: {
    acrName: acr.outputs.acrName
    location: location
    project: project
  }
}

output acrName string = acr.outputs.acrName
output acaManagedIDName string = managedIdentity.outputs.acaManagedIDName
output acaEnvName string = appEnvironment.outputs.acaEnvName
