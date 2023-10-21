# About
This repository is configured to be leveraged by [Azure Deployment Environments](https://learn.microsoft.com/azure/deployment-environments/). 

The repository is a simple ToDo dotnet core app hosted in an App Service whose backed end data is in Cosmos DB. This repository will contain all the source code, Infrastructure as Code (IaC), Azure Deployment Environment (ADE) artifacts, and Azure DevOps YAML Pipeline code.

# Intention
This repository is a one stop shop to show how ADEs can be leveraged to not only build a one off developer environment; however, can be used in a CI pipeline with the following activities:
- Create an ADE
- Deploy the code to the newly created ADE
- Run an Azure Load Test against the ADE Environment
- Delete the ADE Environment *Always will run

# Perquisites
## Infrastructure  
First, for the infrastructure we will require the following to already be deployed:
- NoSQL Cosmos DB Account
  - Database named Tasks
  - Container named Item
- Log Analytics Workspace
- An empty resource group to deploy the resources into...if wanting to deploy a stand alone instance
- Azure Load Testing Instance *optional if you want to run the CI/CD steps

These are required as in a typical enterprise scenario the data resources and the logging resources will be located under different resource groups and managed by different software pipelines. This is a well architected guideline as it will enable the components to scale separate, provide a better security model, and separate component lifecycle.

## Azure Deployment Environment
This resource assumes you already have an ADE deployed out into Azure. This is not covered and if wanting to learn how please refer to the [product documentation](https://learn.microsoft.com/azure/deployment-environments/)

### Environment Type
The UID handling the Environment Type Deployments will need to have access Contributor and User Access Admin.

### Catalog
To Configure the catalog you should have a Key Vault created with a PAT token for GitHub or ADO stored in the Key Vault and the UID of the Dev Center needs the ability to retrieve it to authenticate to your copy of the repository. An [additional walkthrough can be found here](https://learn.microsoft.com/azure/deployment-environments/how-to-configure-catalog)

# IaC
The IaC for this project is located in the `infrastructure` folder. The `main.bicep` file is configured to use [private bicep registry modules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/private-module-registry?tabs=azure-powershell). The source modules are located in a [separate repository](https://github.com/JFolberth/bicep_registry)

If you'd rather not host this registry only the `main.json` is actually required for the ADE. If wanting to just deploy the `bicep` file you are welcome to run a `decompile` against the `main.json`

The modules are structured based on the individual service. As such the main.bicep will make a call to each service required to be created. Which for this project the following services are created:
- Azure App Service Plan
- Azure App Service
- Application Insights
- User Assigned Identity
- RBAC Cosmos DB Role Assignment

The deployment is being done at the Resource Group to best fit into the ADE model.

# Application Code
The application code is contained in the `src` directory. This code was taken from [cosmos-dotnet-core-todo-app](https://github.com/Azure-Samples/cosmos-dotnet-core-todo-app) Additional details can be found on the source project's repository

# Tests
There is a very basic Azure Load Test available for this application. All the test does is hit the site at the base URL. This was configured to simply illustrated one way testing could be inserted into your CI pipeline. For additional information on Azure Load Testing check out the [product documentation.](https://learn.microsoft.com/azure/load-testing/) 

# Azure Deployment Environment
The ADE relies on a series of files. All of which are under the `infrastructure` folder as ideally we'd like the ADE to leverage the same template our application will leverage when deploying to future environments. This would ensure consistency across all deployments.

The following files are required for ADE configuration:
- `main.json`
  - This is the main template file the ADE will read from when deploying
- `mainfest.yaml`
  - Contains the inputs that will be present to a developer when create an ADE for this project
- `parameters/ade.eus.parameters.json`
  - `json` file that will contain values to satisfy the `mainfest.yaml` when interacting with a Dev Center via the CLI. This will build the ADE has part of the CI Pipeline.

# Azure DevOps Pipelines
These are contained in the YAML folder. The YAML Templates leverages templates defined in [TheYAMLPipelineOne](https://github.com/JFolberth/TheYAMLPipelineOne).

Though not required this is used for simplicity in managing and reusing pipelines. I have included a fully expanded pipeline if you'd prefer to run this pipeline as a single instance. The `azure-pipeline-expanded.yml` file will only have the CI including the Load Testing and ADE pieces for simplicity. You will need to update for items specific to your environment. These attributes are denoted by `<>`. For instance these properties would include Service Connection Name, Dev Center Name, etc. 

# Additional Resources
- [Scott Hanselman Walkthrough on Deployment Environments](https://www.youtube.com/watch?v=_rRiVELgdf4)
- [Introduction to Azure Deployment Environment Components](https://blog.johnfolberth.com/introduction-to-azure-deployment-environment-components/)
- [Azure Deployment Environments – Creating a Developer Sandbox](https://blog.johnfolberth.com/azure-deployment-environments-creating-a-developer-sandbox/)
- [Azure Deployment Environments – Creating an Application Sandbox](https://blog.johnfolberth.com/azure-deployment-environments-creating-an-application-sandbox/)
