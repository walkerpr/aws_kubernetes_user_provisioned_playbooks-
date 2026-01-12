#!/bin/bash
NAME=$1
NUMBER=$2

PATH="../../certs/$NAME/d$NUMBER"
CA_PATH="../../certs/certificate-authority"

CA_KEY="$CA_PATH/server-ca.key"
CA_CRT="$CA_PATH/server-cacert.crt"
CA_EXTFILE="ca_cert.cnf"
SERVER_EXT="server_ext.cnf"
SERVER_CONF="server_cert.cnf"
OPENSSL_CMD="/usr/bin/openssl"



DOMAIN="dev.sample.dev"

function clean_directories {
  /usr/bin/rm -rf $PATH/server/*.crt
  /usr/bin/rm -rf $PATH/server/*.key
  /usr/bin/rm -rf $PATH/cnf/*.cnf
  /usr/bin/rm -rf $PATH/csr/*.csr
  /usr/bin/mkdir -p $PATH/csr
  /usr/bin/mkdir -p $PATH/cnf
  /usr/bin/mkdir -p $PATH/server
  /usr/bin/mkdir -p $CA_PATH
}



function generate_root_ca {

    ## generate rootCA private key
    echo "Generating RootCA private key"
    if [[ ! -f $CA_KEY ]];then
       $OPENSSL_CMD genrsa -out $CA_KEY 2048 2>/dev/null
       [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $CA_KEY" && exit 1
    else
       echo "$CA_KEY seems to be already generated, skipping the generation of RootCA key"
       return 0
    fi

    ## generate rootCA certificate
    if [[ ! -f $CA_CERT ]];then
      echo "Generating RootCA certificate"
      $OPENSSL_CMD req -new -x509 -days 3650 -config $CA_EXTFILE -key $CA_KEY -out $CA_CRT 2>/dev/null
      [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $CA_CRT" && exit 1
    else
       echo "$CA_CERT seems to be already generated, skipping the generation of RootCA key"
       return 0
    fi


    ## read the certificate
    echo "Verify RootCA certificate"
    $OPENSSL_CMD  x509 -noout -text -in $CA_CRT >/dev/null 2>&1
    [[ $? -ne 0 ]] && echo "ERROR: Failed to read $CA_CRT" && exit 1

}

function set_certificate_info {
  APP=image-registry.apps
  TYPE=kub
  SERVER_KEY="$PATH/server/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.key"
  SERVER_CSR="$PATH/csr/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.csr"
  SERVER_CRT="$PATH/server/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.crt"
  SERVER_PFX="$PATH/server/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.pfx"
  SERVER_EXT_MOD="$PATH/cnf/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.cnf"
  generate_server_certificate

  APP=application-sample
  TYPE=kub
  SERVER_KEY="$PATH/server/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.key"
  SERVER_CSR="$PATH/csr/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.csr"
  SERVER_CRT="$PATH/server/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.crt"
  SERVER_PFX="$PATH/server/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.pfx"
  SERVER_EXT_MOD="$PATH/cnf/$APP.$NUMBER.$TYPE.$NAME.$DOMAIN.cnf"
  generate_server_certificate
}

function generate_server_certificate {
  echo "Creating custom extension file."
  /usr/bin/cp $SERVER_EXT $SERVER_EXT_MOD
  /usr/bin/cat >> $SERVER_EXT_MOD <<EOF
DNS.1 = $APP.$NUMBER.$TYPE.$NAME.$DOMAIN
DNS.2 = *.dev.sample.dev
EOF
  echo "Generating server private key"
  $OPENSSL_CMD genrsa -out $SERVER_KEY 2048 2>/dev/null
  [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_KEY" && exit 1

  echo "Generating certificate signing request for server"
  $OPENSSL_CMD req -new -key $SERVER_KEY -out $SERVER_CSR -config $SERVER_CONF -subj "/CN=$APP.$NUMBER.$TYPE.$NAME.$DOMAIN"  2>/dev/null
  [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_CSR" && exit 1

  echo "Generating RootCA signed server certificate"
  $OPENSSL_CMD x509 -req -in $SERVER_CSR -CA $CA_CRT -CAkey $CA_KEY -out $SERVER_CRT -CAcreateserial -days 3650 -sha512 -extfile $SERVER_EXT_MOD
  [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_CRT" && exit 1

  echo "Verifying the server certificate against RootCA"
  $OPENSSL_CMD verify -CAfile $CA_CRT $SERVER_CRT >/dev/null 2>&1
  [[ $? -ne 0 ]] && echo "ERROR: Failed to verify $SERVER_CRT against $CA_CRT" && exit 1
  ## read the certificate
  echo "Verifying certificate matches key"
  CERT="$($OPENSSL_CMD x509 -in $SERVER_CRT  -pubkey -noout -outform pem | /usr/bin/sha512sum )"
  KEY="$($OPENSSL_CMD rsa -in $SERVER_KEY  -pubout -outform pem | /usr/bin/sha512sum)"
  if [ "$KEY" != "$CERT" ]; then
    echo "Certificate and key do not match" && exit 1
  fi

  $OPENSSL_CMD  x509 -noout -text -in $CA_CRT >/dev/null 2>&1
  [[ $? -ne 0 ]] && echo "ERROR: Failed to read $CA_CRT" && exit 1
  /usr/bin/rm $SERVER_EXT_MOD
}

function generate_server_certificate_pkcs {
    echo "Generating pkcs"
    $OPENSSL_CMD pkcs12 -export -out $SERVER_PFX -inkey $SERVER_KEY -in $SERVER_CRT -certfile $CA_CRT 2>/dev/null
    [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_PFX" && exit 1

}

# MAIN
clean_directories
generate_root_ca
set_certificate_info

/usr/bin/rm -rf $PATH/csr
/usr/bin/rm -rf $PATH/cnf
/usr/bin/rm -rf $PATH/ca