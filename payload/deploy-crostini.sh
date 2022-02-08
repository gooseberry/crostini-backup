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
REQUIRED_PACKAGES=(lsb-release \
  vim \
  mesa-utils \
  apt-file)

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
