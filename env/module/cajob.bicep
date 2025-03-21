param location string
param project string
param ghpat string
param repoOwner string
param repoName string
param tags {
  *: string
}

param acrName string
param acaEnvironmentName string
param acaMsiName string
@allowed([ '0.25', '0.5', '0.75', '1.0', '1.25', '1.5', '1.75', '2.0' ])
param containerCpu string = '0.25'
@allowed([ '0.5Gi', '1.0Gi', '1.5Gi', '2.0Gi', '2.5Gi', '3.0Gi', '3.5Gi', '4.0Gi' ])
param containerMemory string = '0.5Gi'
param image string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource acaEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: acaEnvironmentName
}

resource acaMsi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: acaMsiName
}

resource acaJob 'Microsoft.App/jobs@2023-05-01' = {
  name: 'caj-${project}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${acaMsi.id}': {}
    }
  }
  properties: {
    environmentId: acaEnv.id
    configuration: {
      registries: [
        {
          server: acr.properties.loginServer
          identity: acaMsi.id
        }
      ]
      secrets: [
        {
          name: 'personal-access-token'
          value: ghpat
        }
      ]
      replicaTimeout: 1800
      triggerType: 'Event'
      eventTriggerConfig: {
        scale: {
          rules: [
            {
              name: 'github-runner-scaling-rule'
              type: 'github-runner'
              auth: [
                {
                  triggerParameter: 'personalAccessToken'
                  secretRef: 'personal-access-token'
                }
              ]
              metadata: {
                githubAPIURL: 'https://api.github.com'
                owner: repoOwner
                repos: repoName
                targetWorkflowQueueLength: 1
              }
            }
          ]
        }
      }
    }
    template: {
      containers: [
        {
          name: 'github-runner'
          image: '${acr.properties.loginServer}/${project}/${image}'
          resources: {
            cpu: json(containerCpu)
            memory: containerMemory
          }
          env: [
            {
              name: 'GITHUB_PAT'
              secretRef: 'personal-access-token'
            }
            {
              name: 'RUNNER_SCOPE'
              value: 'repo'
            }
            {
              name: 'GH_URL'
              value: 'https://github.com/${repoOwner}}/${repoName}'
            }
            {
              name: 'REGISTRATION_TOKEN_API_URL'
              value: 'https://api.github.com/repos/${repoOwner}/${repoName}/actions/runners/registration-token'
            }
            {
              // Remove this once https://github.com/microsoft/azure-container-apps/issues/502 is fixed
              name: 'APPSETTING_WEBSITE_SITE_NAME'
              value: 'az-cli-workaround'
            }
            {
              name: 'MSI_CLIENT_ID'
              value: acaMsi.properties.clientId
            }
            {
              name: 'EPHEMERAL'
              value: '1'
            }
            {
              name: 'RUNNER_NAME_PREFIX'
              value: project
            }
          ]
        }
      ]
    }
  }
}
