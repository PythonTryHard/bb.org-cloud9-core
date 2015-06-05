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

#20150517
#do not load pty.js when testing connection since that can crash node …
echo "revert: [https://github.com/c9/core/commit/9a865df0ece860f15c3aea5284a6c490a7a9d920]"
git revert --no-edit 9a865df0ece860f15c3aea5284a6c490a7a9d920

#20150528
#plugins/c9.vfs.extend/collab-server.js removed in:
#https://github.com/c9/core/commit/3931e937cd293a7d4efa738987da5597a1dbe5a8

#20150513
#echo ""
#jsonalyzer calls initDB before checkInstall
#echo "revert: [https://github.com/c9/core/commit/80c06144f934c4d5e6d1d8de36fdd3e865c19e2d]"
#git revert --no-edit 80c06144f934c4d5e6d1d8de36fdd3e865c19e2d

echo ""
#send more errors from worker to raygun
echo "revert: [https://github.com/c9/core/commit/8a6d9ac4b90dd27c091f9ef91b37669203b0fafd]"
git revert --no-edit 8a6d9ac4b90dd27c091f9ef91b37669203b0fafd

echo ""
#use runInThisContext instead of runInNewContext
echo "revert: [https://github.com/c9/core/commit/8091c4b789bcec53f7c8dc610a46efc11f5d9b50]"
git revert --no-edit 8091c4b789bcec53f7c8dc610a46efc11f5d9b50

#20150510
#echo ""
#fsOptions.homeDir is missing on ssh workspaces
#echo "revert: [https://github.com/c9/core/commit/2c273b97a948f4a318ec73d826e1e888c676474b]"
#git revert --no-edit 2c273b97a948f4a318ec73d826e1e888c676474b

#20150509
#echo ""
#use node from c9 dir
#echo "revert: [https://github.com/c9/core/commit/9e1bb472c6e671bba702dc8824526632f90af89d]"
#git revert --no-edit 9e1bb472c6e671bba702dc8824526632f90af89d

git_apply="git apply"

#git_apply="git am"

echo ""
echo "patches"

${git_apply} ${DIR}/patches/0001-Revert-use-node-from-c9-dir.patch

${git_apply} ${DIR}/patches/0001-bb.org-defaults.patch
if [ "x${arch}" = "xarmv7l" ] ; then
	${git_apply} ${DIR}/patches/0002-bb.org-use-systemd.patch
fi
${git_apply} ${DIR}/patches/0003-core-dont-updateCore-we-checkout-a-sha-commit-and-do.patch

mkdir -p ~/.c9/
touch ~/.c9/installed

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

		#https://github.com/c9/install/blob/master/install.sh

		project="nak"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="pty.js@0.2.7-1"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="coffee"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="less"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="sass"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="typescript"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

		project="stylus"
		echo ""
		echo "Build: [npm install ${project} --arch=armhf]"
		npm install ${project} --arch=armhf

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

