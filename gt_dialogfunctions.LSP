(DEFUN gtdialogs:batchplot (/	       x	  $dclid     $result
			    $filename  $fileid	  $returnlist
			    i	       $layout	  $layouts
			   )
  (SETQ $returnlist (LIST))
  (IF (AND (SETQ $filename (VL-FILENAME-MKTEMP "gtBatchPlot.dcl"))
	   (SETQ $fileid (OPEN $filename "w"))
      )
    (PROGN
      (FOREACH x (LIST
		   "gtBatchPlot : dialog {"
		   "    label = \"GTLISP - Batch Plot\";"
		   "    : row {"
		   "        : list_box {"
		   "            label =\"Select Layouts to Plot\";"
		   "            key = \"layoutList\";"
		   "            height = 10;"
		   "            width = 10;"
		   "            multiple_select = true;"
		   "            fixed_width_font = true;"
		   "            value = \"\";"
		   "        }"
		   "    }"
		   "    spacer;"
		   "	spacer;"
		   "    ok_cancel;"
		   "}"
		  )
	(PRINC x $fileid)
	(WRITE-LINE "" $fileid)
      )
      (CLOSE $fileid)
    )
  )
  ;;Show the dialog and get a reponse
  (COND
    ((SETQ $dclid (LOAD_DIALOG $filename))
     (NEW_DIALOG "gtBatchPlot" $dclid)

     (SETQ $layouts (LAYOUTLIST))
     (START_LIST "layoutList")
     (MAPCAR 'ADD_LIST $layouts)
     (END_LIST)

     (ACTION_TILE
       "accept"
       "(SETQ $selectedLayouts (GET_TILE \"layoutList\"))(done_dialog 1)"
     )
     (SETQ $result (START_DIALOG))

     (UNLOAD_DIALOG $dclid)		; Unload Dialog
     (VL-FILE-DELETE $filename)		; Delete the DCL file

     (IF (AND $result (= $result 1))
       (PROGN


	 ;;--- Setup a variable to run through the list
	 (SETQ i 1)

	 ;;--- cycle through the list getting all of the selected items
	 (WHILE	(SETQ $layout (READ $selectedlayouts))
	   (SETQ $returnlist
		  (APPEND $returnlist
			  (LIST (NTH $layout $layouts))
		  )
	   )
	   (WHILE
	     (AND
	       (/= " " (SUBSTR $selectedlayouts i 1))
	       (/= "" (SUBSTR $selectedlayouts i 1))
	     )
	      (SETQ i (1+ i))
	   )
	   (SETQ $selectedlayouts (SUBSTR $selectedlayouts i))
	 )
	 (PRINC $returnlist)
       )
     )
    )
  )
  $returnlist
)

(DEFUN gtdialogs:timeentry
       ($project / $result x $dclid $filename $fileid)
  ;;Create the Dialog File
  (IF (AND (SETQ $filename (VL-FILENAME-MKTEMP "TimesEntry.dcl"))
	   (SETQ $fileid (OPEN $filename "w"))
      )
    (PROGN (FOREACH x (LIST
			"gt_times : dialog {"
			"	label = \"GTTimes - Time Entry\";"
			" initial_focus = \"description\";"
			"	: row{"
			"		: edit_box {"
			"			label=\"Project:\";"
			"			key=\"project\";"
			"			mnemonic=\"P\";"
			"			is_tab_stop=true;"
			"			edit_width=7;"
			"		}"
			"		: edit_box {"
			"			label=\"Description:\";"
			"			key=\"description\";"
			"			edit_width=25;"
			"			value=\"\";"
			"			mnemonic=\"D\";"
			"                 initial_focus = true;"
			"			is_tab_stop=true;"
			"                 allow_accept = true;"
			"		}"
			"	}"
			"	spacer;"
			"	spacer;"
			" ok_cancel;"
			"}"
		       )
	     (PRINC x $fileid)
	     (WRITE-LINE "" $fileid)
	   )
	   (CLOSE $fileid)
    )
  )
  ;;Show the dialog and get a reponse
  (COND
    ((SETQ $dclid (LOAD_DIALOG $filename))
     (NEW_DIALOG "gt_times" $dclid)
     (SET_TILE "project" $project)
     (ACTION_TILE
       "accept"
       "(SETQ $result (LIST (CONS \"project\" (GET_TILE \"project\")) (CONS \"description\" (GET_TILE \"description\"))))(done_dialog)"
     )
     (START_DIALOG)
     (UNLOAD_DIALOG $dclid)
     (VL-FILE-DELETE $filename)
     (IF $result
       $result
       nil
     )
    )
    (T nil)
  )
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTDialogs:YesNo</function>
<summary>Prompts the user for a response to a yes/no question.</sumary>
<param name="$boxtitle">Dialog window title.</param>
<param name="$question">Question to ask the user. Note: use '\n' for multiple lines.</param>
<returns>T - if the response was yes. Nil - if the response was no.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtdialogs:yesno
		       ($boxtitle  $question  /		 $width
			x	   $dclid     $result	 $filename
			$fileid
		       )
  ;;Calculate the box width
  (SETQ $width 0)
  (FOREACH x (gtstrings:split $question "\n")
    (IF	(< $width (STRLEN x))
      (SETQ $width (STRLEN x))
    )
  )
  ;;Create the Dialog File
  (IF (AND (SETQ $filename (VL-FILENAME-MKTEMP "YesNo.dcl"))
	   (SETQ $fileid (OPEN $filename "w"))
      )
    (PROGN
      (FOREACH x
	       (LIST
		 "YesNo : dialog { key = \"Title\";"
		 "  spacer;"
		 (STRCAT
		   "  : paragraph{ :text_part { key = \"Question\" ; height="
		   (ITOA (LENGTH (gtstrings:split $question "\n")))
		   "; width = "
		   (ITOA (+ $width 4))
		   " ; alignment = centered; }}"
		 )
		 "  spacer;"
		 "  : row { fixed_width = true; alignment = centered;"
		 "    : button { key = \"Yes\"; label = \"&Yes\"; is_default = true;}"
		 "    : button { key = \"No\"; label = \"&No\"; is_cancel = true;}"
		 "  }"
		 "}"
	       )
	(PRINC x $fileid)
	(WRITE-LINE "" $fileid)
      )
      (CLOSE $fileid)
    )
  )
  ;;Show the dialog and get a reponse
  (COND	((SETQ $dclid (LOAD_DIALOG $filename))
	 (NEW_DIALOG "YesNo" $dclid)
	 (SET_TILE "Title" $boxtitle)
	 (SET_TILE "Question" $question)
	 (ACTION_TILE "Yes" "(done_dialog 1)")
	 (ACTION_TILE "No" "(done_dialog 0)")
	 (SETQ $result (START_DIALOG))
	 (UNLOAD_DIALOG $dclid)		; Unload Dialog
	 (VL-FILE-DELETE $filename)	; Delete the DCL file
	 (IF (AND $result (= $result 1))
	   T
	   nil
	 )
	)
	(T nil)
  )
)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTDialogs:Splash</function>
<summary>Shows the first run splash screen and guides the user through initial setup.</sumary>

<param name="$additionalinfo">Additional information to be displayed inside the splash screen. Typically the version.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gtdialogs:splash	($additionalinfo	       /
			 x		$dclid	       $result
			 $filename	$fileid	       $basepath
			 $acadobject	$loopt	       $prefsobject
			 $supportpath	$tabnameobject
			)
  (IF (AND (SETQ $filename (VL-FILENAME-MKTEMP "gtSplash.dcl"))
	   (SETQ $fileid (OPEN $filename "w"))
      )
    (PROGN
      (FOREACH x
	       (LIST
		 "gtSplash : dialog {"
		 "    label = \"GTLISP - Glynn Tucker LISP Utilities\";"
		 "    : image {"
		 "	key = \"gtlogo\";"
		 "	alignment = centered;"
		 "	color = -15;"
		 "	fixed_width = true;"
		 "	fixed_height = true;"
		 "	width = 58.26;"
		 "	height = 6.12;	"
		 "    }"
		 "    spacer;"
		 "    : text {"
		 "        key = \"txtline1\";"
		 "        label = \"\";"
		 "        alignment = centered;"
		 "        width = 18;"
		 "        fixed_width_font = true;"
		 "    }"
		 "    spacer;"
		 "    : text {"
		 "        key = \"txtline2\";"
		 "        label = \"Copyright (C) Glynn Tucker Consulting Engineers 1999 - 2011\";"
		 "        alignment = centered;"
		 "    }"
		 "    spacer;"
		 "    : image {"
		 "	key = \"divider\";"
		 "	alignment = centered;"
		 "	color = 250;"
		 "	fixed_height = true;"
		 "	height = 0.1;"
		 "    }"
		 "    : text {"
		 "        key = \"statusline1\";"
		 "        label = \"NOTE: The main utility file was not identified within any of the support file search paths.\";"
		 "        alignment = centered;"
		 "    }"
		 "    : text {"
		 "        key = \"statusline2\";"
		 "        label = \"Press 'Continue' to browse for the folder and resolve this issue.\";"
		 "        alignment = centered;"
		 "    }"
		 "    spacer;"
		 "    spacer;"
		 "    : button {"
		 "        key = \"accept\";"
		 "        label = \"Continue\";"
		 "        is_default = true;"
		 "        mnemonic = \"C\";"
		 "        width = 10;"
		 "        alignment = centered;"
		 "        fixed_width = true;"
		 "    }"
		 "}"
		)
	(PRINC x $fileid)
	(WRITE-LINE "" $fileid)
      )
      (CLOSE $fileid)
    )
  )
  ;;Show the dialog and get a reponse
  (COND
    ((SETQ $dclid (LOAD_DIALOG $filename))
     (NEW_DIALOG "gtSplash" $dclid)
     (gtdclfulllogo "gtlogo")
     (SET_TILE "txtline1" $additionalinfo)
     (ACTION_TILE "accept" "(done_dialog 1)")
     (SETQ $result (START_DIALOG))
     (UNLOAD_DIALOG $dclid)		; Unload Dialog
     (VL-FILE-DELETE $filename)		; Delete the DCL file
     (IF (AND $result (= $result 1))
       (PROGN
	 (PRINC "\nAdding the base support path to list.")
	 (SETQ $loopt T)
	 (WHILE	$loopt
	   (SETQ $basepath (gtsystem:browseforfolder))
	   (IF $basepath
	     (PROGN
	       (IF (FINDFILE (STRCAT $basepath "\\" "GTLISP.VLX"))
		 (SETQ $loopt nil)
		 (ALERT
		   "Unable to find GTLISP.vlx within the specified directory. Please try again."
		 )
	       )
	     )
	     (PROGN
	       (SETQ $loopt nil)
	       (ALERT
		 "Note: The GTLISP Utilities may not function as intended until a linking support path is found."
	       )
	     )
	   )
	 )
	 (IF $basepath
	   (PROGN
	     ;;Append the Support File Search Path
	     (SETQ $acadobject (VLAX-GET-ACAD-OBJECT))
	     (SETQ $prefsobject
		    (VLAX-GET-PROPERTY $acadobject 'preferences)
	     )
	     (SETQ $tabnameobject
		    (VLAX-GET-PROPERTY $prefsobject 'files)
	     )
	     (SETQ $supportpath
		    (VLAX-GET-PROPERTY
		      $tabnameobject
		      'supportpath
		    )
	     )
	     (VLAX-PUT-PROPERTY
	       $tabnameobject
	       'supportpath
	       (STRCAT $supportpath ";" $basepath)
	     )
	   )
	 )
       )
     )
    )
  )
  (PRINC)
)
