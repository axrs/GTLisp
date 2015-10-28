;;-------------------=={ create folder }==---------------------;;
;;                                                             ;;
;;  Creates a single folder a the specified path.              ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtsystem:createfolder "C:\\Some\\path\\")          ;;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $path - Path to create the folder.                         ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  nothing.                                                   ;;
;;-------------------------------------------------------------;;
(DEFUN gtsystem:createfolder ($path)
    (IF (NOT (VL-FILE-DIRECTORY-P $path))
        (VL-MKDIR $path)
    )
    (PRINC)
)

;;-------------------=={ create folder }==---------------------;;
;;                                                             ;;
;;  Opens up the windows folder browsing dialog.               ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $result (gtsystem:browseforfolder))           ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  The file path to the selected folder, or the system path id;;
;;-------------------------------------------------------------;;
(DEFUN gtsystem:browseforfolder (/)
    (ACET-UI-PICKDIR)
)

;;-------------------=={ build folders }==---------------------;;
;;                                                             ;;
;;  Builds folders along a path from the drawing location.     ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtsystem:buildpath "SOME\\NEW\\DIRECTORY\\")       ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  The file path to the newly created folder.                 ;;
;;-------------------------------------------------------------;;
(DEFUN gtsystem:buildpath ($path / $dwgpath $temp)
    (SETQ $dwgpath (GETVAR "DWGPREFIX"))
    (PRINC (STRCAT "Drawing Path: " $dwgpath "\n"))
    (SETQ $temp $path)
    (WHILE (NOT (= (STRCASE $temp) (gtstrings:replace (STRCASE $temp) "(UP)" "")))
        (SETQ $path (gtstrings:replace $path "(up)" ""))
        (SETQ $path (gtstrings:replace $path "(UP)" ""))
        (SETQ $path (gtstrings:replace $path "(uP)" ""))
        (SETQ $path (gtstrings:replace $path "(Up)" ""))
        (SETQ $temp (gtstrings:replace (STRCASE $temp) "(UP)" ""))

        (PRINC (STRCAT "End of Folder Path: " (NTH 1 (REVERSE (gtstrings:split $dwgpath "\\"))) "\n"))
        (SETQ
            $dwgpath (SUBSTR $dwgpath
                             1
                             (-
                                 (-
                                     (STRLEN $dwgpath)
                                     (STRLEN
                                         (LAST (gtstrings:split $dwgpath "\\"))
                                     )
                                 )
                                 1
                             )
                     )
        )
        (PRINC (STRCAT "New Path: " $dwgpath "\n"))

    )
    (SETQ $path (gtstrings:split (VL-STRING-LEFT-TRIM " \\" $path) "\\"))
    (FOREACH $folder $path
        (SETQ $dwgpath (STRCAT $dwgpath $folder "\\"))
        (SETQ $dwgpath (gtstrings:replace $dwgpath "\\\\" "\\"))
        (gtsystem:createfolder $dwgpath)
    )
    (PRINC "\nFinished Building Folders")
    $dwgpath
)