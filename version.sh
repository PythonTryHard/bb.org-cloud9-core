#!/bin/bash -e

#https://github.com/c9/core

package_name="c9-core"
debian_pkg_name="${package_name}"
package_version="3.0.2745+git20150920"
package_source="${package_name}_${package_version}.orig.tar.xz"
src_dir="${package_name}_${package_version}"

git_repo="https://github.com/c9/core.git"
git_sha="35cba3911cfe853488b591f64de4f89339340424"
reprepro_dir="c/${package_name}"
dl_path=""

#https://github.com/c9/core/commits/master?page=5

#20150604: bisected down to this commit...
#https://github.com/c9/core/commit/9e1bb472c6e671bba702dc8824526632f90af89d
