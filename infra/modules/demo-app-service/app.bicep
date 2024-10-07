param rgLocation string = resourceGroup().location
param name string
param appServicePlanId string
param appSettings array = []

var defaultConfig =[
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'DEMO'
  }
  {
    name: 'ASPNETCORE_URLS'
    value: 'https://+:443'
  }
]
@description('The linux wersion')
@allowed([ 
  'DOTNETCORE|6.0' 
  'DOTNETCORE|8.0' 
  'DOTNETCORE|Latest' 
])
param linuxFxVersion string='DOTNETCORE|8.0'
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: rgLocation  
  properties:{
    serverFarmId: appServicePlanId
    siteConfig:{
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      // alwaysOn: true
      //ftpsState: 'Disabled'
      appSettings: concat(defaultConfig, appSettings)
    }
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output appServiceId string = appService.id
output appName string = appService.name
output hostName string = appService.properties.defaultHostName
