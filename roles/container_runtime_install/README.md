container-runtime-install
=========

This role handles the downloading of necessary files to install the container run time containerd and additinal files for configuring kubernetes. 


Role Variables
--------------

kubernetes_downloads
- Contains all the Source Urls for downloading files
- Contains the destination location for each file that gets downloaded
```
kubernetes_downloads
  - src: "https://someurl.com/afile"
    dest: "/opt/afile"
```

Example Playbook
----------------



    - hosts: cp_nodes
      vars:
        containerd_version: "1.2.3"
        runc_version: "1.2.3"
        cni_version: "1.6.2"
      roles:
         - container-runtime-install

