FROM cassandra:latest

RUN apt update && \
    apt install -y openssh-server sudo && \
    mkdir -p /var/run/sshd && \
    useradd -ms /bin/bash sshuser && \
    echo 'sshuser:password' | chpasswd && \ 
    usermod -aG sudo sshuser 

COPY start.sh /start.sh
RUN chmod +x /start.sh  

CMD [ "/start.sh" ]