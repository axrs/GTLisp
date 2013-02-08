;;-------------------=={ STYLE DIRECTOR }==--------------------;;
;; Style director is a utility to automatically switch styles  ;;
;; for a list of specified commands.                           ;;
;;-------------------------------------------------------------;;

(SETQ $styledirectortextstyle "GTSTD")
(SETQ $styledirectortextcommands "[DM]TEXT,TEXT,*LEADER,*GTLEADER*")
(SETQ $styledirectordimensionstyle "GTSTD")
(SETQ $styledirectordimensioncommands "DIM*")

;;Debugging Mode
(SETQ *printcommand* nil)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Override default settings if a configuration value exists.                  |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF
  (NOT (= (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_STYLE") nil))
   (SETQ $styledirectortextstyle
	  (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_STYLE")
   )
)
(IF
  (NOT (= (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_COMMANDS") nil)
  )
   (SETQ $styledirectortextcommands
	  (gtconfig:getvalue
	    $gtconfig
	    "STANDARDS"
	    "TEXT_COMMANDS"
	  )
   )
)
(IF
  (NOT
    (= (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_STYLE") nil)
  )
   (SETQ $styledirectordimensionstyle
	  (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_STYLE")
   )
)
(IF
  (NOT (= (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_COMMANDS")
	  nil
       )
  )
   (SETQ $styledirectordimensioncommands
	  (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_COMMANDS")
   )
)

(PRINC (STRCAT "\nSet StyleDirector text style to: "
	       $styledirectortextstyle
       )
)
(PRINC (STRCAT "\nSet StyleDirector text command filter to: "
	       $styledirectortextcommands
       )
)
(PRINC (STRCAT "\nSet StyleDirector dimension style to: "
	       $styledirectordimensionstyle
       )
)
(PRINC (STRCAT "\nSet StyleDirector dimension command filter to: "
	       $styledirectordimensioncommands
       )
)
(SETQ *styledirector-styledata*
       (LIST
	 ;;        COMMAND           LAYER NAME                        ;;
	 (LIST $styledirectortextcommands $styledirectortextstyle)
	 (LIST $styledirectordimensioncommands $styledirectordimensionstyle)
	)
)



;;------------------------------------------------------------;;
(DEFUN gtStyleDirector:StyleDirector (on / reactor)
  (SETQ	reactor
	 (CAR
	   (VL-MEMBER-IF
	     (FUNCTION
	       (LAMBDA (reactor)
		 (EQ "StyleDirector" (VLR-DATA reactor))
	       )
	     )
	     (CDAR (VLR-REACTORS :VLR-COMMAND-REACTOR))
	   )
	 )
  )
  (IF on
    (IF	reactor
      (IF (VLR-ADDED-P reactor)
	(PRINC "\nStyleDirector already running.")
	(PROGN
	  (VLR-ADD reactor)
	  (PRINC "\nStyleDirector Enabled.")
	)
      )
      (PROGN
	(VLR-COMMAND-REACTOR
	  "StyleDirector"
	  '(
	    (:VLR-COMMANDWILLSTART . gtStyleDirector:StyleDirector-set)
	    (:VLR-COMMANDENDED . gtStyleDirector:StyleDirector-reset)
	    (:VLR-COMMANDCANCELLED . gtStyleDirector:StyleDirector-reset)
	    (:VLR-COMMANDFAILED . gtStyleDirector:StyleDirector-reset)
	   )
	)
	(VLR-LISP-REACTOR
	  "LISPStyleDirector"
	  '(
	    (:VLR-LISPWILLSTART . gtStyleDirector:StyleDirector-set)
	    (:VLR-LISPENDED . gtStyleDirector:StyleDirector-reset)
	   )
	)
	(PRINC "\nLayer Director Enabled.")
      )
    )
    (IF	reactor
      (PROGN
	(VLR-REMOVE reactor)
	(PRINC "\nStyleDirector Disabled.")
      )
      (PRINC "\nStyleDirector not running.")
    )
  )
  (PRINC)
)

(DEFUN gtStyleDirector:StyleDirector-set (reactor params / layer tmp)
  (SETQ $x params)
  (IF
    (AND
      (SETQ params (STRCASE (CAR params)))
      (SETQ layer
	     (CADAR
	       (VL-MEMBER-IF
		 (FUNCTION
		   (LAMBDA (item)
		     (WCMATCH params (STRCASE (CAR item)))
		   )
		 )
		 *styledirector-styledata*
	       )
	     )
      )
      (SETQ tmp (gtStyleDirector:StyleDirector-createlayer layer))
      (ZEROP (LOGAND 1 (CDR (ASSOC 70 tmp))))
    )
     (PROGN
       (SETQ *StyleDirector-oldstyle* (GETVAR 'clayer))
       (SETVAR 'clayer layer)
     )
  )
  (IF *printcommand*
    (PRINT params)
  )

  (PRINC)
)

(DEFUN gtStyleDirector:StyleDirector-reset (reactor params / tmp)
  (IF
    (AND
      (NOT (= params nil))
      (SETQ params (STRCASE (CAR params)))
      (NOT (WCMATCH params "U,UNDO"))
      *StyleDirector-oldstyle*
      (SETQ tmp (TBLSEARCH "LAYER" *StyleDirector-oldstyle*))
      (ZEROP (LOGAND 1 (CDR (ASSOC 70 tmp))))
    )
     (PROGN
       (SETVAR 'clayer *StyleDirector-oldstyle*)
       (SETQ *StyleDirector-oldstyle* nil)
     )
  )
  (PRINC)
)

(DEFUN gtStyleDirector:StyleDirector-createlayer (name)
  (COND
    ((TBLSEARCH "LAYER" name))
    ((ENTMAKE
       (LIST
	 '(0 . "LAYER")
	 '(100 . "AcDbSymbolTableRecord")
	 '(100 . "AcDbLayerTableRecord")
	 (CONS 2 name)
	 '(70 . 0)
       )
     )
    )
  )
)

(COND
  ;;Always enable enable the times
  ((= "T"
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_STYLE_DIRECTOR")
   )
   (gtStyleDirector:StyleDirector T)
  )
  ((= "ON"
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_STYLE_DIRECTOR")
   )
   (gtStyleDirector:StyleDirector T)
  )
)
(PRINC)
