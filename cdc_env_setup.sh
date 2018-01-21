#!/bin/sh

dpkg_cmd='sudo apt-get'
package_list=
echo  "Update"

$dpkg_cmd update && $dpkg_cmd upgrade -y > log


echo  "Uninstall Docker"

$dpkg_cmd remove docker docker-engine docker.io -y >> log

echo  "Install docker requirements"

$dpkg_cmd install apt-transport-https  ca-certificates  curl software-properties-common -y >> log

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo  "Verifying Docker key install"
sudo apt-key fingerprint 0EBFCD88

echo "Configure repository"
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

$dpkg_cmd update

echo "Install software common for ansible"
$dpkg_cmd install software-properties-common -y >> log

echo "Add ansible repo"
sudo apt-add-repository ppa:ansible/ansible -y

echo "Update"
$dpkg_cmd update > log

echo "Install Ansible"
$dpkg_cmd  install ansible -y >> log


echo "Install docker"
$dpkg_cmd install docker-ce -y >> log

echo "Test docker"
sudo docker run hello-world

echo "FROM ubuntu:16.04

RUN apt-get update && apt-get install -y openssh-server vim
RUN mkdir /var/run/sshd
RUN echo 'root:ssgpassword' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD /usr/sbin/sshd -D" > Dockerfile


docker build -t ubuntu-ssh .
docker run -dt --name finalssh ubuntu-ssh  

docker network create --subnet 192.168.1.0/24 ssg-dc-vnet 
docker network connect --ip 192.168.1.2  ssg-dc-vnet finalssh

