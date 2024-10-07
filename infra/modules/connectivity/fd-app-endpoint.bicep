param fdInstanceName string

param frontDoorConnectionPrefix string

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

param defaultHostNames array

resource profile 'Microsoft.Cdn/profiles@2021-06-01' existing= {
  name: fdInstanceName
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroups 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = [for (hostname, index) in defaultHostNames: {
  name: '${frontDoorConnectionPrefix}OriginGroup${index}'
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
  }
}]

resource origins 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for (hostname, index) in defaultHostNames: {
  name: '${frontDoorConnectionPrefix}Origin${index}'
  dependsOn: [originGroups]
  parent: originGroups[index]
  properties: {
    hostName: hostname
    originHostHeader: hostname
    httpPort: 80
    httpsPort: 443
    enabledState: 'Enabled'
    weight: 1000
    priority: 1
  }
}]

resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2021-06-01' = {
  name: 'BlueGreenRuleSet'
  parent: profile
}

resource frontDoorRuleGreen 'Microsoft.Cdn/profiles/ruleSets/rules@2024-05-01-preview' = {
  name: 'RedirectToGreen'
  parent: ruleSet
  properties: {
    order: 0
    conditions: [
        {
            name: 'RequestHeader'
            parameters: {
                typeName: 'DeliveryRuleRequestHeaderConditionParameters'
                operator: 'Equal'
                selector: 'X-Target-Origin'
                negateCondition: false
                matchValues: ['green']
                transforms: ['Lowercase']
            }
        }
    ]
    actions: [
      {
        name: 'RouteConfigurationOverride'
        parameters: {
          originGroupOverride: {
            originGroup: {
              id: originGroups[1].id
            }
            forwardingProtocol: 'MatchRequest'
          }
          cacheConfiguration: null
          typeName: 'DeliveryRuleRouteConfigurationOverrideActionParameters'
        }
      }
    ]
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: '${frontDoorConnectionPrefix}Route0'
  parent: endpoint
  properties: {
    originGroup: {
      id: originGroups[0].id
    }
    ruleSets: [
      {
        id: ruleSet.id
      }
    ]
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
