;;; auth-source-keytar.el --- Integrate auth-source with keytar  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Shen, Jen-Chieh
;; Created date 2021-03-29 19:24:39

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Emacs Lisp interface for node-keytar
;; Keyword: keytar password credential secret security
;; Version: 0.1.2
;; Package-Requires: ((emacs "24.4"))
;; URL: https://github.com/emacs-grammarly/auth-source-keytar

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Integrates keytar (https://www.npmjs.com/package/keytar) within
;; auth-source.
;;

;;; Code:

(require 'auth-source)
(require 'subr-x)

(defgroup auth-source-keytar nil
  "Keytar integration within auth-source."
  :prefix "auth-source-keytar-"
  :group 'auth-source)

(defconst auth-source-keytar-package-name "@emacs-grammarly/keytar-cli"
  "NPM package name for keytar to execute.")

(defcustom auth-source-keytar-install-dir
  (expand-file-name (locate-user-emacs-file ".cache/keytar"))
  "Absolute path to installation directory of keytar."
  :risky t
  :type 'directory
  :group 'auth-source-keytar)

;;
;; (@* "Util" )
;;

(defun auth-source-keytar--execute (cmd &rest args)
  "Return non-nil if CMD executed succesfully with ARGS."
  (save-window-excursion
    (let ((inhibit-message t) (message-log-max nil))
      (= 0 (shell-command (concat cmd " "
                                  (mapconcat #'shell-quote-argument args " ")))))))

(defun auth-source-keytar--execute-string (cmd &rest args)
  "Return result in string after CMD is executed with ARGS."
  (save-window-excursion
    (let ((inhibit-message t) (message-log-max nil))
      (string-trim (shell-command-to-string
                    (concat cmd " " (mapconcat #'shell-quote-argument args " ")))))))

(defun auth-source-keytar--exe-path ()
  "Return path to keytar executable."
  (let ((path (executable-find
               (if auth-source-keytar-install-dir
                   (concat auth-source-keytar-install-dir "/"
                           (cond ((eq system-type 'windows-nt) "/")
                                 (t "bin/"))
                           "keytar")
                 "keytar"))))
    (when (and path (file-exists-p path))
      path)))

(defun auth-source-keytar-installed-p ()
  "Return non-nil if `keytar-cli' installed succesfully."
  (auth-source-keytar--exe-path))

(defun auth-source-keytar--ckeck ()
  "Key before using `keytar-cli'."
  (unless (auth-source-keytar-installed-p)
    (user-error "[WARNING] Make sure you have installed `%s` through `npm` or hit `M-x auth-source-keytar-install`"
                auth-source-keytar-package-name)))

(defun auth-source-keytar--valid-return (result)
  "Return nil if RESULT is invalid output."
  (if (or (string= "null" result) (string-match-p "TypeError:" result)
          (string-match-p "Not enough arguments" result))
      nil result))

(defun auth-source-keytar-install ()
  "Install keytar package through npm."
  (interactive)
  (if (auth-source-keytar-installed-p)
      (message "NPM package `%s` is already installed" auth-source-keytar-package-name)
    (if (apply #'auth-source-keytar--execute (append
                                              `("npm" "install" "-g" ,auth-source-keytar-package-name)
                                              (when auth-source-keytar-install-dir `("--prefix" ,auth-source-keytar-install-dir))))
        (message "Successfully install `%s` through `npm`!" auth-source-keytar-package-name)
      (user-error "Failed to install` %s` through `npm`, make sure you have npm installed"
                  auth-source-keytar-package-name))))

;;
;; (@* "Keytar" )
;;

(defun auth-source-keytar-get-password (service account)
  "Get the stored password for the SERVICE and ACCOUNT."
  (auth-source-keytar--ckeck)
  (auth-source-keytar--valid-return
   (auth-source-keytar--execute-string (auth-source-keytar--exe-path) "get-pass"
                                       "-s" service "-a" account)))

(defun auth-source-keytar-set-password (service account password)
  "Save the PASSWORD for the SERVICE and ACCOUNT to the keychain.

Adds a new entry if necessary, or updates an existing entry if one exists."
  (auth-source-keytar--ckeck)
  (auth-source-keytar--execute (auth-source-keytar--exe-path) "set-pass" "-s" service "-a"
                               account "-p" password))

(defun auth-source-keytar-delete-password (service account)
  "Delete the stored password for the SERVICE and ACCOUNT."
  (auth-source-keytar--ckeck)
  (auth-source-keytar--execute (auth-source-keytar--exe-path) "delete-pass"
                               "-s" service "-a" account))

(defun auth-source-keytar-find-credentials (service)
  "Find all accounts and password for the SERVICE in the keychain."
  (auth-source-keytar--ckeck)
  (auth-source-keytar--valid-return
   (auth-source-keytar--execute-string (auth-source-keytar--exe-path) "find-creds" "-s" service)))

(defun auth-source-keytar-find-password (service)
  "Find a password for the SERVICE in the keychain.

This is ideal for scenarios where an account is not required."
  (auth-source-keytar--ckeck)
  (auth-source-keytar--valid-return
   (auth-source-keytar--execute-string (auth-source-keytar--exe-path) "find-pass" "-s" service)))

;;
;; (@* "Auth Source" )
;;

;;;###autoload
(defun auth-source-keytar-enable ()
  "Enable auth-source-keytar."
  (add-to-list 'auth-sources 'keytar)
  (auth-source-forget-all-cached))

(defvar auth-source-keytar-backend
  `(auth-source-backend
    "keytar"
    :source "."  ; not used
    :type 'keytar
    :search-function #'auth-source-keytar-search)
  "Auth-source backend for keytar.")

(cl-defun auth-source-keytar-search
    (&rest spec &key service account &allow-other-keys)
  "Given some search query, return matching credentials.

See `auth-source-search' for details on the parameters SPEC, SERVICE
and ACCOUNT."
  (cond ((and service account) (auth-source-keytar-get-password service account))
        (service (auth-source-keytar-find-credentials service))
        (t (user-error "Missing key `service` in search query"))))

(defun auth-source-keytar-backend-parse (entry)
  "Create a keytar auth-source backend from ENTRY."
  (when (eq entry 'keytar)
    (auth-source-backend-parse-parameters entry auth-source-keytar-backend)))

(if (boundp 'auth-source-backend-parser-functions)
    (add-hook 'auth-source-backend-parser-functions #'auth-source-keytar-backend-parse)
  (advice-add 'auth-source-backend-parse :before-until #'auth-source-keytar-backend-parse))

(provide 'auth-source-keytar)
;;; auth-source-keytar.el ends here
