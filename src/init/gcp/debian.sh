#! /bin/bash

# Trust gitlab public key
mkdir -p /root/.ssh
echo 'gitlab.ensimag.fr ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICajbnFVYz5T0kfb6Zouoafh7L4FOojcKowJfxLbZKiq' >> /root/.ssh/known_hosts
chmod 0600 /root/.ssh/known_hosts
# Setup ansible
apt install -y ansible git
# Ansible pull script
APP_ROLE=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/app_role" -H "Metadata-Flavor: Google")
echo "ansible-pull main.yml --url ${ansible_url} --checkout ${ansible_ref} -e app_role=$APP_ROLE > /var/log/ansible-pull.log 2>&1" > /opt/ansible-pull.sh
chmod 0744 /opt/ansible-pull.sh
# Run in for the first time
/opt/ansible-pull.sh
# Schedule updates every 10 minutes
echo '*/10 * * * * root /opt/ansible-pull.sh' > /etc/cron.d/ansible_pull_cronjob
