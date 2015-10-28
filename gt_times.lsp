;;--------------------=={ TIME TRACKER }==---------------------;;
;; Time tracker is a utility which is used to track time spent ;;
;; working on individual drawings and a collective idle time.  ;;
;;                                                             ;;
;; $idletime      - Duration in seconds before drawing is      ;;
;;                  assumed to idle (i.e. draftsperson has     ;;
;;                  stopped working).                          ;;
;; $totalidletime - Duration in seconds before AutoCAD is      ;;
;;                  assumed idle (across all drawings).        ;;
;; $edittime      - Running edit time for current drawing.     ;;
;; $editlast      - Last known drawing edit time.              ;;
;; 'cadidletime   - Last known edit time GLOBAL for session.   ;;
;;-------------------------------------------------------------;;
(SETQ $idletime 300)
(SETQ $savetime 300)
(SETQ $totalidletime 300)

(IF (NOT $edittime)
  (SETQ $edittime 0)
)
(SETQ $editlast (GETVAR "CDATE"))

(IF (NOT (VL-BB-REF 'cadidletime))
  (VL-BB-SET 'cadidletime (GETVAR "CDATE"))
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Override default settings if a configuration value exists.                  |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF (gtconfig:getvalue $gtconfig $gtuserid "SAVE_TIME")
  (PROGN
    (SETQ $savetime
	   (ATOI
	     (gtconfig:getvalue $gtconfig $gtuserid "SAVE_TIME")
	   )
    )
    (PRINC (STRCAT "\nSet MINIMUM WORK time to "
		   (ITOA $savetime)
		   " seconds."
	   )
    )
  )
)
(IF (gtconfig:getvalue $gtconfig $gtuserid "IDLE_TIMEOUT")
  (PROGN
    (SETQ $idletime
	   (ATOI
	     (gtconfig:getvalue $gtconfig $gtuserid "IDLE_TIMEOUT")
	   )
    )
    (PRINC (STRCAT "\nSet DRAWING idle time to "
		   (ITOA $idletime)
		   " seconds."
	   )
    )
  )
)
(IF (gtconfig:getvalue $gtconfig $gtuserid "INACTIVE_TIMEOUT")
  (PROGN
    (SETQ $totalidletime
	   (ATOI (gtconfig:getvalue
		   $gtconfig
		   $gtuserid
		   "INACTIVE_TIMEOUT"
		 )
	   )
    )
    (PRINC (STRCAT "\nSet APPLICATION idle time to "
		   (ITOA $totalidletime)
		   " seconds."
	   )
    )
  )
)



;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:timeentrydcl</function>
<summary>Creates a Basic DCL dialog for entering a project ID and description of the work done.</summary>

<param name="$project">Project ID</param>
<returns>T if the dialog accept was pressed, nil if cancelled.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gttimes:timeentrydcl
       ($project / $result x $dclid $filename $fileid)

  ;;Create a new temporary file for the DCL dialog.
  (IF (AND (SETQ $filename (VL-FILENAME-MKTEMP "TimesEntry.dcl"))
	   (SETQ $fileid (OPEN $filename "w"))
      )
    ;;Populate the temporary file with the DCL code.
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
  ;;Create and display a new instance of the dialog.
  (COND
    ((SETQ $dclid (LOAD_DIALOG $filename))
     (NEW_DIALOG "gt_times" $dclid)
     ;;Assign the passed in project ID to the edit box.
     (IF (EQ $project "EXTERNAL")
       (PROGN
	 (SET_TILE "description" "Work Outside of AutoCAD")
	 (SET_TILE "project" "XXX0000")
       )
       (SET_TILE "project" $project)
     )
     (ACTION_TILE
       "accept"
       "(SETQ $result (LIST (CONS \"project\" (GET_TILE \"project\")) (CONS \"description\" (GET_TILE \"description\"))))(done_dialog)"
     )
     (START_DIALOG)
     ;;On dialog finish, unload the dialog and remove the temporary file.
     (UNLOAD_DIALOG $dclid)
     (VL-FILE-DELETE $filename)
     ;;Return the result of the dialog.
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
<function>GTTimes:SaveDialogDCL</function>
<sumary>On Drawing Close Reactor Event. Displays the time entry dialog just before the drawing closes.</sumary>

<param name="reactor">Autolisp data associated with the reactor.</param>
<param name="arguments">Event callback information.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttimes:savedialogdcl (reactor arguments / $result)
  ;;Ensure the document editing time is greater than the idle time
  ;;Prevents drawing just opened for quick viewing to be saved or tracked.
  (IF (< $savetime $edittime)
    (PROGN
      ;;Get the project information from the user
      (SETQ $result (gttimes:timeentrydcl
		      (NTH 0 (gtstrings:split (GETVAR "DWGNAME") " "))
		    )
      )
      ;;If the dialog was accepted, create a time entry within the file.
      (IF $result
	(gttimes:createentry
	  (CDR (ASSOC "project" $result))
	  (CDR (ASSOC "description" $result))
	)
      )
    )
  )
  (PRINC)
)


(DEFUN gttimes:savedialogdclmanual ($total / $result)
  ;;Get the project information from the user
  (SETQ $result (gttimes:timeentrydcl "EXTERNAL"))
  ;;If the dialog was accepted, create a time entry within the file.
  (IF $result
    (gttimes:createforcedentry
      (CDR (ASSOC "project" $result))
      (CDR (ASSOC "description" $result))
      $total
    )
  )
  (PRINC)
)

(DEFUN gttimes:calculatetotalidletime ($time / $hour $min $total)
  ;;Calculate the minutes
  (SETQ $min (/ $time 60))
  ;;Calculate the hours
  (SETQ	$hour
	 (/ $min 60)
  )
  ;;Update the minutes to remove the hours
  (SETQ $min (- $min (* 60 $hour)))

  ;;Modify the string output of the minutes and hours, prepending a 0 to produce hh:mm strings
  (IF (< $min 10)
    (PROGN
      (IF (< $hour 10)
	(SETQ $total (STRCAT "0" (ITOA $hour) ":0" (ITOA $min)))
	(SETQ $total (STRCAT (ITOA $hour) ":0" (ITOA $min)))
      )
    )
    (PROGN
      (IF (< $hour 10)
	(SETQ $total (STRCAT "0" (ITOA $hour) ":" (ITOA $min)))
	(SETQ $total (STRCAT (ITOA $hour) ":" (ITOA $min)))
      )
    )
  )
  $total
)



(DEFUN gttimes:calculatetime (/ $hour $min $total)
  ;;Calculate the minutes
  (SETQ $min (/ $edittime 60))
  ;;Calculate the hours
  (SETQ	$hour
	 (/ $min 60)
  )
  ;;Update the minutes to remove the hours
  (SETQ $min (- $min (* 60 $hour)))

  ;;Modify the string output of the minutes and hours, prepending a 0 to produce hh:mm strings
  (IF (< $min 10)
    (PROGN
      (IF (< $hour 10)
	(SETQ $total (STRCAT "0" (ITOA $hour) ":0" (ITOA $min)))
	(SETQ $total (STRCAT (ITOA $hour) ":0" (ITOA $min)))
      )
    )
    (PROGN
      (IF (< $hour 10)
	(SETQ $total (STRCAT "0" (ITOA $hour) ":" (ITOA $min)))
	(SETQ $total (STRCAT (ITOA $hour) ":" (ITOA $min)))
      )
    )
  )
  $total
)



;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:CreateEntry</function>
<summary>Creates a time modification entry within the specified text file.</sumary>

<param name="$project">Project ID.</param>
<param name="$description">Description of completed works.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gttimes:createentry ($project $description / $file $total)

  ;;Generate the time log folder path.
  (SETQ
    $file (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		  "\\times\\"
		  $gtuserid
		  "\\"
	  )
  )
  (gtsystem:createfolder $file)
  ;;Append the log file name (of todays date) to the end of the folder path
  (SETQ
    $file (STRCAT $file (SUBSTR (RTOS (GETVAR "CDATE")) 1 8) ".gtl")
  )

  (SETQ $total (gttimes:calculatetime))

  ;;Update the user on the progress
  (PRINC "\nSaving Times")

  ;;Open the generate file name
  ;;(as append so as not to remove any existing entries, but allows file creation if not existing)
  (IF (SETQ $file (OPEN $file "a"))
    (PROGN
      ;;Output a formatted string as the time entry
      (PRINC
	(gttimes:logstring
	  $project
	  $description
	  (GETVAR "DWGNAME")
	  $total
	)
	$file
      )
      (CLOSE $file)
    )
  )
  (PRINC)
)

(DEFUN gttimes:logstring ($project $description $dwg $total /)
  (STRCAT (STRCASE $project)
	  "|"
	  $dwg
	  "|"
	  $total
	  "|"
	  (STRCASE $description)
	  "| "
	  ;;Phase
	  "| "
	  ;;Rework
	  "|0"
	  ;;Inserted
	  "\n"
  )
)


(DEFUN gttimes:createforcedentry ($project $description $total / $file)

  ;;Generate the time log folder path.
  (SETQ
    $file (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		  "\\times\\"
		  $gtuserid
		  "\\"
	  )
  )
  (gtsystem:createfolder $file)
  ;;Append the log file name (of todays date) to the end of the folder path
  (SETQ
    $file (STRCAT $file (SUBSTR (RTOS (GETVAR "CDATE")) 1 8) ".gtl")
  )

  ;;Update the user on the progress
  (PRINC "\nSaving Times")

  ;;Open the generate file name
  ;;(as append so as not to remove any existing entries, but allows file creation if not existing)
  (IF (SETQ $file (OPEN $file "a"))
    (PROGN
      ;;Output a formatted string as the time entry
      (PRINC
	(gttimes:logstring
	  $project
	  $description
	  (GETVAR "DWGNAME")
	  $total
	)
	$file
      )
      (CLOSE $file)
    )
  )
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:EnableReactor</function>
<sumary>Creates the document reactors (not persistent) for command and editor events.</sumary>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gttimes:enablereactor (/)
  ;;Check if a reactor doesn't already exist
  (OR *gttimes:timesreactor*
      ;;Otherwise, create the reactor
      (SETQ *gttimes:timesreactor*
	     (LIST
	       (VLR-COMMAND-REACTOR
		 nil
		 '(
		   (:VLR-COMMANDWILLSTART . gttimes:oncommandreactor)
		   (:VLR-COMMANDENDED . gttimes:oncommandreactor)
		  )
	       )
	       (VLR-EDITOR-REACTOR
		 nil
		 '(
		   (:VLR-BEGINCLOSE . gttimes:savedialogdcl)
		   (:VLR-SAVECOMPLETE . gttimes:onsavereactor)
		  )
	       )
	     )
      )
  )
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:OnSaveReactor</function>
<summary>
The onsavereactor ensures that when a drawing with times tracking is enable, the reactor remains
enabled throughout the drawing session.
</summary>

<param name="reactor">The reactor name passed in from the reactor event.</param>
<param name="arguments">Any attached arguments are passed in.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttimes:onsavereactor (reactor arguments /)
  (gttimes:enablereactor)
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:OnCommandReactor</function>
<summary>Fires when a command is issued within the active drawing, updating the tracked time value.</sumary>

<param name="reactor">Autolisp data associated with the reactor.</param>
<param name="arguments">Event callback information.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttimes:oncommandreactor	(reactor	 arguments
				 /		 $currenttime
				 $previoustime	 $applicationidletime
				 $timedifference $hr
				 $min		 $sec
				)


  (SETQ $currenttime (RTOS (GETVAR "CDATE") 2 6))
  (SETQ $previoustime (RTOS $editlast 2 6))


  ;;Calculates the current time in seconds
  (SETQ	$currenttime
	 (+ (* 60 60 (ATOI (SUBSTR $currenttime 10 2)))
	    (* 60 (ATOI (SUBSTR $currenttime 12 2)))
	    (ATOI (SUBSTR $currenttime 14 2))
	 )
  )
  ;;Calculates the old time in seconds
  (SETQ	$previoustime
	 (+ (* 60 60 (ATOI (SUBSTR $previoustime 10 2)))
	    (* 60 (ATOI (SUBSTR $previoustime 12 2)))
	    (ATOI (SUBSTR $previoustime 14 2))
	 )
  )

  ;;Check AutoCAD inactive time
  (IF (VL-BB-REF 'cadidletime)
    (PROGN
      (SETQ $applicationidletime (RTOS (VL-BB-REF 'cadidletime) 2 6))
      ;;Calculates the application idle time in seconds
      (SETQ $applicationidletime
	     (+	(* 60 60 (ATOI (SUBSTR $applicationidletime 10 2)))
		(* 60 (ATOI (SUBSTR $applicationidletime 12 2)))
		(ATOI (SUBSTR $applicationidletime 14 2))
	     )
      )

      ;;If the application inactive time is greater than the totalidle time allowed
      ;;Ask for a log entry
      (IF (< $totalidletime (- $currenttime $applicationidletime))
	(PROGN
	  (ALERT
	    (STRCAT "AutoCAD has been idle for "
		    (gttimes:calculatetotalidletime
		      (- $currenttime $applicationidletime)
		    )
		    ".\nPlease enter work description on next dialog."
	    )
	  )
	  (gttimes:savedialogdclmanual
	    (gttimes:calculatetotalidletime
	      (- $currenttime $previoustime)
	    )
	  )
	)
      )
    )
  )

  ;;Update the last cad usage time to now
  (VL-BB-SET 'cadidletime (GETVAR "CDATE"))


  ;;If the time difference is less than the idletime, incriment the edit time
  (IF (> $idletime (- $currenttime $previoustime))
    (SETQ $edittime (+ $edittime (- $currenttime $previoustime)))
  )
  ;;Update the last edit time
  (SETQ $editlast (GETVAR "CDATE"))
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:EditTime</function>
<sumary>Prints the current editing time in seconds to the console window.</sumary>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gttimes:edittime	(/)
  (PRINC (STRCAT "\nCurrent editing time: " (ITOA $edittime)))
  (PRINC)
)

(DEFUN c:gt_times_edittime ()
  (gttimes:edittime)
)


(DEFUN gttimes:idletime	(/ $applicationidletime)
  (SETQ $applicationidletime (RTOS (VL-BB-REF 'cadidletime) 2 6))
  ;;Calculates the application idle time in seconds
  (SETQ	$applicationidletime
	 (+ (* 60 60 (ATOI (SUBSTR $applicationidletime 10 2)))
	    (* 60 (ATOI (SUBSTR $applicationidletime 12 2)))
	    (ATOI (SUBSTR $applicationidletime 14 2))
	 )
  )
  (PRINC (gttimes:calculatetotalidletime $applicationidletime)
  )
  (PRINC)
)

(DEFUN c:gt_times_idletime ()
  (gttimes:idletime)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTTimes:EditTimeString</function>
<sumary>Builds a simple Edittime string.</sumary>

<returns>String output containing the current editing time.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gttimes:edittimestring (/)
  (STRCAT "\nEDIT TIME: " (ITOA $edittime))
  (PRINC)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>Nil</function>
<sumary>Fires on the loading of the routine. Enabling the times tracking if desired.</sumary>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(COND
  ;;Always enable enable the times
  ((= "T"
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_TIMES")
   )
   (gttimes:enablereactor)
  )
  ((= "ON"
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_TIMES")
   )
   (gttimes:enablereactor)
  )
  ((= "S"
      (gtconfig:getvalue $gtconfig $gtuserid "ENABLE_TIMES")
   )
   (gttimes:enablereactor)
  )
)
(PRINC)



