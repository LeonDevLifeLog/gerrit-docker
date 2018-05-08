#!/bin/bash
if [[ ! -e ~/.ssh/id_rsa ]] ; then
	sudo mkdir -p /var/gerrit/.ssh 
	sudo ssh-keygen -q -t rsa -N '' -f /var/gerrit/.ssh/id_rsa
	sudo chown gerrit:gerrit -R /var/gerrit/.ssh
fi
echo "====================================SSH Public Key======================================================"
cat ~/.ssh/id_rsa.pub
echo "====================================SSH Public Key======================================================"
eval $(ssh-agent -s)
echo -n '' | ssh-add
ssh-keyscan -t rsa -p 10022 git.xyz.cn > ~/.ssh/known_hosts
git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME:80/}" && \
git config -f /var/gerrit/etc/gerrit.config noteDb.changes.autoMigrate true && \
/var/gerrit/bin/gerrit.sh run
