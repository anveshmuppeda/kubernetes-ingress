# Securing the Ingress Using Cert-Manager  
To secure your Ingress Resources, you’ll install Cert-Manager, create a ClusterIssuer for production, and modify the configuration of your Ingress to use the TLS certificates. Once installed and configured, your app will be running behind HTTPS.  



Step 4 — Securing the Ingress Using Cert-Manager
To secure your Ingress Resources, you’ll install Cert-Manager, create a ClusterIssuer for production, and modify the configuration of your Ingress to use the TLS certificates. Once installed and configured, your app will be running behind HTTPS.

ClusterIssuers are Cert-Manager Resources in Kubernetes that provision TLS certificates for the whole cluster. The ClusterIssuer is a specific type of Issuer.

Before installing Cert-Manager to your cluster via Helm, you’ll create a namespace for it:

kubectl create namespace cert-manager
You’ll need to add the Jetstack Helm repository to Helm, which hosts the Cert-Manager chart. To do this, run the following command:

helm repo add jetstack https://charts.jetstack.io
Helm will return the following output:

Output
"jetstack" has been added to your repositories
Then, update Helm’s chart cache:

helm repo update
It may take a moment for the update:

Output
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "jetstack" chart repository
Update Complete. ⎈Happy Helming!⎈
Finally, install Cert-Manager into the cert-manager namespace by running the following command:

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.10.1 --set installCRDs=true
In this command, you also set the installCRDs parameter to true in order to install cert-manager CustomResourceDefinition manifests during the Helm install. At the time of writing, v1.10.1 was the latest version. You can refer to ArtifactHub to find the latest version number.

You will receive the following output:

Output
NAME: cert-manager
LAST DEPLOYED: Wed Nov 30 19:46:39 2022
NAMESPACE: cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
cert-manager v1.10.1 has been deployed successfully!
...
The output indicates that the installation was successful.


The NOTES of the output (which has been truncated in the display above) states that you need to set up an Issuer to issue TLS certificates.

You’ll now create one that issues Let’s Encrypt certificates, and you’ll store its configuration in a file named cert_issuer.yaml. Create and open this file:

Add the following lines:
cert_issuer.yaml

apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-nginx-cert
spec:
  # ACME issuer configuration
  # `email` - the email address to be associated with the ACME account (make sure it's a valid one)
  # `server` - the URL used to access the ACME server’s directory endpoint
  # `privateKeySecretRef` - Kubernetes Secret to store the automatically generated ACME account private key
  acme:
    email: anveshmuppeda@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-nginx-private-key-cert
    solvers:
      # Use the HTTP-01 challenge provider
      - http01:
          ingress:
            class: nginx


This configuration defines a ClusterIssuer that contacts Let’s Encrypt in order to issue certificates. You’ll need to replace your_email_address with your email address to receive any notices regarding the security and expiration of your certificates.

Save and close the file.

Roll it out with kubectl:

kubectl apply -f production_issuer.yaml

You will receive the following output:

Output
clusterissuer.cert-manager.io/letsencrypt-prod created

With Cert-Manager installed, you’re ready to introduce the certificates to the Ingress Resource defined in the previous step. Open secure-kubernetes-ingress.yaml for editing:

Add the below lines:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-app-ingress
  labels:
    app: secure-app
  annotations:
    cert-manager.io/issuer: letsencrypt-nginx-cert
spec:
  tls:
  - hosts:
    - myblogs.101xdev.com
    secretName: letsencrypt-nginx-cert
  ingressClassName: nginx
  rules:
  - host: "myblogs.101xdev.com"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: secure-app-svc
            port:
              number: 80

The tls block under spec defines what Secret will store the certificates for your sites (listed under hosts), which the letsencrypt-nginx-cert ClusterIssuer issues. The secretName must be different for every Ingress you create.

Remember to replace the myblogs.101xdev.com with your own domains. When you’ve finished editing, save and close the file.

Re-apply this configuration to your cluster by running the following command:
kubectl apply -f hello-kubernetes-ingress.yaml

You will receive the following output:

Output
ingress.networking.k8s.io/hello-kubernetes-ingress configured
You’ll need to wait a few minutes for the Let’s Encrypt servers to issue a certificate for your domains. In the meantime, you can track progress by inspecting the output of the following command:

kubectl describe certificate hello-kubernetes-tls

The end of the output will be similar to this:

Output
Events:
  Type    Reason     Age    From                                       Message
  ----    ------     ----   ----                                       -------
  Normal  Issuing    2m34s  cert-manager-certificates-trigger          Issuing certificate as Secret does not exist
  Normal  Generated  2m34s  cert-manager-certificates-key-manager      Stored new private key in temporary Secret resource "hello-kubernetes-tls-hxtql"
  Normal  Requested  2m34s  cert-manager-certificates-request-manager  Created new CertificateRequest resource "hello-kubernetes-tls-jnnwx"
  Normal  Issuing    2m7s   cert-manager-certificates-issuing          The certificate has been successfully issued
When the last line of output reads The certificate has been successfully issued, you can exit by pressing CTRL + C.

Navigate to one of your domains in your browser. You’ll find the padlock appears next to the URL, signifying that your connection is now secure.

In this step, you installed Cert-Manager using Helm and created a Let’s Encrypt ClusterIssuer. You then updated your Ingress Resource to take advantage of the Issuer for generating TLS certificates. In the end, you have confirmed that HTTPS works correctly by navigating to one of your domains in your browser.



