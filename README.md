## Ejercicio Final: Extender la Configuración de Terraform para Incluir una Base de Datos RDS

### Desafío

En este ejercicio, extenderás la configuración de Terraform para incluir una base de datos RDS en cada workspace, con diferentes tamaños según el entorno (`prod` y `dev`). Esto te permitirá practicar la creación y gestión de recursos más complejos en múltiples workspaces.

### Objetivo

El objetivo es practicar la creación y gestión de recursos más complejos en múltiples workspaces, adaptando la configuración según el entorno.

### Pasos Detallados

#### Paso 1: Configuración Inicial

1. **Crear un Directorio de Trabajo**: Crea un nuevo directorio para tu proyecto Terraform.

    ```bash
    mkdir terraform-multiple-workspaces
    cd terraform-multiple-workspaces
    ```

#### Paso 2: Definir la Configuración de Terraform

1. **Crear un archivo de configuración principal (`main.tf`)**: Este archivo contendrá la configuración para los recursos de AWS, incluyendo la instancia EC2 y la base de datos RDS.

    ```hcl
    provider "aws" {
      region = "us-east-1"
    }

    locals {
      environment   = terraform.workspace
      bucket_name   = terraform.workspace == "prod" ? "prod-example-bucket" : "dev-example-bucket"
      instance_type = terraform.workspace == "prod" ? "t2.small" : "t2.micro"
      db_instance_class = terraform.workspace == "prod" ? "db.t2.medium" : "db.t2.micro"
      db_allocated_storage = terraform.workspace == "prod" ? 20 : 10
    }

    resource "aws_instance" "example" {
      ami           = "ami-01b799c439fd5516a" # Amazon Linux 2 AMI
      instance_type = local.instance_type

      tags = {
        Name        = "${local.environment}-example-instance"
        Environment = local.environment
      }
    }

    resource "aws_db_instance" "example" {
      allocated_storage    = local.db_allocated_storage
      engine               = "mysql"
      engine_version       = "5.7"
      instance_class       = local.db_instance_class
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

2. **Inicializar Terraform**: Inicializa tu configuración de Terraform para preparar el directorio de trabajo.

    ```bash
    terraform init
    ```

#### Paso 3: Crear y Cambiar entre Workspaces

1. **Listar Workspaces Disponibles**: Verifica los workspaces disponibles en tu proyecto.

    ```bash
    terraform workspace list
    ```

2. **Crear un Nuevo Workspace**: Crea workspaces para `development` y `prod`.

    ```bash
    terraform workspace new development
    terraform workspace new prod
    ```

3. **Cambiar a un Workspace Existente**: Cambia entre los workspaces según sea necesario.

    ```bash
    terraform workspace select development
    terraform workspace select prod
    ```

#### Paso 4: Desplegar Recursos en Diferentes Workspaces

1. **Aplicar Configuración en el Workspace `development`**:

    ```bash
    terraform workspace select development
    terraform apply -auto-approve
    ```

    Verifica los recursos creados en la consola de AWS, asegurándote de que una instancia EC2 `t2.micro` y una base de datos RDS `db.t2.micro` estén presentes.

2. **Aplicar Configuración en el Workspace `prod`**:

    ```bash
    terraform workspace select prod
    terraform apply -auto-approve
    ```

    Verifica los recursos creados en la consola de AWS, asegurándote de que una instancia EC2 `t2.small` y una base de datos RDS `db.t2.medium` estén presentes.

#### Paso 5: Verificar y Administrar Workspaces

1. **Verificar los Recursos**: Navega a la consola de AWS y verifica que los recursos se hayan creado correctamente en cada workspace.

2. **Renombrar un Workspace**: Si necesitas renombrar un workspace, sigue estos pasos detallados:

    - **Selecciona el Workspace que quieres renombrar**:

        ```bash
        terraform workspace select old-name
        ```

    - **Extrae el estado actual del workspace**:

        ```bash
        terraform state pull >old-name.tfstate
        ```

    - **Crea un nuevo Workspace con el nuevo nombre**:

        ```bash
        terraform workspace new new-name
        ```

    - **Empuja el estado al nuevo workspace**:

        ```bash
        terraform state push old-name.tfstate
        ```

    - **Verifica el estado del nuevo workspace**:

        ```bash
        terraform show
        ```

    - **Elimina el viejo workspace**:

        ```bash
        terraform workspace delete -force old-name
        ```

    - Cada comando realiza lo siguiente:
        - `terraform workspace select old-name`: Cambia al workspace existente que deseas renombrar.
        - `terraform state pull >old-name.tfstate`: Descarga el estado actual del workspace en un archivo.
        - `terraform workspace new new-name`: Crea un nuevo workspace con el nombre deseado.
        - `terraform state push old-name.tfstate`: Sube el estado del viejo workspace al nuevo.
        - `terraform show`: Verifica que el estado en el nuevo workspace es correcto.
        - `terraform workspace delete -force old-name`: Elimina el viejo workspace.

#### Paso 6: Limpieza de Recursos

1. **Destruir Recursos en un Workspace**: Antes de eliminar un workspace, debes destruir todos los recursos asociados con él para evitar problemas futuros.

    ```bash
    terraform workspace select development
    terraform destroy -auto-approve
    ```

2. **Eliminar el Workspace**: Una vez que todos los recursos han sido destruidos, puedes proceder a eliminar el workspace.

    ```bash
    terraform workspace select default
    terraform workspace delete development
    ```

    Si intentas eliminar un workspace que todavía tiene recursos asociados, recibirás un error. Usa la opción `-force` si estás seguro de que quieres eliminar el workspace y manejar manualmente cualquier recurso residual:

    ```bash
    terraform workspace delete -force development
    ```

3. **Eliminar todos los Workspaces**:

    ```bash
    terraform workspace select default
    terraform workspace delete prod
    terraform workspace delete dev
    ```

### Etiquetas de Recursos

- **Etiqueta Name**:
  - En el workspace `prod`: `prod-example-instance`
  - En el workspace `dev`: `dev-example-instance`
- **Etiqueta Environment**:
  - En ambos workspaces (`prod` y `dev`): El valor es el nombre del workspace (es decir, `prod` o `dev`).

### Ejercicio Final Completado

Has extendido la configuración de Terraform para incluir una base de datos RDS en cada workspace con diferentes tamaños según el entorno (`prod` y `dev`). Esto te permite practicar la creación y gestión de recursos más complejos en múltiples workspaces, asegurando que cada entorno esté adecuadamente aislado y configurado.
