#!/usr/bin/env bash

pkg_name="$1"
if [ -x "$(command -v pylint)" ]; then
    echo "$pkg_name"
    exit
fi

if [ "$OS" = "Windows_NT" ]; then
    user_site_path=$(python -m site --user-site)
    if [ -x "$(command -v cygpath)" ]; then
        user_site_path=$(cygpath -u "$user_site_path")
    fi
    user_site_parent=$(dirname "$user_site_path")
    pkg_bin="$user_site_parent/scripts/$pkg_name.exe"
else
    pkg_bin="$(python -m site --user-base)/bin/$pkg_name"
fi
if [ -x "$pkg_bin" ]; then
    echo "$pkg_bin"
    exit
fi

remote_url=$(git config remote.origin.url)
if [[ "$remote_url" == https://* ]] || [ -z "$remote_url" ]; then
    GIT_URL_SCHEMA="https"
else
    GIT_URL_SCHEMA="ssh"
fi
>&2 echo "$pkg_name is not installed. You can reinstall git pipelines by using the following script: "
>&2 echo "curl -fsSL https://github.com/FinAI-Project/git-pipelines/raw/main/install.sh | GIT_URL_SCHEMA=$GIT_URL_SCHEMA bash"
exit 127