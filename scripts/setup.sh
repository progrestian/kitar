# exports

export DEBIAN_FRONTEND=noninteractive
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# add non-root user

adduser --gecos "" user
usermod -aG sudo user

cp /root/secrets.sh /home/user/secrets.sh

# setup ssh

mkdir -p /home/user/.ssh

cd /home/user/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC36rSdOyGFdDcc6jSSMD6AOtiTQpbTF67dGkDL9a8euelXNhW/LMliLut71Jrwz0fdg8OvvXAsk8QqaaNS+31hpeIEa4TLWzcUZMK50QXiuGqUAhUJfWuHGbtQnMWlgZAVIff/bEm3dXxgqDO9I5KBXkfi1on4PqhTQttV478ypJZxI+u0boOaOhrP59wRQSphMTj2HaobR72MAfP8IWqYh0VJ0k9Ei+tf/SK8lirHn/L29Yuhyrr8EGMrdjXZvqxv02Ai1oeOxVDehepgO2CENKwIcs3au+xvr4hv5Rfk2sknYiA3EgbqkB9fksnNuRD9u8dPEzyM3CkjdEU3T2E9KUK94m6uMzreCWWKo1JEzcHWbKlETxBiYYytAEtl5L7imIt32py650nWcqL24UTYPla2VC7e4clcBeMgAFiG8+L1P1f4fVUfRvZw6smaXA1AaBmErwOnOJTd1XPkKlfIlwXoZXrKkWSrVB4Z5T7D4oRb8m5whqnjpq0bbcRx/fs= progrestian@menara" >> authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCV7bUCqCw9GudqrxATEt3LapFam5BmgbbCF384O5Kg2fRF8HTiWC1STuaGzw4sYpHHo43YfIy+uXC0/PmQhvHE93aNCE5LugGxsB0nFOe//4GUFa6YlZMCxLZDmeX9evNAQRE8dq4OxMGmNrXrqtVQHpGmCSeaJPZfx6mY1dMWn/5QKnNYKR651fjordT9O2C3CDM9JP4u/w2myc1eEgj5iMg8Tw3xeXymBlsVkHfsOYzVYEhUzPFY35L4qWbXWeXP4Mh65eITJm/EJZmh2/F5pGb9FWCVLIuJYwF2UZ8MPN/UD4IKWE2kJ/E96yTUPk0c6AmikUrjn+l5aY554CjP progrestian@asing" >> authorized_keys

# install dependencies

apt-get -y -qq -o=Dpkg::Use-Pty=0 update
apt-get -y -qq -o=Dpkg::Use-Pty=0 install \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  gnupg-agent \
  socat \
  software-properties-common \
  ufw

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

apt-get -y -qq -o=Dpkg::Use-Pty=0 update
apt-get -y -qq -o=Dpkg::Use-Pty=0 install \
  docker-ce \
  docker-ce-cli \
  docker-compose \
  containerd.io

# enable https

ufw allow ssh
ufw allow http
ufw allow https
ufw enable

# setup acme.sh

mkdir -p /home/user/ssl/progrestian.com

cd /root
git clone --quiet https://github.com/acmesh-official/acme.sh.git

cd acme.sh
./acme.sh --install

. /root/.acme.sh/acme.sh.env
. /root/secrets.sh

/root/.acme.sh/acme.sh \
  --issue \
  --dns dns_hetzner \
  --home /root/.acme.sh \
  --domain progrestian.com \
  --domain '*.progrestian.com'

/root/.acme.sh/acme.sh \
  --install-cert \
  --home /root/.acme.sh \
  --domain progrestian.com \
  --fullchain-file /home/user/ssl/progrestian.com/fullchain \
  --key-file /home/user/ssl/progrestian.com/key \

# setup kitar

cd /home/user
git clone --quiet https://github.com/progrestian/kitar.git

cd kitar
docker-compose build
docker-compose pull

