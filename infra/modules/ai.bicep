param name string
param location string = resourceGroup().location
param WorkspaceResourceId string

resource appInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  kind: 'web'
  location: location
  properties:{
    Application_Type:'web'
    Request_Source:'rest'
    Flow_Type:'Bluefield'
    WorkspaceResourceId: WorkspaceResourceId
  }
}

output instrumentationKey string = appInsight.properties.InstrumentationKey
output insightsName string = appInsight.properties.Name
output insightsId string = appInsight.id
output connectionString string = appInsight.properties.ConnectionString
