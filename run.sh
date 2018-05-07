#!/bin/bash
file="~/.ssh/id_rsa"
if [ ! -f "$file" ]; then
	mkdir -p ~/.ssh 
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa
fi
echo "====================================ssh Public key======================================================"
cat ~/.ssh/id_rsa.pub
echo "====================================ssh Public key======================================================"
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
ssh-keyscan -t -p 10022 rsa git.xyz.cn > ~/.ssh/known_hosts
git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME:8080/}" && \
git config -f /var/gerrit/etc/gerrit.config noteDb.changes.autoMigrate true && \
/var/gerrit/bin/gerrit.sh run
