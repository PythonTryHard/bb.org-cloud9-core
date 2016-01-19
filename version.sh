#!/bin/bash -e

#https://github.com/c9/core

package_name="c9-core"
debian_pkg_name="${package_name}"
package_version="3.1.1084+git20160118"
package_source="${package_name}_${package_version}.orig.tar.xz"
src_dir="${package_name}_${package_version}"

git_repo="https://github.com/c9/core.git"
git_sha="1fdcebb0e0e42b9aa3cd31c206b01798c0292c0a"
reprepro_dir="c/${package_name}"
dl_path=""

#https://github.com/c9/core/commits/master?page=5

#20150604: bisected down to this commit...
#https://github.com/c9/core/commit/9e1bb472c6e671bba702dc8824526632f90af89d
