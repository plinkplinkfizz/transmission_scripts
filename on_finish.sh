#!/usr/bin/env bash

# First add the user transmission to sudoers
# `echo "transmission  ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/transmission


REMOTE_ADDR="localhost"
MOVE_DIR="/home/username/Downloads"
LOG_FILE="$HOME/log.txt"
CHANGED_OWNER="username"
CHANGED_GROUP="groupname"


echo "[i] Running script for: $TR_TORRENT_NAME" >> "$LOG_FILE"
TRANSMISSION_DATA=$(transmission-remote "$REMOTE_ADDR" -t"$TR_TORRENT_HASH" --stop -v)

if echo "$TRANSMISSION_DATA" | grep -q "responded: \"success\""; then
  #only if stopped successfully
  echo "[i] Torrent stopped!" >> "$LOG_FILE"
  echo "[i] Attempting to move contents" >> "$LOG_FILE"
else
  echo "[e] Failed to stop torrent!" >> "$LOG_FILE"
  exit;
fi

sudo mv "$TR_TORRENT_DIR/$TR_TORRENT_NAME" "$MOVE_DIR"
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "[e] Moving directory failed!" >> "$LOG_FILE"
  exit;
fi
echo "[i] Directory moved to destination!" >> "$LOG_FILE"

sudo chown -R $CHANGED_OWNER "$MOVE_DIR/$TR_TORRENT_NAME"
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "[w] Failed changing owner to $CHANGED_OWNER!" >> "$LOG_FILE"
fi
echo "Changed owner!" >> "$LOG_FILE"

sudo chgrp -R $CHANGED_GROUP "$MOVE_DIR/$TR_TORRENT_NAME"
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "[w] Failed to change group to $CHANGED_GROUP!" >> "$LOG_FILE"
fi
echo "Changed group!" >> "$LOG_FILE"

sudo -u "$CHANGED_OWNER" restorecon -R "$MOVE_DIR/$TR_TORRENT_NAME"
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "[w] Failed to change access with restorecon!" >> "$LOG_FILE"
fi
echo "Changed selinux access-level!" >> "$LOG_FILE"
