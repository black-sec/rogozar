#!/bin/bash

# Rogozar Tunnel Setup Script - Multi Tunnel
# Version: v2.1
# @coderman_ir

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

function pause() {
  echo
  read -rp "Press ENTER to continue..."
}
function show_header() {
  clear
  cat << "EOF"
______
| ___ \
| |_/ /___   __ _  ___ ______ _ _ __
|    // _ \ / _ |/ _ \_  / _ | '__|
| |\ \ (_) | (_| | (_) / / (_| | |
\_| \_\___/ \__, |\___/___\__,_|_|
             __/ |
            |___/
EOF
  echo
  echo -e "${GREEN}Welcome to Rogozar Tunnel Setup (Multi Tunnel) | @coderman_ir ${RESET}"
  echo -e "${RED}Version: v2.1 | Github : https://github.com/black-sec/rogozar"
  echo
  echo -e "${GREEN}-----------------------------------------"
  IP=$(hostname -I 2>/dev/null | awk '{print $1}')
  echo -e "IP Server: ${YELLOW}${IP}${RESET}"
  if command -v gost >/dev/null 2>&1; then
    echo -e "Core: ${GREEN}installed${RESET}"
  else
    echo -e "Core: ${RED}uninstalled${RESET}"
  fi
 
  echo -e "${GREEN}-----------------------------------------"
}

function show_menu() {
  show_header
  echo -e "${BLUE}${BOLD}1) Setup Iran-side (Server)${RESET}"
  echo -e "${BLUE}${BOLD}2) Setup Kharej-side (Client)${RESET}"
  echo -e "${RED}${BOLD}3) Manage Tunnels (Edit/Restart/Status)${RESET}"
  echo -e "${WHITE}4) Install gost Core${RESET}"
  echo -e "${WHITE}5) Exit${RESET}"
  echo -ne "${YELLOW}Your choice: ${RESET}"

  read -r choice
}

function install_gost_core() {
  echo -e "${GREEN}Installing gost core...${RESET}"
  bash <(curl -fsSL https://github.com/go-gost/gost/raw/master/install.sh) --install

  if command -v gost >/dev/null 2>&1; then
    echo -e "${GREEN}gost core installed successfully.${RESET}"
  else
    echo -e "${RED}Failed to install gost core.${RESET}"
  fi
  pause
}

function setup_iran_server() {
  echo -n "Enter unique name for this server tunnel (e.g. server1): "
  read -r NAME
  echo -ne "${YELLOW}Enter one or more ports separated by comma (e.g. 443,8080):${RESET} "
  read -r PORT_LIST
  IFS=',' read -ra PORTS <<< "$PORT_LIST"
  PORTARRAY="(${PORTS[*]})"
  SERVICE_NAME="rogozar-server-$NAME"
  CONFIG_PATH="/etc/rogozar/rogozarServer-$NAME.yml"

  mkdir /etc/rogozar
  echo -e "${GREEN}Creating gost config file at $CONFIG_PATH ...${RESET}"
  cat << EOF | sudo tee "$CONFIG_PATH" > /dev/null
services:

- name: service-relay+mwss-0
  addr: :8440
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: mwss
    metadata:
      mux.version: 2
      mux.keepaliveInterval: 5s
      mux.keepaliveTimeout: 15s
      mux.maxFrameSize: 65535
      mux.maxReceiveBuffer: 33554432
      mux.maxStreamBuffer: 8388608

- name: service-relay+mwss-1
  addr: :8441
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: mwss
    metadata:
      mux.version: 2
      mux.keepaliveInterval: 7s
      mux.keepaliveTimeout: 20s
      mux.maxFrameSize: 32768
      mux.maxReceiveBuffer: 25165824
      mux.maxStreamBuffer: 5242880

- name: service-relay+mwss-2
  addr: :8442
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: mwss
    metadata:
      mux.version: 2
      mux.keepaliveInterval: 10s
      mux.keepaliveTimeout: 25s
      mux.maxFrameSize: 16384
      mux.maxReceiveBuffer: 20971520
      mux.maxStreamBuffer: 4194304

- name: service-relay+mwss-3
  addr: :8443
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: mwss
    metadata:
      mux.version: 2
      mux.keepaliveInterval: 12s
      mux.keepaliveTimeout: 30s
      mux.maxFrameSize: 8192
      mux.maxReceiveBuffer: 16777216
      mux.maxStreamBuffer: 3145728

- name: service-relay+mwss-4
  addr: :8444
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: mwss
    metadata:
      mux.version: 2
      mux.keepaliveInterval: 15s
      mux.keepaliveTimeout: 35s
      mux.maxFrameSize: 4096
      mux.maxReceiveBuffer: 12582912
      mux.maxStreamBuffer: 2097152

- name: service-relay+mwss-5
  addr: :8445
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: mwss
    metadata:
      mux.version: 2
      mux.keepaliveInterval: 20s
      mux.keepaliveTimeout: 40s
      mux.maxFrameSize: 2048
      mux.maxReceiveBuffer: 8388608
      mux.maxStreamBuffer: 1048576

- name: service-relay+ssh
  addr: :8446
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: ssh
    metadata:
      authorizedKeyFile: /root/.ssh/rogozar.pub

- name: service-relay+icmp
  addr: :0
  loggers:
  - logger-std
  - logger-all
  handler:
    type: relay
    metadata:
      bind: true
  listener:
    type: icmp

loggers:
- name: logger-std
  log:
    level: info
    format: json
    output: stderr
    rotation:
      maxSize: 100
      maxAge: 7
      maxBackups: 4
      localTime: false
      compress: false
- name: logger-all
  log:
    level: error
    format: json
    output: /etc/rogozar/logs/allLogs
    rotation:
      maxSize: 100
      maxAge: 7
      maxBackups: 4
      localTime: false
      compress: false
EOF

  create_service "$SERVICE_NAME" "$CONFIG_PATH"
  create_hopper "$SERVICE_NAME" "$PORTARRAY"
}


function setup_foreign_client() {
  echo -ne "${YELLOW}Enter Iran server domain or IP:${RESET} "
  read -r IRAN_DOMAIN
  echo -ne "${YELLOW}Enter one or more ports separated by comma (e.g. 443,8080):${RESET} "
  read -r PORT_LIST
  IFS=',' read -ra PORTS <<< "$PORT_LIST"

  echo -ne "${YELLOW}Enter unique name for this tunnel (e.g. home):${RESET} "
  read -r NAME

  mkdir /etc/rogozar
  SERVICE_NAME="rogozar-$NAME"
  CONFIG_PATH="/etc/rogozar/rogozarClient-$NAME.yml"
  SSH_KEY_PATH="/root/.ssh/rogozar"

  echo -e "${YELLOW}Cleaning old SSH keys if exist...${RESET}"
  rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"

  echo -e "${YELLOW}Generating SSH key...${RESET}"
  ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" > /dev/null

  # strip trailing comment (root@host)
  sed -i 's/ [^ ]*$//' "$SSH_KEY_PATH.pub"

  echo
  echo -e "${RED}Please copy the public key below to your Iran server:${RESET}"
  echo
  echo -e "${RED}$(cat "$SSH_KEY_PATH.pub")${RESET}"
  echo
  echo -e "${RED}Upload it to: /root/.ssh/rogozar.pub on your Iran server.${RESET}"
  echo

  echo -e "${YELLOW}Creating gost config...${RESET}"

  # بخش ابتدایی فایل
  cat << EOF | sudo tee "$CONFIG_PATH" > /dev/null
# Auto-generated by Rogozar Script
services:
EOF

  # تولید بخش مربوط به هر پورت
  for PORT in "${PORTS[@]}"; do
    cat << EOF | sudo tee -a "$CONFIG_PATH" > /dev/null
  - name: service-rtcp-$PORT
    addr: :$PORT
    loggers:
    - logger-std
    - logger-all
    handler:
      type: rtcp
    listener:
      type: rtcp
      chain: chain-multitunnel
    forwarder:
      nodes:
      - name: target-$PORT
        addr: :$PORT

  - name: service-rudp-$PORT
    addr: :$PORT
    loggers:
    - logger-std
    - logger-all
    handler:
      type: rudp
    listener:
      type: rudp
      chain: chain-multitunnel
    forwarder:
      nodes:
      - name: target-$PORT
        addr: :$PORT

EOF
  done

  # ادامه پیکربندی بعد از لیست سرویس‌ها
  cat << EOF | sudo tee -a "$CONFIG_PATH" > /dev/null
chains:
- name: chain-multitunnel
  hops:
  - name: hop-0
    selector:
      strategy: fifo
      maxFails: 1
      failTimeout: 60s
    nodes:
    - name: node-mwss-0
      addr: $IRAN_DOMAIN:8440
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: mwss
        metadata:
          mux.version: 2
          mux.keepaliveInterval: 5s
          mux.keepaliveTimeout: 15s
          mux.maxFrameSize: 65535
          mux.maxReceiveBuffer: 33554432
          mux.maxStreamBuffer: 8388608
    - name: node-mwss-1
      addr: $IRAN_DOMAIN:8441
      medatada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: mwss
        metadata:
          mux.version: 2
          mux.keepaliveInterval: 7s
          mux.keepaliveTimeout: 20s
          mux.maxFrameSize: 32768
          mux.maxReceiveBuffer: 25165824
          mux.maxStreamBuffer: 5242880
    - name: node-mwss-2
      addr: $IRAN_DOMAIN:8442
      medatada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: mwss
        metadata:
          mux.version: 2
          mux.keepaliveInterval: 10s
          mux.keepaliveTimeout: 25s
          mux.maxFrameSize: 16384
          mux.maxReceiveBuffer: 20971520
          mux.maxStreamBuffer: 4194304
    - name: node-mwss-3
      addr: $IRAN_DOMAIN:8443
      metadada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: mwss
        metadata:
          mux.version: 2
          mux.keepaliveInterval: 12s
          mux.keepaliveTimeout: 30s
          mux.maxFrameSize: 8192
          mux.maxReceiveBuffer: 16777216
          mux.maxStreamBuffer: 3145728
    - name: node-mwss-4
      addr: $IRAN_DOMAIN:8444
      medatada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: mwss
        metadata:
          mux.version: 2
          mux.keepaliveInterval: 15s
          mux.keepaliveTimeout: 35s
          mux.maxFrameSize: 4096
          mux.maxReceiveBuffer: 12582912
          mux.maxStreamBuffer: 2097152
    - name: node-mwss-5
      addr: $IRAN_DOMAIN:8445
      medatada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: mwss
        metadata:
          mux.version: 2
          mux.keepaliveInterval: 20s
          mux.keepaliveTimeout: 40s
          mux.maxFrameSize: 2048
          mux.maxReceiveBuffer: 8388608
          mux.maxStreamBuffer: 1048576
    - name: node-ssh
      addr: $IRAN_DOMAIN:8446
      medatada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: ssh
        metadata:
          privateKeyFile: $SSH_KEY_PATH
    - name: node-icmp
      addr: $IRAN_DOMAIN:0
      medatada:
        backup: true
      connector:
        type: relay
        metadata:
          nodelay: true
      dialer:
        type: icmp
loggers:
- name: logger-std
  log:
    level: info
    format: json
    output: stderr
    rotation:
      maxSize: 100
      maxAge: 7
      maxBackups: 4
      localTime: false
      compress: false
- name: logger-all
  log:
    level: error
    format: json
    output: /etc/rogozar/logs/allLogs
    rotation:
      maxSize: 100
      maxAge: 7
      maxBackups: 4
      localTime: false
      compress: false
EOF

  create_service "$SERVICE_NAME" "$CONFIG_PATH"
}

function create_service() {
  local SERVICE=$1
  local CONFIG_FILE=$2

  echo -e "${YELLOW}Creating systemd service '$SERVICE'...${RESET}"

  cat << EOF | sudo tee /etc/systemd/system/$SERVICE.service > /dev/null
[Unit]
Description=Rogozar Tunnel - $SERVICE
After=network.target

[Service]
ExecStart=/usr/local/bin/gost -C $CONFIG_FILE
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now "$SERVICE"
  echo -e "${GREEN}Tunnel '$SERVICE' created and started.${RESET}"
  pause
}

function create_hopper() {
  local SERVICE=$1
  local PORT_LIST=$2

  echo -e "${GREEN}Creating hopper"
  cat << EOF | sudo tee /etc/rogozar/porthopper.sh > /dev/null
#!/bin/bash

# Gost's port list from best quality to worst
GOSTPORTS=(8440 8441 8442 8443 8444)

# Connection port list
CONNECTIONPORTS=$PORT_LIST

# Max connection thresholds for each port (customize as needed)
THRESHOLDS=(100 200 500 1000 3000)

# Get number of established connections to a port
get_connection_count() {
    ss -Htan state established "( sport = :\$1 )" | wc -l
}

# Block port using iptables
block_port() {
    local port=\$1
    if ! iptables -C INPUT -p tcp --dport "\$port" -j REJECT &>/dev/null; then
        echo "Blocking port \$port"
        iptables -I INPUT -p tcp --dport "\$port" -j REJECT
        systemctl restart $SERVICE
    fi
}

# Unblock port using iptables
unblock_port() {
    local port=\$1
    if iptables -C INPUT -p tcp --dport "\$port" -j REJECT &>/dev/null; then
        echo "Unblocking port \$port"
        iptables -D INPUT -p tcp --dport "\$port" -j REJECT
        systemctl restart $SERVICE
    fi
}

# Control logic
while true; do

    echo "[\$(date)] Checking gost port load..."
    conn_count=0

    for i in "\${!CONNECTIONPORTS[@]}"; do
        connport=\${CONNECTIONPORTS[\$i]}
        port_connection_count=\$(get_connection_count "\$connport")
        (( conn_count += \$port_connection_count ))
    done

    echo "Number of current connections: \$conn_count"

    for i in "\${!GOSTPORTS[@]}"; do
        gostport=\${GOSTPORTS[\$i]}
        threshold=\${THRESHOLDS[\$i]}

        if (( conn_count > threshold )); then
            echo "Port \$gostport threshold: \$threshold"
            block_port "\$gostport"
        else
            echo "Port \$gostport threshold: \$threshold"
            unblock_port "\$gostport"
        fi
    done

    echo "[\$(date)] Waiting 60 seconds before next check..."
    sleep 60

done
EOF
  cat << EOF | sudo tee /etc/systemd/system/rogozar-port-hopper.service > /dev/null
[Unit]
Description=Gost Port Manager Script
After=network.target

[Service]
ExecStart=/etc/rogozar/porthopper.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

  sudo chmod +x /etc/rogozar/porthopper.sh
  sudo systemctl daemon-reload
  sudo systemctl start "rogozar-port-hopper"
  sudo systemctl enable "rogozar-port-hopper"
  echo -e "${GREEN}Service 'rogozar-port-hopper' created and started.${RESET}"
  pause
}

function manage_tunnels() {
  mapfile -t services < <(ls /etc/systemd/system | grep '^rogozar-.*\.service' | sed 's/\.service$//')

  if [ ${#services[@]} -eq 0 ]; then
    echo -e "${RED}No rogozar services found.${RESET}"
    pause
    return
  fi

  echo "Available tunnels:"
  for i in "${!services[@]}"; do
    echo "$((i+1))) ${services[$i]}"
  done

  echo -n "Select a tunnel to manage (1-${#services[@]}): "
  read -r index

  if ! [[ "$index" =~ ^[0-9]+$ ]] || [ "$index" -lt 1 ] || [ "$index" -gt "${#services[@]}" ]; then
    echo -e "${RED}Invalid selection.${RESET}"
    pause
    return
  fi

  SERVICE="${services[$((index-1))]}"
  CONFIG_FILE_CLIENT="/etc/rogozar/rogozarClient-${SERVICE#rogozar-}.yml"
  CONFIG_FILE_SERVER="/etc/rogozar/rogozarServer-${SERVICE#rogozar-server-}.yml"
  SERVICE_FILE="/etc/systemd/system/${SERVICE}.service"

  echo
  echo "1) View Config"
  echo "2) Edit Config (nano)"
  echo "3) Restart Tunnel"
  echo "4) Disable Tunnel (stop)"
  echo "5) Enable Tunnel (start)"
  echo "6) Show Status"
  echo "7) Delete Tunnel"
  echo "8) Back"
  echo -n "Your choice: "
  read -r action

  case $action in
    1)
      if [ -f "$CONFIG_FILE_CLIENT" ]; then
        cat "$CONFIG_FILE_CLIENT"
      elif [ -f "$CONFIG_FILE_SERVER" ]; then
        cat "$CONFIG_FILE_SERVER"
      else
        echo -e "${RED}Config file not found.${RESET}"
      fi
      pause
      ;;
    2)
      BACKUP_FILE="/etc/rogozar/backups/$(basename "$CONFIG_FILE_CLIENT" .yml)-$(date +%s).yml"
      if [ -f "$CONFIG_FILE_CLIENT" ]; then
        cp "$CONFIG_FILE_CLIENT" "$BACKUP_FILE"
        nano "$CONFIG_FILE_CLIENT"
      elif [ -f "$CONFIG_FILE_SERVER" ]; then
        BACKUP_FILE="/etc/rogozar/backups/$(basename "$CONFIG_FILE_SERVER" .yml)-$(date +%s).yml"
        cp "$CONFIG_FILE_SERVER" "$BACKUP_FILE"
        nano "$CONFIG_FILE_SERVER"
      else
        echo -e "${RED}Config file not found.${RESET}"
      fi
      pause
      ;;
    3)
      sudo systemctl restart "$SERVICE"
      echo -e "${GREEN}Restarted.${RESET}"
      pause
      ;;
    4)
      sudo systemctl stop "$SERVICE"
      echo -e "${YELLOW}Stopped.${RESET}"
      pause
      ;;
    5)
      sudo systemctl start "$SERVICE"
      echo -e "${GREEN}Started.${RESET}"
      pause
      ;;
    6)
      sudo systemctl status "$SERVICE" --no-pager
      pause
      ;;
    7)
      read -p "Are you sure you want to delete the tunnel '$SERVICE'? [y/N]: " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo systemctl stop "$SERVICE"
        sudo systemctl disable "$SERVICE"
        sudo rm -f "$SERVICE_FILE"
        sudo systemctl daemon-reload
        echo -e "${RED}Service file deleted.${RESET}"

        if [ -f "$CONFIG_FILE_CLIENT" ]; then
          sudo rm -f "$CONFIG_FILE_CLIENT"
          echo -e "${RED}Client config deleted.${RESET}"
        fi

        if [ -f "$CONFIG_FILE_SERVER" ]; then
          sudo rm -f "$CONFIG_FILE_SERVER"
          echo -e "${RED}Server config deleted.${RESET}"
        fi
      else
        echo "Deletion cancelled."
      fi
      pause
      ;;
    8) return ;;
    *)
      echo -e "${RED}Invalid choice.${RESET}"
      pause
      ;;
  esac
}


# Main loop
while true; do
  show_menu
  case $choice in
    1) setup_iran_server ;;
    2) setup_foreign_client ;;
    3) manage_tunnels ;;
    4) install_gost_core ;;
    5) exit 0 ;;
    *) echo "Invalid choice. Please enter 1–5." ; pause ;;
  esac
done
