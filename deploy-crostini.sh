#!/usr/bin/env bash
#
# Script to re-initialize common tools on crostini

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail

readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Script Specific Variables
SSH_PRIVATE_KEY=$"$HOME/.ssh/id_ed25519"
REQUIRED_PACKAGES=(lsb-release \
  vim \
  mesa-utils \
  zenity)

extract_files () {
  echo
  echo "Extracting backup files..."
  tar -xvf ./backup.tar -C $HOME
  echo "Finished extracting files."
  echo
}

update_system () {
  echo
  echo "Running system updates..."
  sudo apt-get update && sudo apt-get upgrade -y
  echo "System updates completed."
  echo
}

setup_git () {
  echo
  echo "Configuring ssh and git..."
  error_status=false
  msg="    setting permissions for ${SSH_PRIVATE_KEY}..."
  echo "${msg}"
  if chmod 400 "${SSH_PRIVATE_KEY}" ; then
    echo -e "\e[1A\e[K${msg}DONE!"
  else
    echo -e "\e[1A\e[K${msg}FAILED!"
    echo
    echo "*****ERROR*****"
    echo "This script was unable to set the private key persmissions."
    echo "Please check your ssh keys manually."
    echo "*****ERROR*****"
    error_status=true
  fi

  echo "Ssh configuration complete."
  if $error_status ; then
    echo "The script encountered some errors while executing.  You may"
    echo "need to address these manually before you can run git."
  fi
  echo
}

install_packages () {
  packages=$@

  echo
  echo "Installing additional packages..."
  for package in ${packages[@]}
  do
    msg="    ${package}..."
    echo
    echo "${msg}"
    if dpkg --get-selections | grep "^$package[[:space:]]*install$" >/dev/null ; then
      echo -e "\e[1A\e[K${msg}INSTALLED!"
    else
      echo -e "\e[1A\e[K${msg}MISSING!"
      echo "    Installing $package"
      sudo apt-get install $package -y
      echo
      echo
    fi
  done
  echo
  echo "Done installing additional packages."
  echo
}

main () {

  echo "************************************************************"
  echo "***                Crostini Deployment                   ***"
  echo "***                   - INSTALLER -                      ***"
  echo "************************************************************"
  echo
  echo "This script will restore your crostini backup files, update"
  echo "the underlying debian image, setup your ssh keys and git"
  echo "configuration, and install debian packages that are often"
  echo "used but aren't included by default in the vm."
  echo

  extract_files
  update_system
  setup_git
  install_packages ${REQUIRED_PACKAGES[@]}

  echo
  echo "************************************************************"
  echo "***                Crostini Deployment                   ***"
  echo "***             - INSTALLATION COMPLETE -                ***"
  echo "************************************************************"
  echo
  echo "The Crostini deployment script has completed.  Your system"
  echo "is now ready to use."
  echo
  exit 0
}

main
