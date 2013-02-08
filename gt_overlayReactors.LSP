(IF	(= (STRCASE
		 (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_OVERLAY")
		 nil
	   )
	   "ON"
	)
  (PROGN
	(OR	*reactor:grdisplay*
		(SETQ *reactor:grdisplay*
			   (LIST
				 (VLR-COMMAND-REACTOR
				   nil
				   '(
					 (:VLR-COMMANDWILLSTART . reactor:grdisplay)
					 (:VLR-COMMANDENDED . reactor:grdisplay)
					)
				 )
				 (VLR-MOUSE-REACTOR
				   nil
				   '(
					 (:VLR-BEGINDOUBLECLICK . reactor:grdisplay)
					 (:VLR-BEGINDOUBLECLICK . reactor:grdisplay)
					)

				 )
				 (VLR-WINDOW-REACTOR
				   nil
				   '(
					 (:VLR-DOCFRAMEMOVEDORRESIZED . reactor:grdisplay)
					 (:VLR-MAINFRAMEMOVEDORRESIZED . reactor:grdisplay)
					)

				 )
				 (VLR-LISP-REACTOR
				   nil
				   '(
					 (:VLR-LISPWILLSTART . reactor:grdisplay)
					 (:VLR-LISPENDED . reactor:grdisplay)
					 (:VLR-LISPCANCELLED . reactor:grdisplay)
					)
				 )
			   )
		)

	)
  )
)
(PRINC)