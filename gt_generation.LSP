;;----------------=={ Save Blocks to DWG }==-------------------;;
;;                                                             ;;
;;  Creates the GT Blocks and saves them as DWG files.         ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:saveblock "BlockName" gt:createblockfunction)   ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  nil                                                        ;;
;;-------------------------------------------------------------;;
(DEFUN gtblocks:saveblock ($blockname $createfn / $filename)

    (SETQ $olderror *error*)
    gterror:savesettings
    (SETQ *error gterror:trap)
    (SETVAR "CMDECHO" 0)

    (SETQ $filename (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH") "\\" $blockname ".dwg"))
    ($createfn)
    (IF (FINDFILE $filename)
        (COMMAND "_.-WBLOCK" $filename "_y" $blockname)
        (COMMAND "_.-WBLOCK" $filename $blockname)
    )
    (PRINC (STRCAT "\nCreated leader block: " $filename))

    (SETQ *error* nil)
    (gterror:restoresettings)
)

(DEFUN gtblocks:createall ()
    (gtblocks:createarr1)
    (gtblocks:createarr2)
    (gtblocks:createarr3)
    (gtblocks:createarr4)
    (gtblocks:createarr5)
    (gtblocks:createarr6)
    (gtblocks:createarr7)
    (gtblocks:createarr8)
    (PRINC)
)
(DEFUN gtblocks:savearr1 () (gtblocks:saveblock "GT-ARR1" gtblocks:createarr1))
(DEFUN gtblocks:savearr2 () (gtblocks:saveblock "GT-ARR2" gtblocks:createarr2))
(DEFUN gtblocks:savearr3 () (gtblocks:saveblock "GT-ARR3" gtblocks:createarr3))
(DEFUN gtblocks:savearr4 () (gtblocks:saveblock "GT-ARR4" gtblocks:createarr4))
(DEFUN gtblocks:savearr5 () (gtblocks:saveblock "GT-ARR5" gtblocks:createarr5))
(DEFUN gtblocks:savearr6 () (gtblocks:saveblock "GT-ARR6" gtblocks:createarr6))
(DEFUN gtblocks:savearr7 () (gtblocks:saveblock "GT-ARR7" gtblocks:createarr7))
;;-----------------=={ Create Block ARR1 }==-------------------;;
;;                                                             ;;
;;  Creates the GT Dimension Arrow block without a DWG file.   ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr1)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR1. Standalone function.                               ;;
;;-------------------------------------------------------------;;

(DEFUN gtblocks:createarr1 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR1") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 -1.73205 1.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 -1.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 -1.73205 -1.0 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)

;;-----------------=={ Create Block ARR2 }==-------------------;;
;;                                                             ;;
;;  Creates the GT Arrow Leader block without a DWG file.      ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr2)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR2. Standalone function.                               ;;
;;-------------------------------------------------------------;;
(DEFUN gtblocks:createarr2 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR2") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 3.03109 1.75 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 3.03109 -1.75 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)

;;-----------------=={ Create Block ARR3 }==-------------------;;
;;                                                             ;;
;;  Creates the GT Fall Arrow block without a DWG file.        ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr3)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR3. Standalone function.                               ;;
;;-------------------------------------------------------------;;
(DEFUN gtblocks:createarr3 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR3") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 -1.0 0.166667 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 -0.475643 0.0396369 0.0) (11 -1.0 0.0833333 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 -1.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 -0.475643 -0.0396369 0.0) (11 -1.0 -0.0833333 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 0.0 0.0 0.0) (11 -1.0 -0.166667 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (10 -1.0 -0.166667 0.0) (11 -1.0 0.166667 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)

;;-----------------=={ Create Block ARR4 }==-------------------;;
;;                                                             ;;
;;  Creates the GT ???? Arrow block without a DWG file.        ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr4)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR4. Standalone function.                               ;;
;;-------------------------------------------------------------;;

(DEFUN gtblocks:createarr4 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR4") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "CIRCLE") (8 . "0") (62 . 4) (10 0.0 0.0 0.0) (40 . 0.25)))
    (ENTMAKE '((0 . "CIRCLE") (8 . "0") (62 . 4) (10 0.0 0.0 0.0) (40 . 0.65)))
    (ENTMAKE '((0 . "ENDBLK")))
)

;;-----------------=={ Create Block ARR5 }==-------------------;;
;;                                                             ;;
;;  Creates the GT ???? Arrow block without a DWG file.        ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr5)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR5. Standalone function.                               ;;
;;-------------------------------------------------------------;;
(DEFUN gtblocks:createarr5 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR5") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 3) (10 0.0 0.0 0.0) (11 -2.5 2.5 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 3) (10 0.0 0.0 0.0) (11 -2.5 -2.5 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 3) (10 -2.5 2.5 0.0) (11 -2.5 -2.5 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)

;;-----------------=={ Create Block ARR6 }==-------------------;;
;;                                                             ;;
;;  Creates the GT ???? Arrow block without a DWG file.        ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr6)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR6. Standalone function.                               ;;
;;-------------------------------------------------------------;;

(DEFUN gtblocks:createarr6 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR6") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "CIRCLE") (8 . "0") (62 . 4) (10 0.0 0.0 0.0) (40 . 0.45)))
    (ENTMAKE '((0 . "CIRCLE") (8 . "0") (62 . 4) (10 0.0 0.0 0.0) (40 . 0.85)))
    (ENTMAKE '((0 . "ENDBLK")))
)

;;-----------------=={ Create Block ARR7 }==-------------------;;
;;                                                             ;;
;;  Creates the GT ???? Arrow block without a DWG file.        ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:createarr7)                                ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  GTARR7. Standalone function.                               ;;
;;-------------------------------------------------------------;;

(DEFUN gtblocks:createarr7 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR7") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 7) (10 0.0 0.0 0.0) (11 -3.03109 1.75 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 1) (10 0.0 0.0 0.0) (11 -1.0 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 7) (10 0.0 0.0 0.0) (11 -3.03109 -1.75 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)

(DEFUN gtblocks:createarr8 ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-ARR8") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '((0 . "CIRCLE") (8 . "0") (62 . 7) (10 0.0 0.0 0.0) (40 . 1)))
    (ENTMAKE '((0 . "ENDBLK")))
)

(DEFUN gtblocks:createsectiontail ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-SECT-TAIL") (70 . 2) (10 0.0 0.0 0.0)))
    ;;Triangle Constructor
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 7) (10 -3.5 -3.5 0.0) (11 1.5 1.5 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 7) (10 -2.5 -3.5 0.0) (11 -7.5 1.5 0.0)))
    (ENTMAKE '((0 . "HATCH")
               (100 . "AcDbEntity")
               (8 . "0")
               (62 . 1)
               (100 . "AcDbHatch")
               (10 0.0 0.0 0.0)
               (210 0.0 0.0 1.0)
               (2 . "SOLID")
               (70 . 1)
               (71 . 0)
               (91 . 1)
               (92 . 1)
               (93 . 3)

               (72 . 1)
               (10 0.0 0.0 0.0)
               (11 -3.0 -3.0 0.0)
               (72 . 1)
               (10 -3.0 -3.0 0.0)
               (11 -6.0 0.0 0.0)
               (72 . 1)
               (10 -6.0 0.0 0.0)
               (11 0.0 0.0 0.0)
               (97 . 0)
               (75 . 0)
               (76 . 1)

               (98 . 1)
               (10 -3.06316 -1.00244 0.0)
              )
    )
    ;;Leader Line
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 3) (10 -6.0 0.0 0.0) (11 4.0 0.0 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)

(DEFUN gtblocks:createsectionhead ()
    (ENTMAKE '((0 . "BLOCK") (2 . "GT-SECT-HEAD") (70 . 2) (10 0.0 0.0 0.0)))
    (ENTMAKE '(
               (0 . "WIPEOUT")
               (8 . "0")
               (100 . "AcDbEntity")
               (100 . "AcDbWipeout")
               (90 . 0)
               (10 -6.51285 -6.5 0.0)
               (11 13.0257 0.0 0.0)
               (12 0.0 13.0257 0.0)
               (13 1.0 1.0 0.0)
               (70 . 7)
               (280 . 1)
               (71 . 2)
               (91 . 51)
               (14 -0.0313953 -0.498027 0.0)
               (14 -0.0936907 -0.490157 0.0)
               (14 -0.154508 -0.474542 0.0)
               (14 -0.21289 -0.451427 0.0)
               (14 -0.267913 -0.421177 0.0)
               (14 -0.318712 -0.38427 0.0)
               (14 -0.364484 -0.341287 0.0)
               (14 -0.404508 -0.292906 0.0)
               (14 -0.438153 -0.23989 0.0)
               (14 -0.464888 -0.183076 0.0)
               (14 -0.484292 -0.123358 0.0)
               (14 -0.496057 -0.06168 0.0)
               (14 -0.5 0.000986636 0.0)
               (14 -0.496057 0.0636533 0.0)
               (14 -0.484292 0.125332 0.0)
               (14 -0.464888 0.185049 0.0)
               (14 -0.438153 0.241863 0.0)
               (14 -0.404508 0.294879 0.0)
               (14 -0.364484 0.34326 0.0)
               (14 -0.318712 0.386243 0.0)
               (14 -0.267913 0.423151 0.0)
               (14 -0.21289 0.4534 0.0)
               (14 -0.154508 0.476515 0.0)
               (14 -0.0936907 0.49213 0.0)
               (14 -0.0313953 0.5 0.0)
               (14 0.0313953 0.5 0.0)
               (14 0.0936907 0.49213 0.0)
               (14 0.154508 0.476515 0.0)
               (14 0.21289 0.4534 0.0)
               (14 0.267913 0.423151 0.0)
               (14 0.318712 0.386243 0.0)
               (14 0.364484 0.34326 0.0)
               (14 0.404508 0.294879 0.0)
               (14 0.438153 0.241863 0.0)
               (14 0.464888 0.185049 0.0)
               (14 0.484292 0.125332 0.0)
               (14 0.496057 0.0636533 0.0)
               (14 0.5 0.000986636 0.0)
               (14 0.496057 -0.06168 0.0)
               (14 0.484292 -0.123358 0.0)
               (14 0.464888 -0.183076 0.0)
               (14 0.438153 -0.23989 0.0)
               (14 0.404508 -0.292906 0.0)
               (14 0.364484 -0.341287 0.0)
               (14 0.318712 -0.38427 0.0)
               (14 0.267913 -0.421177 0.0)
               (14 0.21289 -0.451427 0.0)
               (14 0.154508 -0.474542 0.0)
               (14 0.0936907 -0.490157 0.0)
               (14 0.0313953 -0.498027 0.0)
               (14 -0.0313953 -0.498027 0.0)
              )
    )
    ;;Circle Constructor
    (ENTMAKE '(
               (0 . "HATCH") ;Entity Type
               (100 . "AcDbEntity")
               (8 . "0") ;Layer
               (62 . 1) ;Color
               (100 . "AcDbHatch")
               (10 0.0 0.0 0.0) ;Starting Point
               (210 0.0 0.0 1.0)
               (2 . "SOLID")
               (70 . 1) ;Fill Type (1 = solid, 0 = pattern fill)
               (71 . 0) ;Associativity flag (1 = 
               (91 . 1)
               (92 . 7)
               (72 . 1) ;Shape type (1 = straight edge)
               (73 . 1) ;Associativity Flag (1 = Associative, 0 = Non-Associative)
               (93 . 5)
               (10 9.2814 0.0 0.0) ;Seed point
               (42 . 0.0)
               (10 6.5 0.0 0.0) ;Seed point
               (42 . -1.0)
               (10 -6.5 0.0 0.0) ;Seed point
               (42 . 0.0)
               (10 -9.2814 0.0 0.0) ;Seed point
               (42 . 0.0)
               (10 1.11022e-016 -9.68689 0.0) ;Seed point
               (42 . 0.0)
               (97 . 0)
               (75 . 1) ;Hatch Style (0 = Normal, 1 = Outer, 2 = Ignore)
               (76 . 1) ;Hatch pattern type (0 = User-Defined, 1 = Predefined, 2 = Custom)
               (47 . 0.0933144) ;Pixel size to determine pattern density
               (98 . 1) ;Number of seed points
               (10 0.580544 -8.01639 0.0) ;Seed point
              )
    )
    (ENTMAKE '((0 . "CIRCLE") (8 . "0") (62 . 7) (10 0.0 0.0 0.0) (40 . 6.5)))
    ;;Horizontal Line Constructors
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 1) (10 -6.5 0.0 0.0) (11 -10.5 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 1) (10 6.5 0.0 0.0) (11 10.5 0.0 0.0)))
    ;;Angle Line Constructors
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 1) (10 10.0 0.75 0.0) (11 -0.3 -10.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 1) (10 6.5 0.0 0.0) (11 10.5 0.0 0.0)))
    (ENTMAKE '((0 . "LINE") (8 . "0") (62 . 3) (10 6.5 0.0 0.0) (11 16.5 0.0 0.0)))
    (ENTMAKE '((0 . "ENDBLK")))
)