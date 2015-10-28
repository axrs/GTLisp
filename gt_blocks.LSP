(DEFUN gtblocks:tagreplace (sblock
                            sprompt
                            stag
                            /
                            ss1
                            entname
                            iacadblockreference2
                            attobjlst
                            iacadblock3
                            promptstring
                           )
    (SETQ ss1 nil)
    (SETQ ss1 (SSGET "X"
                     (LIST (CONS 0 "INSERT")
                           (CONS 2 sblock)
                           (CONS 410 (GETVAR "CTAB"))
                     )
              )
    )
    (IF ss1
        (PROGN
            (SETQ entname (SSNAME ss1 0))
            (SETQ iacadblockreference2 (VLAX-ENAME->VLA-OBJECT entname))
            (IF (= (VLA-GET-HASATTRIBUTES iacadblockreference2) :VLAX-TRUE)
                (SETQ attobjlst (VLAX-SAFEARRAY->LIST
                                    (VARIANT-VALUE
                                        (VLA-GETATTRIBUTES iacadblockreference2)
                                    )
                                )
                )
                ()
            )
            (SETQ iacadblock3
                     (VLA-ITEM (VLA-GET-BLOCKS
                                   (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT))
                               )
                               sblock
                     )
            )
            (FOREACH attrib attobjlst
                (VLAX-FOR promptstring iacadblock3
                    (IF (= (VLA-GET-OBJECTNAME promptstring)
                           "AcDbAttributeDefinition"
                        )
                        (PROGN
                            (IF (= (VLA-GET-PROMPTSTRING promptstring) sprompt)
                                (PROGN
                                    (IF (= (VLA-GET-TAGSTRING promptstring)
                                           (VLA-GET-TAGSTRING attrib)
                                        )
                                        (PROGN
                                            (VLA-PUT-TAGSTRING promptstring stag)
                                            (VLA-PUT-TAGSTRING attrib stag)
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    (PRINC)
)


;;----------------=={ get block attribute }==------------------;;
;;                                                             ;;
;;  Gets an attribute value from a block on a specified layout.;;
;;-------------------------------------------------------------;;
;;  Usage: (gtblocks:getattribute "Block" "Tag" "S-01")        ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  String of the attribute text (if found) or nil.            ;;
;;-------------------------------------------------------------;;
;;  Restrictions:                                              ;;
;;  Requires the use of the VisualLisp enviromnent.            ;;
;;  Will not work with Dynamic Blocks.                         ;;
;;  This method also assumes that there is only one block on   ;;
;;  the specified layout to search (i.e. a title block).       ;;
;;-------------------------------------------------------------;;

(DEFUN gtblocks:getattribute ($block
                              $tag
                              $layout
                              /
                              $filter
                              $val
                              $ss1
                              $attributes
                              $arrib
                              $titletext
                              $entname
                             )
    (VL-LOAD-COM)
    (IF (= nil $layout)
        (SETQ $layout (GETVAR "CTAB"))
    )

    (SETQ $filter (LIST (CONS 0 "INSERT") (CONS 410 $layout)))
    (SETQ $filter (APPEND $filter (gt:dyn-ssfilter $block)))
    (SETQ $ss1 (SSGET "x" $filter))
    (SETQ $entname (SSNAME $ss1 0))
    (SETQ $titletext (VLAX-ENAME->VLA-OBJECT $entname))
    (SETQ $attributes (VLAX-INVOKE $titletext "GetAttributes"))
    (FOREACH $attrib $attributes
        (IF
            (= (VLA-GET-TAGSTRING $attrib) $tag)
               (SETQ $val (VLA-GET-TEXTSTRING $attrib))
        )
    )
    $val
)

;;------------------=={ block to height }==--------------------;;
;;                                                             ;;
;;  Moves a block insertion point to the tag reference height. ;;
;;-------------------------------------------------------------;;
;;  Usage: (blocktoheight "Block Name" "Tag")                  ;;
;;-------------------------------------------------------------;;
(DEFUN gtblocks:blocktoheight
                              ($block
                               $tag
                               /
                               $ss
                               $i
                               $entity
                               $dxflist
                               $vlentity
                               $attrib
                               $attributes
                               $file
                               $outputlist
                              )
    (SETQ $ss
             (SSGET "X"
                    (APPEND (LIST (CONS 0 "INSERT"))
                            (gt:dyn-ssfilter $block)
                            (LIST (CONS 410 (GETVAR "ctab")))
                    )
             )
    )
    (SETQ $i 0)
    ;;Iterate through the selection set
    (WHILE (< $i (SSLENGTH $ss))
        (SETQ $entity (SSNAME $ss $i))
        (SETQ $dxflist (ENTGET $entity))
        (SETQ $location (CDR (ASSOC 10 $dxflist)))
        ;;Obtain the point value from the block reference
        (SETQ $vlentity (VLAX-ENAME->VLA-OBJECT $entity))
        (SETQ $attributes (VLAX-INVOKE $vlentity "GetAttributes"))
        (SETQ $val nil)
        (FOREACH $attrib $attributes
            (IF
                (= (STRCASE (VLA-GET-TAGSTRING $attrib)) (STRCASE $tag))
                   ;;Change entity height
                   (PROGN
                       (SETQ $val (ATOF (VLA-GET-TEXTSTRING $attrib)))
                       (SETQ $dxflist
                                (SUBST (CONS 10
                                             (LIST (NTH 0 (CDR (ASSOC 10 $dxflist)))
                                                   (NTH 1 (CDR (ASSOC 10 $dxflist)))
                                                   $val
                                             )
                                       )
                                       (ASSOC 10 $dxflist)
                                       $dxflist
                                )
                       )
                       (ENTMOD $dxflist)
                       (ENTUPD $entity)
                   )
            )
        )
        (SETQ $i (+ $i 1))
    )
    (PRINC)
)

(DEFUN gtblocks:pointstocsv
                            ($layer
                             $block
                             $tag
                             /
                             $ss
                             $i
                             $entity
                             $dxflist
                             $vlentity
                             $attrib
                             $attributes
                             $file
                             $outputlist
                            )
    (SETQ $ss
             (SSGET "X"
                    (APPEND (LIST (CONS 0 "INSERT") (CONS 8 $layer))
                            (gt:dyn-ssfilter $block)
                            (LIST (CONS 410 (GETVAR "ctab")))
                    )
             )
    )
    (SETQ $i 0)
    (IF
        (SETQ
            $file (OPEN (STRCAT (GETVAR "DWGPREFIX")
                                "setoutpoints "
                                (gtmisc:getdatecustom "YYYYMMDD")
                                ".csv"
                        )
                        "w"
                  )
        )
           (PROGN
               ;;Iterate through the selection set
               (WHILE (< $i (SSLENGTH $ss))
                   (SETQ $entity (SSNAME $ss $i))
                   (SETQ $dxflist (ENTGET $entity))
                   (SETQ $location (CDR (ASSOC 10 $dxflist)))
                   ;;Obtain the point value from the block reference
                   (SETQ $vlentity (VLAX-ENAME->VLA-OBJECT $entity))
                   (SETQ $attributes (VLAX-INVOKE $vlentity "GetAttributes"))
                   (SETQ $val nil)
                   (FOREACH $attrib $attributes
                       (IF
                           (= (VLA-GET-TAGSTRING $attrib) $tag)
                              (SETQ $val (VLA-GET-TEXTSTRING $attrib))
                       )
                   )
                   (SETQ $outputlist
                            (APPEND (LIST (STRCAT $val
                                                  ","
                                                  (RTOS (NTH 0 $location))
                                                  ","
                                                  (RTOS (NTH 1 $location))
                                          )
                                    )
                                    $outputlist
                            )
                   )
                   ;;(WRITE-LINE (STRCAT $val "," (RTOS (NTH 0 $location)) "," (RTOS (NTH 1 $location))) $file)
                   (SETQ $i (+ $i 1))
               )
           )
    )
    (SETQ $outputlist (gtmisc:stringtolist $outputlist))
    (FOREACH $point $outputlist
        (WRITE-LINE $point $file)
    )
    (CLOSE $file)
    (PRINC (STRCAT "\nPoints saved to: "
                   (GETVAR "DWGPREFIX")
                   "setoutpoints "
                   (gtmisc:getdatecustom "YYYYMMDD")
                   ".csv"
           )
    )
)

(DEFUN gt:dyn-is-p (bn / gt$return)
    (COND
        ((AND (= (TYPE bn) 'ename)
              (VLAX-PROPERTY-AVAILABLE-P
                  (VLAX-ENAME->VLA-OBJECT bn)
                  'isdynamicblock
              )
         )
         (SETQ gt$return
                  (VLA-GET-ISDYNAMICBLOCK (VLAX-ENAME->VLA-OBJECT bn))
         )
        )
        ((AND (= (TYPE bn) 'vla-object)
              (vlax-property-avilable-p bn 'isdynamicblock)
         )
         (SETQ gt$return (VLA-GET-ISDYNAMICBLOCK bn))
        )
        ((AND (= (TYPE bn) 'str)
              (TBLSEARCH "BLOCK" bn)
         )
         (SETQ gt$return
                  (VLA-GET-ISDYNAMICBLOCK
                      (VLA-ITEM
                          (VLA-GET-BLOCKS
                              (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT))
                          )
                          (VLAX-MAKE-VARIANT bn VLAX-VBSTRING)
                      )
                  )
         )
        )
        (T (SETQ gt$return :VLAX-FALSE))
    )
    (COND
        ((= gt$return :VLAX-TRUE) T)
        ((= gt$return :VLAX-FALSE) nil)
        (T nil)
    )
)

(DEFUN gt:dyn-ssfilter (bn / gt$filter gt$object gt$ss gt$temp)
    (SETQ gt$filterlist (LIST (CONS 0 "INSERT") (CONS 2 "`*U*")))
    (IF (SETQ gt$ss (SSGET "X" gt$filterlist))
        (PROGN
            (REPEAT (SSLENGTH gt$ss)
                (IF (AND (gt:dyn-is-p (SSNAME gt$ss 0))
                         (WCMATCH (STRCASE (VLA-GET-EFFECTIVENAME
                                               (SETQ gt$object
                                                        (VLAX-ENAME->VLA-OBJECT (SSNAME gt$ss 0))
                                               )
                                           )
                                  )
                                  (STRCASE bn)
                         )
                    )
                    (SETQ gt$filter
                             (APPEND gt$filter
                                     (LIST (VLA-GET-NAME gt$object))
                             )
                    )
                )
                (SSDEL (SSNAME gt$ss 0) gt$ss)
            )
        )
    )
    (IF gt$filter
        (APPEND (LIST (CONS -4 "<OR"))
                (MAPCAR '(LAMBDA (x)
                             (CONS 2 (STRCAT "`" x))
                         )
                        gt$filter
                )
                (LIST (CONS 2 bn) (CONS -4 "OR>"))
        )
        (LIST (CONS 2 bn))
    )
)



(DEFUN gtblocks:deletereference
                                ($filter / $blk $xrefs $name $entity $ss $i)
    (WHILE (SETQ $blk (TBLNEXT "BLOCK" (NOT $blk)))
        (IF (> (LOGAND 4 (CDR (ASSOC 70 $blk))) 0)
            (PROGN
                (SETQ $name  (CDR (ASSOC 2 $blk))
                      $xrefs (IF $xrefs
                                 (STRCAT $xrefs "," $name)
                                 $name
                             )
                )
            )
        )
    )
    (IF (NOT (= $xrefs nil))
        (PROGN
            (SETQ $ss (SSGET "X" (LIST '(0 . "INSERT") (CONS 2 $xrefs))))
            (SETQ $i 0)
            (WHILE (< $i (SSLENGTH $ss))
                (SETQ $entity (SSNAME $ss $i))
                (SETQ $name (CDR (ASSOC 2 (ENTGET $entity))))

                (IF (WCMATCH $name $filter)
                    (PROGN
                        (VLAX-INVOKE-METHOD
                            (VLAX-ENAME->VLA-OBJECT (SSNAME $ss $i))
                            'delete
                        )
 ;(ENTDEL $entity)
                    )
                )
                (SETQ $i (+ 1 $i))
            )
        )
    )

)