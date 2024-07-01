# Migración de Terraform State de Local a Remoto (S3)

Este documento te guiará a través de la migración del estado de Terraform desde un archivo local a un backend remoto utilizando Amazon S3. La configuración se basa en un archivo `main.tf` que define recursos para diferentes entornos (`dev` y `prod`).


## Contenido de `main.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

locals {
  environment         = terraform.workspace
  bucket_name         = terraform.workspace == "prod" ? "prod-example-bucket" : "dev-example-bucket"
  instance_type       = terraform.workspace == "prod" ? "t2.small" : "t3.micro"
  db_instance_class   = terraform.workspace == "prod" ? "db.t3.medium" : "db.t3.micro"
  db_allocated_storage= terraform.workspace == "prod" ? 20 : 10
}

resource "aws_instance" "example" {
  ami           = "ami-01b799c439fd5516a"
  instance_type = local.instance_type

  tags = {
    Name        = "${local.environment}-example-instance"
    Environment = local.environment
  }
}

resource "aws_db_instance" "example" {
  allocated_storage    = local.db_allocated_storage
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = local.db_instance_class
  db_name              = "exampledb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"

  tags = {
    Name        = "${local.environment}-example-db"
    Environment = local.environment
  }
}
```

---

## Paso 1: Crear y administrar recursos localmente

### 1.1 Inicializar Terraform

Primero, inicializa Terraform en tu directorio de trabajo. Esto descarga los plugins necesarios y configura el entorno.

```bash
terraform init
```

### 1.2 Seleccionar el entorno de trabajo (Workspace)

Terraform permite gestionar múltiples entornos (`workspaces`). Para este ejemplo, utilizaremos los workspaces `dev` y `prod`.

Crea y selecciona el workspace `dev`:

```bash
terraform workspace new dev
```

Para cambiar al workspace `prod` en el futuro, puedes usar:

```bash
terraform workspace select prod
```

### 1.3 Aplicar la configuración

Con el workspace `dev` seleccionado, aplica la configuración para crear los recursos definidos:

```bash
terraform apply
```

Terraform pedirá confirmación antes de aplicar los cambios. Ingresa `yes` para continuar.

---

## Paso 2: Crear un bucket de S3 manualmente

### 2.1 Crear el bucket S3

Accede a la consola de AWS y navega a S3 para crear un nuevo bucket. Sigue estos pasos:

1. Abre la [Consola de Amazon S3](https://s3.console.aws.amazon.com/s3/).
2. Haz clic en "Create bucket".
3. Asigna un nombre único al bucket y selecciona la región `us-east-1`.
4. Deja las configuraciones por defecto o personalízalas según tus necesidades.
5. Haz clic en "Create bucket" para finalizar.

### 2.2 Configurar la política de bucket (opcional)

Si planeas que múltiples usuarios o servicios accedan al bucket, configura una política que permita el acceso necesario.

Ejemplo de política de bucket que permite acceso completo al bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::nombre-de-tu-bucket",
        "arn:aws:s3:::nombre-de-tu-bucket/*"
      ]
    }
  ]
}
```

Ajusta `"Principal"` y `"Action"` según tus necesidades de seguridad.

---

## Paso 3: Migrar el estado de Terraform de local a remoto

### 3.1 Configurar el backend en Terraform

Edita tu archivo `main.tf` para especificar que Terraform debe usar el bucket de S3 como backend. Agrega el siguiente bloque de configuración al principio del archivo:

```hcl
terraform {
  backend "s3" {
    bucket = "nombre-de-tu-bucket"
    key    = "ruta/a/tu/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Reemplaza `nombre-de-tu-bucket` con el nombre del bucket que creaste y ajusta la `key` a la ruta deseada dentro del bucket donde se almacenará el archivo de estado.

### 3.2 Migrar el estado

Ejecuta el siguiente comando para iniciar la migración del estado de local a remoto:

```bash
terraform init -migrate-state
```

Terraform te preguntará si deseas migrar el estado. Confirma ingresando `yes`.

---

## Paso 4: Verificar la migración

### 4.1 Comprobar el estado remoto

Después de la migración, verifica que el archivo `terraform.tfstate` ahora está en tu bucket de S3. Accede a la consola de S3 y navega a la ruta especificada en el bloque `backend` de Terraform.

### 4.2 Confirmar la gestión de recursos

Ejecuta `terraform plan` para asegurarte de que Terraform está utilizando el estado remoto correctamente:

```bash
terraform plan
```

Deberías ver que Terraform no intenta recrear los recursos, ya que ahora está gestionando el estado desde S3.

### 4.3 Aplicar cambios

Si todo está correcto, intenta aplicar un cambio menor en tu configuración para verificar la gestión continua del estado remoto.

Por ejemplo, cambia el tipo de instancia en `main.tf`:

```hcl
locals {
  environment         = terraform.workspace
  bucket_name         = terraform.workspace == "prod" ? "prod-example-bucket" : "dev-example-bucket"
  instance_type       = terraform.workspace == "prod" ? "t2.medium" : "t3.micro" # Cambia t2.small a t2.medium
  db_instance_class   = terraform.workspace == "prod" ? "db.t3.medium" : "db.t3.micro"
  db_allocated_storage= terraform.workspace == "prod" ? 20 : 10
}
```

Ejecuta `terraform apply` nuevamente y confirma los cambios. Esto validará que el estado remoto se está utilizando correctamente para aplicar los cambios.

