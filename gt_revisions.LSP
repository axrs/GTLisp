;|
**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=X_CLOUDS.LSP-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
**                              by XANDER - SEP 09                               **
**                          Rectangular Revision Clouds                          **
**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
** REVISION:                                                                     **
**    A               First release                                 ~22/09/2009  **
**    B               Increased the cloud selection filter           27/10/2010  **
**                    Sends the newly created cloud to the background            **
**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
**                                                                               **
** COMMAND LIST:                                                                 **
**                                                                               **
** FUNCTION                  DESCRIPTION                                         **
**                                                                               **
** RCCLOUD            Draws Rectangular Revision Clouds                          **
**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
|;
										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
(DEFUN c:rccloud () (c:x_revcloud))		; Defined list of comands capable of starting the revcloud routine                **
(DEFUN c:rectcloud () (c:x_revcloud))	;                                                                                 **
(DEFUN c:rcloud () (c:x_revcloud))		;                                                                                 **
(DEFUN c:x_revcloud	()					;                                                                                 **
  (x_rc_revcloud)						;                                                                                 **
)										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**

										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
(DEFUN x_rc_create_layer (layer linetype color) ; X_RC_CREATE_LAYER                                                               **
  (COMMAND "-LAYER"	"MAKE" layer "COLOR" color layer "LTYPE" linetype layer	nil	"") ; Small Function to Create a Layer if required                                    **
  (PRINC)								;                                                                                 **
)										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**

										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
(DEFUN x_rc_save ()						; X_RC_SAVE                                                                       **
  (SETQ ds (GETVAR "dimscale"))			; This function was originally produced by the infamous Dr.Who                    **
  (SETQ inlayer (GETVAR "clayer"))		; The concept of the function was to save all system variables the written        **
  (SETQ incolor (GETVAR "cecolor"))		; routines might need to change in-order to run effectively.                      **
  (SETQ inltype (GETVAR "celtype"))		;                                                                                 **
  (SETQ inort (GETVAR "orthomode"))		; The function here has been adopted, modified and dynamically changed throughout **
  (SETQ inos (GETVAR "osmode"))			; my routines to allow for only specific variables in-play to be saved and        **
  (SETQ inpkbx (GETVAR "pickbox"))		; restored.  Insuring less memory is used by AutoCAD and that functions can be    **
  (SETQ inplwd (GETVAR "plinewid"))		; altered without fear of damaging any other routines                             **
  (SETQ inecho (GETVAR "cmdecho"))		;                                                                                 **
)										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**

(DEFUN x_rc_restore	()					;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
  (SETVAR "clayer" inlayer)				; X_RC_RESTORE                                                                    **
  (SETVAR "cecolor" incolor)			; Function used to restore any altered variables during the calling routines.     **
  (SETVAR "celtype" inltype)			;                                                                                 **
  (SETVAR "orthomode" inort)			;                                                                                 **
  (SETVAR "osmode" inos)				;                                                                                 **
  (SETVAR "pickbox" inpkbx)				;                                                                                 **
  (SETVAR "plinewid" inplwd)			;                                                                                 **
  (SETVAR "cmdecho" inecho)				;                                                                                 **
)										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**

										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**
(DEFUN x_rc_revcloud ()					; X_RC_REVCLOUD                                                                   **
  (x_rc_save)							; Save the Current Drawing Settings                                               **
  (SETVAR "cmdecho" 0)					; Turn on/off command line echo (1 for on, 0 for off)                             **
  (SETVAR "osmode" 0)					;                                                                                 **
  (SETQ rc_layer "Rev-Cloud")			; Set the revision cloud layer variable to 'Rev-Cloud                             **
  (x_rc_create_layer rc_layer "Continuous" "253") ; Create the RevCloud Layer (will skip if it exists)                              **
  (SETVAR "cecolor" "253")				; Set the drawing color to 253 (GT Standard)                                      **
  (SETQ pwid (RTOS (* 0.8 (GETVAR "dimscale")))) ; Calculate the Revision Cloud Width as 0.8*Current Scale (GT Standard)           **
  (COMMAND "plinewid" pwid)				; Set the Polyline didth through the command line                                 **
  (SETQ	inc_angle 110					; Calculate the arc angle                                                         **
		arc_dist  (* 4.50 ds)			;                                                                                 **
  )										;                                                                                 **
  (INITGET 1)							;                                                                                 **
  (SETQ rc_pt1 (GETPOINT "\nSpecify the first corner:")) ; Prompt the User for the First Point of the Rectangle                            **
  (INITGET 33)							;                                                                                 **
  (SETQ rc_pt2 (GETCORNER rc_pt1 "\nSpecify the second corner:")) ; Prompt the user for the Second Point of the Rectangle                           **
  (COMMAND "RECTANGLE" rc_pt1 rc_pt2)	; Draw the Rectangle                                                              **
										;                                                                                 **
  (SETQ rc_pt1x (- (CAR rc_pt1) (* 2 ds))) ; These four points are used to select the rectangle                              **
  (SETQ rc_pt1y (+ (CADR rc_pt1) (* 2 ds))) ; just drawn.  The offsets are provides so as to ensure                           **
  (SETQ rc_pt2x (+ (CAR rc_pt1) (* 2 ds))) ; the rectangle is actually selected.                                             **
  (SETQ rc_pt2y (- (CADR rc_pt1) (* 2 ds))) ;                                                                                 **
										;                                                                                 **
  (SETQ	rc_ents	(SSGET					; Select Entity                                                                   **
				  "C"					; Crosses Points                                                                  **
				  (LIST rc_pt1x rc_pt1y) ; Point 1                                                                         **
				  (LIST rc_pt2x rc_pt2y) ; Point 2                                                                         **
				  '(					;                                                                                 **
					(0 . "POLYLINE,LWPOLYLINE") ; Which is a Polyline                                                             **
					(-4 . "&")			; AND                                                                             **
					(62 . 253)			; the entity color is 253                                                         **
					(70 . 1)			; Which is a closed Polyline                                                      **
				   )					;                                                                                 **
				)						;                                                                                 **
  )										;                                                                                 **
										;                                                                                 **
  (COMMAND "REVCLOUD" "OBJECT" rc_ents "no" nil) ; Turn the Selected Entity (Should be 1 Rectangle) into a Revision Cloud          **
  (SETQ	rc_ents2 (SSGET					; Select Entity                                                                   **
				   "C"					; Crosses Points                                                                  **
				   (LIST rc_pt1x rc_pt1y) ; Point 1                                                                         **
				   (LIST rc_pt2x rc_pt2y) ; Point 2                                                                         **
				   '(					;                                                                                 **
					 (0 . "POLYLINE,LWPOLYLINE") ; Which is a Polyline                                                             **
					 (-4 . "&")			; AND                                                                             **
					 (62 . 253)			; the entity color is 253                                                         **
					)					; NOTE: A revision cloud PolyLine is NOT closed                                   **
				 )						;                                                                                 **
  )										; Obtain the newly created cloud as an Entity                                     **
										;                                                                                 **
  (COMMAND "PEDIT" rc_ents2 "WIDTH" pwid "") ; Edit the Selected revision cloud and change the width                           **
  (COMMAND "plinewid" "0")				; Set the Polyline width back to 0                                                **
  (SETQ askif (STRCASE (GETSTRING "\nDraw Revision Triangle? <Y>:"))) ; Ask if we need to draw a triangle                                               **
  (IF (/= askif "N")					; If the result is anything but 'N'                                               **
	(gt_revtri)							; Call the standard GT routine for Revision Triangles                             **
  )										;                                                                                 **
  (COMMAND "DRAWORDER" rc_ents2 "" "BACK" nil) ; Using the previouslly obtained entity id, send the revision cloud to the back   **
  (x_rc_restore)						; Restore the users variables                                                     **
)										;**=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=**