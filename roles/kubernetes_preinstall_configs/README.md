kubernetes-preinstall-configs
=========

This role is primarly responsible for handling some of the pre install configs as outlined by the kubernetes docs. Primarily this invovles setting up different firewalld rules and systctl configs. 

Example Playbook
----------------

    - hosts: cp_nodes
      roles:
         - kubernetes-preinstall-configs
