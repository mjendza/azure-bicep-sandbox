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

// SQL Server parameters
param sqlServerName string = '${servicesPrefix}sqlserver${servicesPostfix}'
param sqlDatabaseName string = '${servicesPrefix}sqldb${servicesPostfix}'



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
module appInsightModule 'modules/ai.bicep' = {
  name: '${servicesPrefix}AppInsights-Module'
  params: {
    name: '${servicesPrefix}AppInsights-Workspace${servicesPostfix}'
    location: resourceGroup().location
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  dependsOn: [ logAnalyticsWorkspace ]
}

// SQL Server and Database
resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: resourceGroup().location
  tags: tagObject
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Application'
      login: 'SqlServerManagedIdentity'
      sid: sqlServer.identity.principalId
      tenantId: subscription().tenantId
    }
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: resourceGroup().location
  tags: tagObject
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

// Grant roles to the SQL database
resource sqlRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, sqlDatabase.id, 'SqlDbContributor')
  scope: sqlDatabase
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor role
    principalId: sqlServer.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Enable Azure AD authentication for SQL Server
resource sqlServerAzureADOnlyAuth 'Microsoft.Sql/servers/azureADOnlyAuthentications@2021-11-01-preview' = {
  parent: sqlServer
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
}

module demoAppBlue 'modules/demo-app-service/main.bicep' = {
  name: '${servicesPrefix}DemoApp-Blue'
  params: {
    servicesPrefix: '${servicesPrefix}DemoApp-Blue'
    appRuntimeAppConfig: 'Blue'
    appInsightsKeyConnectionString: appInsightModule.outputs.connectionString
    sqlConnectionString: 'Server=${sqlServer.properties.fullyQualifiedDomainName};Database=${sqlDatabaseName};Authentication=Active Directory Default;'
  }
}

module demoAppGreen 'modules/demo-app-service/main.bicep' = {
  name: '${servicesPrefix}DemoApp-Green'
  params: {
    servicesPrefix: '${servicesPrefix}DemoApp-Green'
    appRuntimeAppConfig: 'Green'
    appInsightsKeyConnectionString: appInsightModule.outputs.connectionString
    sqlConnectionString: 'Server=${sqlServer.properties.fullyQualifiedDomainName};Database=${sqlDatabaseName};Authentication=Active Directory Default;'
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
