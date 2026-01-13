kubernetes-install
=========

This role is responsible for handling the installation of kubernetes. It will install and initialize a cluster with a loadbalancer endpoint or on the given cp node depending on whether lb_endpoint is sepcified. Additionally, a container run time must have been installed prior to this role running we provide container-runtime-install as a role to install containerd if needed.


Role Variables
--------------
flannel_subnet is the only variable and uses the default subnet "10.244.0.0/16" but if needed this var can be updated in vars/.
Additionally the playbook calling this role should specify whether or not an lb endpoint is being used. 


Example Playbook
----------------
Example of initializing cluster on cp_node and not using lb assuming container runtime not installed

    - hosts: cp_nodes
      vars:
        use_lb_endpoint: false
        containerd_version: "1.2.3"
        runc_version: "1.2.3"
        cni_version: "1.2.3"
      roles:
         - kubernetes-preinstall-configs
         - container-runtime-install
         - kubernetes-install
Example of initializing cluster using lb endpoint assuming container runtime not installed

    - hosts: cp_nodes
      vars:
        use_lb_endpoint: true
        containerd_version: "1.2.3"
        runc_version: "1.2.3"
        cni_version: "1.2.3"
      roles:
         - kubernetes-preinstall-configs
         - container-runtime-install
         - kubernetes-install


