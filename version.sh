#!/bin/bash -e

#https://github.com/c9/core

package_name="c9-core"
debian_pkg_name="${package_name}"
package_version="3.1.3168+git20161016"
package_source="${package_name}_${package_version}.orig.tar.xz"
src_dir="${package_name}_${package_version}"

git_repo="https://github.com/c9/core.git"
git_sha="32fc12bf922288d0c2b518c73aa75e19f14bed8b"
reprepro_dir="c/${package_name}"
dl_path=""

#https://github.com/c9/core/commits/master?page=5

#20161114:
#https://github.com/c9/core/compare/30cf22dde99b99d3122b89ca3d29a8f8410cde0b...5d7d4e3b3dab1d781a2b171cf2e75e75b02d483f
#git bisect start
#git bisect bad 32fc12bf922288d0c2b518c73aa75e19f14bed8b
#git bisect good 14f675858be5a639c2991a01ab46ed792dde6723
#git bisect bad a4951f6a5e54525456a3c125972fbcb4ef4b3f24
#git bisect good 49cb02527410890b2ff66524f526dfdfb288d832
#git bisect good 586ea62b291de40bc372e2472541a0383cb6b6b3
#git bisect good 30cf22dde99b99d3122b89ca3d29a8f8410cde0b
#git bisect bad a5e116697c23c8ade368cfe60d6a297e4689c14d
#git bisect bad f69a33d2c847e133c70bfcb63cbb5662b6bcf8d6
#git bisect bad 5d7d4e3b3dab1d781a2b171cf2e75e75b02d483f
# first bad commit: [5d7d4e3b3dab1d781a2b171cf2e75e75b02d483f] git.js doesn't need amd-loader and it's causing a global variable leak which makes mocha tests fail

#20150604: bisected down to this commit...
#https://github.com/c9/core/commit/9e1bb472c6e671bba702dc8824526632f90af89d
