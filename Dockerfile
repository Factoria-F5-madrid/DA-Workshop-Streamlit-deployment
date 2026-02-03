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