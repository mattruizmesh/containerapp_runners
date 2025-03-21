targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Name of the project')
param project string

param acrName string
param acaEnvName string
param acaMsiName string
param imageTag string
param ghpat string
// param repoName string
// param repoOwner string

module acj '../module/cajob.bicep' = {
  name: 'acj'
  params: {
    location: location
    project: project
    ghpat: ghpat
    // repoName: repoName
    // repoOwner: repoOwner
    acrName: acrName
    acaEnvironmentName: acaEnvName
    acaMsiName: acaMsiName
    image: imageTag
    tags: {
      environment: 'dv'
      project: project
      owner: 'Matt Ruiz'
    }
  }
}
