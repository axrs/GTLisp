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
(SETQ $gtversion "0.0.1")
(SETQ $gtserver T)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|If the VLX file cannot be found in a support path, show the splash dialog.  |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF (= nil (FINDFILE "GTLISP.VLX"))
    (gtdialogs:splash (STRCAT "GTLISP SERVER Utilities - " $gtversion))
)
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|Ensure a default configuration setting exists                               |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(IF (= nil (FINDFILE (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx")) "\\" "gtconfig.cfg")))
    (PROGN ;;Add to the config sections
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "BASEPATH" (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "PLOTPATH" (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx"))))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "INITIALS" "A.S."))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "DATEFORMAT" "DD.MM.YY"))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "ENABLE_TIMES" "OFF"))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "ENABLE_OVERLAY" "OFF"))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL" "INITIALS" "A.S."))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL_ARCHIVING" "FOLDER" "Superseded\\"))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL_ARCHIVING" "DWGDETACH" "*"))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "GENERAL_ARCHIVING" "IMGDETACH" "*"))
           (SETQ $gtconfig (gtconfig:addsection $gtconfig "LOGGING" "LEVEL" "0"))
           (gtconfig:save $gtconfig
                          (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx")) "\\" "gtconfig.cfg")
           )
    )
    (SETQ $gtconfig (gtconfig:parse (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx")) "\\" "gtconfig.cfg")))
)
(PRINC)