;;------------------=={ get date reverse }==-------------------;;
;;                                                             ;;
;;  Obtains the current date (as per the system) reversed.     ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $variable (gtmisc:getreverse))                  ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Date in the format "yy.mm.dd"                              ;;
;;-------------------------------------------------------------;;

(DEFUN gtmisc:getreverse ()
  (SETQ $time (RTOS (GETVAR "CDATE")))
  (STRCAT (SUBSTR $time 3 2) "." (SUBSTR $time 5 2) "." (SUBSTR $time 7 2))
  
)

;;----------------------=={ get date }==-----------------------;;
;;                                                             ;;
;;  Obtains the current date (as per the system).              ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $variable (gtmisc:getdate))                         ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Date in the format "dd.mm.yy"                              ;;
;;-------------------------------------------------------------;;

(DEFUN gtmisc:getdate ()
  (SETQ $time (RTOS (GETVAR "CDATE")))
  (STRCAT (SUBSTR $time 7 2) "." (SUBSTR $time 5 2) "." (SUBSTR $time 3 2))

)

;;------------------=={ get date custom }==--------------------;;
;;                                                             ;;
;;  Obtains the current date (as per the system).              ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $variable (gtmisc:getdatecustom "DD.MM.YYYY"))      ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Date in the format specified by an input string            ;;
;;-------------------------------------------------------------;;

(DEFUN gtmisc:getdatecustom ($format)
  (SETQ $time (RTOS (GETVAR "CDATE")))
  (SETQ $format (gtstrings:replace $format "YYYY" (SUBSTR $time 1 4)))
  (SETQ $format (gtstrings:replace $format "YY" (SUBSTR $time 3 2)))
  (SETQ $format (gtstrings:replace $format "MM" (SUBSTR $time 5 2)))
  (SETQ $format (gtstrings:replace $format "DD" (SUBSTR $time 7 2)))
  $format
)

(DEFUN gtmisc:stringtolist (listofstring)
  (DEFUN normalizenumberinstring (str / ch i pat ret count buf)
    (SETQ i	0
	  pat	'("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")
	  ret	""
	  count	4
    )
    (WHILE (/= (SETQ ch (SUBSTR str (SETQ i (1+ i)) 1)) "")
      (IF (VL-POSITION ch pat)
	(PROGN
	  (SETQ buf ch)
	  (WHILE
	    (VL-POSITION (SETQ ch (SUBSTR str (SETQ i (1+ i)) 1)) pat)
	     (SETQ buf (STRCAT buf ch))
	  )
	  (WHILE (< (STRLEN buf) count) (SETQ buf (STRCAT "0" buf)))
	  (SETQ ret (STRCAT ret buf))
	)
      )
      (SETQ ret (STRCAT ret ch))
    )
    ret
  )
  (MAPCAR '(LAMBDA (x) (NTH x listofstring))
	  (VL-SORT-I (MAPCAR 'normalizenumberinstring listofstring)
		     '<
	  )
  )
)


(DEFUN gtmisc:removelistduplicates ($item $lst / ll n)
  (FOREACH n $lst
    (COND ((EQUAL n $item)
	   (AND	(NOT (MEMBER $item ll))
		(SETQ ll (CONS n ll))
	   )
	  )
	  (T (SETQ ll (CONS n ll)))
    )
  )
  (REVERSE ll)
)

(DEFUN gtmisc:gettime (/ d hr m s $return)
  (SETQ	d  (RTOS (GETVAR "CDATE") 2 6)
	hr (SUBSTR d 10 2)
	m  (SUBSTR d 12 2)
	s  (SUBSTR d 14 2)
  )
  (SETQ $return (STRCAT hr ":" m ":" s))
)