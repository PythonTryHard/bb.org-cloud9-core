#!/bin/bash -e

. version.sh
arch=$(uname -m)

DIR="$PWD"

if [ -d ${DIR}/${package_name}_${package_version} ] ; then
	rm -rf ${DIR}/${package_name}_${package_version} || true
fi

if [ ! -d ${DIR}/git/ ] ; then
	git clone ${git_repo} ${DIR}/git/
fi

git clone --reference ${DIR}/git/ ${git_repo} ${package_name}_${package_version}

cd ${package_name}_${package_version}/

git checkout ${git_sha} -b tmp

git_apply="git apply"
#git_apply="git am --whitespace=fix"

${git_apply} ${DIR}/patches/0001-bb.org-big-revert.patch

${git_apply} ${DIR}/patches/0002-bb.org-defaults.patch
if [ "x${arch}" = "xarmv7l" ] ; then
	${git_apply} ${DIR}/patches/0003-bb.org-use-systemd.patch
fi
${git_apply} ${DIR}/patches/0004-core-dont-updateCore-we-checkout-a-sha-commit-and-do.patch

#git format-patch -4 -o ${DIR}/patches/
#exit

mkdir -p ~/.c9/
echo 1 > ~/.c9/installed

echo ""
echo "build: [./scripts/install-sdk.sh]"
./scripts/install-sdk.sh

if [ "x${arch}" = "xarmv7l" ] ; then
	echo ""
	echo "build: [npm install --arch=armhf]"
	npm install --arch=armhf
fi

if [ ! "x${arch}" = "xarmv7l" ] ; then
	node server.js -p 8181 -l 0.0.0.0 -a :
else
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
	if [ -d standalonebuild ] ; then

		cd ./standalonebuild/
		npm install systemd --arch=armhf
		npm install heapdump connect-flash ua-parser-js engine.io-client simplefunc --arch=armhf

		#Strip .git directories, saves over 20Mb
		cd plugins/
		find . -name ".git" | xargs rm -rf
		cd ../

		cd ../

		tar -cJvf ${package_name}_${package_version}-build.tar.xz standalonebuild/
		cp -v ${package_name}_${package_version}-build.tar.xz /mnt/farm/testing/
	fi
fi

cd ${DIR}/

