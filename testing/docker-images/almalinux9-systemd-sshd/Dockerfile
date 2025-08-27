FROM almalinux:9
ENV container=docker

RUN dnf -y install systemd systemd-sysv openssh-server sudo python3 passwd && \
    dnf clean all

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do \
      [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
          /etc/systemd/system/*.wants/* \
          /lib/systemd/system/local-fs.target.wants/* \
          /lib/systemd/system/sockets.target.wants/*udev* \
          /lib/systemd/system/sockets.target.wants/*initctl* \
          /lib/systemd/system/basic.target.wants/*

RUN mkdir /var/run/sshd && \
    ssh-keygen -A && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's/^UsePAM no$/#UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd

RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# Use distro-default PAM configuration for sudo

# Relax pam_sepermit in sshd PAM stack to avoid account-phase denial for non-root users in container context
RUN sed -r -i 's/^account\s+required\s+pam_sepermit\.so/account    optional     pam_sepermit.so/' /etc/pam.d/sshd || true

# Fix systemd to allow unprivileged user login
# Enable systemd-user-sessions service by creating symlink manually
RUN ln -sf /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service

VOLUME ["/sys/fs/cgroup"]
EXPOSE 22
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]