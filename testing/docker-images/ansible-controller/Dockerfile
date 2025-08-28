FROM splunk-base-ubuntu2204:latest

# Install debugging tools, nginx, and prepare for Node.js 18
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg iproute2 net-tools nginx apache2-utils ansible && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      nodejs build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Global install of wetty (requires Node >= 18)
# Pin to 2.6.0 (known good)
RUN npm install -g wetty@2.6.0 && \
    ln -sf /usr/bin/node /usr/local/bin/node || true

# Systemd adjustments: enable nginx
RUN systemctl enable nginx || true

EXPOSE 22 3000
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]
