#!/bin/bash
##-----------------------------------------------------------------------------
## Script  : install-docker-wsl2.sh
##
## Topic   : Script & functions to install docker & docker-compose without Windows Docker-Desktop.exe
##
## Exemple : install-docker-wsl2.sh
##-----------------------------------------------------------------------------
#
# VARIABLES -------------------------------------------------------------------

docker_compose_binaries_repository="/usr/local/bin"
docker_compose_binaries=${docker_compose_binaries_repository}/docker-compose
user_repository=/home/"${SUDO_USER:-"${USER}"}"

RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
ORANGE="\e[33m"
NO_COLOR="\e[0m"

INFO="${GREEN}[INFO]${NO_COLOR}"
WARN="${ORANGE}[WARN]${NO_COLOR}"
ERROR="${RED}[EROR]${NO_COLOR}"

# LIBRARY ---------------------------------------------------------------------

download_install_docker() {

    if [ -f /etc/lsb-release ]; then

        echo -e "[$(date "+%d-%m-%Y %T")] - ${INFO} - Docker installation in progress."
        {
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
            groupadd docker
            usermod -aG docker ${local_user}
        } > /dev/null 2>&1
        
        if [[ ! $(type docker) ]]; then
            echo -e "[$(date "+%d-%m-%Y %T")] - ${ERROR} - Docker was not installed properly."
            return 1
        else
            echo -e "[$(date "+%d-%m-%Y %T")] - ${INFO} - Docker installed."
        fi
    else
        echo -e "[$(date "+%d-%m-%Y %T")] - ${ERROR} - This distro of wsl2 is not supported currently."
        return 1
    fi
}

download_docker_compose_binaries() {

    {
        curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o ${docker_compose_binaries}
        chmod 777 ${docker_compose_binaries}
    } > /dev/null 2>&1

    if __check_execution_rights_on_file "${docker_compose_binaries}"; then
        echo -e "[$(date "+%d-%m-%Y %T")] - ${INFO} - Docker Compose installed."
    else
        echo -e "[$(date "+%d-%m-%Y %T")] - ${ERROR} - Docker Compose was not installed properly."
        return 1
    fi
}

add_functions_autostart_docker_service() {

    echo -e "[$(date "+%d-%m-%Y %T")] - ${INFO} - Adding autostart function for docker service."

    if ! __is_function_exist_in_file "${user_repository}/.bashrc" "launch_docker_service"; then
        if echo -e "

launch_docker_service() {
    
    service docker status > /dev/null 2>&1
    if [ \$? -ne 0 ]; then
        echo -e \"[\$(date \"+%d-%m-%Y %T\")] - ${INFO} - Starting docker service, please enter your password :\"
        if ! sudo service docker start > /dev/null 2>&1; then
            echo -e \"[\$(date \"+%d-%m-%Y %T\")] - ${ERROR} - Cannot start the docker service.\"
        else
            echo -e \"[\$(date \"+%d-%m-%Y %T\")] - ${INFO} - Docker service started, switch of the IP of host.docker.internal to wsl.\"
            __update_ip_docker_hostname_windows
        fi
    fi 
}

__update_ip_docker_hostname_windows() {

    wsl_ip=\$(hostname -I | awk '{print \$1}')
    hostname_docker=\"host.docker.internal\"
    hostname_docker_char_esc=\$(__escape_dot_character \"host.docker.internal\")
    hosts_windows_file=\"/mnt/c/Windows/System32/drivers/etc/hosts\"

    if grep -q \"\${hostname_docker}\" \"\${hosts_windows_file}\"; then
        sed -i -e \"s/^.*\${hostname_docker_char_esc}.*\$/\${wsl_ip} \${hostname_docker}/g\" \"\${hosts_windows_file}\"
        echo -e \"[\$(date \"+%d-%m-%Y %T\")] - ${INFO} - Hostname \${hostname_docker} replace with ip : \${wsl_ip}.\"
    else
        echo -e \"\\\n\${wsl_ip} \${hostname_docker}\" >> \"\${hosts_windows_file}\"
        echo -e \"[\$(date \"+%d-%m-%Y %T\")] - ${INFO} - Hostname \${hostname_docker} add with ip : \${wsl_ip}.\"
    fi
}

__escape_dot_character() {

    var_escaped=\$(echo \"\${1}\" | sed 's/\./\\\\\./g')
    echo \"\${var_escaped}\"
}

__escape_dot_character() {

    var_escaped=\$(echo \"\${1}\" | sed 's/\./\\\\\./g')
    echo \"\${var_escaped}\"
}

__escape_dot_character() {

    var_escaped=\$(echo \"\${1}\" | sed 's/\./\\\\\./g')
    echo \"\${var_escaped}\"
}

launch_docker_service
" >> "${user_repository}"/.bashrc; then
            echo -e "[$(date "+%d-%m-%Y %T")] - ${INFO} - Function autostart added in ~/.bashrc."
            echo -e "[$(date "+%d-%m-%Y %T")] - ${WARN} - Please restart your session in order to run the docker daemon."
        fi
    fi
}

__is_function_exist_in_file() {
    
    local file="${1}"
    local function_name="${2}"

    if grep -Fq "${function_name}()" "${file}"; then
        echo -e "[$(date "+%d-%m-%Y %T")] - ${WARN} - Function already exist in ${file}, it will not be added."
    else
        return 1
    fi
}

__exist_file() {

    if [[ -e ${1} ]]; then
        echo -e "[$(date "+%d-%m-%Y %T")] - ${INFO} - Check the existence of the file ${1} - OK"
    else
        echo -e "[$(date "+%d-%m-%Y %T")] - ${ERROR} - The file ${1} doesn't exist."
        return 1
    fi
}

__check_execution_rights_on_file() {

    local file="${1}"

    if __exist_file "${file}"; then
        if [[ $(stat -c %a "${file}") -ne 777 ]]; then
            echo -e "[$(date "+%d-%m-%Y %T")] - ${ERROR} - The file ${file} didn't get the execution rights."
            return 1
        fi 
    fi
}

# MAIN ------------------------------------------------------------------------

echo -e "[$(date "+%d-%m-%Y %T")] - ${WARN} - This script must be run in admin, run script with the following command : ${BLUE}sudo ./install-docker-wsl2.sh${NO_COLOR}"

if download_install_docker; then
    download_docker_compose_binaries
    add_functions_autostart_docker_service
fi
