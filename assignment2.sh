#!/bin/bash

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

# Function to add user with SSH keys
add_user_with_ssh_keys() {
    username="$1"
    ssh_dir="/home/$username/.ssh"

    # Create user if not exists
    id -u "$username" &>/dev/null || useradd -m -s /bin/bash "$username"

    # Create .ssh directory and authorized_keys file
    mkdir -p "$ssh_dir"
    touch "$ssh_dir/authorized_keys"

    # Add RSA and ED25519 public keys to authorized_keys
    cat << EOF > "$ssh_dir/authorized_keys"
    # Paste RSA public key here
    ssh-rsa AAAA...

    # Paste ED25519 public key here
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm

EOF

    # Set correct permissions
    chmod 700 "$ssh_dir"
    chmod 600 "$ssh_dir/authorized_keys"
    chown -R "$username:$username" "$ssh_dir"
}

# Function to configure network interface and /etc/hosts
configure_network_and_hosts() {
    # Add network configuration using netplan
    cat << EOF > /etc/netplan/01-netcfg.yaml
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: true
        eth1:
          addresses:
            - 192.168.16.21/24
          gateway4: 192.168.16.2
          nameservers:
            addresses:
              - 192.168.16.2
            search:
              - home.arpa
              - localdomain
EOF

    # Apply netplan configuration
    netplan apply

    # Update /etc/hosts with server1 entry
    sed -i '/^192\.168\.16\.21/d' /etc/hosts  # Remove old entry if exists
    echo "192.168.16.21 server1" >> /etc/hosts
}

# Function to install and configure software
install_and_configure_software() {
    # Install required software packages
    apt update
    apt install -y apache2 squid ufw

    # Configure Apache2 and Squid (if needed)

    # Configure firewall (ufw)
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow from 192.168.16.0/24 to any port http
    ufw allow from 192.168.16.0/24 to any port 3128  # Assuming Squid uses port 3128
    ufw enable
}

# Main script starts here
echo "Starting configuration..."

# Add user accounts with SSH keys
add_user_with_ssh_keys "dennis"
add_user_with_ssh_keys "aubrey"
add_user_with_ssh_keys "captain"
add_user_with_ssh_keys "snibbles"
add_user_with_ssh_keys "brownie"
add_user_with_ssh_keys "scooter"
add_user_with_ssh_keys "sandy"
add_user_with_ssh_keys "perrier"
add_user_with_ssh_keys "cindy"
add_user_with_ssh_keys "tiger"
add_user_with_ssh_keys "yoda"

# Configure network interface and /etc/hosts
configure_network_and_hosts

# Install and configure software
install_and_configure_software

echo "Configuration completed."
