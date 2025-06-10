# What is a VM ?
when we are hosting ,we host it on a virtual machine
In a datacentre we have hardware on top of the hardware we have a hypervisior after that we have virtual machines

VMs run on a physical server (called the **host**) but are abstracted through a layer of virtualization software called a **hypervisor** (e.g., VMware, KVM). This hypervisor divides the host machine’s resources (CPU, memory, storage) into separate virtual machines.

Each VM acts like a completely independent machine, even though they share the underlying hardware. You can run different operating systems and applications in different VMs on the same physical server.

VMs are highly flexible and easy to scale. You can quickly spin up, modify, or delete VMs, and you can consolidate multiple workloads on a single server.

The virtualization layer introduces a slight overhead in terms of performance because the hypervisor needs to manage resources and ensure each VM operates independently. However, with modern hypervisors and powerful hardware, this overhead is minimal.


References : 
1) https://petal-estimate-4e9.notion.site/What-is-a-VM-1867dfd1073580d68977c35dc558b592