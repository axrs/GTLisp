(DEFUN c:gt-information-about ()
  (ALERT
    (STRCAT
      "GTLISP Utilities"
      "\n\nCopyright (C) Glynn Tucker Consulting Engineers 1999 - 2011"
      "\n\nBuild: "
      $gtversion
    )
  )
)

(DEFUN c:gt-block-attribute-height (/	       $filter	  $layer
				    $block     $tag	  $en
				    $ss	       $keys	  $prompt
				    $key       $keywords  $attribute
				    $attributes
				   )
  (SETQ $keywords "")
  (SETQ $keys "")
  (SETQ $prompt "")
  (SETQ $filter (LIST (CONS 0 "INSERT")))
  (SETQ $ss (SSGET ":S" $filter))
  (SETQ $en (ENTGET (SSNAME $ss 0)))
  (SETQ	$block (VLA-GET-EFFECTIVENAME
		 (VLAX-ENAME->VLA-OBJECT (SSNAME $ss 0))
	       )
  )
  (SETQ	$attributes
	 (VLAX-INVOKE
	   (VLAX-ENAME->VLA-OBJECT (SSNAME $ss 0))
	   "GetAttributes"
	 )
  )

  (FOREACH $attribute $attributes
    (SETQ $keywords (STRCAT $keywords
			    ","
			    (STRCASE (VLA-GET-TAGSTRING $attribute) T)
		    )
    )
  )
  ;;Replace of '_' to '--' (2 hyphens) character to ensure INIT get works.    
  (SETQ $keywords (gtstrings:replace2 $keywords "_" "--"))
  (princ $keywords)
  (SETQ $keywords (VL-STRING-LEFT-TRIM "," $keywords))

  ;;Build the keys and prompt
  (FOREACH $key	(gtstrings:split $keywords ",")
    (SETQ $keys (STRCAT $keys " " $key))
    (SETQ $prompt (STRCAT $prompt "/" $key))
  )

  (SETQ $keys (VL-STRING-LEFT-TRIM " " $keys))
  (SETQ $prompt (VL-STRING-LEFT-TRIM "/" $prompt))

  ;;Prompt for the input
  (INITGET $keys)

  (SETQ	$tag
	 (GETKWORD
	   (STRCAT "\nSpecify a description tag to use:\n["
		   $prompt
		   "]: "
	   )
	 )
  )
  ;;Change the block heights
  (IF (NOT (= $tag nil))
    (gtblocks:blocktoheight
      $block
      (gtstrings:replace2 $tag "--" "_")
    )
  )
)



(DEFUN c:gt-export-setoutpoints	(/	    $filter    $layer
				 $block	    $tag       $en
				 $ss	    $keys      $prompt
				 $key	    $keywords  $attribute
				 $attributes
				)

  (SETQ $olderror *error*)
  (gterror:savesettings)
  (SETQ *error gterror:trap)
  (SETVAR "CMDECHO" 0)

  (SETQ $keywords "")
  (SETQ $keys "")
  (SETQ $prompt "")
  (SETQ $filter (LIST (CONS 0 "INSERT")))
  (SETQ $ss (SSGET ":S" $filter))
  (SETQ $en (ENTGET (SSNAME $ss 0)))
  (SETQ $layer (CDR (ASSOC 8 $en)))
  (SETQ	$block (VLA-GET-EFFECTIVENAME
		 (VLAX-ENAME->VLA-OBJECT (SSNAME $ss 0))
	       )
  )
  (SETQ	$attributes
	 (VLAX-INVOKE
	   (VLAX-ENAME->VLA-OBJECT (SSNAME $ss 0))
	   "GetAttributes"
	 )
  )

  (FOREACH $attribute $attributes
    (SETQ
      $keywords	(STRCAT $keywords "," (VLA-GET-TAGSTRING $attribute))
    )
  )

  (SETQ $keywords (VL-STRING-LEFT-TRIM "," $keywords))
  (FOREACH $key	(gtstrings:split $keywords ",")
    (SETQ $keys (STRCAT $keys " " $key))
    (SETQ $prompt (STRCAT $prompt "/" $key))
  )

  (SETQ $prompt (VL-STRING-LEFT-TRIM "/" $prompt))

  (INITGET $keys)

  (SETQ	$tag
	 (GETKWORD
	   (STRCAT "\nSpecify a description tag to use:\n["
		   $prompt
		   "]: "
	   )
	 )
  )

  (IF (NOT (= $tag nil))
    (PROGN
      (PRINC
	(STRCAT
	  "\nCreating CSV File using the following settings:\nLAYER: "
	  $layer
	  "\nBLOCK: "
	  $block
	  "\nTAG: "
	  $tag
	 )
      )
      (gtblocks:pointstocsv $layer $block $tag)
    )
  )

  (SETQ *error* nil)
  (gterror:restoresettings)
)

(DEFUN c:gt-create-blocks ()
  (gtblocks:createarr1)
  (gtblocks:createarr2)
  (gtblocks:createarr3)
  (gtblocks:createarr4)
  (gtblocks:createarr5)
  (gtblocks:createarr6)
  (gtblocks:createarr7)
)
(DEFUN c:gt-save-blocks	()
  (gtblocks:savearr1)
  (gtblocks:savearr2)
  (gtblocks:savearr3)
  (gtblocks:savearr4)
  (gtblocks:savearr5)
  (gtblocks:savearr6)
  (gtblocks:savearr7)
)

;;----------=====ARCHIVE DRAWING=====----------
