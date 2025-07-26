# DOJO Security Automation - Terraform Project

Este proyecto de Terraform crea la infraestructura necesaria para automatización de seguridad en Azure, incluyendo:

- **Resource Group**: Grupo de recursos para organizar los componentes
- **Logic Apps**: Flujo de trabajo para automatización de procesos de seguridad
- **Azure Policy**: Política para garantizar el cumplimiento de etiquetado

## Prerrequisitos

1. [Terraform](https://www.terraform.io/downloads) >= 1.0
2. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Suscripción de Azure activa

## Configuración

1. Clona este repositorio
2. Autentícate en Azure:
   ```bash
   az login
   ```
3. Copia el archivo de ejemplo de variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
4. Edita `terraform.tfvars` con tus valores específicos

## Despliegue

1. Inicializa Terraform:
   ```bash
   terraform init
   ```

2. Planifica el despliegue:
   ```bash
   terraform plan
   ```

3. Aplica la configuración:
   ```bash
   terraform apply
   ```

## Recursos Creados

### Resource Group
- Nombre: Definido en variable `resource_group_name`
- Ubicación: Definido en variable `location`

### Logic Apps
- Flujo de trabajo con trigger HTTP
- Acción HTTP de ejemplo
- Ideal para automatización de respuestas de seguridad

### Azure Policy
- Política personalizada que requiere etiquetas específicas
- Asignada al grupo de recursos
- Audita el cumplimiento de etiquetado

## Variables

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `resource_group_name` | Nombre del grupo de recursos | `rg-dojo-security-automation` |
| `location` | Región de Azure | `East US` |
| `logic_app_name` | Nombre del Logic App | `logic-dojo-security` |
| `tags` | Etiquetas para recursos | Objeto con etiquetas por defecto |

## Outputs

- `resource_group_name`: Nombre del grupo de recursos creado

## Limpieza

Para eliminar todos los recursos:

```bash
terraform destroy
```

## Seguridad

- Las URLs de callback del Logic App son marcadas como sensibles
- Se recomienda usar Azure Key Vault para secretos en producción
- Revisa las políticas de acceso antes del despliegue

## Próximos Pasos

1. Personalizar el Logic App para casos de uso específicos
2. Añadir más políticas de Azure según necesidades
3. Integrar con Azure Security Center
4. Configurar alertas y monitoreo
