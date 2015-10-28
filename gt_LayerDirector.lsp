;;-------------------=={ LAYER DIRECTOR }==--------------------;;
;; Layer director is a utility to automatically switch layers  ;;
;; for a list of specified commands.                           ;;
;;-------------------------------------------------------------;;

(SETQ $layerdirectortextlayer "Text")
(SETQ $layerdirectortextcommands "[DM]TEXT,TEXT,*LEADER,*GTLEADER*")
(SETQ $layerdirectordimensionlayer "S-Dims")
(SETQ $layerdirectordimensioncommands "DIM*")

;;Debugging Mode
(SETQ *printcommand* nil)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Override default settings if a configuration value exists.                  |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF
  (NOT (= (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_LAYER") nil))
   (SETQ $layerdirectortextlayer
	  (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_LAYER")
   )
)
(IF
  (NOT (= (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_COMMANDS") nil)
  )
   (SETQ $layerdirectortextcommands
	  (gtconfig:getvalue
	    $gtconfig
	    "STANDARDS"
	    "TEXT_COMMANDS"
	  )
   )
)
(IF
  (NOT
    (= (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_LAYER") nil)
  )
   (SETQ $layerdirectordimensionlayer
	  (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_LAYER")
   )
)
(IF
  (NOT (= (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_COMMANDS")
	  nil
       )
  )
   (SETQ $layerdirectordimensioncommands
	  (gtconfig:getvalue $gtconfig "STANDARDS" "DIMENSION_COMMANDS")
   )
)

(PRINC (STRCAT "\nSet LayerDirector text layer to: "
	       $layerdirectortextlayer
       )
)
(PRINC (STRCAT "\nSet LayerDirector text command filter to: "
	       $layerdirectortextcommands
       )
)
(PRINC (STRCAT "\nSet LayerDirector dimension layer to: "
	       $layerdirectordimensionlayer
       )
)
(PRINC (STRCAT "\nSet LayerDirector dimension command filter to: "
	       $layerdirectordimensioncommands
       )
)
(SETQ *layerdirector-layerdata*
       (LIST
	 ;;        COMMAND           LAYER NAME                        ;;
	 (LIST $layerdirectortextcommands $layerdirectortextlayer)
	 (LIST $layerdirectordimensioncommands $layerdirectordimensionlayer)
	)
)



;;------------------------------------------------------------;;
(DEFUN gtlayerdirector:layerdirector (on / reactor)
  (SETQ	reactor
	 (CAR
	   (VL-MEMBER-IF
	     (FUNCTION
	       (LAMBDA (reactor)
		 (EQ "LayerDirector" (VLR-DATA reactor))
	       )
	     )
	     (CDAR (VLR-REACTORS :VLR-COMMAND-REACTOR))
	   )
	 )
  )
  (IF on
    (IF	reactor
      (IF (VLR-ADDED-P reactor)
	(PRINC "\nLayer Director already running.")
	(PROGN
	  (VLR-ADD reactor)
	  (PRINC "\nLayer Director Enabled.")
	)
      )
      (PROGN
	(VLR-COMMAND-REACTOR
	  "LayerDirector"
	  '(
	    (:VLR-COMMANDWILLSTART . gtlayerdirector:layerdirector-set)
	    (:VLR-COMMANDENDED . gtlayerdirector:layerdirector-reset)
	    (:VLR-COMMANDCANCELLED . gtlayerdirector:layerdirector-reset)
	    (:VLR-COMMANDFAILED . gtlayerdirector:layerdirector-reset)
	   )
	)
	(VLR-LISP-REACTOR
	  "LISPLayerDirector"
	  '(
	    (:VLR-LISPWILLSTART . gtlayerdirector:layerdirector-set)
	    (:VLR-LISPENDED . gtlayerdirector:layerdirector-reset)
	   )
	)
	(PRINC "\nLayer Director Enabled.")
      )
    )
    (IF	reactor
      (PROGN
	(VLR-REMOVE reactor)
	(PRINC "\nLayer Director Disabled.")
      )
      (PRINC "\nLayer Director not running.")
    )
  )
  (PRINC)
)

(DEFUN gtlayerdirector:layerdirector-set (reactor params / layer tmp)
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
		 *layerdirector-layerdata*
	       )
	     )
      )
      (SETQ tmp (gtlayerdirector:layerdirector-createlayer layer))
      (ZEROP (LOGAND 1 (CDR (ASSOC 70 tmp))))
    )
     (PROGN
       (SETQ *layerdirector-oldlayer* (GETVAR 'clayer))
       (SETVAR 'clayer layer)
     )
  )
  (IF *printcommand*
    (PRINT params)
  )

  (PRINC)
)

(DEFUN gtlayerdirector:layerdirector-reset (reactor params / tmp)
  (IF
    (AND
      (NOT (= params nil))
      (SETQ params (STRCASE (CAR params)))
      (NOT (WCMATCH params "U,UNDO"))
      *layerdirector-oldlayer*
      (SETQ tmp (TBLSEARCH "LAYER" *layerdirector-oldlayer*))
      (ZEROP (LOGAND 1 (CDR (ASSOC 70 tmp))))
    )
     (PROGN
       (SETVAR 'clayer *layerdirector-oldlayer*)
       (SETQ *layerdirector-oldlayer* nil)
     )
  )
  (PRINC)
)

(DEFUN gtlayerdirector:layerdirector-createlayer (name)
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
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_LAYER_DIRECTOR")
   )
   (gtlayerdirector:layerdirector T)
  )
  ((= "ON"
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_LAYER_DIRECTOR")
   )
   (gtlayerdirector:layerdirector T)
  )
)
(PRINC)
