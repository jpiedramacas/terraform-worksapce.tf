# Guía Completa para Proteger Variables Sensibles en Terraform

En esta guía, aprenderás cómo proteger la información sensible en Terraform. Es común que necesites configurar infraestructura usando información sensible como nombres de usuario, contraseñas, tokens de API o Información Personalmente Identificable (PII). Terraform proporciona varias características para evitar que estos datos se expongan accidentalmente en la salida de la CLI, los registros o el control de versiones.

## Prerrequisitos

Antes de comenzar, asegúrate de tener los siguientes elementos:

- **Terraform v1.2+** instalado localmente.
- **Una cuenta de AWS** con credenciales locales configuradas para su uso con Terraform.
- **CLI de Git** instalada.

> **Nota**: Parte de la infraestructura en este tutorial puede no calificar para el nivel gratuito de AWS. Destruye la infraestructura al finalizar el tutorial para evitar cargos innecesarios. No somos responsables de ningún cargo que puedas incurrir.

## Paso 1: Crear la Infraestructura

Primero, clona el repositorio GitHub que contiene la configuración de Terraform para este tutorial:

```bash
git clone https://github.com/hashicorp/learn-terraform-sensitive-variables.git
cd learn-terraform-sensitive-variables
```

Este repositorio define una aplicación web que incluye una VPC, un balanceador de carga, instancias EC2 y una base de datos.

### Inicializa la Configuración

Inicia la configuración de Terraform:

```bash
terraform init
```

Esto inicializa el backend y descarga los módulos necesarios.

### Aplica la Configuración

Aplica la configuración para crear la infraestructura de ejemplo:

```bash
terraform apply
```

Responde a la solicitud de confirmación escribiendo `yes`. Esto desplegará todos los recursos definidos.

## Paso 2: Refactorizar las Credenciales de la Base de Datos

Vamos a modificar el archivo `main.tf` para eliminar las credenciales de la base de datos codificadas directamente y reemplazarlas con variables sensibles.

### Declarar Variables Sensibles

Abre `variables.tf` y declara las variables para el nombre de usuario y la contraseña de la base de datos:

```hcl
variable "db_username" {
  description = "Nombre de usuario del administrador de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña del administrador de la base de datos"
  type        = string
  sensitive   = true
}
```

### Referenciar Variables Sensibles en `main.tf`

Actualiza el bloque `aws_db_instance.database` en `main.tf` para utilizar las variables declaradas:

```hcl
resource "aws_db_instance" "database" {
  allocated_storage = 5
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password
  db_subnet_group_name = aws_db_subnet_group.private.name
  skip_final_snapshot = true
}
```

## Paso 3: Establecer Valores de Variables Sensibles

Existen varias formas de asignar valores a las variables sensibles. Veremos dos métodos: utilizando un archivo `.tfvars` y utilizando variables de entorno.

### Utilizar un Archivo `.tfvars`

Crea un archivo llamado `secret.tfvars` para asignar valores a las variables sensibles:

```hcl
db_username = "admin"
db_password = "contraseña_insegura"
```

Aplica los cambios usando el parámetro `-var-file`:

```bash
terraform apply -var-file="secret.tfvars"
```

### Utilizar Variables de Entorno

Otra forma de proporcionar valores sensibles es mediante variables de entorno. Terraform busca en el entorno variables que coincidan con el patrón `TF_VAR_<NOMBRE_VARIABLE>`.

En Linux o Mac:

```bash
export TF_VAR_db_username="admin"
export TF_VAR_db_password="otra_contraseña_insegura"
```

En Windows PowerShell:

```powershell
$env:TF_VAR_db_username="admin"
$env:TF_VAR_db_password="otra_contraseña_insegura"
```

Aplica la configuración nuevamente:

```bash
terraform apply
```

## Paso 4: Referenciar Variables Sensibles

Al usar variables sensibles en tu configuración, Terraform redactará estos valores en la salida de los comandos y archivos de registro. Intenta referenciar estas variables en una salida.

### Añadir Variables de Salida Sensibles

Añade los siguientes valores de salida en `outputs.tf`:

```hcl
output "db_connect_string" {
  description = "Cadena de conexión a la base de datos MySQL"
  value       = "Server=${aws_db_instance.database.address}; Database=ExampleDB; Uid=${var.db_username}; Pwd=${var.db_password}"
  sensitive   = true
}
```

Aplica este cambio:

```bash
terraform apply
```

## Paso 5: Manejar Valores Sensibles en el Archivo de Estado

Cuando ejecutas comandos de Terraform con un archivo de estado local, Terraform almacena el estado como texto plano, incluyendo los valores sensibles. 

Abre el archivo `terraform.tfstate` y busca las credenciales para ver cómo se almacenan.

```bash
grep "password" terraform.tfstate
```

> **Nota**: Si tu sistema no tiene el comando `grep`, abre el archivo `terraform.tfstate` en tu editor de texto y busca "password".

## Paso 6: Limpiar la Infraestructura

Destruye la infraestructura que creaste en este tutorial para evitar cargos adicionales:

```bash
terraform destroy
```

Responde a la solicitud de confirmación con `yes`.

---

## Consideraciones Finales

- **No almacenes archivos `.tfvars` con valores sensibles en el control de versiones.**
- **Utiliza la encriptación para proteger el archivo de estado.** HCP Terraform y Terraform Enterprise encriptan todos los valores de las variables antes de almacenarlos.
- **Considera el uso de HashiCorp Vault** para gestionar y asegurar el acceso a tokens, contraseñas y otros valores sensibles.

Terraform facilita la gestión segura de la infraestructura, pero es crucial manejar adecuadamente la información sensible para mantener la seguridad y la integridad de tu entorno.

¡Ahora estás listo para proteger tus variables sensibles en Terraform!
