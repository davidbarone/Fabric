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

## Getting Started
- https://learn.microsoft.com/en-us/fabric/get-started/

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

| Date     | Area     | Provider                             | Description                                           | Level        | Duration  | Url                                                                                                                             | Status         | Rating | Comments                               |
| -------- | -------- | ------------------------------------ | ----------------------------------------------------- | ------------ | --------- | ------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------ | -------------------------------------- |
| 20241214 | Azure    | Microsoft                            | Microsoft Azure Fundamentals: Describe cloud concepts | Beginner     | 1hr       | https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/                          | Completed      | **     |                                        |
| 20241220 | Power BI | DataCamp                             | Introduction to Power BI                              | Beginner     | 4hr       | https://app.datacamp.com/learn/courses/introduction-to-power-bi                                                                 | Completed      | ***    |                                        |
| 20241220 | Azure    | Microsoft                            |                                                       | Beginner     | 1hr       | https://learn.microsoft.com/en-us/training/modules/describe-core-architectural-components-of-azure/3-get-started-azure-accounts | In Progress    |        |                                        |
| 20241221 | DAX      | DataCamp                             | Introduction to DAX in Power BI                       | Beginner     | 3hr       | https://campus.datacamp.com/courses/introduction-to-dax-in-power-bi/getting-started-with-dax?ex=1                               | Completed      | ****   |                                        |
| 20241222 | DAX      | Alberto Ferrari                      | DAX 101                                               | Beginner     | 2hr       | https://www.youtube.com/watch?v=klQAZLr5vxA                                                                                     | Completed      | *****  | Good explanation of DAX basics         |
| 20241223 | Power BI | DataCamp                             | Data Visualisation in Power BI                        | Beginner     | 3hr       | https://app.datacamp.com/learn/courses/data-visualization-in-power-bi                                                           | Completed      | ***    |                                        |
| 20241225 | DAX      | Alberto Ferrari                      | Advanced DAX                                          | Advanced     | 2hr       | https://www.youtube.com/watch?v=6ncHnWMEdic                                                                                     | Completed      | *****  | Good explanation of evaluation context |
| 20241227 | Power BI | DataCamp                             | Data Modelling in Power BI                            | Beginner     | 3hr       | https://app.datacamp.com/learn/courses/data-modeling-in-power-bi                                                                | Completed      | ***    |                                        |
| 20241228 | DAX      | DataCamp                             | DAX Functions in Power BI                             | Beginner     | 3hr       | https://app.datacamp.com/learn/courses/dax-functions-in-power-bi                                                                | Completed      | **     |                                        |
| 20250102 | DAX      | Havens Consulting (w. Danii Maslyuk) | DAX Anti-Patterns Series (13 ep)                      | Intermediate | 5hr       | https://www.youtube.com/playlist?list=PLzN99cpDw6oA4R_YAmkoJpq-g_Dl8i_rh                                                        | 3/13 completed |        |                                        |
| 20250107 | Power BI | Microsoft                            | Get started with Power BI                             | Beginner     | 1hr 30min | https://learn.microsoft.com/en-us/training/paths/get-started-power-bi/                                                          | Completed      | **     | Very basic tour - focus on consumers   |


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