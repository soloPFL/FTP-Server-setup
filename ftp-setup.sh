#!/bin/bash

# Funktion zur Installation des FTP-Servers
install_ftp_server() {
    echo "Installiere vsftpd..."
    sudo apt-get update
    sudo apt-get install vsftpd -y
    echo "vsftpd installiert."
}

# Funktion zur Installation von Snapd
install_snapd() {
    if ! command -v snap &>/dev/null; then
        echo "Snapd ist nicht installiert. Installiere Snapd..."
        sudo apt-get install snapd -y
        echo "Snapd installiert."
    else
        echo "Snapd ist bereits installiert."
    fi
}

# Funktion zur Installation von Certbot über Snap
install_certbot() {
    install_snapd
    echo "Installiere Certbot über Snap..."
    sudo snap install core
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    echo "Certbot installiert."
}

# Funktion zum Starten des FTP-Servers
start_ftp_server() {
    echo "Starte vsftpd..."
    sudo systemctl start vsftpd
    echo "vsftpd gestartet."
}

# Funktion zum Stoppen des FTP-Servers
stop_ftp_server() {
    echo "Stoppe vsftpd..."
    sudo systemctl stop vsftpd
    echo "vsftpd gestoppt."
}

# Funktion zum Neustarten des FTP-Servers
restart_ftp_server() {
    echo "Starte vsftpd neu..."
    sudo systemctl restart vsftpd
    echo "vsftpd neu gestartet."
}

# Funktion zum Anlegen eines neuen FTP-Benutzers
create_ftp_user() {
    USERNAME=$1
    PASSWORD=$2
    HOME_DIR="/home/$USERNAME"

    echo "Erstelle Benutzer $USERNAME..."
    sudo useradd -m $USERNAME
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    sudo chown root:root $HOME_DIR
    sudo chmod a-w $HOME_DIR
    mkdir $HOME_DIR/files
    sudo chown $USERNAME:$USERNAME $HOME_DIR/files

    echo "Benutzer $USERNAME erstellt."
}

# Funktion zum Löschen eines FTP-Benutzers
delete_ftp_user() {
    USERNAME=$1

    echo "Lösche Benutzer $USERNAME..."
    sudo userdel -r $USERNAME
    echo "Benutzer $USERNAME gelöscht."
}

# Funktion zum Anlegen einer Freigabe für einen Benutzer
create_ftp_share() {
    USERNAME=$1
    SHARE_NAME=$2
    SHARE_DIR="/home/$USERNAME/files/$SHARE_NAME"

    echo "Erstelle Freigabe $SHARE_NAME für Benutzer $USERNAME..."
    mkdir -p $SHARE_DIR
    sudo chown $USERNAME:$USERNAME $SHARE_DIR
    echo "Freigabe $SHARE_NAME erstellt."
}

# Funktion zum Löschen einer Freigabe für einen Benutzer
delete_ftp_share() {
    USERNAME=$1
    SHARE_NAME=$2
    SHARE_DIR="/home/$USERNAME/files/$SHARE_NAME"

    echo "Lösche Freigabe $SHARE_NAME für Benutzer $USERNAME..."
    sudo rm -r $SHARE_DIR
    echo "Freigabe $SHARE_NAME gelöscht."
}

# Funktion zur Konfiguration des FTP-Servers
configure_ftp_server() {
    CONFIG_FILE="/etc/vsftpd.conf"
    BACKUP_FILE="/etc/vsftpd.conf.bak"

    echo "Sichere die aktuelle Konfigurationsdatei..."
    sudo cp $CONFIG_FILE $BACKUP_FILE

    echo "Konfiguriere vsftpd..."

    # Frage nach den gewünschten Einstellungen
    read -p "Schreibzugriff aktivieren (yes/no): " WRITE_ENABLE
    read -p "Lokalen Benutzerzugriff aktivieren (yes/no): " LOCAL_ENABLE
    read -p "Benutzerisolation aktivieren (yes/no): " CHROOT_LOCAL_USER
    read -p "Passiven Modus aktivieren (yes/no): " PASV_ENABLE
    read -p "SSL aktivieren (yes/no): " SSL_ENABLE

    # Aktualisiere die Konfigurationsdatei
    sudo sed -i "s/^write_enable=.*/write_enable=$WRITE_ENABLE/" $CONFIG_FILE
    sudo sed -i "s/^local_enable=.*/local_enable=$LOCAL_ENABLE/" $CONFIG_FILE
    sudo sed -i "s/^chroot_local_user=.*/chroot_local_user=$CHROOT_LOCAL_USER/" $CONFIG_FILE

    if [ "$PASV_ENABLE" == "YES" ]; then
        sudo sed -i "s/^#pasv_enable=.*/pasv_enable=YES/" $CONFIG_FILE
        sudo sed -i "s/^#pasv_min_port=.*/pasv_min_port=10000/" $CONFIG_FILE
        sudo sed -i "s/^#pasv_max_port=.*/pasv_max_port=10100/" $CONFIG_FILE
    else
        sudo sed -i "s/^pasv_enable=.*/#pasv_enable=YES/" $CONFIG_FILE
    fi

    if [ "$SSL_ENABLE" == "YES" ]; then
        read -p "Geben Sie Ihre E-Mail-Adresse für Let's Encrypt ein: " EMAIL
        read -p "Geben Sie den Hostnamen für das SSL-Zertifikat ein: " HOSTNAME
        install_certbot
        sudo certbot certonly --standalone -m $EMAIL -d $HOSTNAME --non-interactive --agree-tos

        sudo sed -i "s/^#rsa_cert_file=.*/rsa_cert_file=\/etc\/letsencrypt\/live\/$HOSTNAME\/fullchain.pem/" $CONFIG_FILE
        sudo sed -i "s/^#rsa_private_key_file=.*/rsa_private_key_file=\/etc\/letsencrypt\/live\/$HOSTNAME\/privkey.pem/" $CONFIG_FILE
        sudo sed -i "s/^#ssl_enable=.*/ssl_enable=YES/" $CONFIG_FILE
        sudo sed -i "s/^#force_local_data_ssl=.*/force_local_data_ssl=YES/" $CONFIG_FILE
        sudo sed -i "s/^#force_local_logins_ssl=.*/force_local_logins_ssl=YES/" $CONFIG_FILE
    else
        sudo sed -i "s/^ssl_enable=.*/#ssl_enable=YES/" $CONFIG_FILE
    fi

    echo "vsftpd konfiguriert."
}

# Hauptmenü
while true; do
    echo "FTP-Server-Verwaltung:"
    echo "1. Installiere FTP-Server"
    echo "2. Starte FTP-Server"
    echo "3. Stoppe FTP-Server"
    echo "4. Starte FTP-Server neu"
    echo "5. Konfiguriere FTP-Server"
    echo "6. Erstelle FTP-Benutzer"
    echo "7. Lösche FTP-Benutzer"
    echo "8. Erstelle Freigabe"
    echo "9. Lösche Freigabe"
    echo "10. Beenden"
    read -p "Wählen Sie eine Option: " OPTION

    case $OPTION in
        1)
            install_ftp_server
            ;;
        2)
            start_ftp_server
            ;;
        3)
            stop_ftp_server
            ;;
        4)
            restart_ftp_server
            ;;
        5)
            configure_ftp_server
            ;;
        6)
            read -p "Benutzername: " USERNAME
            read -sp "Passwort: " PASSWORD
            echo
            create_ftp_user $USERNAME $PASSWORD
            ;;
        7)
            read -p "Benutzername: " USERNAME
            delete_ftp_user $USERNAME
            ;;
        8)
            read -p "Benutzername: " USERNAME
            read -p "Name der Freigabe: " SHARE_NAME
            create_ftp_share $USERNAME $SHARE_NAME
            ;;
        9)
            read -p "Benutzername: " USERNAME
            read -p "Name der Freigabe: " SHARE_NAME
            delete_ftp_share $USERNAME $SHARE_NAME
            ;;
        10)
            echo "Beenden..."
            exit 0
            ;;
        *)
            echo "Ungültige Option. Bitte erneut versuchen."
            ;;
    esac
done
