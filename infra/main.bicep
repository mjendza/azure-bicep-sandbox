//basic config
param retentionInDays int = 30

param servicesPrefix string = 'SANDBOX-MJ-'
param servicesPostfix string = '-001'
param tagObject object = {
  TeamName: 'Shared'
  Dept: 'Core'
  Environment: 'SANDBOX'
  Owner: 'MJ'
}



resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: '${servicesPrefix}LogAnalytics-Workspace${servicesPostfix}'
  tags: tagObject
  location: resourceGroup().location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    retentionInDays: retentionInDays
  }
}

module demoAppBlue 'modules/demo-app-service/main.bicep' = {
  name: '${servicesPrefix}DemoApp-Blue'
  params: {
    servicesPrefix: '${servicesPrefix}DemoApp-Blue'
    appRuntimeAppConfig: 'Blue'
  }
}

module demoAppGreen 'modules/demo-app-service/main.bicep' = {
  name: '${servicesPrefix}DemoApp-Green'
  params: {
    servicesPrefix: '${servicesPrefix}DemoApp-Green'
    appRuntimeAppConfig: 'Green'
  }
}

module fd 'modules/connectivity/fd.bicep' = {
  name: '${servicesPrefix}FrontDoor${servicesPostfix}'
  dependsOn: [logAnalyticsWorkspace]
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
    tags: tagObject
    frontDoorProfileName: '${servicesPrefix}FrontDoor${servicesPostfix}'
    frontDoorSkuName: 'Standard_AzureFrontDoor'
  }
}

module demoAppFd 'modules/connectivity/fd-app-endpoint.bicep' = {
  name: '${servicesPrefix}DemoApp-FrontDoorEndpoint${servicesPostfix}'
  dependsOn: [demoAppBlue, demoAppGreen, fd]
  params: {
    defaultHostNames: [demoAppBlue.outputs.hostName, demoAppGreen.outputs.hostName]
    frontDoorConnectionPrefix: '${servicesPrefix}DemoApp-FD-'
    fdInstanceName: fd.outputs.name
  }
}


//APIM
// param apiManagementPublisherEmail string = 'test@your-org.io'
// param apiManagementPublisherName string = 'API-M Publisher'

// module apim 'modules/connectivity/api-m.bicep' = {
//   name: '${servicesPrefix}API-M${servicesPostfix}'
//   params: {
//     apiManagementName: '${servicesPrefix}API-M${servicesPostfix}'
//     logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
//     tags: tagObject
//     apiManagementPublisherEmail: apiManagementPublisherEmail
//     apiManagementPublisherName: apiManagementPublisherName
//   }
// }
