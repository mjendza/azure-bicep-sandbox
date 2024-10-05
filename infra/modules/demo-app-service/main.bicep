param servicesPrefix string 
param aspName string = '${servicesPrefix}-AppServicePlan'
param rgLocation string = resourceGroup().location
param portalName string = '${servicesPrefix}-App'
param appSettings array = []
param appRuntimeAppConfig string
var defaultConfig =[  
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
    planLocation: rgLocation
    planSku: 'F1'
  }
}
module app 'app.bicep' = {
  name: '${portalName}-Module'
  params: {
    name: portalName
    rgLocation: rgLocation
    appServicePlanId: aspModule.outputs.appPlanId
    appSettings: concat(defaultConfig, appSettings)
  }
  dependsOn: [ aspModule ]
}
output appServiceId string = app.outputs.appServiceId
output hostName string = app.outputs.hostName
