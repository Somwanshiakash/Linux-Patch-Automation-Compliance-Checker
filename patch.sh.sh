#!/bin/bash

LOG_FILE="logs/patch.log"
REPORT_FILE="reports/patch_report.txt"

mkdir -p logs reports
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "----------------------------------------" >> $LOG_FILE
echo "$DATE | Patch Automation Started" >> $LOG_FILE

# Detect OS type
if [ -f /etc/debian_version ]; then
    OS="DEBIAN"
elif [ -f /etc/redhat-release ]; then
    OS="REDHAT"
else
    echo "$DATE | ERROR | Unsupported OS" >> $LOG_FILE
    exit 1
fi

echo "$DATE | INFO | OS Detected: $OS" >> $LOG_FILE

# ---------------- UPDATE PROCESS ----------------
if [ "$OS" == "DEBIAN" ]; then
    apt update -y >> $LOG_FILE 2>&1
    apt upgrade -y >> $LOG_FILE 2>&1
elif [ "$OS" == "REDHAT" ]; then
    yum update -y >> $LOG_FILE 2>&1
fi

# ---------------- REBOOT CHECK ----------------
REBOOT_REQUIRED="NO"

if [ "$OS" == "DEBIAN" ] && [ -f /var/run/reboot-required ]; then
    REBOOT_REQUIRED="YES"
elif [ "$OS" == "REDHAT" ]; then
    needs-restarting -r >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        REBOOT_REQUIRED="YES"
    fi
fi

# ---------------- REPORT ----------------
echo "Patch Report - $DATE" > $REPORT_FILE
echo "OS Type          : $OS" >> $REPORT_FILE
echo "Reboot Required  : $REBOOT_REQUIRED" >> $REPORT_FILE

echo "$DATE | INFO | Reboot Required: $REBOOT_REQUIRED" >> $LOG_FILE
echo "$DATE | Patch Automation Completed" >> $LOG_FILE
