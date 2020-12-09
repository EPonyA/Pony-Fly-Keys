(defun pony-binary-end-of-line()
  (interactive)
  (let (($p (point)))
    (goto-char (+
                (/
                 (- (line-end-position) $p)
                 2)
                (point)))))

(defun pony-binary-beginning-of-line()
  (interactive)
  (let (($p (point)))
    (goto-char (+
                (/
                 (- $p (line-beginning-position))
                 2)
                (line-beginning-position)))))

;; https://www.emacswiki.org/emacs/HalfScrolling
(defun zz-scroll-half-page (direction)
  "Scrolls half page up if `direction' is non-nil, otherwise will scroll half page down."
  (let ((opos (cdr (nth 6 (posn-at-point)))))
    ;; opos = original position line relative to window
    (move-to-window-line nil)  ;; Move cursor to middle line
    (if direction
        (recenter-top-bottom -1)  ;; Current line becomes last
      (recenter-top-bottom 0))  ;; Current line becomes first
    (move-to-window-line opos)))  ;; Restore cursor/point position

(defun zz-scroll-half-page-down ()
  "Scrolls exactly half page down keeping cursor/point position."
  (interactive)
  (zz-scroll-half-page nil))

(defun zz-scroll-half-page-up ()
  "Scrolls exactly half page up keeping cursor/point position."
  (interactive)
  (zz-scroll-half-page t))

(defun pony-insert-region-pair()
  (interactive)
  (let ((open "#region\n")
        (close "#endregion\n"))      ; Default kind of region
    (cond ((equal major-mode'emacs-lisp-mode) (setq open "; region\n") (setq close "; endregion\n"))
          ((equal major-mode 'c++-mode) (setq open "#pragma region\n") (setq close "#pragma endregion\n")))
    (xah-insert-bracket-pair open close)))

(defun pony-insert-angle-pair()
  (interactive)
  (let ((open "<")
        (close ">"))
    ;; (cond ((equal major-mode 'emacs-lisp-mode) (setq open "; region\n") (setq close "; endregion\n")
    ;; )
    ;; ((equal major-mode 'c++-mode) (setq open "#pragma region\n") (setq close "#pragma endregion\n")
    ;; )
    ;; )
    (xah-insert-bracket-pair open close)))

(defun pony-copy-current-word()
  (interactive)
  (if (use-region-p)
		(progn
		  (copy-region-as-kill (region-beginning) (region-end)))
	 (progn
		(let ( $pt $p1 $p2 )
		  (setq $pt (point))
		  ;;
		  (skip-chars-backward "-_A-Za-z0-9")
		  (setq $p1 (point))
		  ;;
		  (right-char)
		  (skip-chars-forward "-_A-Za-z0-9")
		  (setq $p2 (point))
		  ;;
		  (copy-region-as-kill $p1 $p2)
		  (nav-flash-show $p1 $p2)
		  ;; Place cursor at whichever end of the word is closer
		  ;; to its starting position.
		  (when (< (- $pt $p1) (- $p2 $pt))
			 (goto-char $p1))))))

(defun pony-copy-current-line()
  (interactive)
  (let ( $p1 $p2 )
    (beginning-of-line)
    (skip-chars-forward "\t ")
    (setq $p1 (point))
    ;;
    (re-search-forward "\n")
    (setq $p2 (point))
    ;;
    (copy-region-as-kill $p1 $p2)
    (nav-flash-show $p1 $p2)))

(defun pony-mark-line()
  (interactive)
  (if (region-active-p)
      ;; Expand selection in the direction of cursor
      ;; if a mark already exists.
      (progn
        (if (equal (point) (region-end))
            (progn
              (re-search-forward "\n")
              (skip-chars-forward "\t"))
          ;;
          (progn
            (beginning-of-line)
            (skip-chars-backward "\t\n ")
            (beginning-of-line)
            (skip-chars-forward "\t "))))
    ;; Mark the beginning of leading whitespace to
    ;; the end of current line, including the newline.
    (progn
      (let ( $p1 $p2 )
        (beginning-of-line)
        (skip-chars-forward "\t ")
        (setq $p1 (point))
        ;;
        (re-search-forward "\n")
        (skip-chars-forward "\t ")
        (backward-char 1)
        (setq $p2 (point))
        ;;
        (set-mark $p1)
        )
      )))

(defun pony-re-search-backward (argRegex)
  (forward-char)
  (re-search-backward argRegex)
  (forward-char)
  (point))

(defun pony-re-search-forward (argRegex)
  (re-search-forward argRegex)
  (backward-char)
  (point))

(defun pony-search-forward (argRegex)
  (setq $exit nil)
  (while (not $exit)
	 (if (equal (point) (point-max))
		  ;; If at end of buffer.
		  (progn
			 (setq $exit t))
		;; If at a character in the regex.
		(progn
		  (if (looking-at argRegex)
				;; End of the word.
				(progn
				  (setq $exit t))
			 (progn
				(forward-char))))))
  (point))

(defun pony-search-backward (argRegex)
  (setq $exit nil)
  (while (not $exit)
	 (if (equal (point) (point-min))
		  ;; If at start of buffer.
		  (progn
			 (setq $exit t))
		;; If at a character in the regex.
		(progn
		  (if (looking-at argRegex)
				;; End of the word.
				(progn
				  (setq $exit t))
			 (progn
				(backward-char))))))
  (forward-char)
  (point))

(defun pony-delete-left-word ()
  (interactive)
  (let ($pL $pR)
	 (setq $white_start nil)
    (setq $exit nil)
    (while (not $exit)
		;; If the cursor begins on a word.
		;;
		(backward-char)
      (if (looking-at "[-_a-zA-Z0-9\$\#\.]+")
          (progn
            (setq temp (- (point) 1))
            (if (equal $white_start nil)
					 (setq $pR (pony-search-forward "[^-_a-zA-Z0-9\$\#]"))
				  (setq $pR $white_start)
				  )
				;; Move cursor beyond . symbol.
				(goto-char temp)
				(setq $pL (pony-search-backward "[^-_a-zA-Z0-9\$\#][^\\.]"))
				(backward-char)
            (if (looking-at "\\.") (setq $pL (- $pL 1)))
            (forward-char)
            ;; Prevent ending on brackets or white-space.
            (when (looking-at "\s(\s)\s- ") (setq $pL (+ $pL 1)))
            (setq $exit t))
        ;; Else-If the cursor begins on an operator.
        ;;
        (progn
          (if (looking-at "[\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]+")
              (progn
                ;; Move backwards to the end of the operator.
                (setq temp (point))
                (if (equal $white_start nil)
						  (setq $pR (pony-search-forward "[^\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]"))
                 	(setq $pR $white_start)
						)
					 (goto-char temp)
					 (setq $pL (pony-search-backward "[^\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]"))
					 (setq $exit t))
            ;; Else, decrement cursor position.
            (progn
              (if (equal (point) (point-min))
                  (user-error "Error. Hit start of buffer."))
				  (if (equal $white_start nil)
						(setq $white_start (point))
					 (if (looking-at "[\"\(\)]")
						  (setq $white_start (point))))
				  ;; (backward-char)
				  )))))
    ;;
    (delete-region $pL $pR)))

(defun pony-move-left-word ()
  (interactive)
  (let ($pL)
    (setq $exit nil)
    (backward-char)
    (while (not $exit)
		;; If the cursor begins on a word  
		;;
      (if (looking-at "[-_a-zA-Z0-9\$\#\.]+")
          (progn
            (backward-char)
				(if (looking-at "[.]")
					 (setq $pL (- $pL 1)))
				(setq $pL (pony-search-backward "[^-_a-zA-Z0-9\$\#][^\\.]"))
            ;; Prevent ending on brackets or white-space.
            ;; (when (looking-at "\s(\s)\s- ") (setq $pL (+ $pL 1)))
            (setq $exit t))
        ;; Else-If the cursor begins on an operator.
         (progn
          (if (looking-at "[\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~]+")
              (progn
                ;; Move backwards to the end of the operator.
                (setq $pL (pony-search-backward "[^\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~]"))
                (setq $exit t))
            ;; Else, decrement cursor position.
            (progn
              (if (equal (point) (point-min))
                  (user-error "Error. Hit start of buffer."))
              (backward-char)
              )))))
     (goto-char $pL)))

(defun pony-delete-right-word ()
  (interactive)
  (let ($pL $pR)
	 (setq $white_start nil)
    (setq $exit nil)
    (while (not $exit)
		;; If the cursor begins on a word.
		;;
      (if (looking-at "[-_a-zA-Z0-9\$\#\.]+")
          (progn
            (setq temp (point))
            ;; (setq $pR (pony-re-search-forward "[^-_a-zA-Z0-9\$\#][^\\.]"))
				(setq $pR (pony-search-forward "[^-_a-zA-Z0-9\$\#][^\\.]"))
            (goto-char temp)
				(if (equal $white_start nil)
					 (setq $pL (pony-search-backward "[^-_a-zA-Z0-9\$\#]"))
				  (setq $pL $white_start)
				  )
            (setq $exit t))
        ;; Else-If the cursor begins on an operator.
        ;;
        (progn
          (if (looking-at "[\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]+")
              (progn
                ;; Move backwards to the end of the operator.
                (setq temp (point))
					 (setq $pR (pony-search-forward "[^\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]"))
					 (setq $pR (+ $pR 1))
                (goto-char temp)
					 (if (equal $white_start nil)
						  (setq $pL (pony-search-backward "[^\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]"))
						(setq $pL $white_start)
						)
                (setq $exit t))
            ;; Else, increment cursor position.
            (progn
              (if (equal (point) (point-max))
						(user-error "Error. Hit end of buffer."))
				  (if (equal $white_start nil)
						(progn
						  (if (looking-at "[\"\(\)]")
								(setq $white_start (+ (point) 1))
							 (setq $white_start (point))
							 ))
					 (if (looking-at "[\"\(\)]")
						  (setq $white_start (+ (point) 1))))
				  (forward-char))))))
    ;;
    (delete-region $pL $pR)))

(defun pony-move-right-word ()
  (interactive)
  (let ($pR)
    (setq $exit nil)
    (forward-char)
    (while (not $exit)
		;; If the cursor begins on a word.
		;;
      (if (looking-at "[-_a-zA-Z0-9\$\#\.]+")
          (progn
            ;; (forward-char)
            (setq $pR (pony-re-search-forward "[^-_a-zA-Z0-9\$\#][^\\.]"))
				;; (setq $pR (+ $pR 1))
            ;; Prevent ending on brackets or white-space.
            (backward-char)
            (when (looking-at "[^\\.]") (setq $pR (- $pR 1)))
            (setq $exit t))
        ;; Else-If the cursor begins on an operator.
        ;;
        (progn
          (if (looking-at "[\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]+")
              (progn
                ;; Move backwards to the end of the operator.
                (setq $pR (pony-re-search-forward "[^\+\-\=\*\/\:\^\?\;\.\,\|\&\%\~\>\<]"))
					 ;; (setq $pR (+ $pR 1))
                ;; (setq $pR (- $pR 1))
                (setq $exit t))
            ;; Else, increment cursor position.
            (progn
              (if (equal (point) (point-max))
                  (user-error "Error. Hit end of buffer."))
              (forward-char))))))
    (goto-char $pR)))
