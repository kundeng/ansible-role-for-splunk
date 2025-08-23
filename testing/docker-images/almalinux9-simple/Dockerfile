FROM almalinux:9
LABEL maintainer="Splunk Lab Testing"

ENV container=docker

# Install packages needed for SSH and Ansible
RUN INSTALL_PKGS='openssh-server sudo python3 passwd glibc-common initscripts iproute' \
    && dnf makecache && dnf install -y $INSTALL_PKGS \
    && dnf clean all

# Clean up systemd properly (based on proven pattern)
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -print0 | xargs -0 rm -vf

# Setup SSH server and disable PAM for container usage
RUN systemctl enable sshd \
    && ssh-keygen -A \
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config.d/50-redhat.conf

VOLUME ["/sys/fs/cgroup"]
EXPOSE 22
ENTRYPOINT ["/usr/sbin/init"]