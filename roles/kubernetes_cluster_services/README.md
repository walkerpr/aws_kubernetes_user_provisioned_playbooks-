kubernetes-cluster-service
=========

This role is responsible for setting up additional services that may be utilized by the kubernetes cluster after kubernetes has been installed. Currently the role will set up the nginx ingress controller to handle all ingress related traffice for an application. Additionally, it will set up a new storage class to utilize nfs storage. 


Role Variables
--------------

Inventory file should contain the cp ip address. Additionally, ingress ports may need to be updated based on any specific requirements 32080 and 32443 are utilized as they easily identify which port matches to http vs https traffice in a normal environment. 


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: cp
      roles:
         - kubernetes-cluster-services

