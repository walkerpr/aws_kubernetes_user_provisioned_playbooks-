kubernetes-api-loadbalancer
=========

This role is responsible for setting a load balancer endpoing to be used when initializing a kubernetes cluster. It utilizes HAproxy as the service for load balancing. 


Role Variables
--------------

no variables in the role but the template for the haproxy configuration is provided in templates/


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: lb
      roles:
         - kubernetes-api-loadbalancer
