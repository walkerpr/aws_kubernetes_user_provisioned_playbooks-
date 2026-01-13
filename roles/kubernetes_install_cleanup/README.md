kubernetes-install-cleanup
=========

This role is responsible for cleaning up any files that were downloaded in the process of installing kubernetes. 


Role Variables
--------------
To make things easier we provide a variable holding all the different paths/files that are downloaded using the different roles. Recall that these paths depend on the versions of files being defined in the playbook as shown below. 


Example Playbook
----------------

    - hosts: servers
      vars:
        containerd_version: "1.2.3"
        runc_version: "1.2.3"
        cni_version: "1.2.3"
      roles:
         - kubernetes-install-cleanup
