;; Update Procedure for Miltion Titleblocks:
;;

(DEFUN milton:update (/ $block $revisiontag $drawingtag $phasetag $oldphasetag)

  ;;Steps:
  ;;1. Relocate Revision to new location (Justify middle centre)
  ;;2.
  (SETQ $block "Milton Title Block")
  (SETQ $revisiontag "R#")
  (SETQ $drawingtag "D#")
  (SETQ $phasetag "P#")
  (SETQ $oldphasetag "S#")

  (DEFUN milton:moveattributes (/
								$ss
								$i
								$entity
								$titletext
								$attributes
								$attrib
							   )

	(SETQ $ss
		   (SSGET "X"
				  (APPEND (LIST (CONS 0 "INSERT"))
						  (gt:dyn-ssfilter $block)
						  (LIST (CONS 410 (GETVAR "ctab")))
				  )
		   )
	)
	(IF	$ss
	  (PROGN
		(SETQ $i 0)
		(WHILE (< $i (SSLENGTH $ss))
		  (SETQ $entity (SSNAME $ss $i))

		  (SETQ $titletext (VLAX-ENAME->VLA-OBJECT $entity))

		  ;;Get each attributes
		  (SETQ $attributes (VLAX-INVOKE $titletext "GetAttributes"))

		  ;;
		  ;;REVISION TAG
		  ;;
		  (FOREACH $attrib $attributes
			(IF
			  (= (STRCASE (VLA-GET-TAGSTRING $attrib))
				 (STRCASE $revisiontag)
			  )
			   (PROGN
				 (PRINC "\nRevision Attribute found:")
				 (PRINC "\n    Setting Attribute Alignment...")
				 (VLA-PUT-ALIGNMENT $attrib ACALIGNMENTCENTER)
				 (PRINC "\n    Moving Attribute Location...")
				 (VLA-PUT-TEXTALIGNMENTPOINT
				   $attrib
				   (VLAX-3D-POINT (LIST 820.836 21.0 0.0))
				 )
			   )
			)

			;;
			;;PHASE TAG
			;;
			(IF
			  (= (STRCASE (VLA-GET-TAGSTRING $attrib))
				 (STRCASE $oldphasetag)
			  )
			   (PROGN
				 (PRINC "\nPhase Attribute found:")
				 (PRINC "\n    Setting Attribute Alignment...")
				 (VLA-PUT-ALIGNMENT $attrib ACALIGNMENTRIGHT)
				 (PRINC "\n    Moving Attribute Location...")
				 (VLA-PUT-TEXTALIGNMENTPOINT
				   $attrib
				   (VLAX-3D-POINT (LIST 783.091 21.00 0.0))
				 )
				 (PRINC "\n    Changing Attribute Tag...")
				 (VLA-PUT-TAGSTRING $attrib $phasetag)
			   )
			)
			;;
			;;DRAWING TAG
			;;
			(IF
			  (= (STRCASE (VLA-GET-TAGSTRING $attrib))
				 (STRCASE $drawingtag)
			  )
			   (PROGN
				 (PRINC "\nDrawing Attribute found:")
				 (PRINC "\n    Setting Attribute Alignment...")
				 (VLA-PUT-ALIGNMENT $attrib ACALIGNMENTLEFT)
				 (PRINC "\n    Moving Attribute Location...")
				 (VLA-PUT-INSERTIONPOINT
				   $attrib
				   (VLAX-3D-POINT (LIST 795.091 21.0 0.0))
				 )
			   )
			)

		  )
		  (SETQ $i (+ $i 1))
		)
	  )
	  (PROGN
		(PRINC "\nUnable to move revision: No title block found.")
	  )
	)
	(PRINC)
  )


  (DEFUN milton:deletetext ($text
							/
							$ss
							$i
							$entity
							$titletext
						   )
	(VLAX-FOR obj
				  (VLA-ITEM
					(VLA-GET-BLOCKS
					  (VLA-GET-ACTIVEDOCUMENT
						(VLAX-GET-ACAD-OBJECT)
					  )
					)
					$block
				  )
	  (PROGN
		(IF
		  (WCMATCH
			(STRCASE (VLA-GET-OBJECTNAME obj))
			"*TEXT"
		  )
		   (PROGN
			 (IF (=
				   (STRCASE $text T)
				   (STRCASE (VLA-GET-TEXTSTRING obj) T)
				 )
			   (PROGN
				 (PRINC (STRCAT "\nRemoving Text Entity with value: " $text))
				 (VLA-DELETE obj)
			   )
			 )
		   )
		)
	  )
	)
	(PRINC)
  )

  (DEFUN milton:movedicipline ($text
							   $new
							   /
							   $ss
							   $i
							   $entity
							   $titletext
							  )

	(VLAX-FOR obj
				  (VLA-ITEM
					(VLA-GET-BLOCKS
					  (VLA-GET-ACTIVEDOCUMENT
						(VLAX-GET-ACAD-OBJECT)
					  )
					)
					$block
				  )
	  (PROGN
		(IF	(AND

			  (WCMATCH (VLA-GET-OBJECTNAME obj) "AcDb*Text")
			  (= (STRCASE $text T) (STRCASE (VLA-GET-TEXTSTRING obj) T))
			)
		  (PROGN
			(PRINC (STRCAT "\nUpdating Text Entity with value: " $text))
			(PRINC (STRCAT "\n    Changing value to: " $text))
			(VLA-PUT-TEXTSTRING obj $new)
			(PRINC "\n    Changing Alignment...")
			(VLA-PUT-ALIGNMENT obj ACALIGNMENTCENTER)
			(PRINC "\n    Changing Location...")
			(VLA-PUT-TEXTALIGNMENTPOINT
			  obj
			  (VLAX-3D-POINT (LIST 789.091 21.0 0.0))
			)
			(SETQ acdoc (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT)))
			(VLA-REGEN acdoc ACALLVIEWPORTS)
		  )
		)
	  )
	)

	(PRINC)
  )

  (milton:deletetext "[")
  (milton:deletetext "]")
  (milton:movedicipline "S-" "-S-")
  (VL-CMDF "_.attsync" "_N" $block)
  (milton:moveattributes)
  (PRINC)
)
(DEFUN c:miltontitleupdate (/)
  (milton:update)
)