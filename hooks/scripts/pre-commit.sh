#!/usr/bin/env bash

YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
SCRIPTS_DIR="$(dirname $0)"
CONFIG_DIR="$(realpath $SCRIPTS_DIR/../conf)"
RUN_MODS=(
    "pylint ."
    "pytest"
)
export PYLINTRC="$CONFIG_DIR/pylintrc"

GIT_ROOT=$(git rev-parse --show-toplevel)
if [ -x "$(command -v cygpath)" ]; then
    GIT_ROOT=$(cygpath -u "$GIT_ROOT")
fi

pushd "$GIT_ROOT" >/dev/null
for module_cmd in "${RUN_MODS[@]}"; do
    module_args=($module_cmd)
    module_name=${module_args[0]}
    if ! python -c "import $module_name" >/dev/null 2>&1; then
        if ! python -m pip install $module_name >/dev/null 2>&1; then
            >&2 echo "$module_name install failed. Please install it manually, e.g., pip install $module_name"
            exit 127
        fi
    fi
    MOD_OUTPUT=$(python -m $module_name "${module_args[@]:1}" 2>&1)
    MOD_EXIT_CODE=$?
    if [ $MOD_EXIT_CODE -ne 0 ]; then
        # NO_TESTS_COLLECTED exception
        if [ "$module_name" = "pytest" ] && [ $MOD_EXIT_CODE -eq 5 ]; then
            continue
        fi
        >&2 echo "$module_name checks failed. Please fix the issues before committing."
        >&2 echo "$MOD_OUTPUT"
        if [ -f pyproject.toml ]; then
            module_conf="pyproject.toml"
        elif [ "$module_name" = "pylint" ]; then
            module_conf="pylintrc"
        elif [ "$module_name" = "pytest" ]; then
            module_conf="pytest.ini"
        fi
        >&2 echo
        >&2 echo "Tips: You can customize the $module_name configuration by editing ${YELLOW}${module_conf}${RESET} to pass the checks."
        if [ ! -f $module_conf ]; then
            >&2 echo "Tips: You can copy the default configuration file from '$CONFIG_DIR/$module_conf' using the following command:"
            >&2 echo "    cp '$CONFIG_DIR/$module_conf' ."
        fi
        exit $MOD_EXIT_CODE
    fi
done
popd >/dev/null

echo "The pre-commit check was successful."