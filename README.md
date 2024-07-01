# Práctica Avanzada de Terraform: Trabajar con Múltiples Workspaces en AWS

## Introducción

En esta práctica avanzada, aprenderás a trabajar con múltiples workspaces de Terraform en AWS. Los workspaces de Terraform permiten gestionar diferentes entornos (como desarrollo, prueba y producción) dentro de la misma configuración de Terraform. Esto facilita la administración de recursos aislados por entorno sin duplicar archivos de configuración.

## Requisitos Previos

1. **Cuenta de AWS**: Necesitas una cuenta de AWS con permisos adecuados para crear y gestionar recursos.
2. **AWS CLI**: Asegúrate de tener la AWS CLI instalada y configurada.
3. **Terraform**: Asegúrate de tener Terraform instalado en tu máquina.

## Sección 1: Trabajar con Múltiples Terraform Workspaces en AWS

### Paso 1: Configuración Inicial

1. **Instalar Terraform**: Asegúrate de tener Terraform instalado. Puedes descargarlo desde [aquí](https://www.terraform.io/downloads).
2. **Configurar AWS CLI**: Configura la AWS CLI con las credenciales adecuadas usando el comando `aws configure`.
3. **Crear un Directorio de Trabajo**: Crea un nuevo directorio para tu proyecto Terraform.

    ```bash
    mkdir terraform-multiple-workspaces
    cd terraform-multiple-workspaces
    ```

### Paso 2: Definir la Configuración de Terraform

4. **Crear un archivo de configuración principal (`main.tf`)**: 

    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    locals {
      environment   = terraform.workspace
      bucket_name   = terraform.workspace == "prod" ? "prod-example-bucket" : "dev-example-bucket"
      instance_type = terraform.workspace == "prod" ? "t2.small" : "t2.micro"
    }

    resource "aws_instance" "example" {
      ami           = "ami-01b799c439fd5516a" # Amazon Linux 2 AMI
      instance_type = local.instance_type

      tags = {
        Name        = "${local.environment}-example-instance"
        Environment = local.environment
      }
    }
    ```

5. **Inicializar Terraform**:

    ```bash
    terraform init
    ```

### Paso 3: Crear y Cambiar entre Workspaces

6. **Listar Workspaces Disponibles**:

    ```bash
    terraform workspace list
    ```

7. **Crear un Nuevo Workspace**:

    ```bash
    terraform workspace new development
    ```

8. **Cambiar a un Workspace Existente**:

    ```bash
    terraform workspace select default
    ```

### Paso 4: Desplegar Recursos en Diferentes Workspaces

9. **Aplicar Configuración en el Workspace `development`**:

    ```bash
    terraform workspace select development
    terraform apply -auto-approve
    ```

    Verifica los recursos creados en la consola de AWS, asegurándote de que una instancia EC2 `t2.micro` esté presente.

10. **Aplicar Configuración en el Workspace `prod`**:

    ```bash
    terraform workspace select prod
    terraform apply -auto-approve
    ```

    Verifica los recursos creados en la consola de AWS, asegurándote de que una instancia EC2 `t2.small` esté presente.

### Paso 5: Administrar Workspaces

#### Renombrar un Workspace

Terraform no tiene un comando directo para renombrar workspaces, pero puedes lograrlo siguiendo estos pasos:

1. **Selecciona el Workspace que quieres renombrar**:

    ```bash
    terraform workspace select old-name
    ```

2. **Extrae el estado actual del workspace**:

    ```bash
    terraform state pull >old-name.tfstate
    ```

3. **Crea un nuevo Workspace con el nuevo nombre**:

    ```bash
    terraform workspace new new-name
    ```

4. **Empuja el estado al nuevo workspace**:

    ```bash
    terraform state push old-name.tfstate
    ```

5. **Verifica el estado del nuevo workspace**:

    ```bash
    terraform show
    ```

6. **Elimina el viejo workspace**:

    ```bash
    terraform workspace delete -force old-name
    ```

Cada comando realiza lo siguiente:
- `terraform workspace select old-name`: Cambia al workspace existente que deseas renombrar.
- `terraform state pull >old-name.tfstate`: Descarga el estado actual del workspace en un archivo.
- `terraform workspace new new-name`: Crea un nuevo workspace con el nombre deseado.
- `terraform state push old-name.tfstate`: Sube el estado del viejo workspace al nuevo.
- `terraform show`: Verifica que el estado en el nuevo workspace es correcto.
- `terraform workspace delete -force old-name`: Elimina el viejo workspace.

#### Eliminar un Workspace

1. **Destruir Recursos en el Workspace**: Antes de eliminar un workspace, debes destruir todos los recursos asociados con él para evitar problemas futuros.

    ```bash
    terraform workspace select development
    terraform destroy -auto-approve
    ```

    Esto destruirá todos los recursos creados en el workspace `development`.

2. **Eliminar el Workspace**: Una vez que todos los recursos han sido destruidos, puedes proceder a eliminar el workspace.

    ```bash
    terraform workspace select default
    terraform workspace delete development
    ```

    Si intentas eliminar un workspace que todavía tiene recursos asociados, recibirás un error como el siguiente:

    ```plaintext
    Error: Workspace is not empty
    Workspace "development" is currently tracking the following resource instances:
      - aws_instance.example

    Deleting this workspace would cause Terraform to lose track of any associated remote objects, which would then require you to delete them manually outside of Terraform. You should destroy these objects with Terraform before deleting the workspace.

    If you want to delete this workspace anyway, and have Terraform forget about these managed objects, use the -force option to disable this safety check.
    ```

    Si estás seguro de que quieres eliminar el workspace y manejar manualmente cualquier recurso residual, puedes usar la opción `-force`:

    ```bash
    terraform workspace delete -force development
    ```

### Paso 6: Limpieza de Recursos

13. **Destruir Recursos en un Workspace**:

    ```bash
    terraform workspace select prod
    terraform destroy -auto-approve
    ```

14. **Eliminar todos los Workspaces**:

    ```bash
    terraform workspace select default
    terraform workspace delete prod
    terraform workspace delete dev
    ```

## Etiquetas de Recursos

- **Etiqueta Name**:
  - En el workspace `prod`: `prod-example-instance`
  - En el workspace `dev`: `dev-example-instance`
- **Etiqueta Environment**:
  - En ambos workspaces (`prod` y `dev`): El valor es el nombre del workspace (es decir, `prod` o `dev`).

## Ejercicio Final

15. **Desafío**: Extiende la configuración de Terraform para incluir una base de datos RDS en cada workspace con diferentes tamaños según el entorno (`prod` y `dev`).

    ```hcl
    resource "aws_db_instance" "example" {
      allocated_storage    = terraform.workspace == "prod" ? 20 : 10
      engine               = "mysql"
      engine_version       = "5.7"
      instance_class       = terraform.workspace == "prod" ? "db.t2.medium" : "db.t2.micro"
      name                 = "exampledb"
      username             = "admin"
      password             = "password"
      parameter_group_name = "default.mysql5.7"

      tags = {
        Name        = "${local.environment}-example-db"
        Environment = local.environment
      }
    }
    ```

16. **Objetivo**: Practicar la creación y gestión de recursos más complejos en múltiples workspaces, adaptando la configuración según el entorno.
