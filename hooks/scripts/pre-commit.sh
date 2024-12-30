#!/usr/bin/env bash

SCRIPTS_DIR="$(dirname $0)"
RUN_UTILS=(
    "pylint ."
    "pytest"
)

GIT_ROOT=$(git rev-parse --show-toplevel)
if [ -x "$(command -v cygpath)" ]; then
    GIT_ROOT=$(cygpath -u "$GIT_ROOT")
fi

pushd "$GIT_ROOT" >/dev/null
for util_cmd in "${RUN_UTILS[@]}"; do
    util_args=($util_cmd)
    util_name=${util_args[0]}
    util_path=$("$SCRIPTS_DIR/get-package-command.sh" $util_name)
    if [ $? -ne 0 ]; then
        exit 127
    fi
    $util_path "${util_args[@]:1}"
    UTIL_EXIT_CODE=$?
    if [ $UTIL_EXIT_CODE -ne 0 ]; then
        # NO_TESTS_COLLECTED exception
        if [ "$util_name" = "pytest" ] && [ $UTIL_EXIT_CODE -eq 5 ]; then
            continue
        fi
        >&2 echo "$util_name execute failed. Please fix the issues before committing."
        exit $UTIL_EXIT_CODE
    fi
done
popd >/dev/null

echo "The pre-commit check was successful."