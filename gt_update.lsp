(DEFUN gtupdate:update (/ $xml)



  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;;
  ;;<function>gtupdate:download</function>
  ;;<sumary>Downloads the latest version of GTLISP from the GlynnTucker software domain.</sumary>
  ;;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtupdate:download
	 (/ $url cp ok tmp util $backupFileName $fileName)
    ;;Store the download link
    (SETQ $url (STRCAT "http://software.glynntucker.com.au/GTLISP/"
		       (CADDR
			 (ASSOC	"version"
				(CADR (CDR (ASSOC "GTLISP" $xml)))
			 )
		       )
		       "/GTLISP.VLX"
	       )
    )
    (PRINC
      (STRCAT "\nAttempting to download the latest version from: "
	      $url
      )
    )


    (SETQ $fileName
	   (gtstrings:replace2
	     (STRCAT (gtconfig:getvalue
		       $gtconfig
		       "GENERAL"
		       "BASEPATH"
		     )
		     "GTLISP.VLX"
	     )
	     "\\\\"
	     "\\"
	   )
    )

    (SETQ $backupFileName (STRCAT $filename ".bak"))
    ;;Delete the old backup
    (WHILE (FINDFILE $backupFileName)
      (VL-FILE-DELETE $backupFileName)
    )
    ;;Download the new version
    (IF
      (VL-CATCH-ALL-ERROR-P
	(VL-CATCH-ALL-APPLY
	  'VL-FILE-COPY
	  (LIST
	    $fileName
	    $backupFileName
	  )
	)
      )
       (PROGN
	 (PRINC "\nUnable to backup the old GTLISP.vlx file.")
       )
       (PROGN
	 (PRINC "\nSucessfully backedup the previous version.")
       )
    )
    (SETQ
      cp (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		 "\\"
		 (VL-FILENAME-BASE $url)
		 (VL-FILENAME-EXTENSION $url)
	 )
    )
    (SETq cp (gtstrings:replace2 cp "\\\\" "\\"))
    
    ;;If the destination file exists, remove it
    (WHILE (FINDFILE cp) (VL-FILE-DELETE cp))

    (SETQ util (VLA-GET-UTILITY
		 (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT))
	       )
    )
    (IF	(EQ (VLA-ISURL util $url) :VLAX-TRUE)
      (IF (VL-CATCH-ALL-ERROR-P
	    (VL-CATCH-ALL-APPLY
	      'VLA-GETREMOTEFILE
	      (LIST util $url 'tmp :VLAX-TRUE)
	    )
	  )
	(PRINC "\nConnection Error.")
	(PROGN ;;If there is an error in copying the file from the tempory directory
	       (IF (VL-CATCH-ALL-ERROR-P
		     (VL-CATCH-ALL-APPLY 'VL-FILE-COPY (LIST tmp cp))
		   )
		 (PRINC "\nUnable to validate version file.")
		 (ALERT "GTLISP utilities was successfully updated.")
	       )
	       (VL-FILE-DELETE tmp)
	)
      )
      (PRINC "\nThe download url is not valid.")
    )
    (PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|Check the current version of GTLISP and offer to download the latest        |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (PRINC "\nConnecting to the update server...")
  (SETQ	$xml (gtxml:read
	       "http://software.glynntucker.com.au/GTLISP/index.php"
	     )
  )
  (IF (= nil $xml)
    (PRINC
      (STRCAT
	"\nUnable to connect to the server for version comparison."
      )
    )
    (PROGN
      (PRINC
	(STRCAT
	  "\nCurrent version: "
	  $gtversion
	  " | Latest version: "
	  (CADDR (ASSOC "version" (CADR (CDR (ASSOC "GTLISP" $xml)))))
	)
      )
      (IF (< $gtversion
	     (CADDR
	       (ASSOC "version"
		      (CADR (CDR (ASSOC "GTLISP" $xml)))
	       )
	     )
	  )
	;;New Version
	(PROGN
	  (IF (gtdialogs:yesno
		"GTLISP - Update Available!"
		(STRCAT	"An update for GTLISP to version "
			(CADDR
			  (ASSOC "version"
				 (CADR (CDR (ASSOC "GTLISP" $xml)))
			  )
			)
			" is available.\nWould you like to update?"
		)
	      )
	    (gtupdate:download)
	  )
	)
	(PRINC "\nGTLISP is upto date.")
      )
    )
  )
  (princ)
)