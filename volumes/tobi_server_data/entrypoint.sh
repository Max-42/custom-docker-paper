#!/bin/sh
set -e

DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
    echo "First start of the docker container, start initialization process..."

    USER_ID=${PUID:-9001}
    GROUP_ID=${PGID:-9001}
    echo "Starting with $USER_ID:$GROUP_ID (UID:GID)"

    addgroup -g $GROUP_ID $DOCKER_GROUP
    adduser -s /bin/sh -u $USER_ID -G $DOCKER_GROUP -D $DOCKER_USER

    chown -vR $USER_ID:$GROUP_ID /opt/minecraft
    chmod -vR ug+rwx /opt/minecraft
    chown -vR $USER_ID:$GROUP_ID /data
    echo "First start of the docker container, start initialization process..."
fi

export HOME=/home/$DOCKER_USER

echo "Skipping wait time for database warmup..."


echo "Ready..."
exec su-exec $DOCKER_USER \

    tmux \
      new-session  -s tobi-server "iftop -i eth1 -f 'dst port 25565' ; read" \; \
      split-window /usr/sbin/sshd && /opt/openjdk-16/bin/java -jar \
        -Xms$MEMORYSIZE \
        -Xmx$MEMORYSIZE \
        $JAVAFLAGS /mc/paperspigot.jar --nojline nogui\
      ; read \; \
      select-layout even-horizontal