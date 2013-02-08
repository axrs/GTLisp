(DEFUN c:gtleader (/ $i	$pointlist $vectorlist $lastpoint $entitylist $combination $flag $start	$head $headblock $loop g base $input $output $textheight $textcolor	$inputstring $oldscale $olderror $pt)

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTLeader:Error</function>
  <summary>Handles AutoCAD Debugging</sumary>
  <param name="$message">AutoCAD Error Message</param>

  <returns>*error* variable</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN gtleader:error	($message)
	(OR	(= $message "Function cancelled")
		(PRINC (STRCAT "\nError: " $message))
	)
	;;Remove the arrow block
	(IF	(AND $headblock
			 (ENTGET $headblock)
		)
	  (ENTDEL $headblock)
	)
	(SETVAR "MLEADERSCALE" $oldscale)
	(SETQ *error* $olderror)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTLeader:Orthoread</function>
  <summary>Orthogonal GRRead</sumary>
  <param name="base">First selection point</param>
  <param name="point">Proposed end point</param>
  
  <returns>Transformed end point</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtleader:orthodread (base point)
	(IF	(ZEROP (GETVAR 'orthomode))
	  point
	  (APPLY 'POLAR
			 (CONS base
				   (
					(LAMBDA	(n / a x z)
					  (SETQ	x (- (CAR (TRANS point 0 n)) (CAR (TRANS base 0 n)))
							z (- (CADDR (TRANS point 0 n)) (CADDR (TRANS base 0 n)))
							a (ANGLE '(0. 0. 0.) n)
					  )
					  (IF (< (ABS z) (ABS x))
						(LIST (+ a (/ PI 2.)) x)
						(LIST a z)
					  )
					)
					 (TRANS (GETVAR 'ucsxdir) 0 1)
				   )
			 )
	  )
	)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTLeadeR:GRDraw</function>
  <summary>Draws an arrow head with a specified rotation</summary>

  <param name="$headblock">Arrow head block entity</param>
  <param name="$rotation">Rotation Angle</param>

  <returns>nil</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN gtleader:grdraw ($headblock $rotation / $entitylist)
	(SETQ $entitylist (ENTGET $headblock))
	(SETQ $entitylist
		   (SUBST (CONS 50 $rotation)
				  (ASSOC 50 $entitylist)
				  $entitylist
		   )
	)
	(ENTMOD $entitylist)
	(ENTUPD $headblock)
	nil
  )

  (DEFUN gtleader:changehead ($headblock $head / $entitylist)
	(SETQ $entitylist (ENTGET $headblock))
	(SETQ $entitylist (SUBST (CONS 2 $head) (ASSOC 2 $entitylist) $entitylist))

	;;Scale the Circle Arrow Head
	(IF	(= $head "GT-ARR8")
	  (PROGN
		(SETQ $entitylist
			   (SUBST (CONS 41 (* (GETVAR "MLEADERSCALE") 2))
					  (ASSOC 41 $entitylist)
					  $entitylist
			   )
		)
		(SETQ $entitylist
			   (SUBST (CONS 42 (* (GETVAR "MLEADERSCALE") 2))
					  (ASSOC 42 $entitylist)
					  $entitylist
			   )
		)
		(SETQ $entitylist
			   (SUBST (CONS 43 (* (GETVAR "MLEADERSCALE") 2))
					  (ASSOC 43 $entitylist)
					  $entitylist
			   )
		)
	  )
	  (PROGN
		(SETQ $entitylist
			   (SUBST (CONS 41 (GETVAR "MLEADERSCALE"))
					  (ASSOC 41 $entitylist)
					  $entitylist
			   )
		)
		(SETQ $entitylist
			   (SUBST (CONS 42 (GETVAR "MLEADERSCALE"))
					  (ASSOC 42 $entitylist)
					  $entitylist
			   )
		)
		(SETQ $entitylist
			   (SUBST (CONS 43 (GETVAR "MLEADERSCALE"))
					  (ASSOC 43 $entitylist)
					  $entitylist
			   )
		)
	  )
	)
	(ENTMOD $entitylist)
	(ENTUPD $headblock)
  )

  (DEFUN gtleader:makemleader ($pointlist $textheight $textcolor $arrow	$text /	dic	$entitylist	$point $direction $textpoint $textwidth)

	(DEFUN colour->mleaderstylecolour (c)
	  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
	  ;|
            <function>gtcolor:rgb->true</function>
            <summary>Converts an RGB color to a true color</sumary>
            <param name="r">Red color value</param>
            <param name="g">Green color value</param>
            <param name="b">Blue color value</param>
            <returns>Color value</returns>
            |;
	  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

	  (DEFUN gtcolor:rgb->true (r g b)
		(+
		  (LSH (FIX r) 16)
		  (LSH (FIX g) 8)
		  (FIX b)
		)
	  )
	  (COND
		((LISTP c)
		 (+ -1040187392 (APPLY 'gtcolor:rgb->true c))
		)
		((= 0 c)
		 -1056964608
		)
		((= 256 c)
		 -1073741824
		)
		((< 0 c 256)
		 (+ -1023410176 (gtcolor:rgb->true 0 0 c))
		)
	  )
	)

	(DEFUN radtodeg	($angle)
	  (/ (* $angle 180.0) PI)
	)

	(SETQ dic (DICTSEARCH
				(SETQ dic (CDR
							(ASSOC -1 (DICTSEARCH (NAMEDOBJDICT) "ACAD_MLEADERSTYLE"))
						  )
				)
				"GTSTD"
			  )
	)


	;;Calculate if the text is left or right
	(SETQ $direction (FIX (radtodeg (ANGLE (CAR $pointlist) (LAST $pointlist)))))
	(IF	(AND (> 270 $direction) (< 90 $direction))
	  (SETQ $direction -1)
	  (SETQ $direction 1)
	)


	(IF	$text
	  (PROGN
		;;Make a temporary MTEXT object to calculate the text width
		(SETQ $entitylist
			   (LIST
				 '(0 . "MTEXT")
				 '(100 . "AcDbEntity")
				 (CONS 410 (GETVAR "CTAB"))
				 (CONS 8 (GETVAR "CLAYER"))
				 '(100 . "AcDbMText")
				 (CONS 10 (CAR $pointlist))
				 (CONS 40 (* $textheight (GETVAR "MLEADERSCALE")))
				 '(41 . 0.0)			;Reference rectangle width

				 '(71 . 1)				;Attachment Point
				 '(72 . 1)				;Drawing Direction (LTR)
				 (CONS 1 $text)			;Text
				 '(7 . "GTSTD")			; Text Style
				 '(210 0.0 0.0 1.0)
				 '(11 1.0 0.0 0.0)
				 '(50 . 0.0)			; Rotation Angle
				 '(73 . 1)				;Spacing Style
				 '(44 . 1.0)			;Line Spacing Factor
			   )
		)
		;;Temporarilary make the text entity then delete it
		(ENTMAKE $entitylist)
		(ENTGET (ENTLAST))
		(SETQ $textwidth (CDR (ASSOC 42 (ENTGET (ENTLAST)))))
		(ENTDEL (ENTLAST))

		;;Calculate the text insertion point
		(IF	(= $direction 1)
		  (SETQ $textwidth 0)
		)
		(SETQ $textpoint
			   (MAPCAR '+
					   (LIST
						 (*	$direction	;Left/Right
							(+ (* 3.0 (GETVAR "MLEADERSCALE")) ;Dog Leg
							   (* 1.5 (GETVAR "MLEADERSCALE")) ;Landing Gap
							   $textwidth
							)
						 )
						 (* (/ $textheight 2) (GETVAR "MLEADERSCALE"))
						 0
					   )
					   (LAST $pointlist)
			   )
		)
	  )
	  (PROGN
		(SETQ $text "")
		(SETQ $textpoint
			   (MAPCAR '+
					   (LIST
						 (*	$direction	;Left/Right
							(+ (* 3.0 (GETVAR "MLEADERSCALE")) ;Dog Leg
							   (* 1.5 (GETVAR "MLEADERSCALE")) ;Landing Gap
							)
						 )
						 (* (/ $textheight 2) (GETVAR "MLEADERSCALE"))
						 0
					   )
					   (LAST $pointlist)
			   )
		)
	  )
	)



	(SETQ $entitylist
		   (LIST
			 '(0 . "MULTILEADER")
			 '(100 . "AcDbEntity")
			 (CONS 410 (GETVAR "CTAB"))	;Tab
			 (CONS 8 (GETVAR "CLAYER"))	;Layer
			 '(100 . "AcDbMLeader")
			 '(300 . "CONTEXT_DATA{")
			 (CONS 40 (GETVAR "MLEADERSCALE")) ;Leader Content Scale (inc Arrow Head)
			 (CONS 10 (LAST $pointlist)) ; Starting Landing Point
			 (CONS 41 (* $textheight (GETVAR "MLEADERSCALE"))) ;Text Height
			 (CONS 140 (GETVAR "MLEADERSCALE")) ; Arrow Head Size
			 (CONS 145 (* 1.5 (GETVAR "MLEADERSCALE"))) ;Landing Gap
			 '(174 . 1)					;Text Angle Type
			 '(175 . 1)					;Text Alignment Type
			 '(176 . 0)					;Block Content Connection Type
			 '(177 . 0)					;Block attribute index
			 '(290 . 1)					;Has MText
			 (CONS 304 $text)			;Default Text Contents
			 '(11 0.0 0.0 1.0)			;Text Direction
			 (CONS 340 (CDR (ASSOC 342 dic))) ;Text Style ID
			 (CONS 12 $textpoint)		;Text Location
			 '
			  (13 1.0 0.0 0.0)			;Text Direction
			 '(42 . 0.0)				;Text Rotation
			 '(43 . 0.0)				;Text Width
			 '(44 . 0.0)				;Text Height
			 '(45 . 0.9)				;Text Line Spacing Factor
			 '(170 . 0)					;Text Line Spacing Style
			 (CONS 90 (colour->mleaderstylecolour $textcolor)) ;Text Color
			 '(171 . 1)					;Text Attachment
			 '(172 . 5)					;Text Flow Direction
			 ;;(91 . -1073741824);Text Background Color
			 ;;(141 . 0.0) ;Text Background Scale Factor
			 ;;(92 . 0);Text Background Transparency
			 ;;(291 . 0);Text Background Color On
			 ;;(292 . 0);Text Background Fill On
			 ;;(173 . 0);Text Column Type
			 ;;(293 . 0);Use Text Auto Height
			 ;;(142 . 0.0);Text Column Width
			 ;;(143 . 0.0);Text Column Gutter Width
			 ;;(294 . 0);Text Column Flow Reversed
			 ;;(295 . 0);Text Use Word Break
			 ;;(296 . 0);Has Block
			 (CONS 110 (CAR $pointlist)) ; Startpoint
			 ;;(111 1.0 0.0 0.0) ; MLeader plane X-Axis
			 ;;(112 0.0 1.0 0.0) ; MLeader Plane Y-Axis
			 ;;(297 . 0);MLeader Plane reversed
			 '
			  (302 . "LEADER{")
			 '(290 . 1)					;Has set Last Leader Line Point
			 '(291 . 1)					;Has Set Dogleg Vector
			 (CONS 10

				   (LAST $pointlist)
			 )							;End of leader (Start of landing)

			 (CONS 11 (LIST $direction 0.0 0.0))
			 ;;Dog Leg Vector
			 '
			  (90 . 0)					;Leader Branch Index
			 (CONS 40 (* 3.0 (GETVAR "MLEADERSCALE"))) ;Dogleg Length
			 '(304 . "LEADER_LINE{")

		   )
	)

	;;Add the captured verticies
	(FOREACH $point	(REVERSE (CDR (REVERSE $pointlist)))
	  (SETQ $entitylist (APPEND $entitylist (LIST (CONS 10 $point))))
	)
	(SETQ $entitylist
		   (APPEND $entitylist
				   (LIST
					 '(91 . 0)			;Leader Line Index
					 ;;(170 . 1); Unknown
					 ;;(92 . -1056964608) ;Leader Line Color
					 ;;(340 . <entity name: 0>) ; Unknown
					 ;;(171 . -2) ; Unknown
					 ;;(40 . 0.0); Unknown
					 ;;(341 . <entity name: 0>) ; Block Content ID
					 ;;(93 . 0);Block Content Color
					 '
					  (305 . "}")
					 '(271 . 0)			;Text Attachment Direction
					 '(303 . "}")
					 '(272 . 9)			;Bottom Text Attachment
					 '(273 . 9)			;Top Text Attachment
					 '(301 . "}")
					 (CONS 340 (CDR (ASSOC 330 dic))) ; Leader Style
					 '(90 . 263168)		;Property override flag
					 '
					  (170 . 1)
					 (CONS 341 (CDR (ASSOC 342 dic))) ;Leader Line Type
					 '(171 . -1)
					 '(290 . 1)
					 '(291 . 1)
					 '(41 . 3.0)		;Dogleg Length
					 (CONS 342
						   (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" $arrow))))
					 )					;Leader Arrow Block
					 '(42 . 1.0)		;Arrow Size

					 '(172 . 2)			; Content Type
					 (CONS 343
						   (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "STYLE" "GTSTD"))))
					 )					;Text Style
					 '(173 . 1)			; Text Attachment type
					 '(95 . 1)			; Text Right Attachment Type
					 '(174 . 1)			; Text Angle Type
					 '(175 . 0)			;Text Alignment Type
					 (CONS 92 (colour->mleaderstylecolour $textcolor)) ;Text Color
					 '(292 . 0)			;Enable frame text
					 ;;(93 . -1073741824);Block content Color
					 '
					  (10 1.0 1.0 1.0)	;Block content scale
					 '(43 . 0.0)		;Block content rotation
					 '(176 . 0)			;Block content connection type
					 '(293 . 0)			;enable annotations cale
					 '(294 . 0)			;Text Direction Negative
					 '(178 . 1)			;Text Align in IPE
					 '(179 . 1)			;Text Attachment Point 1 = top left, 3 = top right
					 (CONS 45 (GETVAR "MLEADERSCALE")) ;Global Scale Factor
					 '(271 . 0)			;Text Direction for MText
					 '(272 . 9)			;Bottom Text Attachment Direction
					 '(273 . 9)			;Top Text Attachment Direction
				   )

		   )
	)

	;;Create the leader
	(ENTMAKE $entitylist)

	;;If the leader head is the circle, update the leader to reflect the appropriate scale
	(IF	(= "GT-ARR8" $arrow)
	  (PROGN
		(SETQ $entitylist (ENTGET (ENTLAST)))
		(SETQ $entitylist
			   (SUBST
				 (CONS 140 (* 2 (GETVAR "MLEADERSCALE")))
				 (ASSOC 140 (ENTGET (ENTLAST)))
				 $entitylist
			   )
		)
		(SETQ $entitylist
			   (SUBST (CONS 42 4.0)
					  (ASSOC 42
							 (MEMBER '(304 . "LEADER_LINE{") (ENTGET (ENTLAST)))
					  )
					  $entitylist
			   )
		)
		(ENTMOD $entitylist)
		(ENTUPD (ENTLAST))
	  )
	)
	(PRINC)
  )

  (SETQ $olderror *error*)
  (SETQ $oldscale (GETVAR "MLEADERSCALE"))
  (SETQ *error* gtleader:error)
  ;;Create all required arrow blocks
  (gtblocks:createall)
  ;;Ensure the default text and MultiLeader style is loaded
  (gttext:createtextstyledefault)
  (gttext:createmultileaderstyledefault)


  (SETVAR "MLEADERSCALE" (GETVAR "DIMSCALE"))
  (SETQ $flag T)
  (SETQ $combination 7)


  (INITGET "18 25 30 35 50 70 100")
  (IF (AND (= $textheight nil)
		   (= (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_HEIGHT")
			  nil
		   )
	  )
	(SETQ $textheight
		   (GETKWORD
			 "\nSpecify Text height [18/25/30/35/50/70/100] <35>: "
		   )
	)
	(SETQ $textheight
		   (GETKWORD
			 (STRCAT "\nSpecify Text height [18/25/30/35/50/70/100] <"
					 (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_HEIGHT")
					 ">: "
			 )
		   )
	)
  )

  (IF (= $textheight nil)
	(IF	(= (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_HEIGHT")
		   nil
		)
	  (SETQ $textheight "35")
	  (SETQ $textheight (gtconfig:getvalue $gtconfig "STANDARDS" "TEXT_HEIGHT"))
	)
  )

  (SETQ $start (GETPOINT "\nSpecify start point: "))
  (SETQ $pointlist (LIST $start))
  (SETQ $head (STRCAT "GT-ARR" (ITOA $combination)))

  (SETQ	$entitylist
		 (LIST
		   (CONS 0 "INSERT")
		   (CONS 100 "AcDbEntity")
		   (CONS 100 "AcDbBlockReference")
		   (CONS 410 (GETVAR "CTAB"))
		   (CONS 8 (GETVAR "CLAYER"))
		   (CONS 2 $head)
		   (CONS 10 $start)
		   (CONS 41 (GETVAR "MLEADERSCALE"))
		   (CONS 42 (GETVAR "MLEADERSCALE"))
		   (CONS 43 (GETVAR "MLEADERSCALE"))
		   '(50 . 0.0)
		   '(70 . 0)
		   '(71 . 0)
		   '(44 . 0.0)
		   '(45 . 0.0)
		   '(210 0.0 0.0 1.0)
		 )
  )
  (ENTMAKE $entitylist)					;Create/Make head block to selected point
  (SETQ $headblock (ENTLAST))

  (PRINC
	"\nSpecify next point (press <tab> to change arrow head): "
  )
  (WHILE $flag

	(SETQ g (GRREAD T))

	(COND
	  ;;Left Click, Add leader point
	  ((= 3 (CAR g))
	   (SETQ $pointlist (APPEND $pointlist (LIST $lastpoint)))
	  )

	  ;;Mouse Move, rotate blocks
	  ((= 5 (CAR g))
	   (REDRAW)
	   (SETQ g (gtleader:orthodread
				 (NTH (- (LENGTH $pointlist) 1) $pointlist)
				 (CADR g)
			   )
	   )
	   (IF (= (LENGTH $pointlist) 1)
		 ;;Draw a line and rotate the arrow head
		 (PROGN
		   (GRDRAW $start g 1 0)
		   (gtleader:grdraw $headblock (+ PI (ANGLE $start g)))
		 )
		 ;;Leave the arrow and rotate around the latest point
		 (PROGN
		   (SETQ $i 1)
		   (WHILE (> (LENGTH $pointlist) $i)
			 (GRDRAW (NTH (- $i 1) $pointlist) (NTH $i $pointlist) 1)

			 (SETQ $i (+ 1 $i))
		   )
		   (GRDRAW (NTH (- (LENGTH $pointlist) 1) $pointlist) g 1 0)
		 )
	   )
	   (SETQ $lastpoint g)
	  )

	  ;;Keyboard Press (TAB)
	  ((AND (= 2 (CAR g)) (= 9 (CADR g)))
	   (IF (= $combination 8)
		 (SETQ $combination 1)
		 (SETQ $combination (+ 1 $combination))
	   )
	   (SETQ $head (STRCAT "GT-ARR" (ITOA $combination)))
	   (gtleader:changehead $headblock $head)
	  )
	  ;;Orthomode toggle
	  ((AND (= 2 (CAR g)) (= 15 (CADR g)))
	   (SETVAR 'orthomode (- 1 (GETVAR 'orthomode)))
	  )

	  ;;Right Click - End the command
	  ((OR (= 11 (CAR g))
		   (= 25 (CAR g))
	   )
	   (SETQ $flag nil)
	  )


	  ;;Enter Key - Read the command line entry
	  ((EQUAL g '(2 13))
	   ;;Capture the mouse point when enter was pressed

	   (SETQ g (gtleader:orthodread
				 (NTH (- (LENGTH $pointlist) 1) $pointlist)
				 (CADR (GRREAD T))
			   )
	   )
	   (COND
		 ;;Distance and angle from last point using grread angle
		 ((AND
			$inputstring
			;;Convert the result into a list
			(SETQ $lastpoint (MAPCAR 'READ (LIST $inputstring)))
			;;The two entries in the list ar numbers
			(NUMBERP (CAR $lastpoint))
		  )
		  ;;If the criteria meets, add a point from the last point.
		  (SETQ	$pointlist
				 (APPEND $pointlist
						 (LIST
						   (POLAR (LAST $pointlist)
								  (ANGLE (LAST $pointlist) g)
								  (CAR $lastpoint)
						   )
						 )
				 )
		  )
		 )

		 ;;Distance and angle from last point
		 ((AND
			$inputstring
			;;First character is the @ symbol
			(= (SUBSTR $inputstring 1 1) "@")
			;;Convert the result into a list
			(SETQ $lastpoint
				   (MAPCAR 'READ
						   (gtstrings:split
							 (SUBSTR $inputstring 2 (1- (STRLEN $inputstring)))
							 "<"
						   )
				   )
			)
			;;Length of the list has to equal 2
			(= (LENGTH $lastpoint) 2)
			;;The two entries in the list ar numbers
			(NUMBERP (CAR $lastpoint))
			(NUMBERP (CADR $lastpoint))
		  )
		  ;;If the criteria meets, add a point from the last point.
		  (SETQ	$pointlist
				 (APPEND $pointlist
						 (LIST
						   (POLAR (LAST $pointlist) (CADR $lastpoint) (CAR $lastpoint))
						 )
				 )
		  )
		 )


		 ;;Comma separated distance and from last point
		 ((AND
			$inputstring
			;;First character is the @ symbol
			(= (SUBSTR $inputstring 1 1) "@")
			;;Convert the result into a list
			(SETQ $lastpoint
				   (MAPCAR 'READ
						   (gtstrings:split
							 (SUBSTR $inputstring 2 (1- (STRLEN $inputstring)))
							 ","
						   )
				   )
			)
			;;Check the length greater than 1, but less than 4
			(< 1 (LENGTH $lastpoint) 4)
			(FOREACH $pt $lastpoint
			  (NUMBERP $pt)
			)
		  )
		  ;;If the criteria meets, add a point from the last point.
		  (IF (= (LENGTH $lastpoint) 2)
			;;Fix the list to have 3 values
			(SETQ $lastpoint (APPEND $lastpoint (LIST 0.0)))

		  )
		  ;;Calculate and append the next point to the list
		  (SETQ	$pointlist
				 (APPEND $pointlist
						 (LIST
						   (MAPCAR '+ $lastpoint (LAST $pointlist))
						 )
				 )
		  )
		 )


		 ;;Comma separated distance (absolute point)
		 ((AND
			$inputstring
			;;Convert the result into a list
			(SETQ $lastpoint (MAPCAR 'READ (gtstrings:split $inputstring ",")))
			;;Check the length greater than 1, but less than 4
			(< 1 (LENGTH $lastpoint) 4)
			(FOREACH $pt $lastpoint
			  (NUMBERP $pt)
			)
		  )
		  (SETQ	$pointlist
				 (APPEND $pointlist
						 (LIST
						   (TRANS $lastpoint 0 0)
						 )
				 )
		  )
		 )
	   )
	   ;;Case regardless, clear the input string and prompt for next
	   (SETQ $inputstring nil)
	   (PRINC
		 "\nSpecify next point (press <tab> to change arrow head): "
	   )
	  )

	  ;;All other cases
	  (T
	   ;;Backspace
	   (IF (= (CADR g) 8)
		 (OR
		   (AND	$inputstring
				(/= $inputstring "")
				(SETQ $inputstring (SUBSTR $inputstring 1 (1- (STRLEN $inputstring))))
				(PRINC (CHR 8))
				(PRINC (CHR 32))
		   )
		   (SETQ $inputstring nil)
		 )
		 (OR
		   (AND	$inputstring
				(SETQ $inputstring (STRCAT $inputstring (CHR (CADR g))))
		   )
		   (SETQ $inputstring (CHR (CADR g)))
		 )
	   )
	   (AND $inputstring (PRINC (CHR (CADR g))))
	  )
	)
  )

  (SETQ $input (GETSTRING T "\nSpecify text or <ENTER> to exit: "))
  (SETQ $output nil)
  (WHILE (NOT (= $input ""))
	(IF	$output
	  (SETQ $output (STRCAT $output "\\P" $input))
	  (SETQ $output $input)

	)
	(SETQ $input (GETSTRING T "\nSpecify text or <ENTER> to exit: "))

  )

  ;;Remove the temporary block
  (ENTDEL $headblock)
  (REDRAW)
  (COND
	((= (ATOI $textheight) 18)
	 (SETQ $textcolor 1)
	)
	((= (ATOI $textheight) 25)
	 (SETQ $textcolor 7)
	)
	((= (ATOI $textheight) 30)
	 (SETQ $textcolor 2)
	)
	((= (ATOI $textheight) 35)
	 (SETQ $textcolor 3)
	)
	((= (ATOI $textheight) 50)
	 (SETQ $textcolor 4)
	)
	((= (ATOI $textheight) 70)
	 (SETQ $textcolor 4)
	)
	((= (ATOI $textheight) 100)
	 (SETQ $textcolor 6)
	)
	(T
	 (SETQ $textcolor 3)
	)

  )

  (gtleader:makemleader
	$pointlist
	(/ (ATOI $textheight) 10.0)
	$textcolor
	$head
	$output
  )

  (PRINC)

)




