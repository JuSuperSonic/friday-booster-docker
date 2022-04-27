# Description

Tutorial to get started with docker

# Prerequisite

## Install WSL2 <img src="https://upload.wikimedia.org/wikipedia/commons/a/ab/Logo-ubuntu_cof-orange-hex.svg" width="40"/> <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Windows_logo_-_2012.svg/1280px-Windows_logo_-_2012.svg.png" width="40"/> 

Using the following link [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

## Install Docker <img src="https://www.docker.com/sites/default/files/d8/styles/role_icon/public/2019-07/Moby-logo.png?itok=sYH_JEaJ" width="50"/>

```bash
$ chmod +x ./install-docker-wsl2.sh
$ sudo ./install-docker-wsl2.sh
```

* Because docker is installed in wsl2 (and not with Docker Desktop), access via localhost to the docker container is not possible, replace your usual localhost in url by docker.host.internal (or the IP of your wsl you can determine by the following command).

```Powershell
PS wsl hostname -I
```

```bash
$ hostname -I | awk '{print $1}'
```