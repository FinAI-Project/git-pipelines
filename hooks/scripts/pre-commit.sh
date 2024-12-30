#!/usr/bin/env bash

SCRIPTS_DIR="$(dirname $0)"
RUN_MODS=(
    "pylint --ignore=${VIRTUAL_ENV:-.venv},tests ."
    "pytest"
)

GIT_ROOT=$(git rev-parse --show-toplevel)
if [ -x "$(command -v cygpath)" ]; then
    GIT_ROOT=$(cygpath -u "$GIT_ROOT")
fi

pushd "$GIT_ROOT" >/dev/null
for module_cmd in "${RUN_MODS[@]}"; do
    module_args=($module_cmd)
    module_name=${module_args[0]}
    if ! python -m $module_name --version >/dev/null 2>&1; then
        >&2 echo "No module named $module_name"
        exit 127
    fi
    python -m $module_name "${module_args[@]:1}"
    MOD_EXIT_CODE=$?
    if [ $MOD_EXIT_CODE -ne 0 ]; then
        # NO_TESTS_COLLECTED exception
        if [ "$module_name" = "pytest" ] && [ $MOD_EXIT_CODE -eq 5 ]; then
            continue
        fi
        >&2 echo "$module_name execute failed. Please fix the issues before committing."
        exit $MOD_EXIT_CODE
    fi
done
popd >/dev/null

echo "The pre-commit check was successful."