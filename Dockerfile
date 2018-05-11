FROM ubuntu:16.04
MAINTAINER Leon

# Add Gerrit packages repository
RUN echo "deb mirror://mirrorlist.gerritforge.com/deb gerrit contrib" > /etc/apt/sources.list.d/GerritForge.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1871F775

# Allow remote connectivity and sudo
RUN apt-get update
RUN apt-key update
RUN apt-get -y install openssh-client sudo wget vim

# Install OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN apt-get -y install openjdk-8-jdk
RUN apt-get -y install gerrit=2.15.1-1 && rm -f /var/gerrit/logs/*


RUN mkdir -p /home/gerrit/.ssh
RUN chown -R gerrit: /home/gerrit/.ssh
RUN adduser gerrit sudo
RUN echo -n 'gerrit:gerrit' | chpasswd
# Enable passwordless sudo for users under the "sudo" group 
RUN sed -i.bkp -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
      /etc/sudoers


USER gerrit
RUN mkdir /var/gerrit/plugins && \
    wget -O /var/gerrit/plugins/reviewers.jar https://gerrit-ci.gerritforge.com/view/Plugins-stable-2.15/job/plugin-reviewers-bazel-stable-2.15/lastSuccessfulBuild/artifact/bazel-genfiles/plugins/reviewers/reviewers.jar && \
    wget -O /var/gerrit/plugins/avatars_external.jar https://gerrit-ci.gerritforge.com/view/Plugins-stable-2.15/job/plugin-avatars-external-bazel-master-stable-2.15/lastSuccessfulBuild/artifact/bazel-genfiles/plugins/avatars-external/avatars-external.jar 

RUN java -jar /var/gerrit/bin/gerrit.war init --batch --install-all-plugins -d /var/gerrit
RUN java -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit

ENV CANONICAL_WEB_URL=

# Allow incoming traffic
EXPOSE 29418 8080

VOLUME ["/var/gerrit/.ssh","/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]
ADD run.sh /var/gerrit/run.sh
# Start Gerrit
CMD bash /var/gerrit/run.sh
