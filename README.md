[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![CELPA](https://celpa.conao3.com/packages/keytar-badge.svg)](https://celpa.conao3.com/#/keytar)
[![MELPA](https://melpa.org/packages/keytar-badge.svg)](https://melpa.org/#/keytar)
[![MELPA Stable](https://stable.melpa.org/packages/keytar-badge.svg)](https://stable.melpa.org/#/keytar)

# keytar

[![CI](https://github.com/emacs-grammarly/keytar/actions/workflows/test.yml/badge.svg)](https://github.com/emacs-grammarly/keytar/actions/workflows/test.yml)

Emacs Lisp interface for [node-keytar](https://www.npmjs.com/package/keytar)
using [@emacs-grammarly/keytar-cli](https://github.com/emacs-grammarly/keytar-cli).

## Installation

You will need [@emacs-grammarly/keytar-cli](https://github.com/emacs-grammarly/keytar-cli)
before using this library.

```bash
npm install -g @emacs-grammarly/keytar-cli
```

or after you have installed `keytar.el` in your `load-path`. Do the following,

```el
(require 'keytar)
(keytar-install)
```

## Usage

List of supported API ported from [node-keytar](https://www.npmjs.com/package/keytar).

* `keytar-get-password`
* `keytar-set-password`
* `keytar-delete-password`
* `keytar-find-credentials`
* `keytar-find-password`

*P.S. Checkout the [node-keytar#docs](https://github.com/atom/node-keytar#docs) for details*

## Examples

A small example to use this library in Emacs Lisp.

```el
(keytar-set-password "service1" "testuser" "hello")  ; t
(keytar-find-credentials "service1")                 ; [ { account: 'testuser', password: 'hello' } ]
(keytar-find-password "service1")                    ; hello
```

## Contribution

If you would like to contribute to this project, you may either
clone and make pull requests to this repository. Or you can
clone the project and establish your own branch of this tool.
Any methods are welcome!
