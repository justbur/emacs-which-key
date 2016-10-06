;;; which-key-tests.el --- Tests for which-key.el -*- lexical-binding: t; -*-

;; Copyright (C) 2015 Justin Burkett

;; Author: Justin Burkett <justin@burkett.cc>
;; URL: https://github.com/justbur/emacs-which-key

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for which-key.el

;;; Code:

(require 'which-key)
(require 'ert)

(ert-deftest which-key-test-prefix-declaration ()
  "Test `which-key-declare-prefixes' and
`which-key-declare-prefixes-for-mode'. See Bug #109."
  (let* (test-mode which-key-key-based-description-replacement-alist)
    (which-key-declare-prefixes
      "SPC C-c" '("complete" . "complete title")
      "SPC C-k" "cancel")
    (which-key-declare-prefixes-for-mode 'test-mode
      "C-c C-c" '("complete" . "complete title")
      "C-c C-k" "cancel")
    (should (equal
             (assoc-string "SPC C-k" which-key-key-based-description-replacement-alist)
             '("SPC C-k" . "cancel")))
    (should (equal
             (assoc-string
              "C-c C-c" (cdr (assq 'test-mode which-key-key-based-description-replacement-alist)))
             '("C-c C-c" . ("complete" . "complete title"))))))

(ert-deftest which-key-test-duplicate-key-elimination ()
  "Make sure we eliminate shadowed keys from our current keymap"
  (let ((our-map '(keymap (?a . 'first-match)
                           (keymap (?a . 'second-match)))))
    (should (equal
             (which-key--canonicalize-bindings our-map)
             '(("a" . 'first-match))))))

(provide 'which-key-tests)
;;; which-key-tests.el ends here
