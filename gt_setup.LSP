(DEFUN setbkcolor ()
  (SETQ	acad	(VLAX-GET-ACAD-OBJECT)
	pref	(VLA-GET-PREFERENCES acad)
	disp	(VLA-GET-DISPLAY pref)
	newcolr	(VLAX-MAKE-VARIANT 255 19)
  )					;setq

  (IF (= (GETVAR "tilemode") 1)
    ;;change the modelspace background color 
    (PROGN
      (SETQ oldcolr	(VLA-GET-GRAPHICSWINMODELBACKGRNDCOLOR disp)
	    ;;convert unsupported variant type 19 to vlax-vbLong 
	    oldcolrlong	(VLAX-VARIANT-CHANGE-TYPE
			  (VLA-GET-GRAPHICSWINMODELBACKGRNDCOLOR disp)
			  VLAX-VBLONG
			)
      )					;setq

      (VLA-PUT-GRAPHICSWINMODELBACKGRNDCOLOR disp newcolr)
      (ALERT (STRCAT "Restore previous background color: "
		     (ITOA (VLAX-VARIANT-VALUE oldcolrlong))
	     )
      )
      ;;restore previous model background color 
      (VLA-PUT-GRAPHICSWINMODELBACKGRNDCOLOR disp oldcolr)
    )					;progn

    ;;change the paperspace (layout) background color 
    (PROGN
      (SETQ oldcolr	(VLA-GET-GRAPHICSWINLAYOUTBACKGRNDCOLOR disp)
	    ;;convert unsupported variant type 19 to vlax-vbLong 
	    oldcolrlong	(VLAX-VARIANT-CHANGE-TYPE
			  (VLA-GET-GRAPHICSWINLAYOUTBACKGRNDCOLOR disp)
			  VLAX-VBLONG
			)
      )					;setq 
      (VLA-PUT-GRAPHICSWINLAYOUTBACKGRNDCOLOR disp newcolr)
      (ALERT (STRCAT "Restore previous background color: "
		     (ITOA (VLAX-VARIANT-VALUE oldcolrlong))
	     )
      )

      ;;restore previous paper space background color 
      (VLA-PUT-GRAPHICSWINLAYOUTBACKGRNDCOLOR disp oldcolr)
    )					;progn 
  )					;if 
)