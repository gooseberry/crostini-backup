#!/usr/bin/env bash
#
# Script to build a self-extracting archive

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variables
set -o nounset
# don't hide errors within pipes
set -o pipefail

readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# script specific variables
BACKUP_FILES=(.ssh \
  .vimrc \
  .gitconfig)

update_backup_files () {

  echo
  echo "Backing up essential system files..."
  
  cd "${script_dir}/payload"

  msg="    Removing old backup files..."
  if [ -e "backup.tar" ]; then
    echo ${msg}
    rm backup.tar
    echo -e "\e[1A\e[K${msg}DONE!"
  fi

  for file in ${BACKUP_FILES[@]}
  do
    tar -rvf backup.tar -C $HOME ${file}
  done

  echo "Essential system files backed-up."
  echo

}

create_payload () {

  echo
  echo "Creating the payload for the self-extracting file..."

  tar cf ../payload.tar ./*
  cd "${script_dir}"

  echo "Payload created."
  echo

}

package_self_extracting_script (){

  echo
  echo "Packaging the self-extracting script."

  msg="    Compressing payload.tar..."
  echo ${msg}
  if [ -e "payload.tar" ]; then
    gzip payload.tar
    echo -e "\e[1A\e[K${msg}DONE!"
  else
    echo -e "\e[1A\e[K${msg}FAILED!"
    echo "payload.tar does not exist"
    exit 1
  fi

  msg="    Appending payload to the decompression script..."
  echo ${msg}
  if [ -e "payload.tar.gz" ]; then
    cat decompress.sh payload.tar.gz > $HOME/deploy.sh
    echo -e "\e[1A\e[K${msg}DONE!"
  else
    echo -e "\e[1A\e[K${msg}FAILED!"
    echo "payload.tar.gz does not exist"
    exit 1
  fi

}

clean_up () {

  msg="    Removing redundant copy of payload.tar.gz..."
  echo ${msg}
  if [ -e "payload.tar.gz" ]; then
    rm payload.tar.gz
    echo -e "\e[1A\e[K${msg}DONE!"
  else
    echo -e "\e[1A\e[K${msg}FAILED!"
    echo "payload.tar.gz does not exist"
  fi

  msg="    Removing redundant copy of backup.tar..."
  echo ${msg}
  cd "${script_dir}/payload"
  if [ -e "backup.tar" ]; then
    rm backup.tar
    echo -e "\e[1A\e[K${msg}DONE!"
  else
    echo -e "\e[1A\e[K${msg}FAILED!"
    echo "backup.tar does not exist"
  fi
}

main () {

  update_backup_files
  create_payload
  package_self_extracting_script
  clean_up
  echo
  echo "***************************************************"
  echo "***          Self-Extracting Deployment         ***"
  echo "***                  COMPLETED                  ***"
  echo "***************************************************"
  echo
  echo "The script has successfully created a self-extracting"
  echo "script to restore your current Crostini environment"
  echo "$HOME/deploy.sh"
  echo "Use this file to restore the current crostini"
  echo "environment in your new build."
  echo
  echo "Enjoy!"
  exit 0
}

main
