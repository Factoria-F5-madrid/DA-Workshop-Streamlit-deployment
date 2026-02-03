# 🚀 Streamlit ML App - Despliegue con Docker

# API CRUD con Django y Django REST Framework

## Índice

1. [Introducción](#introducción)
2. [Requisitos Previos](#requisitos-previos)
3. [Configuración del Proyecto](#configuración-del-proyecto)
4. [Dockerization](#dockerization)
5. [Creación del Modelo](#creación-del-modelo)
6. [Implementación del Serializador](#implementación-del-serializador)
7. [Creación de Vistas API](#creación-de-vistas-api)
8. [Configuración de URLs](#configuración-de-urls)
9. [Prueba de la API](#prueba-de-la-api)
10. [Mejores Prácticas](#mejores-prácticas)
11. [Recursos Adicionales](#recursos-adicionales)

## Requisitos Previos

- Python 3.8+
- pip (gestor de paquetes de Python)
- Docker and Docker Compose
- Workbench instalado para hacer pruebas en local de ser necesario

## Clona la Rama `simple-rest-CRUD`

```bash
git clone -b django-restf-deploy --single-branch https://github.com/Factoria-F5-madrid/Python_Deployment_Automate.git
```

### Estructura de carpetas
```plaintext

DA-Workshop-Streamlit-deployment/ # Carpeta donde guardas tu proyecto
│
├── .dockerignore
├── .gitignore
├── app.py
├── dashboard.py
├── docker-compose.yml
├── Dockerfile
├── modelo_regresion.pkl
├── post.pkl
├── README.md
├── Regression_model_pkl.ipynb
├── requirements.txt
```


### Al abrir el proyecto:

Crear el entorno virtual
```bash
python -m venv .venv
```

Iniciar el entorno virtual

linux o bash
```bash
source .venv/Scripts/activate
```
mac
```bash
source .venv/bin/activate
```
windows o CMD
```bash
.venv/Scripts/activate
```
Instalar las dependencias necesarias con tu archivo reu¿quirements.txt

```bash
 pip install -r requirements.txt
```

## Cuentas necesaria
 - Crea una cuenta en [Docker hub](https://www.docker.com/products/docker-hub/) para subir imágenes de docker públicas - como un github pero de imágenes de docker -

## Dockerización

### Configuración

1. **Crear un archivo llamado `Dockefile` en la raíz del proyecto:**:

```dockerfile
# Establece la imagen base para el contenedor
# python:3.12-slim es una versión ligera de Python 3.12 basada en Debian
# "slim" significa que incluye solo los paquetes esenciales, reduciendo el tamaño de la imagen
FROM python:3.12-slim

# Define el directorio de trabajo dentro del contenedor
# Todas las operaciones posteriores se ejecutarán desde esta ubicación
# Si el directorio no existe, Docker lo creará automáticamente
WORKDIR /app

# Copia el archivo requirements.txt desde el directorio local (host) 
# al directorio actual del contenedor (/app)
# El punto (.) significa "directorio actual" que es /app debido a WORKDIR
COPY requirements.txt .

# Ejecuta el comando pip install dentro del contenedor
# --no-cache-dir evita que pip guarde archivos de caché, reduciendo el tamaño de la imagen
# -r requirements.txt instala todas las dependencias listadas en el archivo
# Esta línea se ejecuta durante la construcción de la imagen (build time)
RUN pip install --no-cache-dir -r requirements.txt

# Copia todos los archivos y directorios del proyecto local 
# al directorio /app del contenedor
# El primer punto (.) se refiere al directorio actual en el host
# El segundo punto (.) se refiere al directorio actual en el contenedor (/app)
COPY . .

# Informa que el contenedor escuchará en el puerto 8000
# NOTA: Esto es solo documentación, no abre realmente el puerto
# Para acceder desde el host, necesitas mapear el puerto con -p en docker run
EXPOSE 8000

# Define el comando por defecto que se ejecutará cuando se inicie el contenedor
# streamlit run: comando para ejecutar una aplicación Streamlit
# app.py: archivo Python que contiene la aplicación Streamlit
# --server.port=8000: configura Streamlit para usar el puerto 8000
# --server.address=0.0.0.0: permite conexiones desde cualquier dirección IP (no solo localhost)
# --server.headless=true: ejecuta Streamlit en modo headless (sin interfaz gráfica local)
CMD ["streamlit", "run", "app.py", "--server.port=8000", "--server.address=0.0.0.0", "--server.headless=true"]
```


2. **Crear un archivo llamado `docker-compose.yml` en la raíz del proyecto:**:

```yml
# Especifica la versión del formato de archivo Docker Compose a utilizar
# La versión 3.8 es compatible con Docker Engine 19.03.0+ y soporta todas las características modernas
version: '3.8'

# Define la sección donde se declaran todos los contenedores (servicios) de la aplicación
# Cada servicio representa un contenedor que formará parte de la aplicación multi-contenedor
services:

  # Define el primer servicio llamado "app"
  # Este nombre se usará como hostname interno entre contenedores
  app:
    # Indica que debe construir la imagen desde el Dockerfile en el directorio actual
    # El punto (.) se refiere al directorio donde está ubicado el docker-compose.yml
    build: .
    
    # Mapea puertos entre el host y el contenedor
    # Formato: "puerto_host:puerto_contenedor"
    # El puerto 8000 del host se conectará al puerto 8000 del contenedor
    ports:
      - "8000:8000"
    
    # Sobrescribe el comando CMD definido en el Dockerfile
    # Ejecuta la aplicación Streamlit con configuración específica para este servicio
    # streamlit run app.py: ejecuta el archivo app.py con Streamlit
    # --server.port=8000: configura el puerto interno del contenedor
    # --server.address=0.0.0.0: acepta conexiones desde cualquier IP
    # --server.headless=true: modo sin interfaz gráfica (apropiado para contenedores)
    command: ["streamlit", "run", "app.py", "--server.port=8000", "--server.address=0.0.0.0", "--server.headless=true"]

  # Define el segundo servicio llamado "dashboard"
  # Este servicio ejecutará la aplicación dashboard en paralelo con "app"
  dashboard:
    # Construye la imagen usando el mismo Dockerfile que el servicio "app"
    # Docker Compose reutilizará la imagen si ya fue construida
    build: .
    
    # Mapea el puerto 8001 del host al puerto 8001 del contenedor dashboard
    # Esto permite acceder a ambos servicios simultáneamente en puertos diferentes
    ports:
      - "8001:8001"
    
    # Comando específico para ejecutar dashboard.py en lugar de app.py
    # Usa el puerto 8001 para evitar conflictos con el servicio "app"
    # El resto de parámetros son idénticos para mantener consistencia
    command: ["streamlit", "run", "dashboard.py", "--server.port=8001", "--server.address=0.0.0.0", "--server.headless=true"]
```

3. **Construir y ejecutar los contenedores:**

```bash
docker-compose up --build -d
```

Este comando construirá la imagen de Docker para el servicio app y dashboard e iniciará el contenedor.

### Comandos útiles de Docker

```bash
# Ver logs de los contenedores
docker-compose logs

# Ver logs específicos del servicio web
docker-compose logs web

# Detener los contenedores
docker-compose down

# Detener y eliminar volúmenes (cuidado: esto borrará los datos de la base de datos)
docker-compose down -v

# Reconstruir solo el servicio web
docker-compose build web
```

## Deployment a Docker Hub y Render

### Subir imagen a Docker Hub manualmente

### Desplegar en Docker Hub y Render

Estos son los pasos para construir tu imagen de Docker, subirla a Docker Hub y luego poder usarla en servicios como Render.

1.  **Construir la imagen Docker:**
    Este comando utiliza el `Dockerfile` en el directorio actual (`.`) para construir una nueva imagen.
    - `-t alexandrazambrano/streamlit-dashboard:latest`: Asigna un "tag" o etiqueta a la imagen. El formato es `tu-usuario/nombre-de-la-imagen:version`. Esto la prepara para subirla a tu repositorio en Docker Hub.

    ```bash
    docker build -t <tu-usuario>/<nombre-de-la-imagen>:<version> .
    ```

2.  **Hacer login en Docker Hub:**
    Inicia sesión en tu cuenta de Docker Hub. Necesitarás reemplazar `<username>` con tu nombre de usuario. Es un requisito para poder subir imágenes.

    ```bash
    docker login -u <username>
    ```

3.  **Subir la imagen a Docker Hub:**
    Este comando publica la imagen que construiste en el repositorio de Docker Hub que especificaste con el tag. Una vez subida, estará disponible públicamente (o de forma privada, según la configuración de tu repositorio).

    ```bash
    docker push <tu-usuario>/<nombre-de-la-imagen>:<version>
    ```

4.  **Verificar localmente:**
    Este comando te permite confirmar que la imagen se ha creado correctamente en tu máquina local.
    - `docker images`: Lista todas las imágenes en tu sistema.
    - `| grep alexandrazambrano`: Filtra la lista para mostrar solo las imágenes que contienen "alexandrazambrano" en su nombre. (Nota: en Windows, puedes usar `findstr` en lugar de `grep`).

    ```bash
    docker images | grep alexandrazambrano
    ```

### Subir imagen a Render
1. Creamos un servicio en Render

![crear servicio en render](./assets/image-1.png)
2. Agregaos la imagen de nuestro dockerhub

![render imagen docker](./assets/image-2.png)

Ve a tu hub en docker hub, para eso, primero en cuentra la imágen con la letra de tu nombre o username, navega a tu perfil y allí verás esta vista:

![alt text](./assets/image-3.png)

entramos a nuestra imagen:

![alt text](./assets/image-4.png)

Buscamos la vista pública:

![alt text](./assets/image-6.png)

copiamos el nombre de nuestra imagen y su etiqueta:

![alt text](./assets/dockerhub-image-link.png)

Agregamos nuestra imagen:

![alt text](./assets/image-5.png)
3. configuramos render:

Mantenemos las configuraciones, pero si quieres puedes cambiar el combre:

![alt text](./assets/image-8.png)

Bajamos un poco más, y seleccionamos el plan gratuito:

![alt text](./assets/image-10.png)

Agregamos nuestras variables de entorno:

![alt text](./assets/image-11.png)

Iniciamos el deploy:

![alt text](./assets/deploy-render.PNG)

¡Y listo! Ahora solo nos queda automatizar, ya casi lo tenemos 😉💜