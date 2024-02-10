  mkdir /tmp/certs
  cd /tmp/certs
  PRI_IP="192.168.1.34"
  SUBJECT="/C=ES/ST=GA/L=Vigo/O=Ketfrix/OU=Ketfrix Server/CN=$(hostname)"
  openssl genrsa -out ca-key.pem 4096
  openssl req -new -x509 -days 3650 -key ca-key.pem -out ca.pem -subj "$SUBJECT"
  openssl req -new -nodes -out server.csr -keyout server-key.pem -subj "$SUBJECT"
  openssl req -subj "/CN=$(hostname)" -new -key server-key.pem -out server.csr
  echo subjectAltName = DNS:$(hostname),IP:${PRI_IP} >> extfile.cnf
  echo extendedKeyUsage = serverAuth >> extfile.cnf
  openssl x509 -req -days 3650 -in server.csr -CA ca.pem -CAkey ca-key.pem   -CAcreateserial -out server-cert.pem -extfile extfile.cnf
  openssl genrsa -out key.pem 4096
  openssl req -subj '/CN=client' -new -key key.pem -out client.csr
  echo extendedKeyUsage = clientAuth > extfile-client.cnf
  openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile-client.cnf
  rm -v client.csr server.csr extfile.cnf extfile-client.cnf
  chmod -v 0400 ca-key.pem key.pem server-key.pem
  chmod -v 0444 ca.pem server-cert.pem cert.pem
  mkdir -p /etc/docker/certs
  cp ca.pem /etc/docker/certs/
  cp server-cert.pem /etc/docker/certs/
  cp server-key.pem /etc/docker/certs/
  mkdir -p /config/kasm/current/certs/docker/
  mkdir -p /config/utilities/watchtower/certs/docker
  mkdir -p /config/ingress/traefik/certs/docker
  cp cert.pem /config/kasm/current/certs/docker/
  cp cert.pem /config/utilities/watchtower/certs/docker
  cp cert.pem /config/ingress/traefik/certs/docker
  cp key.pem /config/kasm/current/certs/docker/
  cp key.pem /config/utilities/watchtower/certs/docker
  cp key.pem /config/ingress/traefik/certs/docker
  cp ca.pem /config/kasm/current/certs/docker/
  cp ca.pem /config/utilities/watchtower/certs/docker
  cp ca.pem /config/ingress/traefik/certs/docker
  cd -
  rm -Rf /tmp/certs