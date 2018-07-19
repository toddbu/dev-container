# Forked from https://github.com/pwntr/samba-alpine-docker

FROM alpine:latest
MAINTAINER Todd Buiten <spam@buiten.com>

# Update the base system
RUN apk update && apk upgrade

# Install samba and supervisord and clear the cache afterwards
RUN apk add bash nodejs nodejs-npm openssh samba samba-common-tools supervisor && rm -rf /var/cache/apk/*

# Change the default port for SSH from 22 to 2223
RUN sed -i 's/#Port 22/Port 2223/g' /etc/ssh/sshd_config; \
 ssh-keygen -A

# Copy config files for samba and supervisord
COPY samba.ini /etc/supervisor.d/
COPY ssh.ini /etc/supervisor.d/
COPY smb.conf /etc/samba/

# Add a non-root user and group called "dev" gid/uid set to 1000
RUN addgroup -g 1000 dev && adduser -D -G dev -u 1000 -s /bin/bash dev
RUN echo -e "dev123!\ndev123!" | passwd dev

# Create a samba user matching our user from above with a very simple password ("letsdance")
RUN echo -e "letsdance\nletsdance" | smbpasswd -a -s -c /etc/samba/smb.conf dev

# Volume mappings
VOLUME /etc/supervisor.d /etc/ssh /etc/samba /home/dev

# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd)
EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
