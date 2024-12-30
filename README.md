# Git pipelines

## Prerequisite

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   Python
    - [Using Python on Unix platforms](https://docs.python.org/3/using/unix.html)
    - [Using Python on Windows](https://docs.python.org/3/using/windows.html)
    - [Using Python on macOS](https://docs.python.org/3/using/mac.html)

## Initialize Git pipelines

To install the required components, you can use the following command:

```sh
curl -fsSL https://github.com/FinAI-Project/git-pipelines/raw/main/install.sh | bash
```

By default, the above script performs a `git clone` operation using the `https` schema.

If you prefer to use the `ssh` schema instead, you can execute the following command:

```sh
curl -fsSL https://github.com/FinAI-Project/git-pipelines/raw/main/install.sh | GIT_URL_SCHEMA=ssh bash
```

### Forced Reinstallation

If you wish to perform a forced reinstallation, you can also utilize the `GIT_URL_SCHEMA` parameter. You can set the value of the `GIT_URL_SCHEMA` parameter to either `https` or `ssh`, depending on your preference.

## Uninstall Git pipelines

```sh
git config unset --global core.hooksPath
rm -rf ~/.git-pipelines
```