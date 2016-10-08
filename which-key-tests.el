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

(deftest which-key-test-prefix-declaration ()
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

(deftest which-key-test-duplicate-key-elimination ()
  "Make sure we eliminate shadowed keys from our current keymap"
  (let ((our-map '(keymap (?a . 'first-match)
                           (keymap (?a . 'second-match)))))
    (should (equal
             (which-key--canonicalize-bindings our-map)
             '(("a" . 'first-match))))))


(deftest which-key-test-simplify-base-binding-plain-symbol ()
  "Given a binding, which--key-simpify-base-binding should return a symbol or
a list"
  (should (equal (which-key--simplify-base-binding 'symbol)
              'symbol)))

(deftest which-key-test-simplify-base-binding-simple-menu-item-with-help ()
  "An old 'simple' menu item with help maps to an appropriate (menu-item ...)"
  (should
   (equal (which-key--simplify-base-binding '("desc" "help string" .
                                              '(keymap '(f1 . help-command))))
          '(menu-item "desc" '(keymap '(f1 . help-command))
                      :help "help string"))))

(deftest which-key-test-simplify-base-binding-simple-menu-item-without-help ()
  (should (equal (which-key--simplify-base-binding '("desc" . 'symbol))
                 '(menu-item "desc" 'symbol))))


(deftest which-key-test-describe-binding-for-simple-cases ()
  (should (equal (which-key--describe-basic-binding 'symbol)
                 "symbol"))
  (should (equal (which-key--describe-basic-binding '(keymap (1 . foo)))
                 "Prefix Command"))
  (should (equal (which-key--describe-basic-binding '(keymap "desc" (1 . foo)))
                 "desc"))
  )

(deftest which-key-test-describe-menu-item-0 ()
  (should (equal (which-key--describe-basic-binding '(menu-item "desc" foo))
                 "desc")))

(deftest which-key-test-describe-menu-item-1 ()
  (should (equal (which-key--describe-basic-binding '(menu-item "desc" nil :help "help"))
                 "desc")))

(deftest which-key-test-describe-menu-item-2 ()
  (should (equal (which-key--describe-basic-binding '(menu-item (or nil "desc") nil))
                 "desc"))
  (should (equal (which-key--describe-basic-binding
                  '(menu-item "desc" nil
                              :enable (or nil t)))
                 "desc"))
  (should (equal (which-key--describe-basic-binding
                  '(menu-item "desc" nil
                              :enable (or nil nil)))
                 nil))
          )

  )

(provide 'which-key-tests)
;;; which-key-tests.el ends here
