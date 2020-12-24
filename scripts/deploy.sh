. scripts/secrets.sh

scp scripts/setup.sh scripts/secrets.sh root@$KITAR_REMOTE:/root/
ssh root@$KITAR_REMOTE ./setup.sh

