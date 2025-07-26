# Azure Policy - Disable Storage Account Public Access

Este módulo de Terraform implementa Azure Policy para deshabilitar automáticamente el acceso público a las Storage Accounts, mejorando la postura de seguridad de la suscripción.

## Funcionalidades

- **Policy Definition**: Define una política personalizada que identifica Storage Accounts con acceso público habilitado
- **Policy Initiative**: Agrupa múltiples políticas relacionadas con seguridad de Storage
- **Automatic Remediation**: Aplica automáticamente la configuración segura usando DeployIfNotExists
- **Compliance Monitoring**: Audita y reporta el estado de cumplimiento

## Uso

1. **Configurar variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Editar terraform.tfvars con tus valores
   ```

2. **Autenticarse en Azure**:
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

3. **Desplegar la política**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Políticas Incluidas

### 1. Disable Storage Account Public Network Access
- **Efecto**: DeployIfNotExists (configurable)
- **Acción**: Deshabilita `publicNetworkAccess` en Storage Accounts
- **Remediación**: Automática si se configura DeployIfNotExists

### 2. Audit Storage Account Public Blob Access
- **Efecto**: Audit
- **Acción**: Audita Storage Accounts que permiten acceso público a blobs

## Configuración de Efectos

- **Audit**: Solo reporta recursos no conformes
- **Deny**: Bloquea la creación de recursos no conformes
- **DeployIfNotExists**: Remedia automáticamente recursos no conformes
- **Disabled**: Deshabilita la política

## Comandos Útiles

```bash
# Ver estado de cumplimiento
az policy state list --policy-assignment-name "disable-storage-public-access-subscription"

# Verificar políticas asignadas
az policy assignment list --query "[?displayName=='Storage Account Security Policy Assignment']"

# Ejecutar remediación manual
az policy remediation create --name "manual-remediation" --policy-assignment "/subscriptions/{sub-id}/providers/Microsoft.Authorization/policyAssignments/{assignment-name}"
```

## Monitoreo

- Las políticas reportan en Azure Policy Compliance Dashboard
- Los eventos de remediación se registran en Activity Log
- Se pueden configurar alertas en Azure Monitor para cambios de políticas

## Seguridad

- La identidad administrada de la asignación de política tiene permisos mínimos
- Solo se otorgan permisos de Storage Account Contributor
- Las exclusiones se pueden configurar para casos especiales
