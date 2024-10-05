param servicesPrefix string 
param aspName string = '${servicesPrefix}-AppServicePlan'
param rgLocation string = resourceGroup().location
param portalName string = '${servicesPrefix}-App'


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
    appSettings:[
      
    ]
  }
  dependsOn: [ aspModule ]
}
output appServiceId string = app.outputs.appServiceId
output hostName string = app.outputs.hostName
