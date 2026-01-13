kubernetes-cluster-service
=========

This role is responsible for generating the CSR's and keys to be used for rotating certificates. Certificate rotation is necessary to either get off of the self signed certs kubernetes uses for its internal clsuter communication or in the event that certificates expire. The CSR's generated here will need to be signed through the NPE portal. Pay extra attention to the SAN's for the kube-apiserver cert as you must add in the IP address for the LB being used if kubernetes node lives behind a load balancer.


Role Variables
--------------




Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: cp
      roles:
         - kubernetes-cert-rotation



Cert Rotation Walkthrough
----------------

```
  # The following command will generate keys and CSRs for all control-plane certificates and kubeconfig files:
  kubeadm certs generate-csr --kubeconfig-dir /opt/k8s-csr/conf --cert-dir /opt/k8s-csr/pki
```
Once you have all the csrs you will need to get them signed through the NPE portal. The only thing to keep in mind is if you are using a LB endpoint for your cluster you will want to make sure when you sign the apiserver certificate you include an extra SAN with the IP address of your LB. Also note that that NPE portal forces a SAN even if the kubeadm csr's don't include one, in these cases simply just copy the name of the cert and place it in the SAN DNS name.

Also final tip, it appears as though edge blocks the download of the raw cer file form the NPE portal, forcing users to have to download the pkcs7 bundle and extract the .cer file. Using chrome, there does not appear to be such a limitation and you are able to download the .cer file. As you download the certs make sure the naming matches the below for each cert remove any system_ that may be present when downloading.

The Conf Certs you will need to sign csr's for are:

- kubernetes-admin.cer
- kube-controller-manager.cer
- kubelet.cer
- kube-scheduler.cer
- kubernetes-super-admin.cer

The pki certs you will need to sign csrs for are:
- kube-apiserver.cer
- kube-apiserver-etcd-client.cer
- kube-apiserver-kubelet-client.cer
- front-proxy-client.cer

The following certs after being signed will need to be placed in /etcd. Additionally pay close attention when you download peer/server cer's as it will want to default to your node hostname.

- kube-etcd-healthcheck-client.cer
- peer.cer
- server.cer

Once all Certs have been signed push them up to your kubenode and make sure the folder is stored in /home/ec2-user/kubeadmCerts

Rename all the cer's to be crt's and drop any kube- or kubernetes- from the names.

For the conf crt's make sure to add in the cert string into its respective .conf file.
```
certificate-value-data: base64certstring
```



Cert Rotation Helpful links
----------------
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/

https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-certs/

https://services.devops.sample.sample.mil/confluence/pages/viewpage.action?pageId=532511999&spaceKey=sample&title=Generate%2BCertificates%2Band%2BRetrieval