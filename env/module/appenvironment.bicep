param location string
param project string
param tags {
  *: string
}


resource acaEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'cae-${project}-shr'
  location: location
  tags: tags
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

output acaEnvName string = acaEnv.name
