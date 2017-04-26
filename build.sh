#!/bin/bash -e

. version.sh
arch=$(uname -m)

DIR="$PWD"

distro=$(lsb_release -cs)

git config --global user.name "Robert Nelson"
git config --global user.email robertcnelson@gmail.com

echo "stop: cloud9*"
sudo systemctl stop cloud9.service || true
sudo systemctl stop cloud9.socket || true

if [ -d ${DIR}/${package_name}_${package_version} ] ; then
	rm -rf ${DIR}/${package_name}_${package_version} || true
fi

if [ ! -d ${DIR}/git/ ] ; then
	git clone ${git_repo} ${DIR}/git/
fi

if [ -d /opt/cloud9 ] ; then
	sudo rm -rf /opt/cloud9/
fi

sudo mkdir -p /opt/cloud9 || true
sudo chown -R 1000:1000 /opt/cloud9

git clone --reference ${DIR}/git/ ${git_repo} /opt/cloud9/

cd /opt/cloud9/

git checkout ${git_sha} -b tmp

git_apply="git apply"
if [ ! "x${arch}" = "xarmv7l" ] ; then
	git_apply="git am --whitespace=fix"
fi

pwd

wfile="0001-Revert-git.js-doesn-t-need-amd-loader-and-it-s-causi.patch"
echo "1: patch -p1 < ${DIR}/patches/${wfile}"
${git_apply} ${DIR}/patches/${wfile}

wfile="0002-bb.org-defaults.patch"
echo "2: patch -p1 < ${DIR}/patches/${wfile}"
if [ ! "x${arch}" = "xarmv7l" ] ; then
	sed -i -e 's:process.env.HOME + "/.c9/:"/opt/cloud9/build/standalonebuild/:g' node_modules/vfs-local/localfs.js
	sed -i -e 's:process.env.HOME;:"/opt/cloud9/";:g' settings/standalone.js
	sed -i -e 's:workspaceDir,:"/var/lib/cloud9",:g' settings/standalone.js
	sed -i -e 's:8181,:3000,:g' settings/standalone.js
	sed -i -e 's:path.join(installPath, "bin/tmux"),:"/usr/bin/tmux",:g' settings/standalone.js
	sed -i -e 's:path.join(__dirname, "../node_modules/nak/bin/nak"),:"/opt/cloud9/build/standalonebuild/node_modules/nak/bin/nak",:g' settings/standalone.js
	sed -i -e 's/packed: false,/packed: true,/g' settings/standalone.js
	git commit -a -m 'bb.org-defaults' -s
else
	${git_apply} ${DIR}/patches/${wfile}
fi

wfile="0003-bb.org-use-systemd.patch"
echo "3: patch -p1 < ${DIR}/patches/${wfile}"
if [ ! "x${arch}" = "xarmv7l" ] ; then
	patch -p1 < ${DIR}/patches/${wfile}
	git commit -a -m 'bb.org: use systemd' -s
else
	${git_apply} ${DIR}/patches/${wfile}
fi

wfile="0004-core-dont-updateCore-we-checkout-a-sha-commit-and-do.patch"
echo "4: patch -p1 < ${DIR}/patches/${wfile}"
if [ ! "x${arch}" = "xarmv7l" ] ; then
	sed -i -e 's:updateCore || true:#updateCore || true:g' scripts/install-sdk.sh
	git commit -a -m 'core dont updateCore we checkout a sha commit and dont autorun' -s
else
	${git_apply} ${DIR}/patches/${wfile}
fi

wfile="0005-un-home.patch"
echo "5: patch -p1 < ${DIR}/patches/${wfile}"
${git_apply} ${DIR}/patches/${wfile}

if [ ! "x${arch}" = "xarmv7l" ] ; then
	git format-patch -5 -o ${DIR}/patches/
#	exit
fi

mkdir -p ~/.c9/
echo 1 > ~/.c9/installed

echo ""
echo "build: [./scripts/install-sdk.sh]"
./scripts/install-sdk.sh

echo ""
if [ "x${arch}" = "xarmv7l" ] ; then
	echo "build: [npm install --arch=armhf]"
	npm install --arch=armhf
else
	echo "build: [npm install]"
	npm install
fi

rm -Rf build/standalone
sync
sync

echo ""
echo "build: [./scripts/makestandalone.sh --compress]"
./scripts/makestandalone.sh --compress

echo ""
echo "build: [./build/build-standalone.sh]"
./build/build-standalone.sh

cd ./build/

if [ ! "x${arch}" = "xarmv7l" ] ; then
	if [ -d standalonebuild ] ; then

		cd ./standalonebuild/

		npm install systemd
		npm install heapdump connect-flash ua-parser-js engine.io-client simplefunc

#		#https://github.com/c9/install/blob/master/install.sh

		project="nak"
		echo ""
		echo "Build: [npm install ${project}]"
		npm install ${project}

		project="pty.js"
		echo ""
		echo "Build: [npm install ${project}]"
		npm install ${project}

		#Strip .git directories, saves over 20Mb
		cd plugins/
		find . -name ".git" | xargs rm -rf
		cd ../

		cd ../

		nodejs_version=$(nodejs --version)

		if [ ! -d /opt/cloud9/.c9/node/bin/ ] ; then
			mkdir -p /opt/cloud9/.c9/node/bin/ || true
		fi
		ln -sf /usr/bin/node /opt/cloud9/.c9/node/bin/node

		echo 1 > /opt/cloud9/.c9/installed

		rm -rf ~/.c9/ || true

		if [ -d /var/lib/cloud9/ ] ; then
			sudo rm -rf /var/lib/cloud9/ || true
		fi

		sudo mkdir -p /var/lib/cloud9/ || true
		sudo chown -R 1000:1000 /var/lib/cloud9/ || true

		sudo cp -v ${DIR}/systemd/cloud9 /etc/default/
		sudo cp -v ${DIR}/systemd/cloud9.socket /lib/systemd/system/
		sudo cp -v ${DIR}/systemd/cloud9.service /lib/systemd/system/
		sudo systemctl daemon-reload || true
		sudo systemctl enable cloud9.socket || true
		sudo systemctl restart cloud9.socket || true
	fi
else
	if [ -d standalonebuild ] ; then

		cd ./standalonebuild/
		npm install systemd --arch=armhf
		npm install heapdump connect-flash ua-parser-js engine.io-client simplefunc --arch=armhf

#		#https://github.com/c9/install/blob/master/install.sh

		project="nak"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="pty.js"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		#Strip .git directories, saves over 20Mb
		cd plugins/
		find . -name ".git" | xargs rm -rf
		cd ../

		cd ../

		nodejs_version=$(nodejs --version)

		tar -cJvf ${package_name}_${package_version}-${nodejs_version}-build.tar.xz standalonebuild/

		if [ ! -f ./deploy/${distro}/${package_name}_${package_version}-${nodejs_version}-build.tar.xz ] ; then
			cp -v /opt/cloud9/build/${package_name}_${package_version}-${nodejs_version}-build.tar.xz ${DIR}/deploy/${distro}/
			echo "New Build: ${package_name}_${package_version}-${nodejs_version}-build.tar.xz"
		fi
	fi
fi

cd ${DIR}/


