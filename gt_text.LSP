;;-------------------=={ get text value }==--------------------;;
;;                                                             ;;
;;  Returns the value of the first found text entity based on  ;;
;;  the specified input criteria.                              ;;
;;-------------------------------------------------------------;;
;;  Usage: (gttext:gettext $LAYOUT $LAYER (LIST x.x y.y z.z) $STYLE  ;;
;;                   $LINETYPE      $COLOR )                   ;;
;;-------------------------------------------------------------;;
;;  Input:  (NOTE: use 'nil' for non-required filters.         ;;
;;  $LAYOUT - Layout Name, nil assumes current layout.         ;;
;;  $LAYER  - The layer containing the text, nil searches all. ;;
;;  $LOC    - (LIST x.xxx y.yyy z.zzz) The location of the text;;
;;  $STYLE  - The Text Style "GT-STANDARD".                    ;;
;;  $LINETYPE - The Text Linetype.                             ;;
;;  $COLOR    - The color (integer) of the text.	       ;;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $filter - The Selection Set Filter.                        ;;
;;  $ss - The entities found matching the filter.              ;;
;;  $output - The found text value.                            ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Either an empty string, or the text value of the entity.   ;;
;;-------------------------------------------------------------;;
(DEFUN gttext:gettext ($layout
					   $layer
					   $location
					   $style
					   $linetype
					   $color
					   /
					   $p
					   $point
					   $info
					   $filter
					   $ss
					   $output
					  )
  (SETQ $filter (LIST (CONS 0 "*TEXT")))
  ;;Layout Filter
  (IF (NOT (= nil $layout))
	(SETQ $filter (APPEND $filter (LIST (CONS 410 $layout))))
	(SETQ $filter (APPEND $filter (LIST (CONS 410 (GETVAR "CTAB")))))
  )
  ;;Layer Filter
  (IF (NOT (= nil $layer))
	(SETQ $filter (APPEND $filter (LIST (CONS 8 $layer))))
  )
  ;;Location Filter
  (IF (NOT (= nil $location))
	(PROGN
	  (SETQ $location (gtstrings:replace $location "(LIST " ""))
	  (SETQ $location (gtstrings:replace $location "(" ""))
	  (SETQ $location (gtstrings:replace $location ")" ""))
	  (SETQ $location (gtstrings:split $location " "))
	  (SETQ $location (MAPCAR 'ATOF $location))
	  ;;(SETQ $filter (APPEND $filter (LIST (CONS 11 $location))))
	)
  )
  ;;Style Filter
  (IF (NOT (= nil $style))
	(SETQ $filter (APPEND $filter (LIST (CONS 7 $style))))
  )
  ;;Linetype Filter
  (IF (NOT (= nil $linetype))
	(SETQ $filter (APPEND $filter (LIST (CONS 6 $linetype))))
  )
  ;;Color Filter
  (IF (NOT (= nil $color))
	(SETQ $filter (APPEND $filter (LIST (CONS 62 $color))))
  )
  ;;Selection Set Filter
  (IF $location
	(SETQ $ss (SSGET "_C"
					 (MAPCAR '+ (LIST -10 10) $location);;Top Left
					 (MAPCAR '+ (LIST 10 -10) $location);;Bottom Right
					 $filter
			  )

	)
	(SETQ $ss (SSGET "X" $filter))
  )

  (IF $ss
	(PROGN
	  (PRINC (STRCAT "Found "
					 (ITOA (SSLENGTH $ss))
					 " objects matching filters.\n"
			 )
	  )
	  (SETQ $info (ENTGET (SSNAME $ss 0)))
	  (gttext:strip_text (CDR (ASSOC 1 $info)) *)
	)
	""
  )
)


;;;=======================[ Strip_Text.lsp ]=============================
;;; Author:  Charles Alan Butler Copyright© 2005-2007 
;;; Version: 2.3  Jan. 26, 2006
;;; Version: 3.0  Jun. 19, 2007
;;; Purpose: Strip format characters from text or mtext string
;;; Returns: A string  
;;; Sub Routines: -None
;;; Arguments: A string variable to remove formats from & Flag string of formats to remove
;;; Format Flag:
;;;   *    Remove All Formats found
;;;   A    Alignment
;;;   C    Color
;;;   F    Font
;;;   H    Height
;;;   L    Underscore
;;;   O    Overscore
;;;   P    Linefeed (Paragraph)  **** ??
;;;   Q    Obliquing
;;;   S    Spacing (Stacking)
;;;   t    Tabs
;;;   T    Tracking
;;;   W    Width
;;;   ~    Non-breaking Space
;;;   %    Plain Text Formatting
;;   
;;;======================================================================

(DEFUN gttext:strip_text (str
						  fmt
						  /
						  skipcnt
						  ndx
						  newlst
						  char
						  fmtcode
						  lst_len
						  is_mtext
						  lst
						  nextchr
						  pt
						  tmp
						 )

  (IF (OR (/= (TYPE fmt) 'str) (= fmt "*") (= fmt ""))
	(SETQ fmt (VL-STRING->LIST "AaCcFfHhLlOoPpQqSsTtQqWw~%"))
	(SETQ fmt (VL-STRING->LIST fmt))
  )
  (SETQ	ndx	0
		;; "fmtcode" is a list of code flags that will end with ; 
		fmtcode
		 (VL-STRING->LIST "CcFfHhTQqWwAa") ;("\C" "\F" "\H" "\T" "\Q" "\W" "\A")
  )
  (IF (/= str "")						; skip if empty text ""
	(PROGN
	  (SETQ	lst		 (VL-STRING->LIST str)
			lst_len	 (LENGTH lst)
			newlst	 '()
			is_mtext nil				; true if mtext
	  )
	  (WHILE (< ndx lst_len)
		;; step through text and find FORMAT CHARACTERS
		(SETQ char	  (NTH ndx lst)		; Get next character
			  nextchr (NTH (1+ ndx) lst)
			  skipcnt 0
		)

		(COND
		  ((AND (= char 123) (= nextchr 92)) ; "{\" mtext code
		   (SETQ is_mtext T
				 skipcnt 1
		   )
		  )

		  ((AND (= char 125) is_mtext)	; "}"
		   (SETQ skipcnt 1)
		  )


		  ((= char 37)					; code start with "%"
		   (IF (NULL nextchr)			; true if % is last char in text
			 (SETQ skipcnt 1)
			 ;;  Dtext codes
			 (IF (= nextchr 37)			; %% code found 
			   (IF (< 47 (NTH (+ ndx 2) lst) 58) ; is a number
				 (IF (VL-POSITION 37 fmt)
				   ;;  number found so fmtcode %%nnn
				   ;;  convert the nnn to a character
				   (SETQ skipcnt 5
						 newlst	 (APPEND newlst
										 (LIST (ATOI (STRCAT (CHR (NTH (+ ndx 2) lst))
															 (CHR (NTH (+ ndx 3) lst))
															 (CHR (NTH (+ ndx 4) lst))
													 )
											   )
										 )
								 )
				   )
				   ;;  keep the code in the string
				   (SETQ skipcnt 5
						 newlst	 (APPEND newlst
										 (LIST 37
											   37
											   (NTH (+ ndx 2) lst)
											   (NTH (+ ndx 3) lst)
											   (NTH (+ ndx 4) lst)
										 )
								 )
				   )
				 )

				 ;; else letter code, so fmtcode %%p, %%d, %%c
				 ;;  CAB note - this code does not always exist in the string
				 ;;  it is used to create the character but the actual ascii code
				 ;;  is used in the string, not the case for %%c
				 (IF (VL-POSITION 37 fmt)
				   (SETQ skipcnt 3
						 newlst	 (APPEND newlst
										 (LIST (COND ((= (NTH (+ ndx 2) lst) "p") 177)
													 ((= (NTH (+ ndx 2) lst) "d") 176)
													 ((= (NTH (+ ndx 2) lst) "c") 216)
													 ((= (NTH (+ ndx 2) lst) "%") 37)
											   )
										 )
								 )
				   )
				   (SETQ skipcnt 3
						 newlst	 (APPEND newlst
										 (LIST 37
											   37
											   (NTH (+ ndx 2) lst)
										 )
								 )
				   )
				 )
			   )						; endif
			 )							; endif
		   )							; endif
		  )								; end cond (= char "%"))


		  ((= char 92)					; code start with "\" 
		   ;;  This section processes mtext codes

		   (COND
			 ;; Process Coded information
			 ((NULL nextchr)			; true if \ is last char in text
			  (SETQ skipcnt 1)
			 )							; end cond 1

			 ((MEMBER nextchr fmtcode)	; this code will end with ";"
			  ;; fmtcode -> ("\C" "\F" "\H" "\T" "\Q" "\W" "\A"))
			  (WHILE (/= (SETQ char (NTH (+ skipcnt ndx) lst)) 59)
				(SETQ skipcnt (1+ skipcnt))
			  )
			  (SETQ skipcnt (1+ skipcnt))
			 )							; end cond 


			 ;; found \U then get 7 character group
			 ((= nextchr 85) (SETQ skipcnt (+ skipcnt 7)))

			 ;; found \M then get 8 character group
			 ((= nextchr 77) (SETQ skipcnt (+ skipcnt 8)))

			 ;; found \P then replace with CR LF 13 10
			 ;;  debug do not add CR LF, just remobe \P
			 ((= nextchr 80)			; "\P"
			  (IF (VL-POSITION 80 fmt)
				(SETQ newlst  (APPEND newlst '(32))
										;ndx     (+ ndx 1)
					  skipcnt 2
				)
			  )
			 )							; end cond 


			 ((= nextchr 123)			; "\{" normal brace
			  (SETQ ndx (+ ndx 1))
			 )							; end cond 

			 ((= nextchr 125)			; "\}" normal brace
			  (SETQ ndx (+ ndx 1))
			 )							; end cond 

			 ((= nextchr 126)			; "\~" non breaking space
			  (IF (VL-POSITION 126 fmt)
				(SETQ newlst  (APPEND newlst '(32)) ; " "
					  skipcnt 2
				)						; end cond 9
			  )
			 )

			 ;; 2 character group \L \l \O \o
			 ((MEMBER nextchr '(76 108 79 111))
			  (SETQ skipcnt 2)
			 )							; end cond 

			 ;;  Stacked text format as "[ top_txt / bot_txt ]"
			 ((= nextchr 83)			; "\S"
			  (SETQ	pt	(1+ ndx)
					tmp	'()
			  )
			  (WHILE
				(NOT
				  (MEMBER
					(SETQ tmp (NTH (SETQ pt (1+ pt)) lst))
					'(94 47 35)			; "^" "/" "#" seperator
				  )
				)
				 (SETQ newlst (APPEND newlst (LIST tmp)))
			  )
			  (SETQ newlst (APPEND newlst '(47))) ; "/"
			  (WHILE (/= (SETQ tmp (NTH (SETQ pt (1+ pt)) lst)) 59) ; ";"
				(SETQ newlst (APPEND newlst (LIST tmp)))
			  )
			  (SETQ	ndx		pt
					skipcnt	(1+ skipcnt)
			  )
			 )							; end cond 


		   )							; end cond stmt  Process Coded information
		  )								; end cond  (or (= char "\\")

		)								; end cond stmt
		;;  Skip format code characters
		(IF	(ZEROP skipcnt)				; add char to string
		  (SETQ	newlst (APPEND newlst (LIST char))
				ndx	   (+ ndx 1)
		  )
		  ;;  else skip some charactersPLOTTABS

		  (SETQ ndx (+ ndx skipcnt))
		)

	  )									; end while Loop
	)									; end progn
  )										; endif
  (VL-LIST->STRING newlst)				; return the stripped string
)										; end defun

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gttext:replacetoday</function>
<summary>Replaces all occurances of 'Today' within a drawing to the current date.
In the format specified inside the config file.
</summary>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttext:replacetoday (/ date month time year)
  (IF (gtconfig:getvalue $gtconfig "GENERAL" "DATEFORMAT")
	(gttext:findreplace
	  "TODAY"
	  (gtmisc:getdatecustom
		(gtconfig:getvalue $gtconfig "GENERAL" "DATEFORMAT")
	  )
	)
	(gttext:findreplace "TODAY" "DD.MM.YY")
  )
  (PRINC)
)


;;;MAIN FUNCTION, USED TO FIND AND REPLACE TEXT ON THE GT TOWNSVILLE RESIDENTIAL TEMPLATES
(DEFUN c:gtdb_trres	(/
					 $databaseobject
					 $dbresult
					 $jobnumber
					 $client
					 $address
					 $engineer
					 $draftsmen
					 $geoconsultant
					 $georef
					 $geoclass
					 $geosoiltype
					 $geofill
					 $geopressure
					 $trussconsultant
					 $trussref
					)
  (SETQ $jobnumber (GETSTRING T "\nJob Number: ")) ;Prompt the user for a Job Number

  (SETQ $databaseobject (gtdatabase:getdatabase))
  (IF (AND $databaseobject (> (STRLEN $jobnumber) 0))
	(PROGN

	  (SETQ	$dbresult
			 (CADR
			   (adolisp_dosql
				 $databaseobject
				 (STRCAT
				   "SELECT job_id, street, suburb, job_for, `client`, company_name FROM jobreg INNER JOIN contact ON jobreg.`client`=contact.contact_id WHERE job_id='"
				   $jobnumber
				   "';"
				 )
			   )
			 )
	  )
	)
  )

  ;;A Database Connection and Result exists
  (IF $dbresult
	(PROGN
	  ;;Do the automatic conversions
	  (IF (TBLSEARCH "BLOCK" "A3-TITLE-2010")
		(PROGN
		  (gttext:findreplace "XXXX1001" (NTH 0 $dbresult)) ;change the title block references
		  (gttext:findreplace "GTJOB" (NTH 0 $dbresult)) ;Change the Concrete Note references
		  (gttext:findreplace "CLIENT" (NTH 5 $dbresult)) ;Change the Client Reference
		  (gttext:findreplace
			"ADDRESS"
			(STRCAT "AT " (NTH 1 $dbresult) ", " (NTH 2 $dbresult))
		  )								;Change the Address Reference
		  (IF (gtconfig:getvalue $gtconfig $gtuserid "INITIALS")
			(gttext:findreplace
			  "X.X."
			  (gtconfig:getvalue $gtconfig $gtuserid "INITIALS")
			)
			(IF	(AND (SETQ $draftsmen (GETSTRING T "\nDraftsmen Initials: "))
					 (> (STRLEN $draftsmen) 0)
				)						;If the draftsmen prompt is greater than 0,
			  (gttext:findreplace "X.X." $draftsmen) ;Change the Draftsmen Initials
			)
		  )
		)
	  )
	  (IF (TBLSEARCH "BLOCK" "A3-TITLE")
		(PROGN
		  (gttext:findreplace "GTJOB" (NTH 0 $dbresult)) ;Change the Concrete Note references
		  (gttext:findreplace "CLIENT" (NTH 5 $dbresult)) ;Change the Client Reference
		  (gttext:findreplace
			"ADDRESS"
			(STRCAT "AT " (NTH 1 $dbresult) ", " (NTH 2 $dbresult))
		  )								;Change the Address Reference
		  (IF (AND
				(SETQ $engineer (GETSTRING T "\nEngineer Initials: "))
				(> (STRLEN $engineer) 0)
			  )							;If the engineers prompt is greater than 0,
			(gttext:findreplace "PTM" $engineer) ;change the engineer initial references
		  )
		  (IF (gtconfig:getvalue $gtconfig $gtuserid "INITIALS")
			(gttext:findreplace
			  "G.K."
			  (gtconfig:getvalue $gtconfig $gtuserid "INITIALS")
			)
			(IF	(AND (SETQ $draftsmen (GETSTRING T "\nDraftsmen Initials: "))
					 (> (STRLEN $draftsmen) 0)
				)						;If the draftsmen prompt is greater than 0,
			  (gttext:findreplace "G.K." $draftsmen) ;Change the Draftsmen Initials
			)
		  )

		)
	  )
	)
	;;No database connection
	(PROGN
	  (IF (TBLSEARCH "BLOCK" "A3-TITLE-2010")
		(PROGN
		  (IF (> (STRLEN $jobnumber) 0)
			(PROGN
			  (gttext:findreplace "XXXX1001" $jobnumber) ;change the title block references
			  (gttext:findreplace "GTJOB" $jobnumber) ;Change the Concrete Note references
			)
		  )
		  (IF (AND (SETQ $client (GETSTRING T "\nClient: "))
				   (> (STRLEN $client) 0)
			  )							;If the client prompt is greater than 0,
			(gttext:findreplace "CLIENT" $client) ;Change the Client Reference
		  )
		  (IF (AND (SETQ $address (GETSTRING T "\nAddress: "))
				   (> (STRLEN $address) 0)
			  )							;If the address prompt is greater than 0,
			(gttext:findreplace "ADDRESS" $address) ;Change the Address Reference
		  )
		  (IF (AND (SETQ $draftsmen (GETSTRING T "\nDraftsmen Initials: "))
				   (> (STRLEN $draftsmen) 0)
			  )							;If the draftsmen prompt is greater than 0,
			(gttext:findreplace "X.X." $draftsmen) ;Change the Draftsmen Initials
		  )
		)
	  )
	  (IF (TBLSEARCH "BLOCK" "A3-TITLE")
		(PROGN
		  (IF (> (STRLEN $jobnumber) 0)	;If the job number prompt is greater than 0,
			(gttext:findreplace "GTJOB" $jobnumber) ;change the title block references
		  )
		  (IF (AND (SETQ $client (GETSTRING T "\nClient: "))
				   (> (STRLEN $client) 0)
			  )							;If the client prompt is greater than 0,
			(gttext:findreplace "CLIENT" $client) ;change the ckuebt references
		  )
		  (IF (AND (SETQ $address (GETSTRING T "\nAddress: "))
				   (> (STRLEN $address) 0)
			  )							;If the address prompt is greater than 0,
			(gttext:findreplace "ADDRESS" $address) ;change the address references
		  )
		  (IF (AND (SETQ $engineer (GETSTRING T "\nEngineer Initials: "))
				   (> (STRLEN $engineer) 0)
			  )							;If the engineers prompt is greater than 0,
			(gttext:findreplace "PTM" $engineer) ;change the engineer initial references
		  )
		  (IF (AND (SETQ $draftsmen (GETSTRING T "\nDraftsmen Initials: "))
				   (> (STRLEN $draftsmen) 0)
			  )							;If the draftsmen prompt is greater than 0,
			(gttext:findreplace "G.K." $draftsmen) ;Change the Draftsmen Initials
		  )
		)
	  )

	)
  )




  (IF (AND
		(SETQ $geoconsultant (GETSTRING T "\nGeotech Consultant: "))
		(> (STRLEN $geoconsultant) 0)
	  )									;If the geotechnical prompt result was greater than 0
	(gttext:findreplace "#GEOCONSULTANT" $geoconsultant) ;change the geotechnical reference
  )

  (IF (AND (SETQ $georef (GETSTRING T "\nGeotech Reference: "))
		   (> (STRLEN $georef) 0)
	  )									;If the length of the geotechnical reference prompt was greater than 0
	(gttext:findreplace "#GEONUMBER" $georef) ;Find and Replace
  )


  (IF (AND
		(SETQ $geoclass (GETSTRING T "\nSite Class: "))
		(> (STRLEN $geoclass) 0)
	  )									;If the length of the soil class prompt was greater than 0
	(gttext:findreplace "#SITECLASS" $geoclass) ;Find and replace
  )


  (IF (AND
		(SETQ $geosoiltype (GETSTRING T "\nSoil Type: "))
		(> (STRLEN $geosoiltype) 0)
	  )									;If the length of the soil type prompt was greater than 0
	(gttext:findreplace "#SOILTYPE" $geosoiltype) ;Find and replace
  )

  (IF (AND (SETQ $geofill (GETSTRING T "\nFill Depth: "))
		   (> (STRLEN $geofill) 0)
	  )
										;If the site fill prompt result was greater than 0
	(PROGN								;Case True, do the following
	  (IF (> (STRLEN $geofill) 1)		;If the length of the prompt result was greater than 1
		(gttext:findreplace				;Case True, Run the text replace function to replace
		  "#FILLDEPTH"					;#FILLDEPTH with
		  (STRCAT "FILL IDENTIFIED TO "
				  $geofill
				  " MAX DEPTH ON SITE"
		  )								;Fill identified to result$ max depth on site
		)
		(gttext:findreplace				;Case False, Run the text replace function to replace
		  "#FILLDEPTH"					;#FILLDEPTH with
		  "FILL NOT IDENTIFIED ON SITE"	;Fill not identified on site
		)
	  )
	)
  )

  (IF (AND
		(SETQ $geopressure (GETSTRING T "\nBearing Pressure: "))
		(> (STRLEN $geopressure) 0)
	  )									;If the soil bearing pressure reference prompt was greater than 0
	(gttext:findreplace "#PRESSURE" $geopressure) ;Find and replace
  )

  (IF (AND
		(SETQ $trussconsultant (GETSTRING T "\nTruss Manufacturer: "))
		(> (STRLEN $trussconsultant) 0)
	  )									;If the length of the truss consultant reference prompt was greather than 0
	(gttext:findreplace "#TRUSSDESIGN" $trussconsultant) ;Find and replace
  )

  (IF (AND
		(SETQ $trussref (GETSTRING T "\nTruss Reference: "))
		(> (STRLEN $trussref) 0)
	  )									;If the length of the truss reference prompt was greater than 0
	(gttext:findreplace "#TRUSSREF" $trussref) ;Find and replace
  )
  (gttext:residentialsheets)
  (gtdatabase:disconnectdatabase $databaseobject)
  (PRINC)
)



;;; FUNCTION TO CHANGE THE NUMBER OF SHEETS ON A DRAWING
;;; S-01, S-02 & S-03 etc...
(DEFUN gttext:residentialsheets	(/ $search $replace $isheet $itemp)
  (SETQ $search "#GTSHEETS")
  (SETQ $replace "")
  (SETQ $isheet (GETINT "\nSpecify the number of sheets: "))
  (IF (NOT (NULL $isheet))
	(PROGN
	  (SETQ $itemp 1)
	  (WHILE (< $itemp $isheet)
		(IF	(> $itemp 1)
		  (PROGN
			(IF	(< $itemp 10)
			  (PROGN
										;If less than 10 (2-9) add the sheet with a 0 infront
				(SETQ $replace (STRCAT $replace "S-0" (ITOA $itemp) ", "))
			  )
			  (PROGN
				(SETQ $replace (STRCAT $replace "S-" (ITOA $itemp) ", "))
			  )
			)
		  )
		  (PROGN
		  )
		)
		(SETQ $itemp (+ $itemp 1))
	  )
	  (IF (< $isheet 10)
		(SETQ $replace (STRCAT $replace "& S-0" (ITOA $isheet) "."))
		(SETQ $replace (STRCAT $replace "& S-" (ITOA $isheet) "."))
	  )
	  (SETQ $replace (gtstrings:replace $replace ", &" " &"))
	  (gttext:findreplace $search $replace)
	)
  )
  (PRINC)
)

(DEFUN gttext:findreplace
						  ($search $replace / atts obj count ss ent str txthgt match?)
  (VLA-STARTUNDOMARK
	(VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT))
  )
  (SETQ ss (SSGET "X" '((0 . "TEXT,MTEXT,DIMENSION,INSERT"))))
  (IF (NOT ss)
	(PRINC "\nNothing to find or replace!")
	(PROGN
	  (SETQ count -1)
	  (WHILE (< (SETQ count (1+ count)) (SSLENGTH ss))
		(SETQ ent (ENTGET (SSNAME ss count))
			  obj (VLAX-ENAME->VLA-OBJECT (CDR (CAR ent)))
		)
		(COND
		  ;;Entity is of type Text
		  ((= (CDR (ASSOC 0 ent)) "TEXT")
		   (PROGN
			 (SETQ str (CDR (ASSOC 1 ent)))
			 (WHILE	(SETQ match? (VL-STRING-SEARCH $search str))
			   (SETQ str (VL-STRING-SUBST $replace $search str))
			   (VLA-PUT-TEXTSTRING obj str)
			 )
		   )
		  )
		  ;;Entity is of type dimension
		  ((= (CDR (ASSOC 0 ent)) "DIMENSION")
		   (PROGN
			 (SETQ str (CDR (ASSOC 1 ent)))
			 (WHILE	(SETQ match? (VL-STRING-SEARCH $search str))
			   (SETQ str (VL-STRING-SUBST $replace $search str))
			   (VLA-PUT-TEXTOVERRIDE obj str)
			 )
		   )
		  )
		  ;;Entity is of type MText
		  ((= (CDR (ASSOC 0 ent)) "MTEXT")
		   (PROGN
			 (SETQ str (VLA-GET-TEXTSTRING obj))
			 (WHILE	(SETQ match? (VL-STRING-SEARCH $search str))
			   (SETQ str (VL-STRING-SUBST $replace $search str))
			   (VLA-PUT-TEXTSTRING obj str)
			 )
		   )
		  )
		  (T
		   ;;All other entities must be blocks
		   (PROGN
			 (IF (= (VLA-GET-HASATTRIBUTES obj) :VLAX-TRUE)
			   (PROGN
				 (SETQ atts (VLA-GETATTRIBUTES obj))
				 (FOREACH x	(VLAX-SAFEARRAY->LIST (VLAX-VARIANT-VALUE atts))
				   (SETQ str (VLA-GET-TEXTSTRING x))
				   (WHILE (SETQ match? (VL-STRING-SEARCH $search str))
					 (SETQ str (VL-STRING-SUBST $replace $search str))
					 (VLA-PUT-TEXTSTRING x str)
				   )
				 )
			   )
			 )
		   )
		  )
		)
	  )
	)
  )
  (VLA-ENDUNDOMARK
	(VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT))
  )
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gttext:createtextstyle</function>
<summary>Create the text style within the drawing if required</summary>

<param name="$stylename">Name for the text style to use.</param>
<param name="$font">Font shx to use.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttext:createtextstyledefault ()
  (gttext:createtextstyle "GTSTD" "iso3098b.shx")
)
(DEFUN gttext:createtextstyle ($stylename $font / $styleentity)
  (IF (= nil (TBLSEARCH "STYLE" $stylename))
	(PROGN
	  (SETQ	$styleentity
			 (LIST
			   (CONS 0 "STYLE")			;Entity type
			   (CONS 100 "AcDbSymbolTableRecord") ;Subclass marker
			   (CONS 100 "AcDbTextStyleTableRecord") ;Subclass marker
			   (CONS 2 $stylename)		;Style Name
			   (CONS 70 0)				;Standard flag value
			   (CONS 40 0)				;Fix text height; 0 if not fixed
			   (CONS 41 0.75)			;Text width factor
			   (CONS 50 0)				;Text oblique angle
			   (CONS 71 0)				;Text generation flags, 0-none, 2-backwards, 4-upsidedown
			   (CONS 42 0)				;Use last text height
			   (CONS 3 $font)			;Primary font file name (shx)
			   (CONS 4 "")				;Bigfont file name; blank if none
			 )
	  )
	  (ENTMAKE $styleentity)
	)
  )
  (PRINC)
)


;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gttext:createdimensionstyle</function>
<summary>Creates a Dimension Style within the current drawing.</sumary>

<param name="$stylename">Name of the dimension style to create.</param>
<param name="$fontstyle">Name of the font style to use.</param>
<param name="$textheight">Dimension text height.</param>
<param name="$textcolor">Dimension text color.</param>

<returns></returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttext:createdimensionstyledefault ()
  (gttext:createdimensionstyle "GTSTD" "GTSTD" 0 3)
)
(DEFUN gttext:createdimensionstyle
								   ($stylename
									$fontstyle
									$textheight
									$textcolor
									/
									$styleentity
								   )

  ;;Look for the arrow blocks, else create them
  (IF (= nil (TBLSEARCH "BLOCK" "GT-ARR1"))
	(gtblocks:createarr1)
  )
  (IF (= nil (TBLSEARCH "BLOCK" "GT-ARR7"))
	(gtblocks:createarr7)
  )

  (IF (= nil (TBLSEARCH "DIMSTYLE" $stylename)) ;If the text style table does not have the text style
	(PROGN								;CASE TRUE, do the following
	  (SETQ	$styleentity
			 (LIST
			   (CONS 0 "DIMSTYLE")		;Entity Type
			   (CONS 100 "AcDbSymbolTableRecord") ;Subclass marker
			   (CONS 100 "AcDbDimStyleTableRecord") ;Subclass marker
			   (CONS 2 $stylename)		;Dimstyle name
			   (CONS 70 0)				;Standard flag value
			   (CONS 3 "")				;DIMPOST   - Prefix and suffix for dimension text
			   (CONS 4 "")				;DIMAPOST  - Prefix and suffix for alternate text
			   ;;(CONS 5 "GTARR1")   -DXF CODES OBSOLETE ;DIMBLK    - Arrow block name
			   ;;(CONS 6 "GTARR1")   -DXF CODES OBSOLETE ;DIMBLK1   - First arrow block name
			   ;;(CONS 7 "")         -DXF CODES OBSOLETE ;DIMBLK2   - Second arrow block name
			   (CONS 40 1.0)			;DIMSCALE  - Overall Scale Factor
			   (CONS 41 1.0)			;DIMASZ    - Arrow size
			   (CONS 42 2.0)			;DIMEXO    - Extension line origin offset
			   (CONS 43 0.0)			;DIMDLI    - Dimension line spacing
			   (CONS 44 2.0)			;DIMEXE    - Extension above dimension line
			   (CONS 45 0.0)			;DIMRND    - Rounding value
			   (CONS 46 0.0)			;DIMDLE    - Dimension line extension
			   (CONS 47 0.0)			;DIMTP     - Plus tolerance
			   (CONS 48 0.0)			;DIMTM     - Minus tolerance
			   (CONS 140 $textheight)	;DIMTXT    - Text height
			   (CONS 141 0.09)			;DIMCEN    - Centre mark size
			   (CONS 142 0.0)			;DIMTSZ    - Tick size
			   (CONS 143 25.4)			;DIMALTF   - Alternate unit scale factor
			   (CONS 144 1.0)			;DIMLFAC   - Linear unit scale factor
			   (CONS 145 0.0)			;DIMTVP    - Text vertical position
			   (CONS 146 1.0)			;DIMTFAC   - Tolerance text height scaling factor
			   (CONS 147 1.0)			;DIMGAP    - Gape from dimension line to text
			   (CONS 71 0)				;DIMTOL    - Tolerance dimensioning
			   (CONS 72 0)				;DIMLIM    - Generate dimension limits
			   (CONS 73 0)				;DIMTIH    - Text inside extensions is horizontal
			   (CONS 74 0)				;DIMTOH    - Text outside horizontal
			   (CONS 75 0)				;DIMSE1    - Suppress the first extension line
			   (CONS 76 0)				;DIMSE2    - Suppress the second extension line
			   (CONS 77 1)				;DIMTAD    - Place text above the dimension line
			   (CONS 78 0)				;DIMZIN    - Zero suppression
			   (CONS 170 0)				;DIMALT    - Alternate units selected
			   (CONS 171 2)				;DIMALTD   - Alternate unit decimal places
			   (CONS 172 0)				;DIMTOFL   - Force line inside extension lines
			   (CONS 173 0)				;DIMSAH    - Separate arrow blocks
			   (CONS 174 0)				;DIMTIX    - Place text inside extensions
			   (CONS 175 0)				;DIMSOXD   - Suppress outside dimension lines
			   (CONS 176 1)				;DIMCLRD   - Dimension line and leader color
			   (CONS 177 1)				;DIMCLRE   - Extension line color
			   (CONS 178 $textcolor)	;DIMCRRT   - Dimension text color
			   (CONS 270 2)				;DIMUNIT (Obsolete in 2011, DIMLUNIT and DIMFRAC)
			   (CONS 271 0)				;DIMADEC   - Angular decimal places
			   (CONS 272 0)				;DIMTDEC   - Tolerance decimal places
			   (CONS 273 2)				;DIMALTU   - Alternate units
			   (CONS 274 2)				;DIMALTTD  - Alternate tolerance decimal places
			   (CONS 275 0)				;DIMAUNIT  - Angular unit format
			   (CONS 280 0)				;DIMJUST   - Justification of text on dimension line
			   (CONS 281 0)				;DIMSD1    - Suppress the first dimension line
			   (CONS 282 0)				;DIMSD2    - Suppress the second dimensions line
			   (CONS 283 1)				;DIMTOLJ   - Tolerance vertical justification
			   (CONS 284 0)				;DIMTZIN   - Zero suppression
			   (CONS 285 0)				;DIMALTZ   - Alternate unit zero suppression
			   (CONS 286 0)				;DIMALTTZ  - Alternate tolerance zero suppression
			   (CONS 287 5)				;DIMFIT (Obsolete in 2011, DIMATFIT and DIMTMOVE)
			   (CONS 288 1)				;DIMUPT    - User positioned text
			   (CONS 340 (TBLOBJNAME "STYLE" $fontstyle)) ;DIMTXSTY  - Text style
			   (CONS 341
					 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR7"))))
			   )						;DIMLDRBLK - Leader arrow block name
			   (CONS 342
					 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR1"))))
			   )						;DIMBLK    - Arrow block name
			   (CONS 343
					 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR1"))))
			   )						;DIMBLK1   - First arrow block name
			   (CONS 344
					 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR1"))))
			   )						;DIMBLK2   - Second arrow block name
			 )
	  )
	  (ENTMAKE $styleentity)
	)
  )
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gttext:createmultileaderstyle</function>
<summary>Creates a MultiLeader style in accordance with GT standards</summary>
<param name="$stylename">Multileader Style name</param>
<param name="$fontname">Textstyle name to use</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gttext:createmultileaderstyledefault	()
  (gttext:createmultileaderstyle "GTSTD" "GTSTD")
)
(DEFUN gttext:createmultileaderstyle ($stylename $fontstyle / $styleentity lst)
  (DEFUN createmultileader (data / dic obj)
	(IF	(AND (SETQ dic (DICTSEARCH (NAMEDOBJDICT) "ACAD_MLEADERSTYLE"))
			 (NOT (DICTSEARCH (SETQ dic (CDR (ASSOC -1 dic))) "GTSTD"))
			 (SETQ obj (ENTMAKEX data))
		)
	  (DICTADD dic (CDR (ASSOC 3 data)) obj)
	)
  )
  (IF (= nil (TBLSEARCH "STYLE" $fontstyle))
	(EXIT)
  )
  (SETQ	lst
		 (LIST
		   (CONS 0 "MLEADERSTYLE")
		   (CONS 100 "AcDbMLeaderStyle")
		   (CONS 179 2)					;Text Attachment Point
		   (CONS 170 2)					;Content Type
		   (CONS 171 1)					;Draw MLeaderOrder Type
		   (CONS 172 0)					;DrawLeaderOrderType
		   (CONS 90 0)					;MaxLeader Segments
		   (CONS 40 0.0)				;First Segment Angle Constraint
		   (CONS 41 0.0)				;Second Segment Angle Constraint
		   (CONS 173 1)					;Leader Line Type
		   (CONS 91 (colour->mleaderstylecolour 1)) ;Leader Line Color (Red)
		   (CONS 340 (TBLOBJNAME "LTYPE" "ByLayer")) ;Leader Line Type
		   (CONS 92 -1)					;Leader Line weight
		   (CONS 290 1)					;Enable Landing
		   (CONS 42 1.5)				;Landing Gap
		   (CONS 291 1)					;Enable Dog Leg
		   (CONS 43 3)					;Dog Leg Length
		   (CONS 3 $stylename)			;MLeaderDescription
		   (CONS 341
				 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GT-ARR7"))))
		   )
										;Leader ArrowID
		   (CONS 44 1)					;Arrow Head Size
		   (CONS 300 "")				;Default Text contents
		   (CONS 342 (TBLOBJNAME "STYLE" $fontstyle)) ;MTextStyleID
		   (CONS 174 1)					;Text Left Attachment Type
		   (CONS 178 1)					;Text Right Attachment Type
		   (CONS 175 1)					;Text Angle Type
		   (CONS 176 0)					;Text Alignment Type
		   (CONS 93 (colour->mleaderstylecolour 3)) ;Text Color
		   (CONS 45 0)					;Text Height
		   (CONS 292 0)					;Enable Frame Text
		   (CONS 297 1)					;Text Always Left Justify
		   (CONS 46 0.18)				;Align Space
		   (CONS 142 1.0)				;Scale
		   (CONS 295 1)					;Overright Property Value
		   (CONS 296 0)					;Is Annotative
		   (CONS 143 0.0)				;Break Gap Size
		   (CONS 271 0)					;Text Attachment Direction (0 = Horizontal, 1 = Vertical)
		   (CONS 272 9)					;Bottom Text Attachment Direction (9 = Center, 10 = Underline & Center)
		   (CONS 273 9)					;Top Text Attachment Direction (9 = Center, 10 = Underline & Center)
		 )
  )
  (createmultileader lst)
  (SETVAR "CMLEADERSTYLE" $stylename)
  (PRINC)
)




;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>cadcoder:updatemultileaderstyle</function>
<summary>Updates an existing multileader style.</summary>
<param name="$stylename">Multileader Style name</param>
<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN cadcoder:updatemultileaderstyle ($stylename / lst dic data)
  (IF
	;;Ensure a dictionary reference
	(AND (SETQ dic (DICTSEARCH (NAMEDOBJDICT) "ACAD_MLEADERSTYLE"))
		 ;;And ensure the multileader style exists
		 (SETQ data (DICTSEARCH (SETQ dic (CDR (ASSOC -1 dic))) $stylename))
	)
	 (PROGN
	   ;;Adjust the DXF Codes as required
	   (SETQ data (SUBST (CONS 297 0) (ASSOC 297 data) data))
	   ;;Update the Multi-leader style entry
	   (ENTMOD data)
	   ;;Update the dictionary
	   (ENTUPD dic)
	 )
  )
  (PRINC)
)


;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>color->mleaderstylecolor</function>
<summary>Converts an ACI color to an mleader color.</sumary>
<param name="c">ACI color</param>

<returns>Mleader color expressed as a 24bit value.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
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


;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>mleaderstylecolor->color</function>
<summary>Converts an MLeader color to the True or ACI color.</sumary>
<param name="c">Mleader color</param>

<returns>True or ACI color.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN mleaderstylecolour->colour (c)

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
    <function>gtcolor:true->rgb</function>
    <summary>Converts an True color to a RGB color</sumary>
    <param name="c">True color to convert</param>
    <returns>Color value</returns>
    |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtcolor:true->rgb (c)
	(LIST
	  (LSH (LSH (FIX c) 8) -24)
	  (LSH (LSH (FIX c) 16) -24)
	  (LSH (LSH (FIX c) 24) -24)
	)
  )
  (IF (< 0 (LOGAND 16777216 c))
	(LAST (gtcolor:true->rgb c))
	(IF	(EQUAL '(0 0 0) (SETQ c (gtcolor:true->rgb c)))
	  256
	  c
	)
  )
)






