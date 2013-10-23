;;;; key bindings and general settings
(setq mac-command-modifier 'meta)
(setq transient-mark-mode t)
(delete-selection-mode 1)

(tool-bar-mode -1)
(show-paren-mode t)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(require 'package)
;; Add the user-contributed repository
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)


;;;; color theme
(load-theme 'solarized-dark t)

;;;; slime
(add-to-list 'load-path "/Applications/slime")
(setq inferior-lisp-program "/usr/local/bin/sbcl")
;(setq inferior-lisp-program "/usr/bin/ccl")
(require 'slime)
(slime-setup '(slime-fancy))

(set-language-environment "UTF-8")
(setenv "LC_LOCALE" "en_US.UTF-8")
(setenv "LC_CTYPE" "en_US.UTF-8")
(setq slime-net-coding-system 'utf-8-unix)
(setq slime-load-failed-fasl 'never)

;;;; org-mode
(setq org-todo-keyword-faces
      '(("TODO" . org-warning) ("MAYBE" . org-warning)))

;;;; web-mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.soy\\'" . web-mode))

;;taken from https://github.com/archimag/cl-closure-template/blob/master/closure-template-html-mode.el
(defun closure-template-compile ()
  "Compile CL-Closure-Template file"
  (interactive)
  (save-buffer)
  (when (slime-connected-p)
    (message "Compiling Closure Templates...")
    (let ((result (slime-eval `(cl:handler-case (cl:progn
                                                 (closure-template:compile-template :common-lisp-backend
                                                                                    (cl:parse-namestring ,(buffer-file-name)))
                                                 (cl:cons t t))
                                                (t (e)
                                                   (cl:cons nil (cl:format nil "~A" e)))))))
      (if (car result)
          (message "Template compilation was done")
        (message "Template compilation error: %s" (cdr result))))))

(define-key web-mode-map (kbd "C-c C-l") 'closure-template-compile)

;;parenscript compile file
(defun parenscript-compile-file ()
  "Compile Parenscript file"
  (interactive)
  (save-buffer)

  (when (slime-connected-p)
    (message "Compiling Parenscript file")
    (let* ((out-name (file-name-base (buffer-file-name)))
	   (out-directory (file-name-directory (buffer-file-name)))
	   (result (slime-eval `(cl:handler-case (cl:progn
						  (cl:with-open-file (out (cl:merge-pathnames (cl:make-pathname :name ,out-name :type "js" :directory '(:relative "js")) (cl:parse-namestring ,out-directory))
									  :direction :output :if-exists :supersede :if-does-not-exist :create)
								     (cl:princ (ps:ps-compile-file (cl:parse-namestring ,(buffer-file-name))) out))
						  (cl:cons t t))
						 (t (e)
						    (cl:cons nil (cl:format nil "~A" e)))))))
      (if (car result)
	  (message "Parenscript compilation was done")
	(message "Parenscript compilation error: %s" (cdr result))))))
  
(define-key slime-mode-map (kbd "C-c C-l") 'parenscript-compile-file)

