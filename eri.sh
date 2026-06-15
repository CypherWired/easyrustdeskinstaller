#!/bin/bash

# =========================================================
#            EASY RUSTDESK INSTALLER                      #
#                     by CypherWire                       #
# =========================================================

# --- CONFIG and VARIABLES ---
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/dinger1986/rustdeskinstall/master/install.sh"
UPDATE_SCRIPT_URL="https://raw.githubusercontent.com/dinger1986/rustdeskinstall/master/update.sh"
RUSTDESK_DIR="/opt/rustdesk"
GITHUB_API_URL="https://api.github.com/repos/rustdesk/rustdesk/releases/latest"

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- UTILITY FUNCTIONS ---
print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)."
        exit 1
    fi
}

check_dependencies() {
    local deps=("wget" "curl" "systemctl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_error "Required dependency '$dep' is not installed."
            exit 1
        fi
    done
}

pause() {
    echo ""
    read -p "Press Enter to continue..."
}

# --- MAIN FUNCTIONS ---

installer() {
    clear
    print_info "Starting RustDesk Server installation..."

    # Check if already installed
    if systemctl list-unit-files | grep -q "rustdesksignal.service"; then
        print_warning "RustDesk service seems to be already installed."
        read -p "Do you want to reinstall/overwrite? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    # Add to hosts if not present
    if ! grep -q "rustdesk-server" /etc/hosts; then
        print_info "Adding rustdesk-server to /etc/hosts..."
        echo "127.0.0.1 rustdesk-server" | tee -a /etc/hosts > /dev/null
    fi

    # Download installer
    print_info "Downloading installation script..."
    if ! wget -q -O install.sh "$INSTALL_SCRIPT_URL"; then
        print_error "Failed to download install.sh. Check your internet connection."
        return
    fi
    chmod +x install.sh

    # Run installer
    print_info "Executing installation script (this may take a while)..."
    ./install.sh
    local exit_code=$?

    # Cleanup
    rm -f install.sh

    if [ $exit_code -eq 0 ]; then
        print_success "Installation script finished."

        # Configure UFW if available
        if command -v ufw &> /dev/null; then
            print_info "Configuring UFW firewall..."
            ufw allow 21115:21119/tcp > /dev/null
            ufw allow 21116/udp > /dev/null
            print_success "UFW rules added."
        else
            print_warning "UFW not found. Please configure your firewall manually."
            print_info "Required ports: 21115-21119/TCP, 21116/UDP"
        fi
    else
        print_error "Installation script failed with exit code $exit_code."
    fi
}

state() {
    clear
    echo -e "${CYAN}==================== RUSTDESK STATUS ====================${NC}"

    if ! systemctl list-unit-files | grep -q "rustdesksignal.service"; then
        print_warning "RustDesk services are not installed."
        return
    fi

    echo -e "\n${YELLOW}--- Signal Server (hbbs) ---${NC}"
    systemctl status rustdesksignal.service --no-pager

    echo -e "\n${YELLOW}--- Relay Server (hbbr) ---${NC}"
    systemctl status rustdeskrelay.service --no-pager

    echo -e "\n${CYAN}=======================================================${NC}"
}

auto_upd() {
    clear
    print_info "Starting RustDesk update..."

    if ! systemctl list-unit-files | grep -q "rustdesksignal.service"; then
        print_error "RustDesk is not installed. Please install it first."
        return
    fi

    print_info "Downloading update script..."
    if ! wget -q -O update.sh "$UPDATE_SCRIPT_URL"; then
        print_error "Failed to download update.sh."
        return
    fi
    chmod +x update.sh

    print_info "Executing update script..."
    ./update.sh
    local exit_code=$?

    rm -f update.sh

    if [ $exit_code -eq 0 ]; then
        print_success "RustDesk updated successfully."
    else
        print_error "Update failed with exit code $exit_code."
    fi
}

auto_client() {
    clear
    print_info "Generating pre-configured Windows client..."

    if [ ! -d "$RUSTDESK_DIR" ]; then
        print_error "RustDesk directory not found. Is the server installed?"
        return
    fi

    # Cleanup old clients
    if ls rustdesk-host* 1> /dev/null 2>&1; then
        print_info "Deleting old pre-configured clients..."
        rm -f rustdesk-host*
    fi

    # Get Domain/IP
    read -p "Enter the IP or Domain for the RustDesk server: " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_error "Domain/IP cannot be empty."
        return
    fi

    # Get Public Key
    local key_file=$(ls "$RUSTDESK_DIR"/*.pub 2>/dev/null | head -n1)
    local key_name=""
    if [[ -f "$key_file" ]]; then
        key_name=$(cat "$key_file")
        print_info "Found public key."
    else
        print_warning "No public key found. The client will be generated without a key (less secure)."
    fi

    # Download latest Windows client
    print_info "Fetching latest Windows client URL from GitHub..."
    # Added head -n 1 to ensure we only get one URL in case of multiple matches
    local download_url=$(curl -s "$GITHUB_API_URL" | grep "browser_download_url.*x86_64.exe" | head -n 1 | cut -d '"' -f 4)

    if [[ -z "$download_url" ]]; then
        print_error "Failed to find the latest Windows client URL."
        return
    fi

    local client_name=$(basename "$download_url")
    print_info "Downloading $client_name..."

    if ! wget -q -O "$client_name" "$download_url"; then
        print_error "Failed to download the client."
        return
    fi

    # Rename client
    local new_name="rustdesk-host=${DOMAIN}"
    if [[ -n "$key_name" ]]; then
        new_name="${new_name},key=${key_name}.exe"
    else
        new_name="${new_name}.exe"
    fi

    mv "$client_name" "$new_name"
    print_success "Client created: ${GREEN}$new_name${NC}"
}

genkey() {
    clear
    print_info "Generating new RustDesk keys..."

    if [ ! -d "$RUSTDESK_DIR" ]; then
        print_error "RustDesk directory not found."
        return
    fi

    # Stop services to avoid file locks
    print_info "Stopping RustDesk services..."
    systemctl stop rustdesksignal.service 2>/dev/null
    systemctl stop rustdeskrelay.service 2>/dev/null

    cd "$RUSTDESK_DIR" || exit

    # Backup old keys instead of deleting immediately
    if ls id_* *.pub 1> /dev/null 2>&1; then
        local backup_dir="keys_backup_$(date +%Y%m%d_%H%M%S)"
        print_info "Backing up old keys to $backup_dir..."
        mkdir -p "$backup_dir"
        mv id_* *.pub "$backup_dir/" 2>/dev/null
    fi

    print_info "Generating new keys (this may take a few seconds)..."
    # Run hbbs to generate keys
    ./hbbs > /dev/null 2>&1 &
    local hbbs_pid=$!

    # Wait for key generation
    local counter=0
    while [ ! -f *.pub ] && [ $counter -lt 15 ]; do
        sleep 1
        counter=$((counter + 1))
    done

    kill $hbbs_pid 2>/dev/null
    wait $hbbs_pid 2>/dev/null

    local pub_file=$(ls *.pub 2>/dev/null | head -n1)
    if [[ -f "$pub_file" ]]; then
        local new_key=$(cat "$pub_file")
        print_success "New keys generated successfully!"
        echo -e "${CYAN}Public Key:${NC} $new_key"

        # Restart services
        print_info "Restarting RustDesk services..."
        systemctl start rustdesksignal.service
        systemctl start rustdeskrelay.service
    else
        print_error "Failed to generate new keys."
        # Restart services even if failed
        systemctl start rustdesksignal.service
        systemctl start rustdeskrelay.service
    fi
}

menu() {
    clear
    echo -e "${NC}EASY RUSTDESK INSTALLER${NC}$"
    echo -e "by CypherWire"
    echo ""
    echo -e "  ${YELLOW}1)${NC} Install RustDesk Server"
    echo -e "  ${YELLOW}2)${NC} Update RustDesk Server"
    echo -e "  ${YELLOW}3)${NC} Generate Pre-configured Windows Client"
    echo -e "  ${YELLOW}4)${NC} View RustDesk Services Status"
    echo -e "  ${YELLOW}5)${NC} Regenerate Server Keys"
    echo -e "  ${YELLOW}0)${NC} Exit"
    echo ""
}

# --- MAIN ---
check_root
check_dependencies

while true; do
    menu
    read -p "$(echo -e ${CYAN}Select an option [0-5]:${NC} )" option
    echo ""

    case $option in
        1) installer ;;
        2) auto_upd ;;
        3) auto_client ;;
        4) state ;;
        5) genkey ;;
        0)
            print_success "Exiting. Goodbye!"
            clear
            exit 0
            ;;
        *)
            print_error "Invalid option. Please select 0-5."
            ;;
    esac

    pause
done
