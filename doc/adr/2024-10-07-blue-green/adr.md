# Blue-Green Deployment

### Submitters
List ADR submitters.
- MJendza


## Change Log
List the changes to the document, incl. state, date, and PR URL.
State is one of: pending, approved, amended, deprecated.
Date is an ISO 8601 (YYYY-MM-DD) string.
PR is the pull request that submitted the change, including information such as the diff, contributors, and reviewers.
Format:
- \[Status of ADR e.g. approved, amended, etc.\]\(URL of pull request\) YYYY-MM-DD


## Referenced Use Case(s)

## Context
Expected behavior:
- Improve deployment process - reduce downtime and risk.
- Improve the ability to rollback changes.

## Proposed Design
FrontDoor RuleSet decision to route traffic to Blue or Green deployment origin.

## Considerations

### Expensive - Possible reductions:
#### Slot deployment (Azure App Service)
##### Pros
  - Easy to implement
  - No additional costs
##### Cons
  - Not fully isolated - same .Net Core version, KeyVault, etc.

## Decision
Make the decision on the FrontDoor level.

## Other Related ADRs
Empty

## References
- https://newsletter.fractionalarchitect.io/p/30-worth-to-know-common-deployment

