#!/bin/bash -e

#https://github.com/c9/core

package_name="c9v3"
debian_pkg_name="${package_name}"
package_version="3.0.1-git20150223"
package_source="${package_name}_${package_version}.orig.tar.xz"
src_dir="${package_name}_${package_version}"

git_repo="https://github.com/c9/core.git"
git_sha="c552c9b6ccab22f0937f951a6c4b53beb8f26b51"
reprepro_dir="c/${package_name}"
dl_path=""

debian_version="${package_version}-1"
debian_patch=""
debian_diff=""

wheezy_version="~bpo70+20141006+1"
jessie_version="~20141123+1"
