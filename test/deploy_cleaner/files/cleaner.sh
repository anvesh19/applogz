#!/bin/bash

# Written with passion by @hatedabamboo
# Disk cleaner script with archive, delete or move functionality
# Distributes via systemd timer + service
# Global variables defined in .env file provided in systemd service file

set -eo pipefail

function die() {
  echo "$*"
  exit 1
}

function delete() {
  echo "Deleting files from ${BASEDIR} with time limit of ${MAXAGE} minutes"
  find "${BASEDIR}" \
    -type f \
    -regextype egrep \
    -regex "${FILEMASK}" \
    -mmin "+${MAXAGE}" \
    -not -path '*/.*' \
    -exec rm -f {} \; \
  || die "Error deleting files"
}

function archive() {
  if [ -z ${TARGETDIR} ]; then
    echo "TARGETDIR not set, defaulting to BASEDIR"
    TARGETDIR=${BASEDIR}
  fi
  if [ -z ${DAYS} ]; then
    echo "DAYS not set, defaulting to 1"
    DAYS=1
  fi
  local date=$(date --date="${DAYS} day ago" +'%Y%m%d')
  FILEMASK=".+\_${date}\_.+"

  echo "Archiving files from ${DAYS} days ago"
  if [ ! -d "${TARGETDIR}/${date}" ]; then
    die "Seems like there's no directory to archive files from, exiting"
  fi
  if [ $(ls "${TARGETDIR}/${date}" | wc -l) -eq 0 ]; then
    echo "No files to archive found, exiting"
    rmdir "${TARGETDIR}/${date}"
    exit 0
  fi
  tar czf "${TARGETDIR}/${date}.tar.gz" "${TARGETDIR}/${date}/" || die "Error archiving files"
  if [ $? -eq 0 ]; then
    rm -rf "${TARGETDIR}/${date}/"
  fi
}

function move() {
  if [ -z ${TARGETDIR} ]; then
    echo "TARGETDIR not set, defaulting to BASEDIR"
    TARGETDIR=${BASEDIR}
  fi
  if [ -z ${DAYS} ]; then
    echo "DAYS not set, defaulting to 1"
    DAYS=1
  fi
  local date=$(date --date="${DAYS} day ago" +'%Y%m%d')
  FILEMASK=".+\_${date}\_.+"

  echo "Moving files from ${DAYS} days ago from ${BASEDIR} to ${TARGETDIR}/${date}"
  if [ ! -d ${TARGETDIR} ]; then
    mkdir -p ${TARGETDIR} && echo "${TARGETDIR} was absent, created"
  fi
  mkdir -p "${TARGETDIR}/${date}"
  find "${BASEDIR}" \
    -type f \
    -regextype egrep \
    -regex "${FILEMASK}" \
    -mmin "+${MAXAGE}" \
    -exec mv {} "${TARGETDIR}/${date}" \; \
  || die "Error moving files"
}

if [ "${ACTION}" == "delete" ]; then
  delete
  exit 0
elif [ "${ACTION}" == "archive" ]; then
  move
  archive
  exit 0
elif [ "${ACTION}" == "move" ]; then
  move
  exit 0
else
  echo "Action variable should be set: delete, archive or move"
  exit 1
fi
