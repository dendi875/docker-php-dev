#!/bin/bash
if [ ! -d "build" ]; then
	echo 'Please run init.sh in docker-php-dev directory'
	exit
fi
VM_STATUS="$(docker-machine status default)"
if [ "${VM_STATUS}" != "Running" ]; then
	echo 'Docker machine not started'
	exit
fi
# custom working directory
if [ -n "$1" ]; then
	if [ ! -d "$1" ]; then
		mkdir -p "$1"
	fi
	INSTALL_DIR=$PWD
	cd "$1"
	# Copy docker-compose file to working directory
	cp -u "$INSTALL_DIR/docker-compose.yml" docker-compose.yml 2>/dev/null
	if [ 0 -ne "$?" ]; then
		echo "$PWD: working directory not writable"
		exit
	fi
fi
# Check if working dir accessible in Virtualbox machine
docker-machine ssh default "df -P $PWD" 1>/dev/null 2>&1
if [ 0 -ne "$?" ]; then
	FS_NAME=$(df -P . | awk 'END { print $1 }')
	FS_ROOT=$(df -P . | awk 'END { print $6 }')
	echo "#!/bin/sh" > bootsync.sh
	echo "mkdir -p $FS_ROOT" >> bootsync.sh
	echo "mount -t vboxsf -o defaults,uid=\`id -u docker\`,gid=\`id -g docker\` ${FS_ROOT:1} $FS_ROOT" >> bootsync.sh
	docker-machine scp bootsync.sh default:/tmp
	docker-machine ssh default "sudo mv /tmp/bootsync.sh /var/lib/boot2docker"
	rm bootsync.sh
	docker-machine stop default
	if [ ! -z "$VBOX_MSI_INSTALL_PATH" ]; then
		VBOXMANAGE="${VBOX_MSI_INSTALL_PATH}VBoxManage.exe"
	else
		VBOXMANAGE="${VBOX_INSTALL_PATH}VBoxManage.exe"
	fi
	"$VBOXMANAGE" sharedfolder add default --name "${FS_ROOT:1}" --hostpath "$FS_NAME\\" --automount
	docker-machine start default
fi
# Pull service images
docker-compose pull
# Download php source code
if [ ! -d "www" ]; then
	mkdir www
fi
pushd www > /dev/null
git --version 1>/dev/null 2>&1
if [ 0 -eq "$?" ]; then
	# hooks dependency
	php -v > /dev/null
	if [ 0 -eq "$?" ]; then
		# git version greater than 2.9
		HOOKS_PATH=`realpath extra/hooks`
		git config --global core.hooksPath "$HOOKS_PATH"
	fi
	REPOS=('PHP' 'DesignPatternsPHP')
	for REPO in ${REPOS[@]}
	do
		if [ ! -d "$REPO" ]; then
			git clone "git@github.com:dendi875/$REPO.git"
		fi
	done
fi
popd > /dev/null