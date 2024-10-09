# Pyenv Guide for Manjaro Linux

## Introduction

**Pyenv** helps manage multiple versions of Python independently from your operating system's default Python installation, preventing issues caused by modifying the system Python. Avoid changing the OS Python or its dependencies unless absolutely necessary.

### Why Use Pyenv?

- **Switch Between Python Versions:** Easily switch between different Python versions.
- **Per-User and Per-Project Customization:** Set a global Python version or define a specific version for a project.
- **Environment Variable Overrides:** Override Python versions using environment variables.
- **Multi-Version Command Searching:** Test compatibility across versions with tools like `tox`.

### How Pyenv Works: PATH and Shims

- **PATH Variable:** Your shell searches for executable commands in directories listed in `PATH`. When you run `python` or `pip`, it finds the match from left to right.
- **Shims:** Shims are small wrapper scripts that Pyenv places at the front of your `PATH`. They make sure that when you run Python commands, they point to the version managed by Pyenv, instead of the system default.
  
  For example, the shim for `python` looks like this:
  ```sh
  #!/usr/bin/env bash
  set -e
  [ -n "$PYENV_DEBUG" ] && set -x

  program="${0##*/}"

  export PYENV_ROOT="$HOME/.pyenv"
  exec "/usr/share/pyenv/libexec/pyenv" exec "$program" "$@"
  ```
  
  This script ensures that the `python` command uses the version managed by Pyenv, based on your current settings.

## Installation on Manjaro Linux

To install Pyenv on Manjaro Linux, follow these steps:

### Step 1: Install Pyenv

Use `pamac` to install Pyenv:

```sh
sudo pamac install pyenv
```

### Step 2: Configure Your Shell Profile

To enable Pyenv for your shell, add the necessary configurations to your shell profile.

#### For Bash:

```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
```

#### For Zsh:

```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

### Step 3: Restart Your Shell

Restart your shell for the changes to take effect:

```sh
exec "$SHELL"
```

### Step 4: Install Python Build Dependencies

Before installing a new Python version, install the required build dependencies:

```sh
sudo pamac install base-devel openssl zlib xz tk
```

## Using Pyenv

### List Available Python Versions

To see the list of Python versions that can be installed:

```sh
pyenv install --list
```

### Install and Set Python Version

To download and install a specific Python version, for example, Python 3.12.6:

```sh
pyenv install 3.12.6
```

To set this version globally for your user account:

```sh
pyenv global 3.12.6
```

Now, whenever you run `python` or `pip`, it will use the Python version managed by Pyenv instead of the system default.

To revert to the system Python version, you can use:

```sh
pyenv global system
```

##

---

*This guide was written by Alexandre Marcel Lucas, inspired by the official documentation of the product.*
