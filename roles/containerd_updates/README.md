containerd-updates
=========

This role configures containerd auth to our sample artifactory instance. This role requires sample to already be deployed. Failure to configure this registry auth piece will result in app deployments unable to pull images from artifactory when attempting to deploy.


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
