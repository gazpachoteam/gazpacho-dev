#!/usr/bin/env bash
# ------------------------------------------------------------
# Gazpacho Dev – Backup del event_store (base de eventos)
# Crea un tar.gz con marca de tiempo y lo guarda en BACKUP_DIR.
# Pensado para ejecutarse vía cron o supervisord una vez al día.
# ------------------------------------------------------------
set -euo pipefail

APP_DIR="/var/www/gazpacho-dev"
EVENT_DIR="$APP_DIR/event_store"
BACKUP_DIR="$APP_DIR/backups"
RETENTION_DAYS=30   # borrar copias de más de 30 días

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="$BACKUP_DIR/event_store_$TIMESTAMP.tar.gz"

echo "[Backup] Creando copia $ARCHIVE …"

tar -czf "$ARCHIVE" -C "$APP_DIR" $(basename "$EVENT_DIR")

echo "[Backup] Copia completada."

# Rotación: eliminar archivos antiguos
find "$BACKUP_DIR" -name 'event_store_*.tar.gz' -type f -mtime +$RETENTION_DAYS -print -delete || true

echo "[Backup] Limpieza de copias >$RETENTION_DAYS días completada." 