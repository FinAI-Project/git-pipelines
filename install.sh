#!/usr/bin/env bash

GITOPS_HTTPS_URL="https://github.com/FinAI-Project/git-pipelines.git"
GITOPS_SSH_URL="git@github.com:FinAI-Project/git-pipelines.git"
GITOPS_HOME="$HOME/.git-pipelines"

# Dependency checks
git --version
GIT_EXIT_CODE=$?
if [ $GIT_EXIT_CODE -ne 0 ]; then
    >&2 echo "Git not installed. Please install Git first."
    exit $GIT_EXIT_CODE
fi
for pybin in python python3 py; do
    $pybin --version
    PYTHON_EXIT_CODE=$?
    if [ $PYTHON_EXIT_CODE -eq 0 ]; then
        PYTHON_BIN=$pybin
        break
    fi
done
if [ $PYTHON_EXIT_CODE -ne 0 ]; then
    >&2 echo "Python not installed. Please install Python first."
    exit $PYTHON_EXIT_CODE
fi
$PYTHON_BIN -m ensurepip
PIP_EXIT_CODE=$?
if [ $PIP_EXIT_CODE -ne 0 ]; then
    >&2 echo "pip install failed."
    exit $PIP_EXIT_CODE
fi

set -e
# Clone Git repo
if [ ! -d "$GITOPS_HOME/.git" ] || [ ! -z "$GIT_URL_SCHEMA" ]; then
    if [ -d "$GITOPS_HOME" ]; then
        rm -rf "$GITOPS_HOME"
    fi
    GITOPS_URL=$GITOPS_HTTPS_URL
    if [ "$GIT_URL_SCHEMA" = "ssh" ]; then
        GITOPS_URL=$GITOPS_SSH_URL
    fi
    pushd $(dirname "$GITOPS_HOME") >/dev/null
    git clone "$GITOPS_URL" $(basename "$GITOPS_HOME")
    popd >/dev/null

    # Git configurations
    git config set --global core.hooksPath "~/.git-pipelines/hooks"
else
    pushd "$GITOPS_HOME" >/dev/null
    git pull -q origin main
    popd >/dev/null
fi

# Ensure permissions
chmod a+x $GITOPS_HOME/*.sh
chmod a+x $GITOPS_HOME/hooks/*
chmod a+x $GITOPS_HOME/hooks/scripts/*.sh

# Check utilities
if [ -z "$SKIP_INSTALL_DEPENDENCIES" ]; then
    DEPEND_UTILS=(pylint pytest)
    SCRIPTS_DIR="$(dirname $0)/hooks/scripts"
    INSTALL_UTILS=()

    # Disable virtual env
    if [ -n "$VIRTUAL_ENV" ]; then
        OLD_PATH=$PATH
        PATH=$(echo $PATH | sed -e "s,$VIRTUAL_ENV/bin:,,g")
    fi

    for pkg_name in "${DEPEND_UTILS[@]}"; do
        "$SCRIPTS_DIR/get-package-command.sh" $pkg_name >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            INSTALL_UTILS+=("$pkg_name")
        fi
    done

    # Install utilities
    if [ ${#INSTALL_UTILS[@]} -gt 0 ]; then
        $PYTHON_BIN -m pip install $INSTALL_UTILS
    fi

    # Enable virtual env
    if [ -n "$OLD_PATH" ]; then
        PATH=$OLD_PATH
    fi
fi

echo "The installation of Git pipelines has been completed."