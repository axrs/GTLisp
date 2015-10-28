(DEFUN gtsections:drawsection (/	   $head       $tail
			       $headblock  $tailblock  $start
			       $end	   $direction  $flag
			       $flip	   $combination
			       $entityt	   $entityh
			      )
  (SETQ $flag T)
  (SETQ $flip -1)

  (SETQ $head (gtblocks:createsectionhead))
  (SETQ $tail (gtblocks:createsectiontail))
  (SETQ $start (GETPOINT "\nSpecify start point: "))

  ;;Get head/tail positions
  (COMMAND "_.-insert"
	   $head
	   $start
	   (GETVAR "dimscale")
	   (GETVAR "dimscale")
	   0
  )
  (SETQ $headblock (VLAX-ENAME->VLA-OBJECT (ENTLAST)))
  (COMMAND "_.-insert"
	   $tail
	   $start
	   (* -1 (GETVAR "dimscale"))
	   (GETVAR "dimscale")
	   0
  )
  (SETQ $tailblock (VLAX-ENAME->VLA-OBJECT (ENTLAST)))


  (SETQ $combination 0)
  (WHILE $flag
    (SETQ g (GRREAD T))
    (COND
      ;;Exit
      ((= 3 (CAR g))
       (SETQ $flag nil)
      )

      ;;Mouse Move, rotate blocks
      ((= 5 (CAR g))
       (SETQ g (gtsections:orthogrread $start (CADR g)))
       (REDRAW)
       (GRDRAW $start g 1 1)
       (IF (= 1 $flip)
	 (gtsections:grdraw
	   $headblock
	   $tailblock
	   (+ PI (ANGLE $start g))
	   g
	 )
	 (gtsections:grdraw $headblock $tailblock (ANGLE $start g) g)
       )
      )

      ;;Keyboard Press (TAB)
      ((AND (= 2 (CAR g)) (= 9 (CADR g)))
       (SETQ $flip (* $flip -1))

       ;;(VLAX-PUT-PROPERTY $headblock 'rotation (+ (VLAX-GET-PROPERTY $headblock 'rotation) PI))
       (VLAX-PUT-PROPERTY
	 $headblock
	 'XScaleFactor
	 (* -1 (VLAX-GET-PROPERTY $headblock 'XScaleFactor))
       )
       ;;(VLAX-PUT-PROPERTY $tailblock 'rotation (+ (VLAX-GET-PROPERTY $headblock 'rotation) PI))
       (VLAX-PUT-PROPERTY
	 $tailblock
	 'XScaleFactor
	 (* -1 (VLAX-GET-PROPERTY $tailblock 'XScaleFactor))
       )

      )
      ;;Orthomode toggle
      ((AND (= 2 (CAR g)) (= 15 (CADR g)))
       (SETVAR 'orthomode (- 1 (GETVAR 'orthomode)))
      )

      ;;Right Click - Change symbol combinations
      ((or
	 (= 11 (CAR g))
	 (= 25 (CAR g))
	   (AND (= 2 (CAR g))(= 13 (CADR g)))
	 (AND (= 2 (CAR g))(= 32 (CADR g)))
	   )
       (SETQ $combination (1+ $combination))
       (IF (< 3 $combination)
	 (SETQ $combination 0)
       )
       (COND
	 ;;Head/tail
	 ((= 0 $combination)
	  (VLAX-PUT-PROPERTY $headblock 'name "GT-Sect-Head")
	 )
	 ;;Head/head
	 ((= 1 $combination)
	  (VLAX-PUT-PROPERTY $tailblock 'name "GT-Sect-Head")
	 )
	 ;;Tail/Head
	 ((= 2 $combination)
	  (VLAX-PUT-PROPERTY $headblock 'name "GT-Sect-Tail")
	 )
	 ;;Tail/Tail
	 ((= 3 $combination)
	  (VLAX-PUT-PROPERTY $tailblock 'name "GT-Sect-Tail")
	 )
       )
      )
    )
  )
  (IF
    (AND $headblock $tailblock)
     (SETQ
       *object-reactor-headblock
	(VLR-OBJECT-REACTOR
	  (LIST $headblock)
	  $tailblock
	  '((:VLR-MODIFIED . update-block))
	)
       *object-reactor-tailblock
	(VLR-OBJECT-REACTOR
	  (LIST $tailblock)
	  $headblock
	  '((:VLR-MODIFIED . update-block))
	)
     )
  )
  (PRINC)
)

;;Block 1 is the block modified, block 2 is the block to move
(DEFUN update-block (block1 reactor params / block2)
  (SETQ block2 (VLR-DATA reactor))
  (IF
    (AND
      (VLAX-READ-ENABLED-P block1)
      (VLAX-WRITE-ENABLED-P block2)
      (NOT (OR (VLAX-ERASED-P block1) (VLAX-ERASED-P block2)))
    )
     (PROGN
       (SETQ $point1 (VLAX-VARIANT-VALUE
		       (VLAX-GET-PROPERTY block1 'insertionpoint)
		     )
       )
       (SETQ $point2 (VLAX-VARIANT-VALUE
		       (VLAX-GET-PROPERTY block2 'insertionpoint)
		     )
       )
       (VLAX-PUT-PROPERTY
	 block2
	 'rotation
	 (+ (ANGLE (LIST (VLAX-SAFEARRAY-GET-ELEMENT $point1 0)
			 (VLAX-SAFEARRAY-GET-ELEMENT $point1 1)
		   )
		   (LIST (VLAX-SAFEARRAY-GET-ELEMENT $point2 0)
			 (VLAX-SAFEARRAY-GET-ELEMENT $point2 1)
		   )
	    )
	    PI
	 )
       )
     )
  )
  (PRINC)
)


;;;Rotates the blocks with the mouse
(DEFUN gtsections:grdraw
       ($head $tail $rotation $base / $entityh $entityt)
  (VLAX-PUT-PROPERTY $head 'rotation $rotation)
  (VLAX-PUT-PROPERTY $tail 'rotation $rotation)
  (VLA-PUT-INSERTIONPOINT $tail (VLAX-3D-POINT $base))
)

(DEFUN c:gttest	()
  (gtsections:drawsection)
)

;;Forces the grread to be to 90 degrees or not
(DEFUN gtsections:orthogrread (base point)
  (IF (ZEROP (GETVAR 'orthomode))
    point
    (APPLY 'POLAR
	   (CONS base
		 (
		  (LAMBDA (n / a x z)
		    (SETQ x (- (CAR (TRANS point 0 n)) (CAR (TRANS base 0 n)))
			  z (- (CADDR (TRANS point 0 n)) (CADDR (TRANS base 0 n)))
			  a (ANGLE '(0. 0. 0.) n)
		    )
		    (IF	(< (ABS z) (ABS x))
		      (LIST (+ a (/ PI 2.)) x)
		      (LIST a z)
		    )
		  )
		   (TRANS (GETVAR 'ucsxdir) 0 1)
		 )
	   )
    )
  )
)

;;Returns the absolute distance between poinrt
(DEFUN gtsections:absolutdistance ($start $end / $xdist $ydist)
  (SETQ $xdist (- (CAR $start) (CAR $end)))
  (SETQ $ydist (- (CADR $start) (CADR $end)))
  (IF (= 0 $ydist)
    $xdist
    (/ $xdist $ydist)
  )
)