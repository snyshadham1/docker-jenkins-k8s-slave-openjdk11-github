FROM dva-registry.internal.salesforce.com/dva/sfdc_centos7_java11_build:21

#Install Docker daemona and add jenkins to docker group
COPY yum_repos/devops.repo /etc/yum.repos.d/
RUN useradd --create-home --shell /bin/bash jenkins && echo "jenkins:jenkins" | chpasswd
RUN yum  -y install yum-plugin-ovl && \
    yum install -y install git sudo which && \
    yum --enablerepo devops -y install docker-ce jq && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/lib/rpm/__db* && \
    echo "jenkins        ALL = (root) NOPASSWD:SETENV: /usr/bin/dockerd, /usr/local/bin/jenkins-slave.sh" > /etc/sudoers.d/jenkins && chmod 440 /etc/sudoers.d/jenkins && \
    usermod -G docker jenkins

#Add sfdc cert and set symlinks
COPY updatecert.sh alt_install.sh /opt/java/
COPY Salesforce_Internal_Root_CA_1.pem Salesforce_Internal_Root_CA_2_Infra.pem Salesforce_Internal_Root_CA_2_Security.pem Salesforce_Legacy_CASFM-00.pem Salesforce_Internal_Root_CA_3.pem \
     /etc/pki/ca-trust/source/anchors/
RUN chmod 755 /opt/java/updatecert.sh && /opt/java/updatecert.sh
RUN chmod 755 /opt/java/alt_install.sh && /opt/java/alt_install.sh

#set locale
RUN echo "LANG=en_US.utf8" >> /etc/locale.conf

#Copy p4 binay
COPY p4 /usr/bin/p4 
RUN chmod 755 /usr/bin/p4

ENV JENKINS_REMOTING_VERSION 4.5
ENV HOME /home/jenkins

WORKDIR /
COPY remoting-4-5.jar /usr/share/jenkins/
RUN chmod 755 /usr/share/jenkins

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
RUN chmod 755 /usr/local/bin/jenkins-slave.sh

RUN rm -f /etc/yum.repos.d/devops.repo

USER jenkins

VOLUME /home/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]

