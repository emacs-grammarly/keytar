[![Build Status](https://travis-ci.com/emacs-grammarly/auth-source-keytar.svg?branch=master)](https://travis-ci.com/emacs-grammarly/auth-source-keytar)
[![CELPA](https://celpa.conao3.com/packages/auth-source-keytar-badge.svg)](https://celpa.conao3.com/#/auth-source-keytar)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# auth-source-keytar

Emacs Lisp interface for [node-keytar](https://www.npmjs.com/package/keytar)
using [@emacs-grammarly/keytar-cli](https://github.com/emacs-grammarly/keytar-cli).

## Installation

You will need [@emacs-grammarly/keytar-cli](https://github.com/emacs-grammarly/keytar-cli)
before using this library.

```bash
npm install -g @emacs-grammarly/keytar-cli
```

or after you have installed `auth-source-keytar.el` in your `load-path`. Do the following,

```el
(require 'auth-source-keytar)
(auth-source-keytar-install)
```

## Usage

List of supported API ported from [node-keytar](https://www.npmjs.com/package/keytar).

* `auth-source-keytar-get-password`
* `auth-source-keytar-set-password`
* `auth-source-keytar-delete-password`
* `auth-source-keytar-find-credentials`
* `auth-source-keytar-find-password`

*P.S. Checkout the [node-keytar#docs](https://github.com/atom/node-keytar#docs) for details*

## Examples

A small example to use this library in Emacs Lisp.

```el
(auth-source-keytar-set-password "service1" "testuser" "hello")  ; t
(auth-source-keytar-find-credentials "service1")                 ; [ { account: 'testuser', password: 'hello' } ]
(auth-source-keytar-find-password "service1")                    ; hello
```

If you attempt to use `auth-source` then,

```el
(auth-source-keytar-enable)
(auth-source-keytar-search :service "service1" :account "testuser")
```

## Contribution

If you would like to contribute to this project, you may either
clone and make pull requests to this repository. Or you can
clone the project and establish your own branch of this tool.
Any methods are welcome!
