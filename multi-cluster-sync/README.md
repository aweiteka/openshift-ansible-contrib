# Multi-cluster Openshift Sync

This is a Proof of Concept (PoC) set of playbooks to assist in synchronizing specific items between OpenShift clusters.

## Use Cases

1. I want to sync arbitrary objects between clusters. Objects may include projects, users, service accounts, imagestreams.
1. I want to automate object sync between clusters so updates on one cluster are populated to other clusters within seconds (not minutes or millisecconds).
1. If I push an image to the *cluster 1* registry endpoint configured with shared storage with other clusters, I should be able to pull the image from the *cluster 2* registry endpoint without having to tag and push the image to each registry.

### Demonstrated Examples

- Ensure certain projects, users, permissions and service accounts exist on all clusters. These are dependent objects that will be sync'd.
- **Manually sync** dockercfg secrets and imagestreams on one cluster (e.g. the central registry) with other clusters (runtime clusters).
- **Watch for changes** on imagestreams on one cluster ("master") and apply to other clusters ("slaves").

## Scope

**Is**

Cluster reconciliation. For example, regional or geographic clusters (US, EMEA, APAC) that need to be synchronized. More specifically, reconciling the *dev* or *stage* clusters between regions.

**Is Not**

- Controlling application promotion. This could be performed using playbooks, Jenkins or other tooling but it is not the objective here.
- Defining base cluster configuration, e.g. projects, RBAC settings, etc. While this playbook could be extended for this purpose, it is really a secondary concern that is too broad to be of any practical use. Some basic objects are created as part of a demonstration.

## Using the playbook

1.  As cluster-admin, get the 'management-admin' token. *NOTE: not all permissions are in place for this. Until resolved, use the session token as cluster-admin `oc whoami -t`*

        oc sa get-token -n management-infra management-admin
1. Edit the **inventory** file adding **connection details** for the clusters you want to sync. Use the output from step one for the *token* value.
1. Edit the **vars/create.yml** file with the list of objects you want to create on all clusters. See "Scope" above regarding limitations of the "create" use case.
1. Edit the **vars/sync.yml** file with the list of objects you want to synchronize from the master to slave clusters.

### Run Manually to Configure Clusters and Sync

1. Run the playbook

        ansible-playbook sync.yml

### Automated Watch and Sync

In this scenario run an `oc observe` command on a particular object (e.g. imagestreams), running the playbook as necessary using the `watch.sh` wrapper script.

1. Run wrapper script as part of an 'oc observe' command

        oc observe imagestreams --all-namespaces \
            -a '{ .metadata.annotations.sync }' -- \
            ./watch.sh
1. Any change to imagestreams will run the wrapper script. Only those annotated 'sync: me' will trigger the playbook. Use this command to annotate an imagestream:

        oc annotate imagestream NAME sync=me

### Automated Watch and Sync from a Pod: FIXME/TEST

In this scenario run the observer command from a pod with this customized playbook.

1. Build the playbook into the image

        oc new-build -e INSTALL_OC=true \
        docker.io/aweiteka/playbook2image~. \
        --name=syncplaybook
1. Create the controller

        oc create -f observer.yaml

The observer deployment will leave a watch open on the imagestreams.

## TODO / Open Issues

- 'management-infra' token not able to apply changes in all projects?
- Log what changed for 'apply' role
- Logging in general (use openshift-ansible?)
- Suppress output to provide a useful report (use openshift-ansible?)
- Use OpenShift Ansible module
- Create controller template and instructions for creating inventory, handling secrets and building playbook.
- Draw cluster diagrams to describe use cases.
