;;-------------------=={ Bolt Information }==------------------;;
;;                                                             ;;
;;  Produces a table representation of bolt distances.         ;;
;;  The first run is hard coded, but all other runs use the    ;;
;;  'bolt.info' file (user changable).                         ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Nothing.                                                   ;;
;;-------------------------------------------------------------;;
(DEFUN c:gt-information-bolts (/ $info)
    (SETQ $info (STRCAT
                    "--------------------------------------------------------------------------------\n"
                    "                         BOLT DISTANCE (mm) INFORMATION                         \n"
                    "--------------------------------------------------------------------------------\n"
                    " BOLT SIZE | SHEARED | MACHINED | ROLLED | MIN PITCH | FACE DIST | CORNER DIST  \n"
                    "-----------|---------|----------|--------|-----------|-----------|--------------\n"
                    "    M10    |   20    |    20    |   15   |    25     |    15     |      25      \n"
                    "    M12    |   25    |    20    |   15   |    30     |    20     |      25      \n"
                    "    M16    |   30    |    25    |   20   |    40     |    25     |      35      \n"
                    "    M20    |   35    |    30    |   25   |    50     |    30     |      35      \n"
                    "    M24    |   40    |    35    |   30   |    60     |    40     |      45      \n"
                    "    M30    |   50    |    45    |   40   |    75     |    45     |      55      \n"
                    "    M36    |   60    |    55    |   50   |    90     |    55     |      65      \n"
                    "--------------------------------------------------------------------------------"
                )
    )
    (gttables:information "bolts" $info "GTLISP - BOLT INFORMATION")
)
(DEFUN c:gt-information-reinforcement (/ $info)
    (SETQ $info (STRCAT
                    "--------------------------------------------------------------------------------\n"
                    "                               BAR BENDING DETAILS                              \n"
                    "--------------------------------------------------------------------------------\n"
                    "TYPE OF BAR          | MINIMUM |                BAR DIAMETER (mm)               \n"
                    "                     | PIN DIA |  6    10   12   16   20   24   28   32   36    \n"
                    "---------------------|---------|------------------------------------------------\n"
                    "FITMENTS:            |         |                                                \n"
                    "D500L & R250N BARS   |   3db   | 100  110  120   *    *    *    *    *    *     \n"
                    "D500N BARS           |   4db   | 110  130  140  170  200  230  270  300  340    \n"
                    "---------------------|---------|------------------------------------------------\n"
                    "REINF. IF NOT BELOW  |   5db   | 120  140  160  180  220  260  300  340  380    \n"
                    "---------------------|---------|------------------------------------------------\n"
                    "BENDS DESIGNED TO BE |   4db   | 110  130  140  170   *    *    *    *    *     \n"
                    "STRAIGHTENED OR      |   5db   |  *    *    *    *   220  260                   \n"
                    "SUBSEQUENTLY REBENT  |   6db   |  *    *    *    *    *    *   330  380  430    \n"
                    "---------------------|---------|------------------------------------------------\n"
                    "BENDS EPOXY-COATED   |   5db   | 120  140  160  180   *    *    *    *    *     \n"
                    "OR GALVANISED        |   8db   |  *    *    *    *   290  340  390  440  500    \n"
                    "---------------------|---------|------------------------------------------------\n"
                    "* - NOT TO BE USED                                                              "
                )
    )
    (gttables:information "reinforcement" $info "GTLISP - REINFORCEMENT BENDING DETAILS")
)

(DEFUN c:gt-information-purlins (/ $info)
    (SETQ $info (STRCAT
                    "                DIMENSIONS OF ZED & CEE SECTION PURLINS                \n"
                    "-----------------------------------------------------------------------\n"
                    "           |  t   |  D   ||        ZEDS        ||    CEES     ||       \n"
                    "  SECTION  |  mm  |  mm  ||  E   |  F   |  L   ||  B   |  L   || GAUGE \n"
                    "           |      |      ||  mm  |  mm  |  mm  ||  mm  |  mm  ||       \n"
                    "-----------------------------------------------------------------------\n"
                    " Z/C10010  | 1.0  |  102 ||  53  |  49  | 12.5 ||  51  | 12.5 ||  40   \n"
                    " Z/C10012  | 1.2  |  102 ||  53  |  49  | 12.5 ||  51  | 12.5 ||  40   \n"
                    " Z/C10015  | 1.5  |  102 ||  53  |  49  | 13.5 ||  51  | 13.5 ||  40   \n"
                    " Z/C10019  | 1.9  |  102 ||  53  |  49  | 14.5 ||  51  | 14.5 ||  40   \n"
                    "-----------------------------------------------------------------------\n"
                    " Z/C15012  | 1.2  |  152 ||  65  |  61  | 15.5 ||  64  | 14.5 ||  60   \n"
                    " Z/C15015  | 1.5  |  152 ||  65  |  61  | 16.5 ||  64  | 15.5 ||  60   \n"
                    " Z/C15019  | 1.9  |  152 ||  65  |  61  | 17.5 ||  64  | 16.5 ||  60   \n"
                    " Z/C15024  | 2.4  |  152 ||  66  |  60  | 19.5 ||  64  | 18.5 ||  60   \n"
                    "-----------------------------------------------------------------------\n"
                    " Z/C20015  | 1.5  |  203 ||  79  |  74  | 15.5 ||  76  | 15.5 || 110   \n"
                    " Z/C20019  | 1.9  |  203 ||  79  |  74  | 18.5 ||  76  | 19.0 || 110   \n"
                    " Z/C20024  | 2.4  |  203 ||  79  |  73  | 21.5 ||  76  | 21.0 || 110   \n"
                    "-----------------------------------------------------------------------\n"
                    " Z/C25019  | 1.9  |  254 ||  79  |  74  | 18.0 ||  76  | 18.5 || 160   \n"
                    " Z/C25024  | 2.4  |  254 ||  79  |  73  | 21.0 ||  76  | 20.5 || 160   \n"
                    "-----------------------------------------------------------------------\n"
                    " Z/C30024  | 2.4  |  300 || 100  |  93  | 27.0 ||  96  | 27.5 || 210   \n"
                    " Z/C30030  | 3.0  |  300 || 100  |  93  | 31.0 ||  96  | 31.5 || 210   \n"
                    "-----------------------------------------------------------------------\n"
                    " Z/C35030  | 3.0  |  350 || 129  | 121  | 30.0 || 125  | 30.0 || 260   "
                )
    )
    (gttables:information "purlins" $info "GTLISP - PURLIN DETAILS")
)

(DEFUN gttables:information ($filename $info $title / $file $line $height $width)
    (SETQ $width 0)
    (IF (AND (SETQ $file (FINDFILE (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") "\\info\\" $filename ".info")))
             (SETQ $file (OPEN (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") "\\info\\" $filename ".info") "r"))
        )
        ;;Load from file
        (PROGN
            (SETQ $info "")
            (WHILE (SETQ $line (READ-LINE $file))
                ;;First iteration of the loop omits the first \n in
                ;;string re-compilation.
                (IF (= $info "")
                    (SETQ $info (STRCAT $info $line))
                    (SETQ $info (STRCAT $info "\n" $line))
                )
                (IF (< $width (STRLEN $line))
                    (SETQ $width (+ (STRLEN $line) 1))
                )
            )
            (CLOSE $file)
        )
        ;;Use info from input
        (PROGN
            (gtsystem:createfolder (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") "\\info\\"))
            (IF (SETQ $file (OPEN (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") "\\info\\" $filename ".info") "w"))
                (PROGN
                    (WRITE-LINE $info $file)
                    (CLOSE $file)
                    (SETQ $width (+ (/ (STRLEN $info) (LENGTH (gtstrings:split $info "\n"))) 1))
                )
            )
        )
    )
    (SETQ $height (+ (LENGTH (gtstrings:split $info "\n")) 4))
    (gttables:informationdisplay $info T "info" $title (RTOS $height) (RTOS $width))
    (PRINC)
)


;;-----------------=={ Information Display }==-----------------;;
;;                                                             ;;
;;  Displays member information in either a dialog or cmd line.;;
;;-------------------------------------------------------------;;
;;  Usage:                                                     ;;
;;  (gttables:informationdisplay $info $mode $dcl $title $height);;
;;  $info - Information string to display ("Some\nNew\nLine")  ;;
;;          Maximum characters per line is 80.                 ;;
;;  $mode - Display mode, nil = CommandLine, T = DCL.          ;;
;;  $title - Dialog title.                                     ;;
;;  $height - String representation of dialog height, e.g. "15";;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Nothing.                                                   ;;
;;-------------------------------------------------------------;;

(DEFUN gttables:informationdisplay ($info $mode $dcl $title $height $width / $dialog)
    (IF (= $mode nil)
        (PROGN
            (PRINC $info)
            (EXIT)
        )
    )
    (SETQ $dialog (LOAD_DIALOG (gttables:createinformationdialog $dcl $title $height $width)))

    (IF (NOT (NEW_DIALOG $dcl $dialog))
        (PROGN
            (ALERT
                "Dependicies are missing from this application.\nPlease contact the developer to have this issue resolved."
            )
            (EXIT)
        )
    )
    (ACTION_TILE "accept" "(done_dialog)")
    (SET_TILE "txt" $info)
    (START_DIALOG)
    (DONE_DIALOG)
    (UNLOAD_DIALOG $dialog)
    (PRINC)
)

;;--------------=={ create information dialog }==--------------;;
;;                                                             ;;
;;  Creates the information dialog (for displaying bolt/purlin);;
;;  information from code rather than a .dcl file. This grants ;;
;;  the ability to use one DCL file with a dynamic height value;;
;;  so any alterations to .info files will fit within the dlg. ;;
;;-------------------------------------------------------------;;
;;  Usage:                                                     ;;
;;  (gttables:createinformationdialog $dclID $title $height)   ;;
;;  $dclID - ID of the dialog to use.                          ;;
;;  $title - Title to display at the top of the window.        ;;
;;  $height - String representation for DCL height.            ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  Full path to the temporary .dcl file                       ;;
;;-------------------------------------------------------------;;
(DEFUN gttables:createinformationdialog ($dcl $title $height $width / $filename $file)

    (SETQ $filename (VL-FILENAME-MKTEMP (STRCAT $dcl ".dcl")))
    (SETQ $file (OPEN $filename "w"))
    (WRITE-LINE
        (STRCAT $dcl
                " : dialog {"
                "label = \""
                $title
                "\";"
                ":paragraph {"
                ": text_part {"
                "fixed_width_font = true;"
                "height = "
                $height
                ";"
                "width = "
                $width
                ";"
                "key = \"txt\";"
                "}"
                "}"
                "spacer;"
                ": button {"
                "key = \"accept\";"
                "label = \"Continue\";"
                "is_default = true;"
                "mnemonic = \"C\";"
                "width = 10;"
                "alignment = centered;"
                "fixed_width = true;"
                "}"
                "}"
        )
        $file
    )

    (CLOSE $file)
    $filename
)