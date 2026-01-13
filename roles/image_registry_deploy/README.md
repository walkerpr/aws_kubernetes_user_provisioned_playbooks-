image-registry-deploy
=========

This role is responsible for setting up a local image registry to be used by kubernetes to deploy apps. At this time all locally imported images into the kubernetes cluster must be retagged and pushed to the image-registry so that they can be approriately pulled by th ehelm charts.


Role Variables
--------------

Inventory file should set iamge registry fqdn. Certs must exist in opt/sample/server for the image registry. Additionally vars shoudl be set for the ARTIFACTORY_USERNAME and ARTIFACTORY_PASSWORD for the image pull secret to be properly utilized.

vars/ contains "registry_url" which should be set to the URL for the docker registry where images will be pulled from.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: cp
      roles:
         - image-registry-deploy
