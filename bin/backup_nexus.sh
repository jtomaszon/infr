#!/bin/bash

### Local Variables
localHost="$(hostname)"
localPath="/opt/sonatype-work/"
includeFile="/root/bin/inc/nexus.include"

### Backup Server Variables
bckUser="backups"
bckKey="/root/.ssh/keys/backup.id_rsa"
bckHost="172.16.84.70"
bckPath="${localHost}${localPath}"

### Binaries Constants
MKDIR=$(which mkdir)
SSH=$(which ssh)
TAR=$(which tar)
TAR_OPTS="-cvzf"
RSYNC=$(which rsync)
RSYNC_OPTS="-avz --delete --include-from"
LOGFILE="/var/log/backup_nexus.log"


### cmd
${SSH} -i ${bckKey} ${bckUser}@${bckHost} ${MKDIR} -p ${bckPath}
${RSYNC} ${RSYNC_OPTS} ${includeFile} -e "${SSH} -i ${bckKey}" ${localPath} ${bckUser}@${bckHost}:${bckPath} >> ${LOGFILE}

if [ $? -eq 0 ]; then
  ${SSH} -i ${bckKey} ${bckUser}@${bckHost} ${TAR} ${TAR_OPTS} ${localHost}.$(date +%Y%m%d).tgz ${localHost} >> ${LOGFILE}
  if [ $? -eq 0 ]; then
    ${SSH} -i ${bckKey} ${bckUser}@${bckHost} rm -rf ${localHost}
      if [ $? -eq 0 ]; then
        echo "Cleanup was successed!" >> ${LOGFILE}
      else
        echo "Backup was done with errors!  Check CLEANUP process" >> ${LOGFILE}
	exit 10
      fi
  else
    echo "Backup failed!  Check TAR process" >> ${LOGFILE}
    exit 2
  fi
else
  echo "Backup failed!  Check RSYNC process" >> ${LOGFILE}
  exit 1
fi

echo "Backup was done without errors!" >> ${LOGFILE}
exit 0
