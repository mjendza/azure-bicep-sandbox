param servicesPrefix string
param aspName string = '${servicesPrefix}-AppServicePlan'
param rgLocation string = resourceGroup().location
param portalName string = '${servicesPrefix}-App'
param appSettings array = []
param appRuntimeAppConfig string
param appInsightsKeyConnectionString string
param sqlConnectionString string
param sqlServerName string
param sqlDatabaseName string

var defaultConfig =[
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsightsKeyConnectionString
  }
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: appRuntimeAppConfig
  }
  {
    name: 'ASPNETCORE_URLS'
    value: 'https://+:443'
  }
]

module aspModule 'asp.bicep' = {
  name: '${aspName}-Module'
  params: {
    planName: aspName
    location: rgLocation
    skuName : 'F1'
    skuTier : 'Free'
    kind : 'linux'
  }
}
module app 'app.bicep' = {
  name: '${portalName}-Module'
  params: {
    name: portalName
    rgLocation: rgLocation
    appServicePlanId: aspModule.outputs.appPlanId
    appSettings: concat(defaultConfig, appSettings, [
      {
        name: 'SQL_CONNECTION_STRING'
        value: sqlConnectionString
      }
    ])
  }
  dependsOn: [ aspModule ]
}

resource sqlRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(app.outputs.appServiceId, 'db-reader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'db-reader')
    principalId: app.identity.principalId
    scope: resourceId('Microsoft.Sql/servers/databases', sqlServerName, sqlDatabaseName)
  }
  dependsOn: [ app ]
}

output appServiceId string = app.outputs.appServiceId
output hostName string = app.outputs.hostName
