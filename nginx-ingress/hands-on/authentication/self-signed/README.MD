# Self Signed Certs in Ingress  


## These are the steps for self signed certificates.

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out self-signed-tls.crt -keyout self-signed-tls.key \
    -subj "/CN=anvesh.com" \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "[SAN]\nsubjectAltName=DNS:anvesh.com,DNS:*.anvesh.com"))
```

### Create Kubernetes secret

```bash
kubectl create secret tls self-signed-tls --key self-signed-tls.key --cert self-signed-tls.crt
```

###  
Create ingress, make sure you have ingress controller already installed.  

### Check by hitting the URL  
```bash
curl -v https://161.35.240.187/selfsigned -H 'my-self-signed-domain.com' -k  
curl -v -k https://xyz.com/demo  
```