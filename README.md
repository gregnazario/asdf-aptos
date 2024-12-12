<div align="center">

# asdf-aptos [![Build](https://github.com/gregnazario/asdf-aptos/actions/workflows/build.yml/badge.svg)](https://github.com/gregnazario/asdf-aptos/actions/workflows/build.yml) [![Lint](https://github.com/gregnazario/asdf-aptos/actions/workflows/lint.yml/badge.svg)](https://github.com/gregnazario/asdf-aptos/actions/workflows/lint.yml)

[aptos](https://github.com/gregnazario/asdf-aptos) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add aptos
# or
asdf plugin add aptos https://github.com/gregnazario/asdf-aptos.git
```

aptos:

```shell
# Show all installable versions
asdf list-all aptos

# Install specific version
asdf install aptos latest

# Set a version globally (on your ~/.tool-versions file)
asdf global aptos latest

# Now aptos commands are available
aptos --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/gregnazario/asdf-aptos/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Greg Nazario](https://github.com/gregnazario/)
