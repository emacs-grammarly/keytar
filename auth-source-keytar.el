;;; auth-source-keytar.el --- Integrate auth-source with keytar  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Shen, Jen-Chieh
;; Created date 2021-03-29 19:24:39

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
(require 'keytar)

(defgroup auth-source-keytar nil
  "Keytar integration within auth-source."
  :prefix "auth-source-keytar-"
  :group 'auth-source)

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
  (cond ((and service account) (keytar-get-password service account))
        (service (keytar-find-credentials service))
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
