(DEFUN c:gt_config () (gtconfig:showdialog))
(DEFUN gtconfig:showdialog (/ $basepath $plotpath $dateformat $initials flag)
    (SETQ flag 4)
    (SETQ $gtconfig (gtconfig:parse (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx")) "\\" "gtconfig.cfg")))
    (SETQ $basepath (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH"))
    (SETQ $plotpath (gtconfig:getvalue $gtconfig "GENERAL" "PLOTPATH"))
    (SETQ $dateformat (gtconfig:getvalue $gtconfig "GENERAL" "DATEFORMAT"))
    (SETQ $initials (gtconfig:getvalue $gtconfig "GENERAL" "INITIALS"))
    (SETQ dcl_id (LOAD_DIALOG "gt_config_dcl"))
    (WHILE (> flag 2)
        (IF (NOT (NEW_DIALOG "gtgeneralconfig" dcl_id))
            (EXIT)
        )
        (gtdclsmalllogo "gtlogo")
        (SET_TILE "basepath" $basepath)
        (SET_TILE "plotpath" $plotpath)
        (SET_TILE "initials" $initials)
        (SET_TILE "date" $dateformat)
        ;;Cancel (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") Action
        (ACTION_TILE "cancel" "(done_dialog)")
        ;;Accept (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") Action
        (ACTION_TILE "accept" "(done_dialog 1)")
        ;;Base Directory Browse (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
        (ACTION_TILE "browse1" "(done_dialog 4)")
        ;;Plot Config Browse (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
        (ACTION_TILE "browse2" "(done_dialog 5)")
        (ACTION_TILE "basepath" "(setq $basepath $value)")
        (ACTION_TILE "plotpath" "(setq $plotpath $value)")
        (ACTION_TILE "date" "(setq $dateformat $value)")
        (ACTION_TILE "initials" "(setq $initials $value)")
        (SETQ flag (START_DIALOG))
        ;;Base Directory Browse Action
        (IF (= flag 4)
            (SETQ $basepath (gtsystem:browseforfolder))
        )
        ;;Plot Config Browse Action
        (IF (= flag 5)
            (SETQ $plotpath (gtsystem:browseforfolder))
        )
    )
    (UNLOAD_DIALOG dcl_id)
    ;;Accept - Save config settings
    (IF (= flag 1)
        (PROGN (SETQ $gtconfig (gtconfig:setvalue $gtconfig "GENERAL" "BASEPATH" $basepath))
               (SETQ $gtconfig (gtconfig:setvalue $gtconfig "GENERAL" "PLOTPATH" $plotpath))
               (SETQ $gtconfig (gtconfig:setvalue $gtconfig "GENERAL" "INITIALS" $initials))
               (SETQ $gtconfig (gtconfig:setvalue $gtconfig
                                                  "GENERAL"
                                                  "DATEFORMAT"
                                                  $dateformat
                               )
               )
               (gtconfig:save $gtconfig (STRCAT (VL-FILENAME-DIRECTORY (FINDFILE "GTLISP.vlx")) "\\" "gtconfig.cfg"))
        )
    )
    (PRINC)
)

;;OPENDCL Form Controllers
(DEFUN c:gtlisp_options_oninitialize (/)
    (dcl_messagebox "To Do: code must be added to event handler\r\nc:gtlisp_Options_OnInitialize"
                    "To do"
    )
)

(DEFUN c:gtlisp_options_close_onclicked (/)
    (dcl_form_close gtlisp_options)
)

(DEFUN c:gtlisp_options_save_onclicked (/)
    (dcl_messagebox "To Do: code must be added to event handler\r\nc:gtlisp_Options_save_OnClicked"
                    "To do"
    )
)


(PRINC)