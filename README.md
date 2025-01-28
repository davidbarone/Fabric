# Fabric
Examples, tutorials and reference material relating to the Microsoft Fabric environment.

The following experiences are detailed in sub-folders:
- Data Factory
- Data Engineering
- Data Warehouse
- Data Science
- Real-Time Intelligence
- Power BI

The following fabric-wide technologies are also detailed in sub-folders:
- Copilot
- OneLake
- Purview

Other Azure Features:
- DevOps
  

## Terms
- https://learn.microsoft.com/en-us/fabric/get-started/fabric-terminology

## Fabric Concepts + Licences
- https://learn.microsoft.com/en-us/fabric/enterprise/licenses

## Getting Started
- https://learn.microsoft.com/en-us/fabric/get-started/
- To start Fabric without work email: https://www.youtube.com/watch?v=RHV7jZqc_tE
  - Create free Azure Trial

- To use Power BI Service, require AAD account (organisational account). Person email (e.g. gmail) not allowed
- 2 ways to get AAD organisational account:
  - Microsoft 365 Business subscription
    - https://www.microsoft.com/en-au/microsoft-365/business/compare-all-microsoft-365-business-products
    - https://answers.microsoft.com/en-us/msoffice/forum/all/how-to-obtain-free-trial-of-microsoft-fabric/dc5f8473-553f-45b3-92f2-cda8d8d6410c
    - https://learn.microsoft.com/en-gb/microsoft-365/business-premium/m365-business-premium-setup?view=o365-worldwide&tabs=GetOwn%2CGuided
    - Sign up for Power BI Service using Microsoft 365 trial: https://learn.microsoft.com/en-us/power-bi/enterprise/service-admin-signing-up-for-power-bi-with-a-new-office-365-trial
  - Creating Azure Tenant
    - https://www.youtube.com/watch?v=RHV7jZqc_tE
    - Guy in a cube: https://www.youtube.com/watch?v=uZyy_qqRPiU

- Switching from Microsoft 365 Personal plan to Business Plan
  - https://support.microsoft.com/en-au/office/switch-to-a-microsoft-365-for-business-subscription-9322ffb8-a35d-4407-8ebe-ed6ea0859b9f

- What you need to access Power BI Service:
  - Power BI Licence (e.g. Power BI Pro, Power BI Premium). Can pay for one directly, or indirectly (e.g. via Microsoft 365 E5 subscription)
  - Pro/PPU licence required for Fabric capacities less than F64
  - Do not need Power BI Pro / PPU licence to access MyWorkspace (https://learn.microsoft.com/en-us/fabric/enterprise/licenses)
  - Subscribe to Microsoft Fabric, with a subscription (min F2 capacity)

## Starting a Fabric Trial
- https://learn.microsoft.com/en-us/fabric/get-started/fabric-trial

## Purchasing Fabric
- https://learn.microsoft.com/en-us/fabric/enterprise/buy-subscription

## Azure Portal
- https://portal.azure.com/

## Microsoft Learning
- https://learn.microsoft.com/en-us/training/

## External Training
- https://www.datacamp.com/

## Learning Diary

| Date     | Area          | Provider                             | Description                                                      | Level        | Duration  | Url                                                                                               | Status            | Rating | Comments                                                                |
| -------- | ------------- | ------------------------------------ | ---------------------------------------------------------------- | ------------ | --------- | ------------------------------------------------------------------------------------------------- | ----------------- | ------ | ----------------------------------------------------------------------- |
| 20241220 | Power BI      | DataCamp                             | Introduction to Power BI                                         | Beginner     | 4hr       | https://app.datacamp.com/learn/courses/introduction-to-power-bi                                   | Completed         | ***    |                                                                         |
| 20241221 | DAX           | DataCamp                             | Introduction to DAX in Power BI                                  | Beginner     | 3hr       | https://campus.datacamp.com/courses/introduction-to-dax-in-power-bi/getting-started-with-dax?ex=1 | Completed         | ****   |                                                                         |
| 20241222 | DAX           | Alberto Ferrari                      | DAX 101                                                          | Beginner     | 2hr       | https://www.youtube.com/watch?v=klQAZLr5vxA                                                       | Completed         | *****  | Good explanation of DAX basics                                          |
| 20241223 | Power BI      | DataCamp                             | Data Visualisation in Power BI                                   | Beginner     | 3hr       | https://app.datacamp.com/learn/courses/data-visualization-in-power-bi                             | Completed         | ***    |                                                                         |
| 20241225 | DAX           | Alberto Ferrari                      | Advanced DAX                                                     | Advanced     | 2hr       | https://www.youtube.com/watch?v=6ncHnWMEdic                                                       | Completed         | *****  | Good explanation of evaluation context                                  |
| 20241227 | Power BI      | DataCamp                             | Data Modelling in Power BI                                       | Beginner     | 3hr       | https://app.datacamp.com/learn/courses/data-modeling-in-power-bi                                  | Completed         | ***    |                                                                         |
| 20241228 | DAX           | DataCamp                             | DAX Functions in Power BI                                        | Beginner     | 3hr       | https://app.datacamp.com/learn/courses/dax-functions-in-power-bi                                  | Completed         | **     |                                                                         |
| 20250102 | DAX           | Havens Consulting (w. Danii Maslyuk) | DAX Anti-Patterns Series (13 ep)                                 | Intermediate | 5hr       | https://www.youtube.com/playlist?list=PLzN99cpDw6oA4R_YAmkoJpq-g_Dl8i_rh                          | Completed (13/13) | ****   |                                                                         |
| 20250107 | Power BI      | Microsoft                            | Get started with Power BI                                        | Beginner     | 1hr 30min | https://learn.microsoft.com/en-us/training/paths/get-started-power-bi/                            | Completed         | **     | Very basic tour - focus on consumers                                    |
| 20250107 | Power BI      | Microsoft                            | From Excel workbook to stunning report in Power BI Desktop       | Beginner     | 20mins    | https://learn.microsoft.com/en-gb/power-bi/create-reports/desktop-excel-stunning-report           | Completed         | **     | Create a basic dashboard                                                |
| 20250113 | DAX           | Microsoft                            | Write DAX formulas for Power BI Desktop models                   | Beginner     | 27mins    | https://learn.microsoft.com/en-us/training/modules/dax-power-bi-write-formulas/?source=learn      | Completed         | *****  | Good clear intro to key DAX operators, functions and calculation types. |
| 20250122 | Power BI      | PowerBI.Tips                         | PowerBI.Tips - Daniel Marsh-Patrick - HTML Content Custom Visual | Intermediate | 1hr 26m   | https://www.youtube.com/watch?v=gLyZukIpUg8                                                       | Completed         | ****   | Html Content - using images, hyperlinks, HTML content, SVG etc          |
| 20250124 | Visualisation | Stephen Few                          | Show Me The Numbers (book)                                       | Intermediate | 15hr      | n/a                                                                                               | Completed         | *****  | Visualisation design                                                    |
| 20250128 | Power BI      | Microsoft Learn                      | Use Visuals in Power BI                                          | Intermediate | 76m       | https://learn.microsoft.com/en-us/training/modules/visuals-in-power-bi/                           | Completed         | ***    | How to use basic visuals / page settings                                |
| 20250128 | Power BI      | Microsoft Learn                      | Use Hierarchies + DAX in you first data model                    | Beginner     | 60m       | https://learn.microsoft.com/en-us/training/modules/use-hierarchies-dax-first-data-model/          |                   |        |                                                                         |

## 20241220

### https://learn.microsoft.com/en-us/training/modules/describe-core-architectural-components-of-azure/3-get-started-azure-accounts
- Free 12 month azure account: https://azure.microsoft.com/free
- Support: https://docs.microsoft.com
- Microsoft learn sandbox - uses your account + creates temporary subscription no cost

### https://app.datacamp.com/learn/courses/data-visualization-in-power-bi
- 3 things to consider when adding to a dashboard:
  - Does this contribute to the story? (1 story per page)
  - Is this the right visual element?
  - Is this visual element necessary?

### 20241226 Advanced DAX
- Debugging golden rule
  - Stop thinking
  - Follow the measure, ask yourself what is the current filter context at each step.

### 20241228 DAX Functions in Power BI
- Context:
  - Row:
    - The 'current row' - used by calculated columns 
  - Query:
    - subset of data returned by a formula. Can be changed by slicers, page filters, table columns + row headers
    - Applies AFTER row context
  - Filter:
    - Set of values allowed in each context, or values from related table
    - Applies after filter context (i.e. the effects are temporary / lost)
    - CALCULATE?
    - Arguments to a DAX function

## TO Do
- TAbular editor
- DAX Studio
- Create style template
- Create PBIX Examples
- Create standards / reference doc