;;------------------=={ Global Variables }==-------------------;;
(SETQ gecho nil)
(SETQ gscale nil)
(SETQ glayer nil)
(SETQ gcolor nil)
(SETQ glinetype nil)
(SETQ glineweight nil)
(SETQ glinescale nil)
(SETQ gosnaps nil)
(SETQ gpickbox nil)
(SETQ gbackgroundplot nil)
(SETQ ghatchangle nil)
(SETQ ghatchscale nil)
(SETQ ghatchname nil)
(SETQ gerror nil)

;;--------------------=={ error trapper }==--------------------;;
;;                                                             ;;
;;  A replacement function to AutoCADs default error handler.  ;;
;;  The main difference is the restoration of layers, snaps    ;;
;;  and other user settings saved at the start of the routine. ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $oldError *error*) Save the current error     ;;
;;         (gterror:savesettings)          Saves all the user settings;;
;;         (SETQ *error gterror:trap) Replaces the error handler ;;
;;         (OTHER FUNCTIONS)                                   ;;
;;         (SETQ *error* nil)                                  ;;
;;-------------------------------------------------------------;;
(DEFUN gterror:trap ($error)
    ;;Restore the system error reporting function
    (SETQ *error* nil)
    (gterror:restoresettings)
    (PRINC $error)
    (PRINC "\nRestoring System Variables.")
    (PRINC)
)

;;------------------=={ save user settings }==-----------------;;
;;                                                             ;;
;;  Saves the user settings for restoration during a routine   ;;
;;  break or cancel.                                           ;;
;;-------------------------------------------------------------;;
;;  Usage: (gterror:savesettings)                                     ;;
;;-------------------------------------------------------------;;
(DEFUN gterror:savesettings ()
    (SETQ gecho (GETVAR "CMDECHO"))
    (SETQ gscale (GETVAR "DIMSCALE"))
    (SETQ glayer (GETVAR "CLAYER"))
    (SETQ gcolor (GETVAR "CECOLOR"))
    (SETQ glinetype (GETVAR "CELTYPE"))
    (SETQ glineweight (GETVAR "CELWEIGHT"))
    (SETQ glinescale (GETVAR "CELTSCALE"))
    (SETQ gosnaps (GETVAR "OSMODE"))
    (SETQ gpickbox (GETVAR "PICKBOX"))
    (SETQ gbackgroundplot (GETVAR "BACKGROUNDPLOT"))
    (SETQ ghatchangle (GETVAR "HPANG"))
    (SETQ ghatchscale (GETVAR "HPSCALE"))
    (SETQ ghatchname (GETVAR "HPNAME"))
    (PRINC)
)
;;----------------=={ restore user settings }==----------------;;
;;                                                             ;;
;;  Restores the user settings.                                ;;
;;-------------------------------------------------------------;;
;;  Usage: (gterror:restoresettings)                           ;;
;;-------------------------------------------------------------;;
(DEFUN gterror:restoresettings ()
    (SETVAR "CMDECHO" gecho)
    (SETVAR "DIMSCALE" gscale)
    (SETVAR "CLAYER" glayer)
    (SETVAR "CECOLOR" gcolor)
    (SETVAR "CELTYPE" glinetype)
    (SETVAR "CELWEIGHT" glineweight)
    (SETVAR "CELTSCALE" glinescale)
    (SETVAR "OSMODE" gosnaps)
    (SETVAR "PICKBOX" gpickbox)
    (SETVAR "BACKGROUNDPLOT" gbackgroundplot)
    (SETVAR "HPANG" ghatchangle)
    (SETVAR "HPSCALE" ghatchscale)
    (SETVAR "HPNAME" ghatchname)
    (PRINC)
)


