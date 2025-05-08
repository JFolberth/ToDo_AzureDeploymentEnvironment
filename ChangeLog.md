# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2025-05-08

### Major Update: .NET 8 Upgrade

#### Added
- Added RBAC authentication support for Cosmos DB connections
- Added enhanced logging for application startup and database connections
- Added global.json to specify SDK version requirements
- Added improved error handling for Cosmos DB connections

#### Changed
- Upgraded from .NET Core 3.1 to .NET 8.0
- Updated Azure.Identity from 1.6.1 to 1.10.4
- Updated Microsoft.Azure.Cosmos from 3.30.1 to 3.38.1
- Migrated from Newtonsoft.Json to System.Text.Json for improved performance
- Converted to .NET 8 minimal hosting model (Program.cs)
- Improved security with better exception handling and logging
- Enhanced model validation with nullable reference types
- Updated error handling for Cosmos DB connections
- Switched from legacy Startup.cs pattern to modern .NET 8 minimal hosting
- Improved dependency injection configuration

#### Removed
- Removed Startup.cs in favor of minimal hosting model
- Removed legacy authentication patterns

#### Security
- Documented moderate severity vulnerabilities in Azure.Identity 1.10.4:
  - [GHSA-m5vv-6r4h-3vj9](https://github.com/advisories/GHSA-m5vv-6r4h-3vj9): Vulnerability in Azure Identity libraries could lead to CertificateCredential bypass
  - [GHSA-wvxc-855f-jvrv](https://github.com/advisories/GHSA-wvxc-855f-jvrv): ClientCertificateCredential can be exploited to bypass certificate validation
  - Note: These vulnerabilities are not actively exploitable in this application as it uses Managed Identity/RBAC authentication mode in Azure

## [1.0.0] - Initial Release

- Initial version of ToDo application with .NET Core 3.1
- Azure Cosmos DB integration for data storage
- Azure Deployment Environments (ADE) support