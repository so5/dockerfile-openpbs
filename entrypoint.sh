#!/bin/bash
sed -i -e "s/PBS_SERVER=.*/PBS_SERVER=$(hostname)/" -e "s/PBS_START_MOM=0/PBS_START_MOM=1/" /etc/pbs.conf
sed -i "s/\$clienthost .*/\$clienthost $(hostname)/" /var/spool/pbs/mom_priv/config
LANG=C /etc/init.d/pbs start

#enable history
/opt/pbs/bin/qmgr -c "set server job_history_enable=True"
#limit number of waiting job
#  /opt/pbs/bin/qmgr -c 'set queue workq max_queued="[o:PBS_ALL=3]"'

exec /usr/sbin/sshd -D
