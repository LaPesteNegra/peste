#!/bin/bash

# Variables
LOG_FILE="/var/log/install_script.log"
SOFTWARE_PACKAGES="curl wget git build-essential"
USER="$(whoami)"

# Función para registrar mensajes
log_message() {
  local message="$1"
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Asegúrate de que el script se ejecute como root
if [ "$(id -u)" -ne "0" ]; then
  echo "Este script debe ser ejecutado como root" 1>&2
  exit 1
fi

# Actualizar la lista de paquetes
log_message "Actualizando la lista de paquetes..."
apt-get update >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
  log_message "Error al actualizar la lista de paquetes."
  exit 1
fi

# Instalar los paquetes necesarios
log_message "Instalando paquetes necesarios: $SOFTWARE_PACKAGES..."
apt-get install -y $SOFTWARE_PACKAGES >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
  log_message "Error al instalar los paquetes."
  exit 1
fi

# Configurar permisos y directorios (si es necesario)
log_message "Configurando permisos y directorios..."
mkdir -p /opt/myapp
chown "$USER" /opt/myapp
chmod 755 /opt/myapp

# Descargar archivos necesarios (si es necesario)
log_message "Descargando archivos necesarios..."
wget -O /opt/myapp/myapp.tar.gz https://example.com/myapp.tar.gz >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
  log_message "Error al descargar el archivo."
  exit 1
fi

# Descomprimir y configurar la aplicación
log_message "Descomprimiendo y configurando la aplicación..."
tar -xzf /opt/myapp/myapp.tar.gz -C /opt/myapp >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
  log_message "Error al descomprimir el archivo."
  exit 1
fi

# Configuración adicional (si es necesario)
log_message "Realizando configuraciones adicionales..."
# Aquí puedes agregar comandos adicionales para configurar tu aplicación

# Finalizar
log_message "Instalación completada con éxito."
echo "Instalación completada con éxito. Revisa el archivo de log en $LOG_FILE para más detalles."
