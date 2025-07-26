# DOJO Security Automation - Automatización de Seguridad

Este proyecto implementa automatización de seguridad en Azure utilizando Terraform, Logic Apps y Azure Policy para garantizar el cumplimiento y la gobernanza en la nube.

## Arquitectura del Proyecto

El proyecto implementa una arquitectura de seguridad en capas diseñada para la automatización de la detección, remediación y cumplimiento de políticas de seguridad en Azure.

### Componentes de la Arquitectura

#### 1. **Capa de Infraestructura como Código (IaC)**

- **Terraform**: Motor principal para el despliegue de infraestructura
  - Versión requerida: >= 1.0
  - Provider AzureRM: ~> 4.0
  - Separación modular por responsabilidades

#### 2. **Capa de Automatización y Orquestación**

- **Logic Apps**: Orquestación de flujos de trabajo de seguridad
  - Trigger de recurrencia automática (cada minuto)
  - Integración con Azure Management API
  - Automatización de remediación de Storage Accounts
  - Notificaciones mediante webhooks
  - Managed Identity para autenticación segura

#### 3. **Capa de Cumplimiento y Gobernanza**

- **Azure Policy**: Marco de políticas de cumplimiento
  - Políticas personalizadas para deshabilitar acceso público
  - Políticas de auditoría para monitoreo continuo
  - Iniciativas de políticas agrupadas
  - Asignación a nivel de suscripción
  - Capacidades de remediación automática (DeployIfNotExists)

#### 4. **Capa de Almacenamiento y Logs**

- **Storage Account**: Almacenamiento seguro centralizado
  - Configuración de alta seguridad
  - Contenedores dedicados para logs y reportes
  - Acceso restringido y cifrado
  - Integración con sistemas de monitoreo

#### 5. **Capa de Seguridad e Identidad**

- **Managed Identity**: Autenticación sin credenciales
- **Role-Based Access Control (RBAC)**: Permisos granulares
- **Resource Groups**: Aislamiento y organización de recursos

### Flujo de Automatización

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Azure Policy  │    │   Logic Apps    │    │ Storage Account │
│                 │    │                 │    │                 │
│ • Evalúa        │───▶│ • Se ejecuta    │───▶│ • Almacena logs │
│   cumplimiento  │    │   cada minuto   │    │ • Guarda        │
│ • Identifica    │    │ • Lista Storage │    │   reportes      │
│   violaciones   │    │   Accounts      │    │ • Evidencias    │
│ • Activa        │    │ • Ejecuta       │    │   de remediación│
│   remediación   │    │   remediación   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                       │                       │
          │              ┌─────────────────┐              │
          └─────────────▶│   Webhooks      │◀─────────────┘
                         │                 │
                         │ • Notificaciones│
                         │ • Alertas       │
                         │ • Integración   │
                         │   externa       │
                         └─────────────────┘
```

### Módulos del Proyecto

#### **resources/** - Infraestructura Principal

- Despliegue de recursos core de Azure
- Configuración de Logic Apps con workflows complejos
- Implementación de Storage Accounts seguros
- Gestión de identidades y permisos

#### **azurepolicy/** - Gobierno y Cumplimiento

- Definiciones de políticas personalizadas
- Iniciativas de seguridad para Storage Accounts
- Asignaciones a nivel de suscripción
- Configuración de remediación automática

## Prerrequisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Suscripción de Azure activa
- Permisos de Contributor en la suscripción

## Configuración Inicial

1. **Autenticación en Azure**:
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Configurar variables**:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Editar terraform.tfvars con tus valores
   ```

3. **Inicializar Terraform**:
   ```bash
   cd terraform/
   terraform init
   terraform plan
   terraform apply
   ```

## Estructura del Proyecto

```
DOJOConf2025/
├── README.md                        # Documentación principal del proyecto
├── .gitignore                       # Archivos a ignorar en Git
│
├── resources/                       # Infraestructura principal
│   ├── main.tf                      # Configuración principal y providers
│   ├── variables.tf                 # Definición de variables
│   ├── outputs.tf                   # Outputs del despliegue
│   ├── data.tf                      # Data sources
│   ├── logic-apps.tf                # Logic Apps para automatización
│   ├── storage-account.tf           # Storage Account seguro
│   ├── terraform.tfvars             # Variables de configuración
│   ├── terraform.tfvars.example     # Ejemplo de variables
│   └── .gitignore                   # Archivos específicos de Terraform
│
├── azurepolicy/                     # Políticas de Azure independientes
│   ├── main.tf                      # Configuración principal de políticas
│   ├── azure-policy.tf              # Definiciones de Azure Policy
│   ├── variables.tf                 # Variables para políticas
│   ├── outputs.tf                   # Outputs de políticas
│   ├── terraform.tfvars             # Variables de configuración
│   ├── terraform.tfvars.example     # Ejemplo de variables
│   ├── README.md                    # Documentación específica de políticas
│   └── .gitignore                   # Archivos específicos de políticas
│
└── dococumentos/                            # Documentación adicional
    └──  Checklist_Verificacion_Automatizacion_Seguridad_Con_Ponderacion.pdf             # Lista de checheo para que verifiques el estado de salud de la automatización de tu empresa

```

## Componentes del Proyecto

### Terraform (terraform/)
Módulo principal que despliega la infraestructura core:
- **Resource Group**: Contenedor de recursos principal
- **Logic App**: Automatización de remediación de Storage Accounts con trigger horario
- **Storage Account**: Almacenamiento seguro con contenedores para logs y reportes
- **Role Assignments**: Permisos necesarios para el Logic App
- **Data Sources**: Referencias a configuración actual de Azure

### Azure Policy (azurepolicy/)
Módulo independiente para políticas de cumplimiento:
- **Policy Definitions**: Políticas personalizadas para deshabilitar acceso público
- **Policy Initiatives**: Conjunto de políticas agrupadas para seguridad de Storage
- **Policy Assignments**: Asignación de políticas a nivel de suscripción
- **Role Assignments**: Permisos para remediación automática
- **Compliance Monitoring**: Auditoría y reporte de cumplimiento

## Recursos Creados

### Infraestructura Principal (terraform/)
- **Resource Group**: `rg-dojo-security-automation`
- **Logic App**: `logic-dojo-security` con flujo de automatización
- **Storage Account**: `stdojosecurity001` con configuración segura
- **Storage Containers**: `security-logs` y `security-reports`
- **Managed Identity**: Para autenticación del Logic App

### Políticas de Seguridad (azurepolicy/)
- **Custom Policy**: Deshabilitar acceso público en Storage Accounts
- **Audit Policy**: Monitoreo de acceso público a blobs
- **Policy Initiative**: Conjunto completo de políticas de Storage
- **Subscription Assignment**: Aplicación a nivel de suscripción
- **Managed Identity**: Para remediación automática

## Recursos de Interés

## Terraform
- [Documentación oficial de Terraform](https://www.terraform.io/docs)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terraform Azure Examples](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples)
- [Terraform State Management](https://www.terraform.io/docs/language/state/index.html)
- [Terraform Modules](https://www.terraform.io/docs/language/modules/index.html)

## HashiCorp Terraform Documentation
- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)
- [Terraform Configuration Language](https://developer.hashicorp.com/terraform/language/syntax/configuration)
- [Terraform Variables and Type Constraints](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform Functions](https://developer.hashicorp.com/terraform/language/functions)
- [Terraform Expressions](https://developer.hashicorp.com/terraform/language/expressions)
- [Terraform Providers](https://developer.hashicorp.com/terraform/language/providers)
- [Terraform Resources](https://developer.hashicorp.com/terraform/language/resources)
- [Terraform Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)
- [Terraform Modules Documentation](https://developer.hashicorp.com/terraform/language/modules)
- [Terraform State and Backends](https://developer.hashicorp.com/terraform/language/state)
- [Terraform Workspaces](https://developer.hashicorp.com/terraform/cli/workspaces)
- [Terraform Import](https://developer.hashicorp.com/terraform/cli/import)
- [Terraform Debugging](https://developer.hashicorp.com/terraform/internals/debugging)
- [Terraform Registry](https://registry.terraform.io/)
- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [Terraform Enterprise Documentation](https://developer.hashicorp.com/terraform/enterprise)

## Azure Infrastructure as Code
- [Azure Resource Manager Templates](https://docs.microsoft.com/azure/azure-resource-manager/templates/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure DevOps with Terraform](https://docs.microsoft.com/azure/devops/pipelines/apps/cd/azure/deploy-arm-template)

## Cloud Adoption Framework de Azure
- [Microsoft Cloud Adoption Framework for Azure](https://learn.microsoft.com/azure/cloud-adoption-framework/)

## Azure Well-Architected Framework
- [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/azure/architecture/framework/)

## Logic Apps y Automatización
- [Documentación de Azure Logic Apps](https://docs.microsoft.com/azure/logic-apps/)
- [Logic Apps Connectors](https://docs.microsoft.com/azure/connectors/)
- [Workflow Definition Language](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language)

## Azure Policy
- [Documentación de Azure Policy](https://docs.microsoft.com/azure/governance/policy/)
- [Policy Samples](https://docs.microsoft.com/azure/governance/policy/samples/)
- [Custom Policy Definitions](https://docs.microsoft.com/azure/governance/policy/tutorials/create-custom-policy-definition)

## Documentación de Microsoft Sentinel
- [Documentación de Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/)
- [Guía de inicio rápido de Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/quickstart-onboard)

## Seguridad en Azure
- [Azure Security Center](https://docs.microsoft.com/azure/security-center/)
- [Azure Security Benchmark](https://docs.microsoft.com/azure/security/benchmarks/)
- [Microsoft Defender for Cloud](https://docs.microsoft.com/azure/defender-for-cloud/)
