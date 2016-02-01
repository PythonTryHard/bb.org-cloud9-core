#!/bin/bash -e

#https://github.com/c9/core

package_name="c9-core"
debian_pkg_name="${package_name}"
package_version="3.1.1243+git20160130"
package_source="${package_name}_${package_version}.orig.tar.xz"
src_dir="${package_name}_${package_version}"

git_repo="https://github.com/c9/core.git"
git_sha="7356b8c91334f9d69eefe56b84ae47dce606f253"
reprepro_dir="c/${package_name}"
dl_path=""

#https://github.com/c9/core/commits/master?page=5

#20150604: bisected down to this commit...
#https://github.com/c9/core/commit/9e1bb472c6e671bba702dc8824526632f90af89d
