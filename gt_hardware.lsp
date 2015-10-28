;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTHardware:GenerateID</function>
<summary>Generates a unique ID based on PCName, Username and a fixed drive serial</summary>

<returns>System ID String</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gthardware:generateid
       (/ filesystemobject drives n serial wscript pcname pcuser)
  (SETQ	serial 0
	pcname ""
	pcuser ""
  )
  (COND
    ((SETQ wscript (VLAX-CREATE-OBJECT "WScript.Network"))
     (SETQ pcname (STRCASE (VLAX-GET-PROPERTY wscript "ComputerName"))
					; Computer Name
	   pcuser (VLAX-GET-PROPERTY wscript "UserName") ; UserName
     )

     (VLAX-RELEASE-OBJECT wscript)


     ;; Obtain the first Hard drive serial number
     (COND ((SETQ filesystemobject
		   (VLAX-CREATE-OBJECT
		     "Scripting.FilesystemObject"
		   )
	    )
	    ;; access the Drives collection
	    (SETQ drives (VLAX-GET-PROPERTY filesystemobject 'drives))

	    ;; Check each drive for a fixed drive. When the first drive is found, exit.
	    (VLAX-FOR n	drives
	      ;;If there drive is a fixed drive, get the serial and exit
	      (IF (= (VLAX-GET-PROPERTY n 'drivetype) 2)
		(PROGN
		  (SETQ serial (VLAX-GET-PROPERTY n 'serialnumber))
		)
	      )
	    )


	    ;; Release the vla objects
	    (VLAX-RELEASE-OBJECT drives)
	    (VLAX-RELEASE-OBJECT filesystemobject)
	   )
     )
    )

  )
  (STRCAT (ITOA serial) pcname pcuser)
)