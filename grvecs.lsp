;;  Grread+osnap+GRVECS 
;;  Rewritten by Fools @ TheSwamp.org 
;;   
;;  Use (grread) to get original point 
;;  Use (osnap) to calculate accurate point 
;;  Use (GRVECS) to show AutoSnapMarker 
;;  No return , just show the method 

(DEFUN c:tmp (/
              autosnapmarkercolor
              autosnapmarkersize
              drag
              ghostpt
              lst_osmode
              str_osmode
              time
              distperpixel
              bold
              draftobj
              vecslst
              get_osmode
              sparser
              ypy_vecslist
              ypy_getgrvecs
              ypy_drawvecs
             )
    ;;  CAB  10/5/2006 
    ;;  Fools change a little about ","  (3/3/2007) 
    ;; 
    ;;  Function to return the current osmode setting in the form of a string 
    ;;  If (getvar "osmode") = 175 
    ;;  (get_osmode)  returns   "_end,_mid,_cen,_nod,_int,_per"   
    (DEFUN get_osmode (/ cur_mode mode$)
        (SETQ mode$ "")
        (IF (< 0 (SETQ cur_mode (GETVAR "osmode")) 16383)
            (MAPCAR (FUNCTION (LAMBDA (x)
                                  (IF (NOT (ZEROP (LOGAND cur_mode (CAR x))))
                                      (IF (ZEROP (STRLEN mode$))
                                          (SETQ mode$ (CADR x))
                                          (SETQ mode$ (STRCAT mode$ "," (CADR x)))
                                      )
                                  )
                              )
                    )
                    '((1 "_end")
                      (2 "_mid")
                      (4 "_cen")
                      (8 "_nod")
                      (16 "_qua")
                      (32 "_int")
                      (64 "_ins")
                      (128 "_per")
                      (256 "_tan")
                      (512 "_nea")
                      (1024 "_qui")
                      (2048 "_app")
                      (4096 "_ext")
                      (8192 "_par")
                     )
            )
        )
        mode$
    )
    ;;  This one uses pointers
    ;;  written by CAB @ TheSwamp.org 
    (DEFUN sparser (str delim / ptr lst stp)
        (SETQ stp 1)
        (WHILE (SETQ ptr (VL-STRING-SEARCH delim str (1- stp)))
            (SETQ lst (CONS (SUBSTR str stp (- (1+ ptr) stp)) lst))
            (SETQ stp (+ ptr 2))
        )
        (REVERSE (CONS (SUBSTR str stp) lst))
    )
    ;;My functions
    ;;Initial Grvecs List
    (DEFUN ypy_vecslist (/ circle cross square line)
        (SETQ square '(((-1 1) (-1 -1) (1 -1) (1 1) (-1 1))))
        (SETQ cross '(((-1 1) (1 -1))
                      ((-1 -1) (1 1))
                      ((1 0.859) (-0.859 -1))
                      ((-1 0.859) (0.859 -1))
                      ((0.859 1) (-1 -0.859))
                      ((-0.859 1) (1 -0.859))
                     )
        )
        (SETQ circle '(((0 1)
                        (-0.707 0.707)
                        (-1 0)
                        (-0.707 -0.707)
                        (0 -1)
                        (0.707 -0.707)
                        (1 0)
                        (0.707 0.707)
                        (0 1)
                       )
                      )
        )
        (SETQ line '(((1 1) (-1 1))))
        (LIST (CONS "_end" square) ;square
              '("_mid"
                ((0 1.414) (-1.225 -0.707) (1.225 -0.707) (0 1.414))
               ) ;triangle
              (CONS "_cen" circle) ;circle
              (APPEND '("_nod") square cross) ;circle+cross 
              '("_qua"
                ((0 1.414) (-1.414 0) (0 -1.414) (1.414 0) (0 1.414))
               ) ;square rotate 45
              (CONS "_int" cross) ;cross 
              '("_ins"
                ((-1 1)
                 (-1 -0.1)
                 (0 -0.1)
                 (0 -1.0)
                 (1 -1)
                 (1 0.1)
                 (0 0.1)
                 (0 1.0)
                 (-1 1)
                )
               ) ;two squares 
              '("_per"
                ((-1 1) (-1 -1) (1 -1))
                ((0 -1) (0 0))
                ((0 0) (-1 0))
               ) ;two half square 
              (APPEND '("_tan") circle line) ;circle+line 
              (APPEND '("_nea") '(((1 -1) (-1 -1))) line cross) ;two line+cross
              '("_qui") ; ??? 
              (APPEND '("_app") square cross) ;square+cross 
              '("_ext"
                ((0.1 0) (0.13 0))
                ((0.2 0) (0.23 0))
                ((0.3 0) (0.33 0))
               ) ;three points 
              '("_par" ((0 1) (-1 -1)) ((1 1) (0 -1))) ;two lines rotate 45
        )
    )
    ;;Get Grvecs List
    (DEFUN ypy_getgrvecs (pt dragpt lst vecs / key)
        (SETQ key T)
        (WHILE (AND key lst)
            (IF (EQUAL (OSNAP dragpt (CAR lst)) pt 1E-6)
                (SETQ key nil)
                (SETQ lst (CDR lst))
            )
        )
        (CDR (ASSOC (CAR lst) vecs))
    )
    ;;Use GRVECS 
    (DEFUN ypy_drawvecs (pt vecs size color / lst matrix)
        ;;no Z axis 
        (SETQ matrix (LIST (LIST size 0.0 0.0 (CAR pt))
                           (LIST 0.0 size 0.0 (CADR pt))
                           (LIST 0.0 0.0 1.0 0.0)
                           (LIST 0.0 0.0 0.0 1.0)
                     )
        )
        (GRVECS (APPLY (FUNCTION APPEND)
                       (APPLY (FUNCTION APPEND)
                              (MAPCAR (FUNCTION
                                          (LAMBDA (x)
                                              (IF (> (LENGTH x) 2)
                                                  (MAPCAR (FUNCTION LIST)
                                                          (MAPCAR (FUNCTION (LAMBDA (x) color)) x)
                                                          x
                                                          (CDR x)
                                                  )
                                                  (LIST (CONS color x))
                                              )
                                          )
                                      )
                                      vecs
                              )
                       )
                )
                matrix
        )
    )
    ;;**************************** 
    ;;  Main Routine starts here   
    ;;**************************** 
    (VL-LOAD-COM)
    (SETQ time T)
    (SETQ vecslst (ypy_vecslist))
    (SETQ str_osmode (get_osmode))
    (SETQ lst_osmode (sparser str_osmode ","))
    (SETQ draftobj (VLA-GET-DRAFTING
                       (VLA-GET-PREFERENCES (VLAX-GET-ACAD-OBJECT))
                   )
    )
    (SETQ autosnapmarkersize (VLA-GET-AUTOSNAPMARKERSIZE draftobj))
    (SETQ autosnapmarkercolor (VLA-GET-AUTOSNAPMARKERCOLOR draftobj))
    (WHILE time
        (GRREAD (SETQ drag (GRREAD T 1 1))) ;Can change like (grread T 15 2) 
        (COND ((= (CAR drag) 5)
               (REDRAW)
               (SETQ drag (CADR drag))
               (IF (OR (ZEROP (STRLEN str_osmode))
                       (NULL (SETQ ghostpt (OSNAP drag str_osmode)))
                   )
                   (SETQ ghostpt drag)
                   ;;Beacuse of mouse middle button scroll , calculate "DistPerPixel" every time 
                   (PROGN (SETQ distperpixel (/ (GETVAR "VIEWSIZE") (CADR (GETVAR "SCREENSIZE"))))
                          ;;Bold 
                          (SETQ bold (MAPCAR '*
                                             (LIST distperpixel distperpixel distperpixel)
                                             (LIST (+ autosnapmarkersize 0.5)
                                                   autosnapmarkersize
                                                   (- autosnapmarkersize 0.5)
                                             )
                                     )
                          )
                          (FOREACH item bold
                              (ypy_drawvecs
                                  ghostpt
                                  (ypy_getgrvecs ghostpt drag lst_osmode vecslst)
                                  item
                                  autosnapmarkercolor
                              )
                          )
                   )
               )
              )
              ((= (CAR drag) 3)
               (IF (NULL (SETQ ghostpt (OSNAP (CADR drag) (get_osmode))))
                   (SETQ ghostpt (CADR drag))
               )
               (REDRAW)
               (SETQ time nil)
              )
        )
    )
    (PRINC) ;can return ghostpt if u want 
)