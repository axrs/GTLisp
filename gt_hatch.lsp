;;;CHANGE DIMENSION LAYER SETTINGS HERE
(SETQ xhatchlayer$
         '(
           ("NAME" "S-Hatc") ;Hatch layer name
           ("COLOR" 1) ;Specify a color integer without quotations
           ("LINETYPE" "CONTINUOUS") ;NOTE: If the linetype does not exist within the drawing, then CONTINUOUS will be adopted
          )
)
;;;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-**
;;LoadBearing HATCH
(DEFUN c:lb () (xcreatehatch "SOLID" (GETVAR "DIMSCALE") 1 "235"))
;;EARTH HATCH
(DEFUN c:earth () (xcreatehatch "EARTH" (* 7.5 (GETVAR "DIMSCALE")) 0.785 "8"))
;;ARSAND HATCH
(DEFUN c:arsand () (xcreatehatch "AR-SAND" (* 1 (GETVAR "DIMSCALE")) 0.785 "8"))
;;CONCRETE
(DEFUN c:conc () (xcreatehatch "AR-CONC" (* 1 (GETVAR "DIMSCALE")) 0.785 "8"))
;;GRAVEL
(DEFUN c:gravel () (xcreatehatch "GRAVEL" (* 7.5 (GETVAR "DIMSCALE")) 0.785 "8"))
 ;|
**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
**WARNING: TAMPERING WITH ANY OF THE FUNCTIONS BELOW COULD CAUSE A FAULT TO THE LISP ROUTINES, WHICH CAN BE A PAIN TO DEBUG.         **
**         IF YOU WISH TO HAVE A SETTING CHANGED PLEASE CONSIDER THE FOLLOWING FIRST:                                                **
**         -DO YOU HAVE AN UNDERSTANDING OF LISP ROUTINES AND HOW TO CHANGE THEM?                                                    **
**         -DO YOU KNOW WHERE YOUR ISSUES LIES AND WHAT THE EXACT PROBLEM IS?                                                        **
**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
|;

(DEFUN xcreatehatch (xhatchname$ xscale$ xangle$ xcolor$ / $error)

    (SETQ $error *error*) ;Save the system error reporting function
    (gterror:savesettings)
    (SETQ *error* gterror:trap) ;Change the error trapping utility to a custom function
    (SETVAR "CMDECHO" 0) ;Turn CMD echoing off
    (SETVAR "HPNAME" xhatchname$) ;Set the hatch pattern
    (SETVAR "HPSCALE" xscale$) ;Set the hatch scale
    (SETVAR "HPANG" xangle$) ;Set the hatch angle
    ;;(SETVAR "HPCOLOR" xcolor$)

    (xcreatelayer ;CHECK/CREATE LAYER
        (CADR (ASSOC "NAME" xhatchlayer$)) ;Pull the first value for the placeholder 'NAME' out of the xdimensionlayer$ array
        (CADR (ASSOC "COLOR" xhatchlayer$)) ;Pull the first value for the placeholder 'COLOR' out of the xdimensionlayer$ array
        (CADR (ASSOC "LINETYPE" xhatchlayer$)) ;Pull the first value for the placeholder 'LINETYPE' out of the xdimensionlayer$ array
    )
    (COMMAND "_.-hatch" pause "")
    (SETQ *error* $error) ;Restore the previous error reporting function
    (gterror:restoresettings)
    (PRINC) ;Clean
)


;;;CREATE LAYER FROM SCRATCH
(DEFUN xcreatelayer (xname$ xcolor$ xltype$ / res$)
    (IF (= nil (TBLSEARCH "LTYPE" xltype$)) ;If the LineType table has the LineType specified
        (PROGN ;CASE TRUE, do the following
            (PRINC (STRCAT "\nLinetype: '" ;Inform the user that the specified linetype couldn't be found
                           xltype$
                           "' could NOT be found, adopting CONTINUOUS."
                   )
            )
            (SETQ xltype$ "CONTINUOUS") ;Set xltype$ to CONTINUOUS
        ) ;End of case true
    ) ;End of if
    (IF (= nil (TBLSEARCH "LAYER" xname$)) ;If the result of the table search is nil, i.e no layer exists
        (PROGN ;CASE TRUE, Do the following
            (SETQ res$ (LIST ;Create a list of the layer properties
                           (CONS 0 "LAYER") ;Entity Type
                           (CONS 100 "AcDbSymbolTableRecord") ;Subclass Marker
                           (CONS 100 "AcDbLayerTableRecord") ;Subclass Marker
                           (CONS 2 xname$) ;Layer Name
                           (CONS 6 xltype$) ;Layer Linetype
                           (CONS 62 xcolor$) ;Layer Color
                           (CONS 70 0) ;Standard Flag Values
                           (CONS 290 1) ;Plotable Layer, 1=Plot, 0=Non-Plot
                       )
            )
            (ENTMAKE res$) ;Make the entity
            (PRINC ;Provide the user with feedback, NOTE: STRCAT allows string addition
                (STRCAT "\nSucessfully created the layer: '"
                        xname$
                        "' into the current drawing."
                )
            ) ;Provide user feedback
        ) ;End of case true
        (PRINC ;provide user feedback
            (STRCAT "\nLayer: '"
                    xname$
                    "' already exists within the current drawing."
            )
        )
    ) ;End of if
    (SETVAR "CLAYER" xname$) ;Set the current layer to the newly created layer
    (SETVAR "CELTYPE" "ByLayer") ;Set the current color to 'ByLayer'
    (SETVAR "CECOLOR" "ByLayer") ;Set the current linetype to 'ByLayer'
    (PRINC)
)