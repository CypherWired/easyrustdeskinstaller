#!/bin/bash

#################################################
#            EASY RUSTDESK INSTALLER            #
#                 by CypherWire                 #
#################################################
#                                               #
#      This script automates various tasks      #
#  during the installation of Rustdesk Server.  #
#                                               #
#             Script possible thanks            #
#               to RustdeskInstall              #
#                                               #
#  https://github.com/techahold/rustdeskinstall #
#                                               #
#################################################

### FUNCTIONS ###

# Downloads and installs Rustdesk Server #
installer() {
if [ -f "install.sh" ]; then
        rm "install.sh"
fi
if ! grep -q "rustdesk-server" /etc/hosts; then
        echo "127.0.0.1 rustdesk-server" | sudo tee -a /etc/hosts > /dev/null
fi
wget https://raw.githubusercontent.com/dinger1986/rustdeskinstall/master/install.sh 2>/dev/null
chmod +x install.sh
./install.sh
clear
rm "install.sh"
echo Configuring UFW...
ufw allow 21115:21119/tcp
ufw allow 21116/udp
echo Done.
}

# Shows state of both Signal Server (hbbs) and Relay Server (hbbr) #
state() {
clear
echo ------------------- SIGNAL -----------------------
echo
systemctl status rustdesksignal.service --no-pager
echo
echo ------------------- RELAY ------------------------
echo
systemctl status rustdeskrelay.service --no-pager
echo
echo --------------------------------------------------
}

# Downloads the updater and runs it #
auto-upd() {
if [ -f "update.sh" ]; then
        rm "update.sh"
fi
echo Installing updater...
wget https://raw.githubusercontent.com/dinger1986/rustdeskinstall/master/update.sh 2>/dev/null
chmod +x update.sh
./update.sh
rm "update.sh"
echo Rustdesk updated
}

# Downloads Portable Windows Rustdesk Client and configures it to work with the server automatically #
auto-client() {
if [ -f rustdesk-host* ]; then
        rm -f rustdesk-host*
        echo Old client deleted.
fi
read -p "Introduce the IP/Domain from RustDesk: " DOMAIN
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep "browser_download_url.*x86_64.exe" | cut -d '"' -f 4)
CLIENTNAME=$(basename "$DOWNLOAD_URL")
KEYNAME=$(cat /opt/rustdesk/*.pub 2>/dev/null)
wget "$DOWNLOAD_URL" 2>/dev/null
mv "$CLIENTNAME" "rustdesk-host=$DOMAIN,key=$KEYNAME.exe"
echo Client "rustdesk-host=$DOMAIN,key=$KEYNAME.exe" created.
}

# Menu #
menu() {
clear
cat << "EOF"

╔═════════════════════════════════════════╗
║          EASY RUSTDESK INSTALLER        ║
║               by CypherWire             ║
╚═════════════════════════════════════════╝

1. Install service.
2. Update service.
3. Automatic Portable Client.
4. See Rustdesk Status.
0. Exit.

EOF
}



while true; do
    menu

read -p "Select option: " option

    case $option in
        1)
                installer
                ;;
        2)
                auto-upd
                ;;
        3)
                auto-client
                ;;
        4)
                state
                ;;
        0)
                echo "Bye!"
                clear
                exit 0
                ;;
        *)
                echo "Invalid Option"
                ;;
    esac
echo
    read -p "Press ENTER to continue"
done
