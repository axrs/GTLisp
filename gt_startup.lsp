;;------------------=={ startup function }==-------------------;;
;;                                                             ;;
;;  The following code runs automatically on startup.          ;;
;;  It should validate the location of the main LISP file      ;;
;;  'GTLISP.vlx' through the findfile command. If the file is  ;;
;;  not found, the general configuration dialogue will be shown;;
;;-------------------------------------------------------------;;
(VL-LOAD-COM)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Clear the configuration variable                                            |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(SETQ $gtconfig nil)
(SETQ $gtversion "0.0.14e")
(SETQ $gtuserid (gtstrings:md5hash (gthardware:generateid)))
(PRINC (STRCAT "\nYOUR GTLISP USER ID IS: "
	       $gtuserid
	       " | Generated from: "
	       (gthardware:generateid)
	       "\n"
       )
)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|If the VLX file cannot be found in a support path, show the splash dialog.  |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF (= nil (FINDFILE "GTLISP.VLX"))
  (gtdialogs:splash (STRCAT "GTLISP Utilities - " $gtversion))
)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Ensure a default configuration setting exists                               |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF (= nil
       (FINDFILE
	 (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))
		 "\\"
		 "gtconfig.cfg"
	 )
       )
    )
  (PROGN
    ;;Add to the config sections
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|GENERAL SETTINGS                                                            |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (SETQ $gtconfig (gtconfig:addsection
		      $gtconfig
		      "GENERAL"
		      "BASEPATH"
		      (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))
		    )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "GENERAL"
	     "PLOTPATH"
	     (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "GENERAL"
	     "DATEFORMAT"
	     "DD.MM.YY"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "GENERAL"
	     "CHECK_UPDATES"
	     "ON"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "GENERAL_ARCHIVING"
	     "FOLDER"
	     "Superseded\\"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "GENERAL_ARCHIVING"
	     "DWGDETACH"
	     "*"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "GENERAL_ARCHIVING"
	     "IMGDETACH"
	     "*"
	   )
    )

    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|DATABASE SETTINGS                                                           |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "DATABASE"
	     "SERVER"
	     "database"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     "DATABASE"
	     "DATABASE"
	     "glynntucker"
	   )
    )
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|DRAFTSMAN SETTINGS                                                          |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (SETQ $gtconfig (gtconfig:addsection
		      $gtconfig
		      $gtuserid
		      "INITIALS"
		      "A.S."
		    )
    )
    (SETQ $gtconfig (gtconfig:addsection
		      $gtconfig
		      $gtuserid
		      "EMPLOYEEID"
		      "58"
		    )
    )
    (SETQ $gtconfig (gtconfig:addsection
		      $gtconfig
		      $gtuserid
		      "ENABLE_TIMES"
		      "OFF"
		    )
    )
    (SETQ $gtconfig (gtconfig:addsection
		      $gtconfig
		      $gtuserid
		      "ENABLE_OVERLAY"
		      "OFF"
		    )
    )

    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|LOGGING                                                                     |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (SETQ
      $gtconfig	(gtconfig:addsection $gtconfig "LOGGING" "LEVEL" "0")
    )


    (gtconfig:save
      $gtconfig
      (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))
	      "\\"
	      "gtconfig.cfg"
      )
    )
  )
)
(SETQ
  $gtconfig (gtconfig:parse
	      (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))
		      "\\"
		      "gtconfig.cfg"
	      )
	    )
)
(IF (NOT (gtconfig:hassection $gtconfig $gtuserid))
  (PROGN
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|DRAFTSMAN SETTINGS                                                          |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     $gtuserid
	     "INITIALS"
	     "A.S."
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     $gtuserid
	     "EMPLOYEEID"
	     "58"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     $gtuserid
	     "ENABLE_TIMES"
	     "OFF"
	   )
    )
    (SETQ $gtconfig
	   (gtconfig:addsection
	     $gtconfig
	     $gtuserid
	     "ENABLE_OVERLAY"
	     "OFF"
	   )
    )
    (gtconfig:save
      $gtconfig
      (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))
	      "\\"
	      "gtconfig.cfg"
      )
    )
  )
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Check for utilities update.                                                 |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF (=
      (gtconfig:getvalue $gtconfig "GENERAL" "CHECK_UPDATES")
      "ON"
    )
  (gtupdate:update)
  (PRINC "\nSkipping update check.")
)
(PRINC)