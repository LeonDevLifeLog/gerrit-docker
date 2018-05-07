FROM ubuntu:16.04
MAINTAINER Leon

# Add Gerrit packages repository
RUN echo "deb mirror://mirrorlist.gerritforge.com/deb gerrit contrib" > /etc/apt/sources.list.d/GerritForge.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1871F775

RUN mkdir -p /home/gerrit/.ssh
RUN chown -R gerrit: /home/gerrit/.ssh
RUN adduser gerrit sudo
RUN echo -n 'gerrit:gerrit' | chpasswd
# Enable passwordless sudo for users under the "sudo" group 
RUN sed -i.bkp -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
      /etc/sudoers

# Allow remote connectivity and sudo
RUN apt-get update
RUN apt-key update
RUN apt-get -y install openssh-client sudo

# Install OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN apt-get -y install openjdk-8-jdk
RUN apt-get -y install gerrit=2.15.1-1 && rm -f /var/gerrit/logs/*

USER gerrit
RUN java -jar /var/gerrit/bin/gerrit.war init --batch --install-all-plugins -d /var/gerrit
RUN java -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit

ENV CANONICAL_WEB_URL=

# Allow incoming traffic
EXPOSE 29418 8080

VOLUME ["/home/gerrit/.ssh","/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

# Start Gerrit
CMD git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME:8080/}" && \
    git config -f /var/gerrit/etc/gerrit.config noteDb.changes.autoMigrate true && \
/var/gerrit/bin/gerrit.sh run
