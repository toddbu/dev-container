# Forked from https://github.com/pwntr/samba-alpine-docker

FROM alpine:latest
MAINTAINER Todd Buiten <spam@buiten.com>

# update the base system
RUN apk update && apk upgrade

# install samba and supervisord and clear the cache afterwards
RUN apk add bash samba samba-common-tools supervisor && rm -rf /var/cache/apk/*

# copy config files for samba and supervisord
COPY smb.conf /etc/samba/
COPY samba.ini /etc/supervisor.d/

# add a non-root user and group called "dev" gid/uid set to 1000
RUN addgroup -g 1000 dev && adduser -D -G dev -u 1000 dev
RUN echo -e "dev\ndev" | passwd dev

# create a samba user matching our user from above with a very simple password ("letsdance")
RUN echo -e "letsdance\nletsdance" | smbpasswd -a -s -c /etc/samba/smb.conf dev

# volume mappings
VOLUME /etc/supervisor.d /etc/samba /home/dev

# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd)
EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
