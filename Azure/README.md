# Azure
This is a general page for Azure information during my Fabric learning journey.

## Links:
- https://learn.microsoft.com/

## Getting Started with Azure

## Keeping Azure Costs Down
- https://www.refactored.pro/blog/2019/10/10/how-to-keep-costs-down-while-learning-azure

## Learning Diary

| Date     | Area           | Provider  | Description                                                            | Level    | Duration | Url                                                                                                                             | Status      | Rating | Comments |
| -------- | -------------- | --------- | ---------------------------------------------------------------------- | -------- | -------- | ------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------ | -------- |
| 20241214 | Azure (AZ-900) | Microsoft | Microsoft Azure Fundamentals: Describe cloud concepts                  | Beginner | 1hr      | https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/                          | Completed   | **     |          |
| 20250127 | Azure (AZ-900) | Microsoft | Microsoft Azure Fundamentals: Describe Azure architecture and services | Beginner | 3hr 25m  |
| 20241220 | Azure          | Microsoft |                                                                        | Beginner | 1hr      | https://learn.microsoft.com/en-us/training/modules/describe-core-architectural-components-of-azure/3-get-started-azure-accounts | In Progress |        |          |

## Azure Learning Sandbox
- https://learn.microsoft.com/en-us/training/support/faq?pivots=sandbox
 
## Learning Azure
- https://www.youtube.com/watch?v=bYOgjoX_px4
  - https://learn.microsoft.com/en-us/credentials/ (click 'view poster')
  - Suggested path:
    - AZ-900: Azure Fundamentals
    - AZ-104: Administrator Associate
    - AZ-400: DevOps Engineer Expert
    - AZ-700: Network Engineer Associate

## AZ-900 Azure Fundamentals
- https://learn.microsoft.com/en-gb/credentials/certifications/azure-fundamentals/?practice-assessment-type=certification&WT.mc_id=certposter_poster-wwl
- https://www.youtube.com/watch?v=Pt9LelJ0fL0

### Learning Path: Microsoft Azure Fundamentals: Describe cloud concepts

### Learning Path: Microsoft Azure Fundamentals: Describe Azure architecture and services
- https://learn.microsoft.com/en-gb/training/paths/azure-fundamentals-describe-azure-architecture-services/
- Global Infrastructure map: https://datacenters.microsoft.com/
- Regions: area with at least 1 data centre
- Availability Zone: physically separate data centres within Azure region
  - Use availability zone for high availability - note can be more cost though
- Region Pairs: - paired with another region same geography approx 300 miles away. Reduces effects of natural disasters etc
- Sovereign Regions: Instance of Azure separate from main Azure (e.g. for defence force, China etc) 

#### Azure Management Infrastructure
- Resource: Building block of Azure. Something created, built, deployed, provisioned (e.g. VMs, databases)
- Resource Group: Method of grouping resources. A resource can only be in 1 resource group. Some resources can be moved between resource groups
  - Resource groups cannot be nested
  - e.g. create resource groups per environment (dev, uat, prod)
  - Resource groups provide a convenient way to group resources together. When you apply an action to a resource group, that action will apply to all the resources within the resource group.
- Azure Subscriptions: Unit of management, billing, scale. Need subscription to use Azure
  - Links to an Azure account (Azure account = Identity in Microsoft Entra Id)
  - Using Azure to define boundaries
    - Billing Boundary - you get separate bill/report for each subscription which you can manage separately
    - Access Control Boundary - access management policies are applied at subscription level
  - Creating additional subscriptions
    - e.g. by environment (dev, prod), department, or billing workload (e.g. project)
- Azure Management Groups: Subscriptions are organised into management groups
  - Management groups can be nested
  - 10000 management group limit per directory
  - Management group tree can support up to 6 levels of depth
  - Each management group + subscription can support only 1 parent

