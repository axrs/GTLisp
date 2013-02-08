(DEFUN c:gt_slab_cogs (/)
    (gtslabtools:gtcogs)
)
(DEFUN gtslabtools:gtcogs (/
                           $barpoint
                           $barentity
                           $barstartpoint
                           $barendpoint
                           $barlayer
                           $barcolor
                           $barlinetype
                           $slabpoint
                           $slabentity
                           $slabstartpoint
                           $slabendpoint
                           $intersectionpoint
                           $angle
                           $degrees
                           $direction
                           $response
                           $entity
                           $linepoint1
                           $linepoint2
                           $linepoint3
                           $linepoint4
                           $farpoint1
                           $farpoint2
                           $newbarend
                           $loop
                           $olderror
                           $osmode
                           $previousresponse
                          )
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>gtcogs:trap</function>
    <sumary>GTCogs error trapping</sumary>
    <returns>Nothing</returns>
   |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (DEFUN gtcogs:trap ($error)
        ;;Restore the system error reporting function
        (SETQ *error* nil)
        (SETVAR "OSMODE" $osmode)
        (PRINC "\nGTCogs function cancelled.\n")
        (PRINC $error)
        (PRINC)
    )

    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>radtodeg</function>
    <sumary>Converts radians to degrees.</sumary>
    <returns>$angle in degrees</returns>
   |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (DEFUN radtodeg ($angle)
        (/ (* $angle 180.0) PI)
    )

    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>degtorad</function>
    <sumary>Converts radians to degrees.</sumary>
    <returns>$angle in degrees</returns>
   |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (DEFUN degtorad ($angle)
        (* (/ PI 180.0) $angle)
    )

    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>configure</function>
    <summary>Prompts the user for a bar point and slab point, Initialiasing variables.</summary>

    <returns>Nothing</returns>
    |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (DEFUN gtcogs:configure (/)

        ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
        ;;Bar Configuration and Selection                                             ;;
        ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
        (INITGET 1)
        ;;User cannot press 'enter'

        (SETQ $barentity nil)
        (WHILE (NOT (= (CDR (ASSOC 0 $barentity)) "LINE"))
            (PRINC "\nNote - Bar must be a LINE.")
            (SETQ $barpoint      (GETPOINT "\nSelect a point along the bar: ")
                  $barentity     (ENTGET (CAR (NENTSELP $barpoint)))
                  $barstartpoint (CDR (ASSOC 10 $barentity))
                  $barendpoint   (CDR (ASSOC 11 $barentity))
                  $barlayer      (CDR (ASSOC 8 $barentity))
                  $barcolor      (CDR (ASSOC 62 $barentity))
                  $barlinetype   (CDR (ASSOC 6 $barentity))
            )
        )

        ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
        ;;Slab Configuration and Selection                                            ;;
        ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
        (INITGET 33)
        ;;Turns on rubberbanding, and user cannot press enter
        (SETQ $slabentity nil)
        (WHILE (NOT (= (CDR (ASSOC 0 $slabentity)) "LINE"))
            (PRINC "\nNote: - Concrete edge must be a LINE.")
            (SETQ $slabpoint      (GETPOINT $barpoint "\nSelect a point along the slab edge: ")
                  $slabentity     (ENTGET (CAR (NENTSELP $slabpoint)))
                  $slabstartpoint (CDR (ASSOC 10 $slabentity))
                  $slabendpoint   (CDR (ASSOC 11 $slabentity))
            )
        )

        (SETQ $intersectionpoint (INTERS $barstartpoint $barendpoint $slabstartpoint $slabendpoint nil)
              $angle             (ANGLE $intersectionpoint $barpoint)
              $degrees           (radtodeg $angle)
        )
        (IF (AND (> (FIX $degrees) 90) (<= (FIX $degrees) 270))
            (SETQ $direction -1)
            (SETQ $direction 1)
        )
        (PRINC)
    )


    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;;Main Function                                                               ;;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (SETQ $olderror *error*)
    (SETQ *error* gtcogs:trap)
    (SETQ $osmode (GETVAR "OSMODE"))
    (SETQ $loop T)
    (SETQ $response "BtmCog")
    (WHILE $loop
        (SETVAR "OSMODE" 512)
        (gtcogs:configure)


        ;;Prompt the user for a choice
        (INITGET "BtmCog BC BtmHook BH BtmStep BS TopCog TC TopHook TH TopStep TS Cancel Q")

        (SETQ $response
                 (GETKWORD
                     (STRCAT "\nSpecify a cog type:\n[BtmCog/BtmHook/BtmStep/TopCog/TopHook/TopStep/Cancel] <"
                             $response
                             ">: "
                     )
                 )
        )
        (IF (NOT $response)
            (SETQ $response $previousresponse)
        )
        (SETQ $response (STRCASE $response))
        (SETQ $previousresponse $response)
        ;;Determine which end of the line was selected
        (SETQ $farpoint1 (DISTANCE $intersectionpoint $barstartpoint)
              $farpoint2 (DISTANCE $intersectionpoint $barendpoint)
        )
        (IF (< $farpoint1 $farpoint2)
            (SETQ $newbarend $barendpoint)
            (SETQ $newbarend $barstartpoint)
        )

        (SETQ $entity (LIST '(0 . "LWPOLYLINE")
                            '(100 . "AcDbEntity")
                            '(100 . "AcDbPolyline")
                            (CONS 8 $barlayer) ;BarLayer
                            '(70 . 0) ;Closed Polyline
                            '(43 . 0) ;Constant width
                      )
        )
        (COND
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Cancel the function                                                         ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "CANCEL") (= $response "Q"))
             (SETQ $loop nil
             )
            )
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Bottom Cog                                                                  ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "BTMCOG") (= $response "BC"))
             ;;Calculate the new points

             (PRINC $degrees)
             (PRINC "\n")
             (PRINC $angle)
             (PRINC "\n")
             (PRINC $direction)
             (SETQ $linepoint1 (POLAR $intersectionpoint $angle (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))

                   $linepoint2
                               (POLAR $linepoint1
                                      (+ $angle (degtorad (* $direction 90)))
                                      (* (GETVAR "DIMSCALE") (/ 300.00 100.00))
                               )
             )


             ;;Make a new bar polyline using the same settings
             (SETQ $entity (APPEND $entity
                                   (LIST
                                       '(90 . 3) ;Number of verticies
                                       (CONS 10 $newbarend) ;Start Point
                                       (CONS 10 $linepoint1) ;End Point
                                       (CONS 10 $linepoint2) ;End of Cog
                                   )
                           )
             )
            )
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Case Bottom Hook                                                            ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "BTMHOOK") (= $response "BH"))
             (SETQ $linepoint1 (POLAR $intersectionpoint
                                      $angle
                                      (+
                                          (/
                                              (* (GETVAR "DIMSCALE") (/ 150.00 100.00))
                                              2
                                          )
                                          (* (GETVAR "DIMSCALE") (/ 150.00 100.00))
                                      )
                               )
                   $linepoint2 (POLAR $linepoint1
                                      (+ $angle (degtorad 90))
                                      (* $direction (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
                               )
                   $linepoint3 (POLAR $linepoint2 $angle (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
             )
             (SETQ $entity (APPEND $entity
                                   (LIST
                                       '(90 . 4) ;Number of verticies
                                       (CONS 10 $newbarend) ;Start Point
                                       (CONS 10 $linepoint1) ;End Point
                                       (CONS 42 (* -1 $direction)) ;Arc
                                       (CONS 10 $linepoint2) ;End of arc
                                       (CONS 10 $linepoint3) ;End of hook
                                   )
                           )
             )

            )
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Case Bottom Step                                                            ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "BTMSTEP") (= $response "BS"))
             ;;Calculate the new points
             (SETQ $linepoint1 (POLAR $intersectionpoint $angle (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
                   $linepoint2 (POLAR $linepoint1
                                      (+ $angle (degtorad 90))
                                      (* $direction (* (GETVAR "DIMSCALE") (/ 300.00 100.00)))
                               )
                   $linepoint3 (POLAR $linepoint2
                                      (+ $angle (degtorad 180))
                                      (* (GETVAR "DIMSCALE") (/ 300.00 100.00))
                               )
             )
             ;;Make a new bar polyline using the same settings
             (SETQ $entity (APPEND $entity
                                   (LIST
                                       '(90 . 3) ;Number of verticies
                                       (CONS 10 $newbarend) ;Start Point
                                       (CONS 10 $linepoint1) ;End Point
                                       (CONS 10 $linepoint2) ;Base of Step
                                       (CONS 10 $linepoint3) ;Step Landing
                                   )
                           )
             )

            )
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Case Top Cog                                                                ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "TOPCOG") (= $response "TC"))
             ;;Calculate the new points
             (SETQ $linepoint1 (POLAR $intersectionpoint $angle (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
                   $linepoint2 (POLAR $linepoint1
                                      (+ $angle (degtorad 270))
                                      (* $direction (* (GETVAR "DIMSCALE") (/ 300.00 100.00)))
                               )
             )
             ;;Make a new bar polyline using the same settings
             (SETQ $entity (APPEND $entity
                                   (LIST
                                       '(90 . 3) ;Number of verticies
                                       (CONS 10 $newbarend) ;Start Point
                                       (CONS 10 $linepoint1) ;End Point
                                       (CONS 10 $linepoint2) ;End of Cog
                                   )
                           )
             )
            )

            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Case Top Hook                                                               ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "TOPHOOK") (= $response "TH"))
             (SETQ $linepoint1 (POLAR $intersectionpoint
                                      $angle
                                      (+
                                          (/
                                              (* (GETVAR "DIMSCALE") (/ 150.00 100.00))
                                              2
                                          )
                                          (* (GETVAR "DIMSCALE") (/ 150.00 100.00))
                                      )
                               )
                   $linepoint2 (POLAR $linepoint1
                                      (+ $angle (degtorad 270))
                                      (* $direction (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
                               )
                   $linepoint3 (POLAR $linepoint2 $angle (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
             )
             (SETQ $entity (APPEND $entity
                                   (LIST
                                       '(90 . 4) ;Number of verticies
                                       (CONS 10 $newbarend) ;Start Point
                                       (CONS 10 $linepoint1) ;End Point
                                       (CONS 42 $direction) ;Arc
                                       (CONS 10 $linepoint2) ;End of arc
                                       (CONS 10 $linepoint3) ;End of hook
                                   )
                           )
             )
            )
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ;;Case Top Step                                                               ;;
            ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
            ((OR (= $response "TOPSTEP") (= $response "TS"))
             ;;Calculate the new points
             (SETQ $linepoint1 (POLAR $intersectionpoint $angle (* (GETVAR "DIMSCALE") (/ 150.00 100.00)))
                   $linepoint2 (POLAR $linepoint1
                                      (+ $angle (degtorad 270))
                                      (* $direction (* (GETVAR "DIMSCALE") (/ 300.00 100.00)))
                               )
                   $linepoint3 (POLAR $linepoint2
                                      (+ $angle (degtorad 180))
                                      (* (GETVAR "DIMSCALE") (/ 300.00 100.00))
                               )
             )

             ;;Make a new bar polyline using the same settings
             (SETQ $entity (APPEND $entity
                                   (LIST
                                       '(90 . 3) ;Number of verticies
                                       (CONS 10 $newbarend) ;Start Point
                                       (CONS 10 $linepoint1) ;End Point
                                       (CONS 10 $linepoint2) ;Base of Step
                                       (CONS 10 $linepoint3) ;Step Landing
                                   )
                           )
             )
            )
        )
        ;;If the user didn't cancel, make the bar
        (IF (NOT (OR (= $response "CANCEL") (= $response "Q")))
            (PROGN
                ;;Append the Bar Color and LineType if required
                (IF $barcolor
                    (SETQ $entity (APPEND $entity (LIST (CONS 62 $barcolor))))
                )
                (IF $barlinetype
                    (SETQ $entity (APPEND $entity (LIST (CONS 6 $barlinetype))))
                )
                ;;Remove the existing bar
                (ENTDEL (CAR (NENTSELP $barpoint)))
                ;;Make the bar line
                (ENTMAKE $entity)

            )

        )
    )
    (SETQ *error* $olderror)
    (PRINC)
)