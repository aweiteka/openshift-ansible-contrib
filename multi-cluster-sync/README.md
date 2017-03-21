# Multi-cluster Openshift Sync

This is a Proof of Concept (PoC) playbook to assist in synchronizing specific items between OpenShift clusters.

## Use Cases

1. If I push an image to the *cluster 1* registry endpoint configured with shared storage with other clusters, I should be able to pull the image from the *cluster 2* registry endpoint.
1. I want to sync arbitrary objects between clusters. Objects may include projects, users, service accounts, imagestreams.
1. I want to automate object sync between clusters so updates on one cluster are populated to other clusters within seconds, not minutes.

## Scope

**Is**

Cluster reconciliation. For example, regional or geographic clusters (US, EMEA, APAC) that need to be synchronized. More specifically, reconciling the *dev* or *stage* clusters between regions.

**Is Not**

- Controlling application promotion. This could be performed using playbooks, Jenkins or other tooling but it is not the objective here.
- Defining base cluster configuration, e.g. projects, RBAC settings, etc. While this playbook could be extended for this purpose, it is really a secondary concern that is too broad to be of any practical use. Some basic objects are created as part of a demonstration.

## Using the playbook

1. Create cluster-admin service account tokens for each cluster (TBD)
1. Edit the **inventory** file adding **connection details** for the clusters you want to sync. For the *token* value use command `oc whoami -t`.
1. Edit the **vars/create.yml** file with the list of objects you want to create on all clusters. (See "Scope" above regarding limitations of the "create" use case.)
1. Edit the **vars/sync.yml** file with the list of objects you want to synchronize from the master to slave clusters.
1. Run the playbook

        ansible-playbook -i inventory playbooks/sync.yml

## TODO / Open Issues

- Add dockerpullsecret object
- Document creating cluster admin serviceaccount tokens for long-lived access to cluster (possible?)
- Log what changed for 'apply' role
- Logging in general (use openshift-ansible?)
- Suppress output to provide a useful report (use openshift-ansible?)
- Investigate progress of idempotent OpenShift module to aid in object apply workflow.
- Investigate "masterless" sync where any change to select objects is reconciled both ways.
