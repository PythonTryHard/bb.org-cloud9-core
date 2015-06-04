#!/bin/bash -e

#https://github.com/c9/core

package_name="c9-core"
debian_pkg_name="${package_name}"
package_version="3.0.1+git20150603"
package_source="${package_name}_${package_version}.orig.tar.xz"
src_dir="${package_name}_${package_version}"

git_repo="https://github.com/c9/core.git"
git_sha="1412e15569b76445f2aa9049c61655b69aa7a105"
reprepro_dir="c/${package_name}"
dl_path=""
