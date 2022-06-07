# Initialize Environment

## Introduction

In this lab we will review and start all components required to successfully run this workshop.

*Estimated Time:* 10 minutes

### Objectives

In this lab, you will:
* Launch the workshop instance
* Verify the Oracle Database
* Create and Initialize Kubernetes nodes

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup

## Task 1: Environment Verification

1. Open a terminal instance and verify that the OIG Database is running.

	```
	<copy>systemctl status oracle-database.service</copy>
	```

	![Database system service](images/2-db.png)

	Press Ctrl+C to revert to the terminal.

2. Verify the docker and helm version.

	```
	<copy>docker version</copy>
	```

	```
	<copy>helm version</copy>
	```

	![Docker and helm version](images/1-versions.png)

3. Verify the OIG, OAM and OUD docker images.

	```
	<copy>docker images | grep oracle</copy>
	```

	![Docker images](images/3-dockerimages.png)

## Task 2: Environment Initialization

1. Perform the following prerequisite setup steps to initialize the environment.

	```
	<copy>sudo setenforce 0</copy>
	```

	```
	<copy>sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux</copy>
	```

	```
	<copy>sudo swapoff -a</copy>
	```

2. Note the private IP of the instance.

	```
	<copy>cat /etc/hosts</copy>
	```
	For Example:

	![/etc/hosts file](images/4-ip.png)

3. Deploy and initialize the pod network and make sure that the pod network does not overlap with any of the host networks.

	```
	<copy>sudo kubeadm init --pod-network-cidr=10.244.0.0/16</copy>
	```

*Note : The network CIDR range used in above command for pod network initialization is 10.244.0.0/16 which is NON-OVERLAPPING to the host subnet CIDR of 10.0.0.0/24. The host subnet CIDR will remain the same for each deployment.*

4. Enable kubectl to work with non-root users.

	```
	<copy>sudo mkdir -p /home/oracle/.kube</copy>
	```

	```
	<copy>sudo cp -i /etc/kubernetes/admin.conf /home/oracle/.kube/config</copy>
	```

	```
	<copy>sudo chown -R oracle:oinstall /home/oracle/.kube</copy>
	```

5. Verify the Kubernetes version and schedule pods on the control-pane node.

	```
	<copy>kubectl version --short</copy>
	```

	![Kubectl version](images/5-kube.png)

	```
	<copy>kubectl taint nodes --all node-role.kubernetes.io/master-</copy>
	```

6. List all pods in all namespaces.

	```
	<copy>kubectl get pods --all-namespaces</copy>
	```

7. Update the resources in the cluster and make sure all pods are in the “Running” state.

	```
	<copy>kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml</copy>
	```

	Wait for 1-2 minutes and list all the pods and make sure they are in the Running state.

	```
	<copy>kubectl get pods --all-namespaces</copy>
	```

	![Kube-system pods](images/6-pod.png)


You may now proceed to the next lab.


## Acknowledgements
* **Author** - Keerti R, Anuj Tripathi, NATD Solution Engineering
* **Contributors** -  Keerti R, Anuj Tripathi
* **Last Updated By/Date** - Keerti R, NATD Solution Engineering, January 2022
