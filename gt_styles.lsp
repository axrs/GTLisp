;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gttext:createtextstyle</function>
<summary>Creates the default GlynnTucker text style.</summary>
<returns>T if successful, Nil otherwise</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttext:createtextstyledefault ()
  (gttext:createtextstyle "GTSTD" "iso3098b.shx" 0.75)
)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gtstyle:createtextstyle</function>
<sumary>Creates a basic text style if not already existing.</sumary>

<param name="$stylename">Name of the text style [string].</param>
<param name="$font">Name of the font style (include .shx/.ttf for shader fonts). [string]</param>
<param name="$widthfactor">Text width factor [integer or float].</param>

<returns>T if successful, Nil otherwise</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gtstyle:createtextstyle ($stylename $font $widthfactor /)
  (IF (= nil (TBLSEARCH "STYLE" $stylename))
	(PROGN
	  (ENTMAKE
		(LIST
		  (CONS 0 "STYLE")				;Entity type
		  (CONS 100 "AcDbSymbolTableRecord") ;Subclass marker
		  (CONS 100 "AcDbTextStyleTableRecord") ;Subclass marker
		  (CONS 2 $stylename)			;Style Name
		  (CONS 70 0)					;Standard flag value
		  (CONS 40 0)					;Fix text height; 0 if not fixed
		  (CONS 41 $widthfactor)		;Text width factor
		  (CONS 50 0)					;Text oblique angle
		  (CONS 71 0)					;Text generation flags, 0-none, 2-backwards, 4-upsidedown
		  (CONS 42 0)					;Use last text height
		  (CONS 3 $font)				;Primary font file name (shx)
		  (CONS 4 "")					;Bigfont file name; blank if none
		)
	  )
	)
  )
  (IF (TBLSEARCH "STYLE" $stylename)
	T
	nil
  )
)

(DEFUN gttext:createdimensionstyledefault ()
  (gttext:createdimensionstyle "GTSTD" "GTSTD" 0 3)
)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>gtstyle:createdimensionstyle</function>
<summary>Creates a basic dimension style if not already existing.</sumary>

<param name="$stylename">Name of the dimension style to create. [string]</param>
<param name="$fontstyle">Name of the font style to use. [string]</param>
<param name="$textheight">Dimension text height. [integer or float]</param>
<param name="$textcolor">Dimension text color. [integer or float]</param>
<param name="$leaderarrow">Leader Arrow Block. [string]</param>
<param name="$dimarrow1">Dimension Arrow Block 1. [string]</param>
<param name="$dimarrow2">Dimension Arrow Block 2. [string]</param>

<returns>T if successful, nil otherwise</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gtstyle:createdimensionstyle
									($stylename
									 $fontstyle
									 $textheight
									 $textcolor
									 $leaderarrow
									 $dimarrow1
									 $dimarrow2
									 /
									 $styleentity
									)

  (IF (TBLSEARCH "STYLE" $stylename)
	(PROGN

	  (IF (= nil (TBLSEARCH "BLOCK" $leaderarrow))
		(gtblocks:createarr1)
	  )
	  (IF (= nil (TBLSEARCH "BLOCK" "GT-ARR7"))
		(gtblocks:createarr7)
	  )

	  (IF (= nil (TBLSEARCH "DIMSTYLE" $stylename)) ;If the text style table does not have the text style
		(PROGN							;CASE TRUE, do the following
		  (SETQ	$styleentity
				 (LIST
				   (CONS 0 "DIMSTYLE")	;Entity Type
				   (CONS 100 "AcDbSymbolTableRecord") ;Subclass marker
				   (CONS 100 "AcDbDimStyleTableRecord") ;Subclass marker
				   (CONS 2 $stylename)	;Dimstyle name
				   (CONS 70 0)			;Standard flag value
				   (CONS 3 "")			;DIMPOST   - Prefix and suffix for dimension text
				   (CONS 4 "")			;DIMAPOST  - Prefix and suffix for alternate text
				   ;;(CONS 5 "GTARR1")   -DXF CODES OBSOLETE ;DIMBLK    - Arrow block name
				   ;;(CONS 6 "GTARR1")   -DXF CODES OBSOLETE ;DIMBLK1   - First arrow block name
				   ;;(CONS 7 "")         -DXF CODES OBSOLETE ;DIMBLK2   - Second arrow block name
				   (CONS 40 1.0)		;DIMSCALE  - Overall Scale Factor
				   (CONS 41 1.0)		;DIMASZ    - Arrow size
				   (CONS 42 2.0)		;DIMEXO    - Extension line origin offset
				   (CONS 43 0.0)		;DIMDLI    - Dimension line spacing
				   (CONS 44 2.0)		;DIMEXE    - Extension above dimension line
				   (CONS 45 0.0)		;DIMRND    - Rounding value
				   (CONS 46 0.0)		;DIMDLE    - Dimension line extension
				   (CONS 47 0.0)		;DIMTP     - Plus tolerance
				   (CONS 48 0.0)		;DIMTM     - Minus tolerance
				   (CONS 140 $textheight) ;DIMTXT    - Text height
				   (CONS 141 0.09)		;DIMCEN    - Centre mark size
				   (CONS 142 0.0)		;DIMTSZ    - Tick size
				   (CONS 143 25.4)		;DIMALTF   - Alternate unit scale factor
				   (CONS 144 1.0)		;DIMLFAC   - Linear unit scale factor
				   (CONS 145 0.0)		;DIMTVP    - Text vertical position
				   (CONS 146 1.0)		;DIMTFAC   - Tolerance text height scaling factor
				   (CONS 147 1.0)		;DIMGAP    - Gape from dimension line to text
				   (CONS 71 0)			;DIMTOL    - Tolerance dimensioning
				   (CONS 72 0)			;DIMLIM    - Generate dimension limits
				   (CONS 73 0)			;DIMTIH    - Text inside extensions is horizontal
				   (CONS 74 0)			;DIMTOH    - Text outside horizontal
				   (CONS 75 0)			;DIMSE1    - Suppress the first extension line
				   (CONS 76 0)			;DIMSE2    - Suppress the second extension line
				   (CONS 77 1)			;DIMTAD    - Place text above the dimension line
				   (CONS 78 0)			;DIMZIN    - Zero suppression
				   (CONS 170 0)			;DIMALT    - Alternate units selected
				   (CONS 171 2)			;DIMALTD   - Alternate unit decimal places
				   (CONS 172 0)			;DIMTOFL   - Force line inside extension lines
				   (CONS 173 0)			;DIMSAH    - Separate arrow blocks
				   (CONS 174 0)			;DIMTIX    - Place text inside extensions
				   (CONS 175 0)			;DIMSOXD   - Suppress outside dimension lines
				   (CONS 176 1)			;DIMCLRD   - Dimension line and leader color
				   (CONS 177 1)			;DIMCLRE   - Extension line color
				   (CONS 178 $textcolor) ;DIMCRRT   - Dimension text color
				   (CONS 270 2)			;DIMUNIT (Obsolete in 2011, DIMLUNIT and DIMFRAC)
				   (CONS 271 0)			;DIMADEC   - Angular decimal places
				   (CONS 272 0)			;DIMTDEC   - Tolerance decimal places
				   (CONS 273 2)			;DIMALTU   - Alternate units
				   (CONS 274 2)			;DIMALTTD  - Alternate tolerance decimal places
				   (CONS 275 0)			;DIMAUNIT  - Angular unit format
				   (CONS 280 0)			;DIMJUST   - Justification of text on dimension line
				   (CONS 281 0)			;DIMSD1    - Suppress the first dimension line
				   (CONS 282 0)			;DIMSD2    - Suppress the second dimensions line
				   (CONS 283 1)			;DIMTOLJ   - Tolerance vertical justification
				   (CONS 284 0)			;DIMTZIN   - Zero suppression
				   (CONS 285 0)			;DIMALTZ   - Alternate unit zero suppression
				   (CONS 286 0)			;DIMALTTZ  - Alternate tolerance zero suppression
				   (CONS 287 5)			;DIMFIT (Obsolete in 2011, DIMATFIT and DIMTMOVE)
				   (CONS 288 1)			;DIMUPT    - User positioned text
				   (CONS 340 (TBLOBJNAME "STYLE" $fontstyle)) ;DIMTXSTY  - Text style
				   (CONS 341
						 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR7"))))
				   )					;DIMLDRBLK - Leader arrow block name
				   (CONS 342
						 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR1"))))
				   )					;DIMBLK    - Arrow block name
				   (CONS 343
						 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR1"))))
				   )					;DIMBLK1   - First arrow block name
				   (CONS 344
						 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" "GTARR1"))))
				   )					;DIMBLK2   - Second arrow block name
				 )
		  )
		  (ENTMAKE $styleentity)
		)
	  )
	)
  )
  (IF (TBLSEARCH "DIMSTYLE" $stylename)
	T
	nil
  )

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
										;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
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




(DEFUN gtstyles:checkcreateblock ($block /)
  (IF (= nil (TBLSEARCH "BLOCK" $block))
	;;Create the related GlynnTucker Block (if exists)
	(COND (= (STRCASE $block "GT-ARR1") (gtblocks:createarr1))
		  (= (STRCASE $block "GT-ARR2") (gtblocks:createarr2))
		  (= (STRCASE $block "GT-ARR3") (gtblocks:createarr3))
		  (= (STRCASE $block "GT-ARR4") (gtblocks:createarr4))
		  (= (STRCASE $block "GT-ARR5") (gtblocks:createarr5))
		  (= (STRCASE $block "GT-ARR6") (gtblocks:createarr6))
		  (= (STRCASE $block "GT-ARR7") (gtblocks:createarr7))
		  (T
		   ;;If the block exists, insert it
		   (IF (SETQ $block (FINDFILE (STRCAT $block ".dwg")))
			 (PROGN	(COMMAND "._-insert" $block "_NON" "0,0,0" "" "" "")
					(ENTDEL (ENTLAST))
			 )
			 (PROGN
			   (EXIT)
			 )
		   )
		  )
	)
  )
)

;;;CREATE DIMENSION STYLE FROM SCRATCH
;;;DXF CODE VALUES BASED ON GT35 DIMENSION STYLE
(DEFUN gtstyles:createdimensionstyle ($stylename
									  $textstyle
									  $height
									  $color
									  $leaderblock
									  $arrowblock1
									  $arrowblock2
									  /
									  $entity
									 )
  (IF (= nil (TBLSEARCH "STYLE" $textstyle))
	(PROGN

	  (PRINC
		(STRCAT "\nTextStyle: '" $textstyle "' does NOT exist.")
	  )
	  (EXIT)
	)
  )

  ;;Check and create arrow blocks
  (IF (NOT (= nil $leaderblock))
	(gtstyles:checkcreateblock $leaderblock)
  )
  (IF (NOT (= nil $arrowblock1))
	(gtstyles:checkcreateblock $arrowblock1)
  )
  (IF (NOT (= nil $arrowblock2))
	(gtstyles:checkcreateblock $arrowblock2)
  )



  (IF (= nil (TBLSEARCH "DIMSTYLE" $stylename)) ;If the text style table does not have the text style
	(PROGN								;CASE TRUE, do the following
	  (SETQ	$entity
			 (LIST
			   (CONS 0 "DIMSTYLE")		;Entity Type
			   (CONS 100 "AcDbSymbolTableRecord") ;Subclass marker
			   (CONS 100 "AcDbDimStyleTableRecord") ;Subclass marker
			   (CONS 2 $stylename)		;Dimstyle name
			   (CONS 70 0)				;Standard flag value
			   (CONS 3 "")				;DIMPOST   - Prefix and suffix for dimension text
			   (CONS 4 "")				;DIMAPOST  - Prefix and suffix for alternate text
			   ;;(CONS 5 "GTARR1")   -DXF CODES OBSOLETE					    ;DIMBLK    - Arrow block name
			   ;;(CONS 6 "GTARR1")   -DXF CODES OBSOLETE					    ;DIMBLK1   - First arrow block name
			   ;;(CONS 7 "")         -DXF CODES OBSOLETE					    ;DIMBLK2   - Second arrow block name
			   (CONS 40 100.0)			;DIMSCALE  - Overall Scale Factor
			   (CONS 41 1.0)			;DIMASZ    - Arrow size
			   (CONS 42 2.0)			;DIMEXO    - Extension line origin offset
			   (CONS 43 0.0)			;DIMDLI    - Dimension line spacing
			   (CONS 44 2.0)			;DIMEXE    - Extension above dimension line
			   (CONS 45 0.0)			;DIMRND    - Rounding value
			   (CONS 46 0.0)			;DIMDLE    - Dimension line extension
			   (CONS 47 0.0)			;DIMTP     - Plus tolerance
			   (CONS 48 0.0)			;DIMTM     - Minus tolerance
			   (CONS 140 $height)		;DIMTXT    - Text height
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
			   (CONS 178 $color)		;DIMCRRT   - Dimension text color
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
			   (CONS 340 (TBLOBJNAME "STYLE" $textstyle)) ;DIMTXSTY  - Text style
			   (CONS
				 341
				 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" $leaderblock))))
			   )						;DIMLDRBLK - Leader arrow block name
			   (CONS
				 342
				 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" $arrowblock1))))
			   )						;DIMBLK    - Arrow block name
			   (CONS
				 343
				 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" $arrowblock1))))
			   )						;DIMBLK1   - First arrow block name
			   (CONS
				 344
				 (CDR (ASSOC 330 (ENTGET (TBLOBJNAME "BLOCK" $arrowblock2))))
			   )						;DIMBLK2   - Second arrow block name
			 )							;End of list
	  )									;End of setq
	  (ENTMAKE $entity)					;Make the entity
	  (PRINC							;Report the sucessfull creation of the entity back to the user
		(STRCAT	"\nSucessfully created the dimension style: '"
				$stylename
				"' within the current drawing."
		)
	  )
	)									;End of case true
	(PROGN								;CASE FALSE, do the following
	  (PRINC							;Report the issue to the user
		(STRCAT	"\nDimension style: '"
				$stylename
				"' already exists within the current drawing."
		)
	  )
	)									;End of case false
  )
  (PRINC)
)