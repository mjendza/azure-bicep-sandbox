# azure-bicep-sandbox
Full end to end solution from Firewall (FrontDoor) to application

## How to deploy the infrastructure
1. Use VS Code with the Azure Bicep extension installed.
2. Open the `infra` folder in VS Code.
3. Right click on the `main.bicep` file and select `Deploy Bicep File`.
![screen](doc/run-bicep-vs-code.png)

## Infrastructure
- Azure Front Door (Standard tier)
- AppService (Free tier) - 2 instances Blue and Green

## DemoApp (AppService)
- Asp.Net Minimal API (C#) with a simple API (WeatherForecast)
- ENV configuration dedicated for Blue and Green deployment - to check (if FrontDoor is applying the correct routing - rule)
- env configuration per each deployment (bicep)
- DemoApp.http file to make a local test
- launchSettings.json for Blue and Green deployment
