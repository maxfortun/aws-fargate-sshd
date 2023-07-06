#!/bin/ash -ex

cat >> /etc/ssh/sshd_config << EOT
LogLevel DEBUG
PermitRootLogin prohibit-password
EOT

if [ -n "$CASignatureAlgorithms" ]; then
	echo "CASignatureAlgorithms $CASignatureAlgorithms" >> /etc/ssh/sshd_config
fi

if [ -n "$PubkeyAcceptedKeyTypes" ]; then
	echo "PubkeyAcceptedKeyTypes $PubkeyAcceptedKeyTypes" >> /etc/ssh/sshd_config
fi

if [ -n "$PubkeyAcceptedAlgorithms" ]; then
	echo "PubkeyAcceptedAlgorithms $PubkeyAcceptedAlgorithms" >> /etc/ssh/sshd_config
fi

sed -i 's/root:!/root:*/' /etc/shadow

if [ -n "$TrustedUserCAKeys" ]; then
	for url in $TrustedUserCAKeys; do
		curl -fs "$url" >> /etc/ssh/trusted-user-ca-keys.pem || true
	done
	if [ -s /etc/ssh/trusted-user-ca-keys.pem ]; then
	cat >> /etc/ssh/sshd_config << EOT
TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
EOT
	fi
fi
chmod -R og-rwx /etc/ssh/

if [ -n "$authorized_keys" ]; then
	[ -d /root/.ssh ] || mkdir /root/.ssh
	for url in $authorized_keys; do
		curl -fs "$url" >> /root/.ssh/authorized_keys || true
	done
	chmod -R og-rwx /root/.ssh/
fi

/usr/bin/ssh-keygen -A
exec /usr/sbin/sshd -D $SSHD_ARGS
