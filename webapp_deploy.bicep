targetScope = 'resourceGroup'

param appName string
param runtime string
param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: 'mywebappServicePlankdkollc2an64c'
}

// resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
//   name: '${appName}ServicePlan${uniqueString(resourceGroup().id)}'
//   location: location
//   properties: {
//     reserved: true   // needed for linux
//   }
//   sku: {
//     name: 'F1'
//   }
//   kind: 'linux'
// }

// Use system assigned managed identity to provide secure access to ACR
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: '${appName}${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: runtime 
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      http20Enabled: true
      appSettings: [
        {
          // For Linx containers. 
          // To point your app code to the right port, use the PORT environment variable.
          // See https://learn.microsoft.com/en-us/troubleshoot/azure/app-service/faqs-app-service-linux#how-do-i-specify-port-in-my-linux-container-
          name: 'PORT'
          value: '80'
        }
      ]
      publicNetworkAccess: 'Enabled' 
    }
    httpsOnly: false
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
  }
  identity: {
      type: 'SystemAssigned'
  }
}

