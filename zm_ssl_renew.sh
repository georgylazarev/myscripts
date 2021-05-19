su - zimbra -c "/opt/zimbra/bin/zmproxyctl stop"
su - zimbra -c "/opt/zimbra/bin/zmmailboxdctl stop"
/opt/certbot/certbot-auto renew --standalone
rm -f /opt/zimbra/ssl/letsencrypt-old/*
cp /opt/zimbra/ssl/letsencrypt/* /opt/zimbra/ssl/letsencrypt-old/
rm -f /opt/zimbra/ssl/letsencrypt/* 
rm -f /opt/zimbra/ssl/zimbra/commercial/commercial.key 
cp /etc/letsencrypt/live/mail.an-security.ru/* /opt/zimbra/ssl/letsencrypt/
cat /opt/certbot/letsencryptCA >> /opt/zimbra/ssl/letsencrypt/chain.pem
cp /opt/zimbra/ssl/letsencrypt/privkey.pem /opt/zimbra/ssl/zimbra/commercial/commercial.key
chown zimbra:zimbra /opt/zimbra/ssl/letsencrypt/*
chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key
cd /opt/zimbra/ssl/letsencrypt
su zimbra
zmcertmgr verifycrt comm privkey.pem cert.pem chain.pem
zmcertmgr deploycrt comm cert.pem chain.pem
zmcontrol restart
