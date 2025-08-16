FROM cassandra:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1337 cassandra  || true && \
    mkdir -p /home/cassandra/.ssh && \
    chown cassandra:cassandra /home/cassandra/.ssh && \
    chmod 700 /home/cassandra/.ssh

COPY id_rsa.pub /tmp/id_rsa.pub
RUN cat /tmp/id_rsa.pub >> /home/cassandra/.ssh/authorized_keys && \
    chown cassandra:cassandra /home/cassandra/.ssh/authorized_keys && \
    chmod 600 /home/cassandra/.ssh/authorized_keys && \
    rm /tmp/id_rsa.pub

RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    sed -i \
        -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' \
        -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' \
        /etc/ssh/sshd_config

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]