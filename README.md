# Via HAProxy to two nginx (on docker) static pages
Motivation and requirements for this lab can be found @ https://hsekowski.blogspot.com/2020/03/via-haproxy-to-two-nginx-on-docker.html

Lab description:

You need to have following requirements fulfilled to be able to run this lab:
1) Azure subscription that allows to create virtual machine (https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal)
2) Vagrant and VirtualBox installed on your PC.

This lab was prepared and tested with use of:
1) Azure free account (https://azure.microsoft.com/free/)
2) Vagrant 2.2.6 and VirtualBox 6.0.14 on macOS 10.15.3

Instruction:
1) Find and execute run.sh script
2) Open https://microsoft.com/devicelogin in web browser and enter code when you are asked ; you will need to provide your Azure account credentials as well
3) During first attempt to connect Azure VM from vagrant VM, you'll be asked to confirm the connection. Type 'yes' and press Enter for each Azure VM
4) Once script is completed, you get list of public addresses where static pages are hosted and for load balancer that proxyfies traffic using round robin rule
