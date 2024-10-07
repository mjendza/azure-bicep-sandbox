param planName string
param location string = resourceGroup().location
param skuName string = 'F1'
param skuTier string = 'Free'
param kind string = 'linux'
param reserved bool = true
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = { 
  name: planName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: kind
  properties:{
    reserved: reserved
  }
}

output appPlanId string = appServicePlan.id
