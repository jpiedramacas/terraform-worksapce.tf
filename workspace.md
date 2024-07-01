# Comandos Terraform Workspace

## Comandos y Funciones

### 1. `terraform workspace list`

**Descripción**: Lista todos los workspaces disponibles en el directorio actual.

**Uso**:

```bash
terraform workspace list
```

**Función**: Este comando muestra todos los workspaces que existen en el directorio de trabajo actual, incluyendo el workspace `default`. El workspace actual se indica con un asterisco (`*`).

### 2. `terraform workspace new <nombre_del_workspace>`

**Descripción**: Crea un nuevo workspace.

**Uso**:

```bash
terraform workspace new development
```

**Función**: Este comando crea un nuevo workspace con el nombre especificado y cambia automáticamente a ese workspace. Es útil para configurar nuevos entornos sin afectar los workspaces existentes.

### 3. `terraform workspace select <nombre_del_workspace>`

**Descripción**: Cambia al workspace especificado.

**Uso**:

```bash
terraform workspace select development
```

**Función**: Este comando cambia el contexto al workspace especificado. Si el workspace no existe, se mostrará un error. Cambiar de workspace afecta a todos los comandos posteriores de Terraform, aplicándose a los recursos y estado del workspace seleccionado.

### 4. `terraform workspace show`

**Descripción**: Muestra el nombre del workspace actual.

**Uso**:

```bash
terraform workspace show
```

**Función**: Este comando muestra el nombre del workspace que está actualmente activo. Es útil para verificar en qué workspace se están realizando operaciones.

### 5. `terraform workspace delete <nombre_del_workspace>`

**Descripción**: Elimina un workspace.

**Uso**:

```bash
terraform workspace delete development
```

**Función**: Este comando elimina el workspace especificado. No se puede eliminar el workspace actual, por lo que es necesario cambiar a otro workspace (como `default`) antes de eliminar. Este comando elimina todos los estados y configuraciones asociados con el workspace eliminado.


## Conclusión

Los comandos de Terraform workspace permiten gestionar múltiples entornos de manera eficiente dentro de un solo directorio de configuración. Esto facilita la separación de estados y recursos entre diferentes entornos, mejorando la organización y el control de la infraestructura como código.