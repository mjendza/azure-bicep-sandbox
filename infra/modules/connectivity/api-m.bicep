param apiManagementName string
param apiManagementSkuName string = 'Developer'
param apiManagementPublisherEmail string
param apiManagementPublisherName string
param logAnalyticsWorkspaceName string
param location string = resourceGroup().location
param tags object 

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource apiManagement 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apiManagementName
  location: location
  sku: {
    name: apiManagementSkuName
    capacity: 1
  }
  properties: {
    publisherEmail: apiManagementPublisherEmail
    publisherName: apiManagementPublisherName
  }
  tags: tags
}

resource apiManagementDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${apiManagementName}-diagnostics'
  scope: apiManagement
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
