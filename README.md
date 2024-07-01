# Práctica Avanzada de Terraform: Trabajar con Múltiples Workspaces en AWS

## Introducción

En esta práctica avanzada, aprenderás a trabajar con múltiples workspaces de Terraform en AWS. Los workspaces de Terraform permiten gestionar diferentes entornos (como desarrollo, prueba y producción) dentro de la misma configuración de Terraform. Esto facilita la administración de recursos aislados por entorno sin duplicar archivos de configuración.

## Requisitos Previos

1. **Cuenta de AWS**: Necesitas una cuenta de AWS con permisos adecuados para crear y gestionar recursos.
2. **AWS CLI**: Asegúrate de tener la AWS CLI instalada y configurada.
3. **Terraform**: Asegúrate de tener Terraform instalado en tu máquina.

## Sección 1: Trabajar con Múltiples Terraform Workspaces en AWS

### Paso 1: Configuración Inicial

1. **Instalar Terraform**: Asegúrate de tener Terraform instalado. Puedes descargarlo desde [aquí](https://www.terraform.io/downloads). Siga las instrucciones de instalación para tu sistema operativo.

2. **Configurar AWS CLI**: Configura la AWS CLI con las credenciales adecuadas. Ejecuta el comando:

    ```bash
    aws configure
    ```

    Proporciona tu clave de acceso, clave secreta, región predeterminada (por ejemplo, `us-east-1`) y formato de salida (por ejemplo, `json`).

3. **Crear un Directorio de Trabajo**: Crea un nuevo directorio para tu proyecto Terraform. Este directorio contendrá todos los archivos de configuración necesarios.

    ```bash
    mkdir terraform-multiple-workspaces
    cd terraform-multiple-workspaces
    ```

### Paso 2: Definir la Configuración de Terraform

4. **Crear un archivo de configuración principal (`main.tf`)**: Este archivo define los recursos que se van a crear en AWS y utiliza variables locales para configurar los recursos según el workspace.

    Crea un archivo llamado `main.tf` con el siguiente contenido:

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

    En este archivo:
    - `provider "aws"` especifica que usaremos AWS como proveedor y establece la región en `us-east-1`.
    - `locals` define variables locales que cambian según el workspace actual (`environment`, `bucket_name`, `instance_type`).
    - `resource "aws_instance" "example"` define una instancia EC2 con una AMI específica y un tipo de instancia que varía según el workspace.

5. **Inicializar Terraform**: Inicializa el directorio de trabajo de Terraform. Esto descarga los plugins necesarios para interactuar con AWS.

    ```bash
    terraform init
    ```

### Paso 3: Crear y Cambiar entre Workspaces

6. **Listar Workspaces Disponibles**: Lista todos los workspaces disponibles en el directorio actual.

    ```bash
    terraform workspace list
    ```

    Deberías ver al menos el workspace `default`.

7. **Crear un Nuevo Workspace**: Crea un nuevo workspace llamado `development`.

    ```bash
    terraform workspace new development
    ```

    Esto crea un nuevo workspace y cambia el contexto a `development`.

8. **Cambiar a un Workspace Existente**: Cambia al workspace `default`.

    ```bash
    terraform workspace select default
    ```

### Paso 4: Desplegar Recursos en Diferentes Workspaces

9. **Aplicar Configuración en el Workspace `development`**: Selecciona el workspace `development` y aplica la configuración de Terraform.

    ```bash
    terraform workspace select development
    terraform apply -auto-approve
    ```

    Esto creará los recursos definidos en `main.tf` en el workspace `development`. Verifica los recursos creados en la consola de AWS, asegurándote de que una instancia EC2 `t2.micro` esté presente.

10. **Aplicar Configuración en el Workspace `prod`**: Selecciona el workspace `prod` y aplica la configuración de Terraform.

    ```bash
    terraform workspace new prod
    terraform workspace select prod
    terraform apply -auto-approve
    ```

    Esto creará los recursos definidos en `main.tf` en el workspace `prod`. Verifica los recursos creados en la consola de AWS, asegurándote de que una instancia EC2 `t2.small` esté presente.

### Paso 5: Administrar Workspaces

11. **Renombrar un Workspace**: Aunque Terraform no permite renombrar directamente un workspace, puedes crear un nuevo workspace y eliminar el antiguo.

    ```bash
    terraform workspace new staging
    terraform workspace select default
    terraform workspace delete development
    ```

    Esto crea un nuevo workspace `staging`, cambia al workspace `default` y elimina el workspace `development`.

12. **Eliminar un Workspace**: No puedes eliminar el workspace actual. Primero, cambia a otro workspace y luego elimina el que deseas.

    ```bash
    terraform workspace select default
    terraform workspace delete staging
    ```

### Paso 6: Limpieza de Recursos

13. **Destruir Recursos en un Workspace**: Destruye todos los recursos en el workspace `prod`.

    ```bash
    terraform workspace select prod
    terraform destroy -auto-approve
    ```

14. **Eliminar todos los Workspaces**: Asegúrate de que todos los recursos han sido destruidos antes de eliminar los workspaces.

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

### Desafío: Extiende la configuración de Terraform para incluir una base de datos RDS en cada workspace con diferentes tamaños según el entorno (`prod` y `dev`).

1. **Añadir configuración de RDS en `main.tf`**:

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

    En este bloque:
    - `allocated_storage` y `instance_class` varían según el workspace (`prod` o `dev`).
    - `engine`, `engine_version`, `name`, `username` y `password` son configuraciones específicas de la base de datos RDS.

2. **Aplicar configuración en diferentes workspaces**:

    - **Workspace `dev`**:

        ```bash
        terraform workspace select dev
        terraform apply -auto-approve
        ```

        Verifica que se haya creado una instancia RDS con `10` GB de almacenamiento y clase de instancia `db.t2.micro`.

    - **Workspace `prod`**:

        ```bash
        terraform workspace select prod
        terraform apply -auto-approve
        ```

        Verifica que se haya creado una instancia RDS con `20` GB de almacenamiento y clase de instancia `db.t2.medium`.

### Objetivo

Practicar la creación y gestión de recursos más complejos en múltiples workspaces, adaptando la configuración según el entorno.
