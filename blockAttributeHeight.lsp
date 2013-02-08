(DEFUN c:block-to-attribute-height (/ $filter $layer $block $tag $en $ss $keys $prompt $key $keywords $attribute $attributes)

  (VL-LOAD-COM)

  ;;------------------=={ block to height }==--------------------;;
  ;;                                                             ;;
  ;;  Moves a block insertion point to the tag reference height. ;;
  ;;-------------------------------------------------------------;;
  ;;  Usage: (blocktoheight "Block Name" "Tag")                  ;;
  ;;-------------------------------------------------------------;;
  (DEFUN blocktoheight
		       ($block $tag / $ss $i $entity $dxflist $vlentity $attrib $attributes $file $outputlist)
    (SETQ $ss
	   (SSGET "X"
		  (APPEND (LIST (CONS 0 "INSERT"))
			  (dyn-ssfilter $block)
			  (LIST (CONS 410 (GETVAR "ctab")))
		  )
	   )
    )
    (SETQ $i 0)
    ;;Iterate through the selection set
    (WHILE (< $i (SSLENGTH $ss))
      (SETQ $entity (SSNAME $ss $i))
      (SETQ $dxflist (ENTGET $entity))
      (SETQ $location (CDR (ASSOC 10 $dxflist)))
      ;;Obtain the point value from the block reference
      (SETQ $vlentity (VLAX-ENAME->VLA-OBJECT $entity))
      (SETQ $attributes (VLAX-INVOKE $vlentity "GetAttributes"))
      (SETQ $val nil)
      (FOREACH $attrib $attributes
	(IF
	  (= (STRCASE (VLA-GET-TAGSTRING $attrib)) (STRCASE $tag))
	   ;;Change entity height
	   (PROGN
	     (SETQ $val (ATOF (VLA-GET-TEXTSTRING $attrib)))
	     (SETQ $dxflist
		    (SUBST (CONS 10
				 (LIST (NTH 0 (CDR (ASSOC 10 $dxflist)))
				       (NTH 1 (CDR (ASSOC 10 $dxflist)))
				       $val
				 )
			   )
			   (ASSOC 10 $dxflist)
			   $dxflist
		    )
	     )
	     (ENTMOD $dxflist)
	     (ENTUPD $entity)
	   )
	)
      )
      (SETQ $i (+ $i 1))
    )
    (PRINC)
  )

  ;;----------------------=={ dyn-is-p }==-----------------------;;
  ;;                                                             ;;
  ;;  Determines if a block is dynamic or not.                   ;;
  ;;-------------------------------------------------------------;;
  ;;http://www.theswamp.org/index.php?topic=15160.msg183915#msg183915;;
  ;;-------------------------------------------------------------;;
  (DEFUN dyn-is-p (bn / gt$return)
    (COND
      ((AND (= (TYPE bn) 'ename)
	    (VLAX-PROPERTY-AVAILABLE-P
	      (VLAX-ENAME->VLA-OBJECT bn)
	      'isdynamicblock
	    )
       )
       (SETQ gt$return
	      (VLA-GET-ISDYNAMICBLOCK (VLAX-ENAME->VLA-OBJECT bn))
       )
      )
      ((AND (= (TYPE bn) 'vla-object)
	    (vlax-property-avilable-p bn 'isdynamicblock)
       )
       (SETQ gt$return (VLA-GET-ISDYNAMICBLOCK bn))
      )
      ((AND (= (TYPE bn) 'str)
	    (TBLSEARCH "BLOCK" bn)
       )
       (SETQ gt$return
	      (VLA-GET-ISDYNAMICBLOCK
		(VLA-ITEM
		  (VLA-GET-BLOCKS
		    (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT))
		  )
		  (VLAX-MAKE-VARIANT bn VLAX-VBSTRING)
		)
	      )
       )
      )
      (T (SETQ gt$return :VLAX-FALSE))
    )
    (COND
      ((= gt$return :VLAX-TRUE) T)
      ((= gt$return :VLAX-FALSE) nil)
      (T nil)
    )
  )

  ;;--------------------=={ dyn-ssfilter }==---------------------;;
  ;;                                                             ;;
  ;;  Builds and returns a dynamic block filter.                 ;;
  ;;-------------------------------------------------------------;;
  ;;http://www.theswamp.org/index.php?topic=15160.msg183915#msg183915;;
  ;;-------------------------------------------------------------;;
  (DEFUN dyn-ssfilter (bn / gt$filter gt$object gt$ss gt$temp)
    (SETQ gt$filterlist (LIST (CONS 0 "INSERT") (CONS 2 "`*U*")))
    (IF	(SETQ gt$ss (SSGET "X" gt$filterlist))
      (PROGN
	(REPEAT	(SSLENGTH gt$ss)
	  (IF (AND (dyn-is-p (SSNAME gt$ss 0))
		   (WCMATCH (STRCASE (VLA-GET-EFFECTIVENAME
				       (SETQ gt$object
					      (VLAX-ENAME->VLA-OBJECT (SSNAME gt$ss 0))
				       )
				     )
			    )
			    (STRCASE bn)
		   )
	      )
	    (SETQ gt$filter
		   (APPEND gt$filter
			   (LIST (VLA-GET-NAME gt$object))
		   )
	    )
	  )
	  (SSDEL (SSNAME gt$ss 0) gt$ss)
	)
      )
    )
    (IF	gt$filter
      (APPEND (LIST (CONS -4 "<OR"))
	      (MAPCAR '(LAMBDA (x)
			 (CONS 2 (STRCAT "`" x))
		       )
		      gt$filter
	      )
	      (LIST (CONS 2 bn) (CONS -4 "OR>"))
      )
      (LIST (CONS 2 bn))
    )
  )

  ;;-------------------=={ string replace }==--------------------;;
  ;;                                                             ;;
  ;;  Replaces occurances of a string within a string.           ;;
  ;;-------------------------------------------------------------;;
  ;;  Usage: (gtstrings:replace "Some String" "Search" "replace");;
  ;;-------------------------------------------------------------;;
  ;;  Variables:                                                 ;;
  ;;  $string - Input string to parse.                           ;;
  ;;  $search - string to search for within the $string.         ;;
  ;;  $replace - string to replace $search within the $string.   ;;
  ;;-------------------------------------------------------------;;
  ;;  Returns:                                                   ;;
  ;;  A string with the 'Search' replaced with 'replace'.        ;;
  ;;-------------------------------------------------------------;;


  (DEFUN replace_string	($string $search $replace / $temp)
    (SETQ $temp (find_string $string $search))
    (WHILE (NOT (NULL (CADR $temp)))
      (SETQ $temp (find_string
		    (STRCAT (CAR $temp) $replace (CADR $temp))
		    $search
		  )
      )
      (CAR $temp)
    )
    (CAR $temp)
  )

  ;;---------------------=={ find string }==---------------------;;
  ;;                                                             ;;
  ;;  Finds occurances of a string within a string.              ;;
  ;;-------------------------------------------------------------;;
  ;;  Usage: (find_string "Some String" "Search")                ;;
  ;;-------------------------------------------------------------;;
  ;;  Variables:                                                 ;;
  ;;  $string - Input string to parse.                           ;;
  ;;  $search - string to search for within the $string.         ;;
  ;;  $i    - Current character position                         ;;
  ;;  $repeat - The remainder of the string to repeat through.   ;;
  ;;-------------------------------------------------------------;;
  ;;  Returns:                                                   ;;
  ;;  A split list of the string with the search item removed.   ;;
  ;;-------------------------------------------------------------;;

  (DEFUN find_string ($string $search / $i $repeat)
    (SETQ $i 1)
    (WHILE (<= $i (STRLEN $string))
      (IF (= (SUBSTR $string $i (STRLEN $search)) $search)
	(PROGN
	  (SETQ	$repeat	(LIST (SUBSTR $string 1 (1- $i))
			      (SUBSTR $string (+ $i (STRLEN $search)))
			)
	  )
	  (SETQ $i (1+ (STRLEN $string)))
	)
	(SETQ $i (1+ $i))
      )
    )
    (IF	(NULL $repeat)
      (LIST $string nil)
      $repeat
    )
  )

  ;;--------------------=={ split string }==---------------------;;
  ;;                                                             ;;
  ;;  Splits a string of text at a specified delimiter.          ;;
  ;;-------------------------------------------------------------;;
  ;;  Usage: (SETQ $list (split_string "Some String" "S"))       ;;
  ;;-------------------------------------------------------------;;
  ;;  Variables:                                                 ;;
  ;;  $string - Input string to parse.                           ;;
  ;;  $delimeter - Character to split the string at.             ;;
  ;;  $list - list to return of the split string.                ;;
  ;;  $i - Current character parser count.                       ;;
  ;;-------------------------------------------------------------;;
  ;;  Returns:                                                   ;;
  ;;  A list variable of strings stopping at the delimiter.      ;;
  ;;-------------------------------------------------------------;;

  (DEFUN split_string ($target $delimeter / $target_length ;Target Find Length
		       $counter		;Counter
		       $first_char	;First Character
		       $current_char	;Current Character
		       $first		;First String
		       $return		;Return List
		       $current		;Current Remainaing String
)
    (SETQ $target_length
	   (STRLEN $target)
	  $counter 1
	  $first_char
	   0
	  $first 0
    )
    (REPEAT $target_length
      (SETQ $current_char (SUBSTR $target $counter 1))
      (IF (NOT (= $current_char $delimeter))
	(PROGN
	  (IF (= $first_char 0)
	    (PROGN
	      (SETQ $current $current_char)
	      (SETQ $first_char 1)
	    )
	    (SETQ $current (STRCAT $current $current_char))
	  )
	)
	(PROGN
	  (IF (= $first_char 0)
	    (SETQ $first_char 0)
	    (PROGN
	      (IF (= $first 0)
		(PROGN
		  (SETQ $return (LIST $current))
		  (SETQ $first 1)
		  (SETQ $first_char 0)
		)
		(PROGN
		  (SETQ $return (APPEND $return (LIST $current)))
		  (SETQ $first_char 0)
		)
	      )
	    )
	  )
	)
      )
      (IF (= $counter $target_length)
	(IF (NOT (= $current_char $delimeter))
	  (SETQ $return (APPEND $return (LIST $current)))
	)
      )
      (SETQ $counter (+ $counter 1))
    )
    (SETQ $return $return)
  )


  ;;-------------------------------------------------------------;;
  ;;MAIN FUNCTION                                                ;;
  ;;-------------------------------------------------------------;;
  (SETQ $keywords "")
  (SETQ $keys "")
  (SETQ $prompt "")
  (SETQ $filter (LIST (CONS 0 "INSERT")))
  (SETQ $ss (SSGET ":S" $filter))
  (SETQ $en (ENTGET (SSNAME $ss 0)))
  (SETQ $block (VLA-GET-EFFECTIVENAME (VLAX-ENAME->VLA-OBJECT (SSNAME $ss 0))))
  (SETQ $attributes (VLAX-INVOKE (VLAX-ENAME->VLA-OBJECT (SSNAME $ss 0)) "GetAttributes"))

  (FOREACH $attribute $attributes
    (SETQ $keywords (STRCAT $keywords "," (STRCASE (VLA-GET-TAGSTRING $attribute) T)))
  )
  ;;Replace of '_' to '--' (2 hyphens) character to ensure INIT get works.
  (SETQ $keywords (replace_string $keywords "_" "--"))
  (SETQ $keywords (VL-STRING-LEFT-TRIM "," $keywords))

  ;;Build the keys and prompt
  (FOREACH $key	(split_string $keywords ",")
    (SETQ $keys (STRCAT $keys " " $key))
    (SETQ $prompt (STRCAT $prompt "/" $key))
  )

  (SETQ $keys (VL-STRING-LEFT-TRIM " " $keys))
  (SETQ $prompt (VL-STRING-LEFT-TRIM "/" $prompt))

  ;;Prompt for the input
  (INITGET $keys)

  (SETQ	$tag
	 (GETKWORD
	   (STRCAT "\nSpecify a description tag to use:\n[" $prompt "]: ")
	 )
  )
  (PRINC $tag)

  ;;Change the block heights
  (IF (NOT (= $tag nil))
    (blocktoheight $block (replace_string $tag "--" "_"))
  )

  (PRINC)
)

