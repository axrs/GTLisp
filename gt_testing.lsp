(DEFUN gt-importcsv (/ $file $line $x $y)
    (SETQ $file "X:\\temp\\Alex\\Matt Thesis Data\\To Do Please\\On to new plot if possible\\40lb VERT.csv")
    (PRINC $file)
    (IF (AND (SETQ $file (FINDFILE $file)) (SETQ $file (OPEN $file "r")))

        (PROGN
            (WHILE (SETQ $line (READ-LINE $file))
                (SETQ $line (READ-LINE $file))
                (SETQ $line (gtstrings:split $line ","))
                (SETQ $x (NTH 1 $line))
                (SETQ $y (NTH 0 $line))

                (ENTMAKE (LIST
                             '(0 . "POINT")
                             (CONS 8 "0")
                             (CONS 10
                                   (LIST (ATOF $x) (ATOF $y) 0.0)
                             )
                         )
                )

            )
        )

    )
    (PRINC)
)

