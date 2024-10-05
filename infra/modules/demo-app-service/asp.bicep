param planName string
param planLocation string = resourceGroup().location
param planSku string


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = { 
  name: planName
  location: planLocation
  sku: {
    name: planSku
  }
  kind: 'linux'
}

output appPlanId string = appServicePlan.id
