;;--------------------=={ Log LISP Usage }==------------------;;
;;                                                            ;;
;;  Automatically records daily LISP command usage to a CSV   ;;
;;  log file, stored in the folder indicated at the top of    ;;
;;  the code.                                                 ;;
;;                                                            ;;
;;  To enable automatic logging, load this LISP file on       ;;
;;  startup (recommend using the ACADDOC.lsp).                ;;
;;                                                            ;;
;;  To enable or disable LISP command logging at any time,    ;;
;;  type at the command-line 'LispLogON' or 'LispLogOFF'      ;;
;;  respectively.                                             ;;
;;------------------------------------------------------------;;
;;  Author: Lee Mac, Copyright © 2011 - www.lee-mac.com       ;;
;;------------------------------------------------------------;;
;;  Version 1.0    -    07-11-2011                            ;;
;;------------------------------------------------------------;;

;;------------------------------------------------------------;;
;;  Log File Save Folder                                      ;;
;;------------------------------------------------------------;;
;;  LISP Log files will be saved to this folder.              ;;
;;  The folder will be created if it doesn't exist.           ;;
;;------------------------------------------------------------;;

(SETQ *lisp-log-folder*
	   (STRCAT
		 (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		 "\\DEBUG - "
		 $gtuserid
	   )
)

(SETQ *lisp-log-list* nil)
;;------------------------------------------------------------;;

(DEFUN gtlogging:enablereactor nil
  (IF (NULL *log-lisp-reactor*)
	(SETQ *log-lisp-reactor*
		   (VLR-LISP-REACTOR
			 "LISP-Log"
			 '((:VLR-LISPWILLSTART . lisplog:lispstarted))
		   )
	)
  )
  (IF (NULL *log-save-reactor*)
	(SETQ *log-save-reactor*
		   (VLR-EDITOR-REACTOR
			 "LISP-Log"
			 '((:VLR-BEGINSAVE . lisplog:savelisplogs))
		   )
	)
  )
  (PRINC "\nLISP Logging Enabled.")
  (PRINC)
)

;;------------------------------------------------------------;;

(DEFUN gtlogging:disablereactor	nil
  (IF *log-lisp-reactor*
	(PROGN (VLR-REMOVE *log-lisp-reactor*)
		   (SETQ *log-lisp-reactor* nil)
	)
  )
  (IF *log-save-reactor*
	(PROGN (VLR-REMOVE *log-save-reactor*)
		   (SETQ *log-save-reactor* nil)
	)
  )
  (SETQ *lisp-log-list* nil)
  (VL-PROPAGATE '*lisp-log-list*)
  (PRINC "\nLISP Logging Disabled.")
  (PRINC)
)

;;------------------------------------------------------------;;

(DEFUN lisplog:lispstarted (reactor params)
  (PRINC reactor)
  (PRINC "\n")
  (PRINC params)
  (IF
	(AND
	  (WCMATCH (SETQ params (STRCASE (CAR params))) "(C:*")
	  (NOT
		(MEMBER	params
				'("(gtlogging:enablereactor)" "(gtlogging:disablereactor)")
		)
	  )
	)
	 (PROGN
	   (SETQ *lisp-log-list*
			  (lm:nassoc++
				(LIST (STRCAT (GETVAR 'dwgprefix) (GETVAR 'dwgname))
					  (VL-STRING-TRIM "()" params)
				)
				*lisp-log-list*
			  )
	   )
	   (VL-PROPAGATE '*lisp-log-list*)
	 )
  )
  (PRINC)
)

;;------------------------------------------------------------;;

(DEFUN lisplog:savelisplogs	(reactor params / *error* directory filename file)

  (DEFUN *error* (msg)
	(IF	(AND file (EQ 'file (TYPE file)))
	  (SETQ file (CLOSE file))
	)
	(IF	(NOT (WCMATCH (STRCASE msg) "*BREAK,*CANCEL*,*EXIT*"))
	  (PRINC (STRCAT "\nError: " msg))
	)
	(PRINC)
  )

  (IF *lisp-log-list*
	(PROGN
	  (IF *lisp-log-folder*
		(SETQ *lisp-log-folder*
			   (VL-STRING-RIGHT-TRIM
				 "\\"
				 (VL-STRING-TRANSLATE "/" "\\" *lisp-log-folder*)
			   )
		)
		(SETQ *lisp-log-folder* (VL-STRING-RIGHT-TRIM "\\" (GETVAR 'dwgprefix)))
	  )
	  (SETQ	directory (STRCAT *lisp-log-folder* "\\")
			filename  (STRCAT directory (lm:date "YYYYMODD") ".csv")
	  )
	  (IF (NULL (VL-FILE-DIRECTORY-P directory))
		(lm:createdirectory directory)
	  )
	  (IF (FINDFILE filename)
		(SETQ *lisp-log-list* (lm:mergelists *lisp-log-list* (lm:readlog filename)))
	  )
	  (IF (SETQ file (OPEN filename "w"))
		(PROGN
		  (FOREACH dwg (VL-SORT	*lisp-log-list*
								'(LAMBDA (a b) (< (CAR a) (CAR b)))
					   )
			(WRITE-LINE (CAR dwg) file)
			(FOREACH cmd (VL-SORT (CDR dwg) '(LAMBDA (a b) (> (CADR a) (CADR b))))
			  (WRITE-LINE (STRCAT (CAR cmd) "," (ITOA (CADR cmd))) file)
			)
			(WRITE-LINE "" file)
		  )
		  (SETQ file (CLOSE file))
		  (SETQ *lisp-log-list* nil)
		  (VL-PROPAGATE '*lisp-log-list*)
		)
		(PRINC "\nUnable to write LISP Log.")
	  )
	)
  )
  (PRINC)
)

;;------------------------------------------------------------;;

(DEFUN lm:nassoc++ (key lst / pair)
  (IF key
	(IF	(SETQ pair (ASSOC (CAR key) lst))
	  (SUBST (CONS (CAR key) (lm:nassoc++ (CDR key) (CDR pair)))
			 pair
			 lst
	  )
	  (CONS (CONS (CAR key) (lm:nassoc++ (CDR key) nil)) lst)
	)
	(IF	lst
	  (LIST (1+ (CAR lst)))
	  '(1)
	)
  )
)

;;------------------------------------------------------------;;

(DEFUN lm:date (format)
  (MENUCMD (STRCAT "m=$(edtime,$(getvar,DATE)," format ")"))
)

;;------------------------------------------------------------;;

(DEFUN lm:createdirectory (dir / createdirectory folders)

  (DEFUN createdirectory (root folders)
	(IF	folders
	  ((LAMBDA (dir)
		 (VL-MKDIR dir)
		 (createdirectory dir (CDR folders))
	   )
		(STRCAT root "\\" (CAR folders))
	  )
	)
  )

  (IF (SETQ folders (lm:str->lst (VL-STRING-TRANSLATE "/" "\\" dir) "\\"))
	(createdirectory (CAR folders) (CDR folders))
  )
  (VL-FILE-DIRECTORY-P dir)
)

;;------------------------------------------------------------;;

(DEFUN lm:str->lst (str del / pos)
  (IF (SETQ pos (VL-STRING-SEARCH del str))
	(VL-REMOVE ""
			   (CONS (SUBSTR str 1 pos)
					 (lm:str->lst (SUBSTR str (+ pos 1 (STRLEN del))) del)
			   )
	)
	(LIST str)
  )
)

;;------------------------------------------------------------;;

(DEFUN lm:readlog (filename / file line lst sub1 sub2)
  (IF (SETQ file (OPEN filename "r"))
	(PROGN
	  (WHILE (SETQ line (READ-LINE file))
		(COND
		  ((EQ "" line)
		  )
		  ((= 1 (LENGTH (SETQ line (lm:str->lst line ","))))
		   (IF (AND sub1 sub2)
			 (SETQ lst	(CONS (CONS sub1 sub2) lst)
				   sub1	nil
				   sub2	nil
			 )
		   )
		   (SETQ sub1 (CAR line))
		  )
		  ((= 2 (LENGTH line))
		   (SETQ sub2 (CONS (LIST (CAR line) (ATOI (CADR line))) sub2))
		  )
		)
	  )
	  (IF (AND sub1 sub2)
		(SETQ lst (CONS (CONS sub1 sub2) lst))
	  )
	  (SETQ file (CLOSE file))
	  lst
	)
  )
)

;;------------------------------------------------------------;;

(DEFUN lm:mergelists (l1 l2 / items item)
  (FOREACH group l2
	(IF	(SETQ items (CDR (ASSOC (CAR group) l1)))
	  (PROGN
		(FOREACH pair (CDR group)
		  (IF (SETQ item (ASSOC (CAR pair) items))
			(SETQ items	(SUBST (LIST (CAR pair) (+ (CADR pair) (CADR item)))
							   item
							   items
						)
			)
			(SETQ items (CONS pair items))
		  )
		)
		(SETQ l1 (SUBST (CONS (CAR group) items) (ASSOC (CAR group) l1) l1))
	  )
	  (SETQ l1 (CONS group l1))
	)
  )
  l1
)

;;------------------------------------------------------------;;


(COND
  ;;Always enable enable the times
  ((= "T"
	  (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_LOGGING")
   )
   (gtlogging:enablereactor)
  )
  ((= "ON"
	  (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_LOGGING")
   )
   (gtlogging:enablereactor)
  )
)
(PRINC)



