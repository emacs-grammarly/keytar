;;; keytar.el --- Interface for node-keytar  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Shen, Jen-Chieh
;; Created date 2021-03-09 11:52:53

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Interface for node-keytar.
;; Keyword: keytar password credential secret security
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.3"))
;; URL: https://github.com/jcs090218/keytar

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
;; Interface for node-keytar.
;;

;;; Code:

(defconst keytar-package-name "keytar-cli-2"
  "NPM package name for keytar to execute.")

;;
;; (@* "Util" )
;;

(defun keytar--safe-execute (in-cmd)
  "Correct way to check if IN-CMD execute with or without errors."
  (let ((inhibit-message t) (message-log-max nil))
    (= 0 (shell-command in-cmd))))

(defun keytar-installed-p ()
  "Return non-nil if `keytar-cli-2' installed succesfully."
  (keytar--safe-execute "keytar --help"))

(defun keytar--ckeck ()
  "Key before using `keytar-cli-2'."
  (unless (keytar-installed-p)
    (user-error "[ERROR] Make sure you have installed `keytar-cli-2` through `npm`")))

(defun keytar-install ()
  "Install keytar package through npm."
  (interactive)
  (if (keytar--safe-execute (format "npm install -g %s" keytar-package-name))
      (message "Successfully install %s through `npm`!" keytar-package-name)
    (user-error "Failed to install %s through `npm`..." keytar-package-name)))

;;
;; (@* "API" )
;;

(defun keytar-get-password (service account)
  "Get the stored password for the SERVICE and ACCOUNT."
  (keytar--ckeck)
  (shell-command-to-string (format "keytar get-pass -s %s -a %s" service account)))

(defun keytar-set-password (service account password)
  "Save the PASSWORD for the SERVICE and ACCOUNT to the keychain.

Adds a new entry if necessary, or updates an existing entry if one exists."
  (keytar--ckeck)
  (keytar--safe-execute (format "keytar set-pass -s %s -a %s -p %s"
                                service account password)))

(defun keytar-delete-password (service account)
  "Delete the stored password for the SERVICE and ACCOUNT."
  (keytar--ckeck)
  (keytar--safe-execute (format "keytar delete-pass -s %s -a %s" service account)))

(defun keytar-find-credentials (service)
  "Find all accounts and password for the SERVICE in the keychain."
  (keytar--ckeck)
  (shell-command-to-string (format "keytar find-creds -s %s" service)))

(defun keytar-find-password (service)
  "Find a password for the SERVICE in the keychain.

This is ideal for scenarios where an account is not required."
  (keytar--ckeck)
  (shell-command-to-string (format "keytar find-pass -s %s" service)))

(provide 'keytar)
;;; keytar.el ends here
