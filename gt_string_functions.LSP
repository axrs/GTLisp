;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTStrings:MD5Hash</function>
<sumary>Creates an MD5 hash of the specified message</summary>
<param name="message">String to hash</param>
<returns>md5 hash of the specified string</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtstrings:md5hash (message
						  /
						  h0
						  h1
						  h2
						  h3
						  w
						  a
						  b
						  c
						  d
						  temp
						  asciilist
						  msglength
						  rem64
						  bytes2word
						  little-endian
						  ff
						  gg
						  hh
						  ii
						  int-and
						  int-a_and_~b
						  int-~a_and_b
						  int-xor
						  int-or
						  int-a_or_~b
						  integer->binary-list
						  binary-list->zahl
						  int32bits
						  int64bits
						  rotateleft32
						  int2hex
						 )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN int2hex (zahl / string i a)
	(IF	(AND (NUMBERP zahl)
			 (SETQ zahl (FIX zahl))
		)
	  (PROGN
		(IF	(ZEROP zahl)
		  (SETQ string "0")
		  (SETQ string "")
		)
		(WHILE (< 0.9999 zahl)
		  (SETQ a (RTOS (/ (FLOAT zahl) 16) 2 1))
		  (IF (VL-STRING-SEARCH "." a)
			(SETQ a (SUBSTR a 1 (- (STRLEN a) 2)))
		  )
		  (SETQ i (FIX (- zahl (* (ATOF a) 16))))
		  (SETQ	string (STRCAT (IF (> i 9)
								 (CHR (+ 87 i)) ;_55 für "A"
								 (CHR (+ 48 i))
							   )
							   string
					   )
		  )
		  (SETQ zahl (ATOF a))
		)
	  )
	)
	string
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN integer->binary-list (zahl countbits / a liste bitlist bit i)
	(IF	(AND (NUMBERP zahl)
			 (SETQ zahl (FIX zahl))
			 (MEMBER countbits '(8 16 32 64 128))
		)
	  (PROGN
		(WHILE (< 0.99999 zahl)
		  (SETQ a (RTOS (/ (FLOAT zahl) 2.0) 2 1))
		  (IF (VL-STRING-SEARCH "." a)
			(SETQ a (SUBSTR a 1 (- (STRLEN a) 2)))
		  )
		  (SETQ i (FIX (- zahl (* (ATOF a) 2))))
		  (SETQ liste (CONS i liste))
		  (SETQ zahl (ATOF a))
		)
		(SETQ liste (REVERSE liste))
		(REPEAT	countbits
		  (OR (SETQ bit (CAR liste)) (SETQ bit 0))
		  (SETQ bitlist (CONS bit bitlist))
		  (SETQ liste (CDR liste))
		)
		bitlist
	  )
	)
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN binary-list->zahl (binary-list / zahl i)
	(IF	(AND (= (TYPE binary-list) 'LIST)
			 (VL-EVERY '(LAMBDA (x) (MEMBER x '(0 1))) binary-list)
		)
	  (PROGN
		(SETQ i -1)
		(SETQ zahl 0)
		(SETQ binary-list (REVERSE binary-list))
		(REPEAT	(LENGTH binary-list)
		  (SETQ zahl (+ zahl (* (EXPT 2.0 (SETQ i (1+ i))) (CAR binary-list))))
		  (SETQ binary-list (CDR binary-list))
		)
		(FIX zahl)
	  )
	)
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN int32bits (zahl) (integer->binary-list zahl 32))
  (DEFUN int64bits (zahl) (integer->binary-list zahl 64))
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN rotateleft32 (zahl bits / bitlist)
	(IF	(AND (= (TYPE bits) 'int)
			 (SETQ bitlist (integer->binary-list zahl 32))
		)
	  (PROGN
		(REPEAT	bits
		  (SETQ bitlist (REVERSE (CONS (CAR bitlist) (REVERSE (CDR bitlist)))))
		)
		(binary-list->zahl bitlist)
	  )
	)
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN int-and (a b)
	(IF	(AND (SETQ a (int32bits a)) (SETQ b (int32bits b)))
	  (binary-list->zahl
		(MAPCAR	'(LAMBDA (x y)
				   (IF (AND (= x 1) (= y 1))
					 1
					 0
				   )
				 )
				a
				b
		)
	  )
	)
  )
  (DEFUN int-a_and_~b (a b)
	(IF	(AND (SETQ a (int32bits a)) (SETQ b (int32bits b)))
	  (binary-list->zahl
		(MAPCAR	'(LAMBDA (x y)
				   (IF (AND (= x 1) (= y 0))
					 1
					 0
				   )
				 )
				a
				b
		)
	  )
	)
  )
  (DEFUN int-~a_and_b (a b)
	(IF	(AND (SETQ a (int32bits a)) (SETQ b (int32bits b)))
	  (binary-list->zahl
		(MAPCAR	'(LAMBDA (x y)
				   (IF (AND (= x 0) (= y 1))
					 1
					 0
				   )
				 )
				a
				b
		)
	  )
	)
  )
  (DEFUN int-xor (a b)
	(IF	(AND (SETQ a (int32bits a)) (SETQ b (int32bits b)))
	  (binary-list->zahl
		(MAPCAR	'(LAMBDA (x y)
				   (IF (/= x y)
					 1
					 0
				   )
				 )
				a
				b
		)
	  )
	)
  )
  (DEFUN int-or	(a b)
	(IF	(AND (SETQ a (int32bits a)) (SETQ b (int32bits b)))
	  (binary-list->zahl
		(MAPCAR	'(LAMBDA (x y)
				   (IF (OR (= x 1) (= y 1))
					 1
					 0
				   )
				 )
				a
				b
		)
	  )
	)
  )
  (DEFUN int-a_or_~b (a b)
	(IF	(AND (SETQ a (int32bits a)) (SETQ b (int32bits b)))
	  (binary-list->zahl
		(MAPCAR	'(LAMBDA (x y)
				   (IF (OR (= x 1) (= y 0))
					 1
					 0
				   )
				 )
				a
				b
		)
	  )
	)
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN little-endian (zahl countbits / bitlist byte bytelist)
	(IF	(AND (SETQ bitlist (integer->binary-list zahl 64))
			 (SETQ bitlist (REVERSE bitlist))
			 (MEMBER countbits '(8 16 32 64))
		)
	  (PROGN
		(REPEAT	(/ countbits 8)
		  (SETQ byte nil)
		  (REPEAT 8
			(SETQ byte (CONS (CAR bitlist) byte))
			(SETQ bitlist (CDR bitlist))
		  )
		  (SETQ bytelist (CONS byte bytelist))
		)
		(MAPCAR 'binary-list->zahl (REVERSE bytelist))
	  )
	)
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN bytes2word	(b1 b2 b3 b4)
	(binary-list->zahl
	  (APPEND
		(integer->binary-list b4 8)
		(integer->binary-list b3 8)
		(integer->binary-list b2 8)
		(integer->binary-list b1 8)
	  )
	)
  )
;;; - -------------------------------------------------------------------------- - ;
  (DEFUN ff	(aa bb cc dd xx ss tt)
	(+ (rotateleft32
		 (+ aa (int-or (int-and bb cc) (int-a_and_~b dd bb)) xx tt)
		 ss
	   )
	   bb
	)
  )
  (DEFUN gg	(aa bb cc dd xx ss tt)
	(+ (rotateleft32
		 (+ aa (int-or (int-and bb dd) (int-a_and_~b cc dd)) xx tt)
		 ss
	   )
	   bb
	)
  )
  (DEFUN hh	(aa bb cc dd xx ss tt)
	(+ (rotateleft32 (+ aa (int-xor bb (int-xor cc dd)) xx tt) ss)
	   bb
	)
  )
  (DEFUN ii	(aa bb cc dd xx ss tt)
	(+ (rotateleft32
		 (+ aa (int-xor cc (int-a_or_~b bb dd)) xx tt)
		 ss
	   )
	   bb
	)
  )
;;; - ------------- MAIN ------------------------------------------------------- - ;
  (IF (= (TYPE message) 'str)
	(PROGN
	  (SETQ h0 1732584193)
	  (SETQ h1 4023233417)
	  (SETQ h2 2562383102)
	  (SETQ h3 271733878)
	  (SETQ asciilist (VL-STRING->LIST message)) ;_-> ASCII-Code-Liste erstellen
	  (SETQ msglength (LENGTH asciilist)) ;_bitlength = MSGlength*8 da je Zeichen 8 Bit
	  (SETQ asciilist (CONS 128 (REVERSE asciilist))) ;_Bit "1" und 7 Bit"0" erweitern
 ;_weitere BIT "0" anhängen bis (MSG-Bitlengt - 64) durch 512  teilbar  ist, d.h.
 ;_Erweitern mit "0" (= 8x Bit "0")  bis  (MSGLENGTH - 8) durch 64  teilbar  ist.
	  (REPEAT (- 64
				 (IF (= 0 (SETQ rem64 (REM (+ msglength 9) 64)))
				   64
				   rem64
				 )
			  )
		(SETQ asciilist (CONS 0 asciilist))
	  )
 ;_MESSAGE um MSG-Bitlengt=MSGLENGTHx8 als 64-Bit little-endian Integer erweitern
	  (SETQ	asciilist (APPEND (REVERSE asciilist)
							  (little-endian (* msglength 8) 64)
					  )
	  )
 ;_ Aufteilung  der  ASCII-LISTE in aufeinander  folgenden  512-Bit Blöcken sowie
 ;_ Unterteilung jeden Blockes in 16  32-bit little-endian Worte W(i), 0 < i < 15
	  (WHILE asciilist ;_ Solange 512 BIT-Block = 64 CHAR-CODE-Block ...
		(SETQ w nil) ;_neuer leerer Block 16x32 BLOCK
		(REPEAT	16 ;_und den mit 16 x in 32Bit-little-endian gewandelten auffüllen
		  (SETQ	w (CONS	(bytes2word
						  (CAR asciilist)
						  (CADR asciilist)
						  (CADDR asciilist)
						  (CADDDR asciilist)
						)
						w
				  )
		  )
		  (SETQ asciilist (CDDDDR asciilist))
		)
		(SETQ w (REVERSE w)) ;_wegen Zusammenfügen mit cons wieder "reversen"
		(SETQ a	h0
			  b	h1
			  c	h2
			  d	h3
		) ;_Initialisiere den Hash-Wert für diesen Block:
		(SETQ a (ff a b c d (NTH 0 w) 7 3614090360)) ;_ = 0xD76AA478  NR:  1
		(SETQ d (ff d a b c (NTH 1 w) 12 3905402710)) ;_ = 0xE8C7B756  NR:  2
		(SETQ c (ff c d a b (NTH 2 w) 17 606105819)) ;_ = 0x242070DB  NR:  3
		(SETQ b (ff b c d a (NTH 3 w) 22 3250441966)) ;_ = 0xC1BDCEEE  NR:  4
		(SETQ a (ff a b c d (NTH 4 w) 7 4118548399)) ;_ = 0xF57C0FAF  NR:  5
		(SETQ d (ff d a b c (NTH 5 w) 12 1200080426)) ;_ = 0x4787C62A  NR:  6
		(SETQ c (ff c d a b (NTH 6 w) 17 2821735955)) ;_ = 0xA8304613  NR:  7
		(SETQ b (ff b c d a (NTH 7 w) 22 4249261313)) ;_ = 0xFD469501  NR:  8
		(SETQ a (ff a b c d (NTH 8 w) 7 1770035416)) ;_ = 0x698098D8  NR:  9
		(SETQ d (ff d a b c (NTH 9 w) 12 2336552879)) ;_ = 0x8B44F7AF  NR: 10
		(SETQ c (ff c d a b (NTH 10 w) 17 4294925233)) ;_ = 0xFFFF5BB1  NR: 11
		(SETQ b (ff b c d a (NTH 11 w) 22 2304563134)) ;_ = 0x895CD7BE  NR: 12
		(SETQ a (ff a b c d (NTH 12 w) 7 1804603682)) ;_ = 0x6B901122  NR: 13
		(SETQ d (ff d a b c (NTH 13 w) 12 4254626195)) ;_ = 0xFD987193  NR: 14
		(SETQ c (ff c d a b (NTH 14 w) 17 2792965006)) ;_ = 0xA679438E  NR: 15
		(SETQ b (ff b c d a (NTH 15 w) 22 1236535329)) ;_ = 0x49B40821  NR: 16

		(SETQ a (gg a b c d (NTH 1 w) 5 4129170786)) ;_ = 0xF61E2562  NR: 17
		(SETQ d (gg d a b c (NTH 6 w) 9 3225465664)) ;_ = 0xC040B340  NR: 18
		(SETQ c (gg c d a b (NTH 11 w) 14 643717713)) ;_ = 0x265E5A51  NR: 19
		(SETQ b (gg b c d a (NTH 0 w) 20 3921069994)) ;_ = 0xE9B6C7AA  NR: 20
		(SETQ a (gg a b c d (NTH 5 w) 5 3593408605)) ;_ = 0xD62F105D  NR: 21
		(SETQ d (gg d a b c (NTH 10 w) 9 38016083)) ;_ = 0x02441453  NR: 22
		(SETQ c (gg c d a b (NTH 15 w) 14 3634488961)) ;_ = 0xD8A1E681  NR: 23
		(SETQ b (gg b c d a (NTH 4 w) 20 3889429448)) ;_ = 0xE7D3FBC8  NR: 24
		(SETQ a (gg a b c d (NTH 9 w) 5 568446438)) ;_ = 0x21E1CDE6  NR: 25
		(SETQ d (gg d a b c (NTH 14 w) 9 3275163606)) ;_ = 0xC33707D6  NR: 26
		(SETQ c (gg c d a b (NTH 3 w) 14 4107603335)) ;_ = 0xF4D50D87  NR: 27
		(SETQ b (gg b c d a (NTH 8 w) 20 1163531501)) ;_ = 0x455A14ED  NR: 28
		(SETQ a (gg a b c d (NTH 13 w) 5 2850285829)) ;_ = 0xA9E3E905  NR: 29
		(SETQ d (gg d a b c (NTH 2 w) 9 4243563512)) ;_ = 0xFCEFA3F8  NR: 30
		(SETQ c (gg c d a b (NTH 7 w) 14 1735328473)) ;_ = 0x676F02D9  NR: 31
		(SETQ b (gg b c d a (NTH 12 w) 20 2368359562)) ;_ = 0x8D2A4C8A  NR: 32

		(SETQ a (hh a b c d (NTH 5 w) 4 4294588738)) ;_ = 0xFFFA3942  NR: 33
		(SETQ d (hh d a b c (NTH 8 w) 11 2272392833)) ;_ = 0x8771F681  NR: 34
		(SETQ c (hh c d a b (NTH 11 w) 16 1839030562)) ;_ = 0x6D9D6122  NR: 35
		(SETQ b (hh b c d a (NTH 14 w) 23 4259657740)) ;_ = 0xFDE5380C  NR: 36
		(SETQ a (hh a b c d (NTH 1 w) 4 2763975236)) ;_ = 0xA4BEEA44  NR: 37
		(SETQ d (hh d a b c (NTH 4 w) 11 1272893353)) ;_ = 0x4BDECFA9  NR: 38
		(SETQ c (hh c d a b (NTH 7 w) 16 4139469664)) ;_ = 0xF6BB4B60  NR: 39
		(SETQ b (hh b c d a (NTH 10 w) 23 3200236656)) ;_ = 0xBEBFBC70  NR: 40
		(SETQ a (hh a b c d (NTH 13 w) 4 681279174)) ;_ = 0x289B7EC6  NR: 41
		(SETQ d (hh d a b c (NTH 0 w) 11 3936430074)) ;_ = 0xEAA127FA  NR: 42
		(SETQ c (hh c d a b (NTH 3 w) 16 3572445317)) ;_ = 0xD4EF3085  NR: 43
		(SETQ b (hh b c d a (NTH 6 w) 23 76029189)) ;_ = 0x04881D05  NR: 44
		(SETQ a (hh a b c d (NTH 9 w) 4 3654602809)) ;_ = 0xD9D4D039  NR: 45
		(SETQ d (hh d a b c (NTH 12 w) 11 3873151461)) ;_ = 0xE6DB99E5  NR: 46
		(SETQ c (hh c d a b (NTH 15 w) 16 530742520)) ;_ = 0x1FA27CF8  NR: 47
		(SETQ b (hh b c d a (NTH 2 w) 23 3299628645)) ;_ = 0xC4AC5665  NR: 48

		(SETQ a (ii a b c d (NTH 0 w) 6 4096336452)) ;_ = 0xF4292244  NR: 49
		(SETQ d (ii d a b c (NTH 7 w) 10 1126891415)) ;_ = 0x432AFF97  NR: 50
		(SETQ c (ii c d a b (NTH 14 w) 15 2878612391)) ;_ = 0xAB9423A7  NR: 51
		(SETQ b (ii b c d a (NTH 5 w) 21 4237533241)) ;_ = 0xFC93A039  NR: 52
		(SETQ a (ii a b c d (NTH 12 w) 6 1700485571)) ;_ = 0x655B59C3  NR: 53
		(SETQ d (ii d a b c (NTH 3 w) 10 2399980690)) ;_ = 0x8F0CCC92  NR: 54
		(SETQ c (ii c d a b (NTH 10 w) 15 4293915773)) ;_ = 0xFFEFF47D  NR: 55
		(SETQ b (ii b c d a (NTH 1 w) 21 2240044497)) ;_ = 0x85845DD1  NR: 56
		(SETQ a (ii a b c d (NTH 8 w) 6 1873313359)) ;_ = 0x6FA87E4F  NR: 57
		(SETQ d (ii d a b c (NTH 15 w) 10 4264355552)) ;_ = 0xFE2CE6E0  NR: 58
		(SETQ c (ii c d a b (NTH 6 w) 15 2734768916)) ;_ = 0xA3014314  NR: 59
		(SETQ b (ii b c d a (NTH 13 w) 21 1309151649)) ;_ = 0x4E0811A1  NR: 60
		(SETQ a (ii a b c d (NTH 4 w) 6 4149444226)) ;_ = 0xF7537E82  NR: 61
		(SETQ d (ii d a b c (NTH 11 w) 10 3174756917)) ;_ = 0xBD3AF235  NR: 62
		(SETQ c (ii c d a b (NTH 2 w) 15 718787259)) ;_ = 0x2AD7D2BB  NR: 63
		(SETQ b (ii b c d a (NTH 9 w) 21 3951481745)) ;_ = 0xEB86D391  NR: 64
 ;_ Addiere den Hash-Wert des Blocks zur Summe der vorherigen Hashes:
		(SETQ h0 (+ h0 a))
		(SETQ h1 (+ h1 b))
		(SETQ h2 (+ h2 c))
		(SETQ h3 (+ h3 d))
	  )
	  (APPLY 'STRCAT
			 (APPEND (MAPCAR '(LAMBDA (x / y)
								(SETQ y (int2hex x))
								(IF	(= (STRLEN y) 1)
								  (STRCAT "0" y)
								  y
								)
							  )
							 (little-endian h0 32)
					 )
					 (MAPCAR '(LAMBDA (x / y)
								(SETQ y (int2hex x))
								(IF	(= (STRLEN y) 1)
								  (STRCAT "0" y)
								  y
								)
							  )
							 (little-endian h1 32)
					 )
					 (MAPCAR '(LAMBDA (x / y)
								(SETQ y (int2hex x))
								(IF	(= (STRLEN y) 1)
								  (STRCAT "0" y)
								  y
								)
							  )
							 (little-endian h2 32)
					 )
					 (MAPCAR '(LAMBDA (x / y)
								(SETQ y (int2hex x))
								(IF	(= (STRLEN y) 1)
								  (STRCAT "0" y)
								  y
								)
							  )
							 (little-endian h3 32)
					 )
			 )
	  )
	)
  )
)


;;--------------------=={ split string }==---------------------;;
;;                                                             ;;
;;  Splits a string of text at a specified delimiter.          ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $list (gtstrings:split "Some String" "S"))       ;;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse.                           ;;
;;  $delimeter - Character to split the string at.             ;;
;;  $list - list to return of the split string.                ;;
;;  $i - Current character parser count.                       ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  A list variable of strings stopping at the delimiter.      ;;
;;-------------------------------------------------------------;;
;;  Restrictions:                                              ;;
;;  Requires the use of the VisualLisp enviromnent.            ;;
;;-------------------------------------------------------------;;

(DEFUN gtstrings:vl-split ($string $delimeter / $list $i)
  ;;Iterate through the search string looking for the delimeter
  (WHILE (SETQ $i (VL-STRING-SEARCH $delimeter $string))
	(SETQ $list (CONS (SUBSTR $string 1 $i) $list))
	(SETQ $string (SUBSTR $string (+ 2 $i)))
  )
  ;;If the search string is empty
  (IF (= $string "")
	(SETQ $list (CONS "" $list))
	(SETQ $list (CONS $string $list))
  )
  ;;Return the found list of strings
  $list
)

(DEFUN gtstrings:split ($target
						$delimeter
						/
						$target_length	;Target Find Length
						$counter		;Counter
						$first_char		;First Character
						$current_char	;Current Character
						$first			;First String
						$return			;Return List
						$current		;Current Remainaing String
					   )
  (SETQ	$target_length
		 (STRLEN $target)
		$counter 1
		$first_char
		 0
		$first 0
  )
  (REPEAT $target_length
	(SETQ $current_char (SUBSTR $target $counter 1))
	(IF	(NOT (= $current_char $delimeter))
	  (PROGN
		(IF	(= $first_char 0)
		  (PROGN
			(SETQ $current $current_char)
			(SETQ $first_char 1)
		  )
		  (SETQ $current (STRCAT $current $current_char))
		)
	  )
	  (PROGN
		(IF	(= $first_char 0)
		  (SETQ $first_char 0)
		  (PROGN
			(IF	(= $first 0)
			  (PROGN
				(SETQ $return (LIST $current))
				(SETQ $first 1)
				(SETQ $first_char 0)
			  )
			  (PROGN
				(SETQ $return (APPEND $return (LIST $current)))
				(SETQ $first_char 0)
			  )
			)
		  )
		)
	  )
	)
	(IF	(= $counter $target_length)
	  (IF (NOT (= $current_char $delimeter))
		(SETQ $return (APPEND $return (LIST $current)))
	  )
	)
	(SETQ $counter (+ $counter 1))
  )
  (SETQ $return $return)
)


;;-------------------=={ string replace }==--------------------;;
;;                                                             ;;
;;  Replaces occurances of a string within a string.           ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtstrings:replace "Some String" "Search" "replace");;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse.                           ;;
;;  $search - string to search for within the $string.         ;;
;;  $replace - string to replace $search within the $string.   ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  A string with the 'Search' replaced with 'replace'.        ;;
;;-------------------------------------------------------------;;

(DEFUN gtstrings:replace ($string $search $replace / $temp)
  (SETQ $temp (gtstrings:find $string $search))
  (IF (NOT (NULL (CADR $temp)))
	(STRCAT (CAR $temp) $replace (CADR $temp))
	$string
  )
)


;;-------------------=={ string replace }==--------------------;;
;;                                                             ;;
;;  Replaces occurances of a string within a string.           ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtstrings:replace "Some String" "Search" "replace");;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse.                           ;;
;;  $search - string to search for within the $string.         ;;
;;  $replace - string to replace $search within the $string.   ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  A string with the 'Search' replaced with 'replace'.        ;;
;;-------------------------------------------------------------;;

(DEFUN gtstrings:replace2 ($string $search $replace / $temp)
  (SETQ $temp (gtstrings:find $string $search))
  (WHILE (NOT (NULL (CADR $temp)))
	(SETQ $temp	(gtstrings:find
				  (STRCAT (CAR $temp) $replace (CADR $temp))
				  $search
				)
	)
	(CAR $temp)
  )
  (CAR $temp)
)

;;---------------------=={ find string }==---------------------;;
;;                                                             ;;
;;  Finds occurances of a string within a string.              ;;
;;-------------------------------------------------------------;;
;;  Usage: (gtstrings:find "Some String" "Search")                ;;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse.                           ;;
;;  $search - string to search for within the $string.         ;;
;;  $i    - Current character position                         ;;
;;  $repeat - The remainder of the string to repeat through.   ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  A split list of the string with the search item removed.   ;;
;;-------------------------------------------------------------;;

(DEFUN gtstrings:find ($string $search / $i $repeat)
  (SETQ $i 1)
  (WHILE (<= $i (STRLEN $string))
	(IF	(= (SUBSTR $string $i (STRLEN $search)) $search)
	  (PROGN
		(SETQ $repeat (LIST	(SUBSTR $string 1 (1- $i))
							(SUBSTR $string (+ $i (STRLEN $search)))
					  )
		)
		(SETQ $i (1+ (STRLEN $string)))
	  )
	  (SETQ $i (1+ $i))
	)
  )
  (IF (NULL $repeat)
	(LIST $string nil)
	$repeat
  )
)


;;------------------=={ template String }==--------------------;;
;;                                                             ;;
;;  Parses an input string for templating variables inside '<>';;
;;  Predominately used when parsing the config file.           ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $list (gtstrings:template "<SOME:CONFIG:STRING>");;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse (from config file).        ;;
;;  $list - Variable holding the list of found templates.      ;;
;;  $i    - Holds the character position of the first '<'.     ;;
;;  $count - Holds the current character iteration.            ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  A list of the template structs within the string.          ;;
;;-------------------------------------------------------------;;
(DEFUN gtstrings:template ($string / $list)
  (SETQ $i nil)
  (SETQ $count 1)
  (WHILE (< $count (+ (STRLEN $string) 1))
	(IF	(= "<" (SUBSTR $string $count 1))
	  (SETQ $i $count)
	)
	(IF	(= ">" (SUBSTR $string $count 1))
	  (SETQ $list (CONS (SUBSTR $string (+ $i 1) (- $count $i 1)) $list))
	)
	(SETQ $count (+ 1 $count))
  )
  (REVERSE $list)
)


;;---------------------=={ titlecase }==-----------------------;;
;;                                                             ;;
;;  Parses an input string and converts the output to title    ;;
;;  title case, attempting to accommodate generic exceptions.  ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $string (gtstrings:totitlecase $string))                 ;;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse.                           ;;
;;  $markers - A list of exceptions fo the title case rule.    ;;
;;  $result - Output string.                                   ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  The input string converted into titlecase.                 ;;
;;-------------------------------------------------------------;;

(DEFUN gtstrings:totitlecase ($string / $markers $result)
  (SETQ
	$markers
			 '(" a "
			   " am "
			   " an "
			   " and "
			   " and/or "
			   " as "
			   " at "
			   " in "
			   " is "
			   " of "
			   " on "
			   " or "
			   " the "
			   " to "
			   " Mc"
			   " Mac"
			   " '"
			   " ("
			   ")("
			   " "
										; list is language dependent and can of course be extended...
			  )
	$result	 ""
	$string	 (STRCAT " " (STRCASE $string 'T)) ; temporarily add a space 
  )
  (WHILE (/= $string "")
	(IF
	  (NOT
		(VL-SOME
		  '(LAMBDA ($a)
			 (IF (WCMATCH $string (STRCAT (STRCASE $a 'T) "*"))
			   (IF (OR (= $a " ")
					   (= $a (SETQ $a (VL-STRING-RIGHT-TRIM " " $a)))
				   )
				 (SETQ
				   $result (STRCAT $result
								   $a
								   (STRCASE (SUBSTR $string (1+ (STRLEN $a)) 1))
						   )
				   $string (SUBSTR $string (+ (STRLEN $a) 2))
				 )
				 (SETQ
				   $result (STRCAT $result $a)
				   $string (SUBSTR $string (1+ (STRLEN $a)))
				 )
			   )
			 )
		   )
		  $markers
		)
	  )
	   (SETQ
		 $result (STRCAT $result (SUBSTR $string 1 1))
		 $string (SUBSTR $string 2)
	   )
	)
  )
  (STRCAT (STRCASE (SUBSTR $result 2 1)) (SUBSTR $result 3))
)

;;-----------------=={ friendly filename }==-------------------;;
;;                                                             ;;
;;  Parses an input string and converts the output to a windows;;
;;  friendly filename format (removing illegal characters).    ;;
;;-------------------------------------------------------------;;
;;  Usage: (SETQ $string (gtstrings:tofriendlyfilename $string)) ;;
;;-------------------------------------------------------------;;
;;  Variables:                                                 ;;
;;  $string - Input string to parse.                           ;;
;;  $illegal - A list of illegal file naming characters.       ;;
;;-------------------------------------------------------------;;
;;  Returns:                                                   ;;
;;  The input string converted into a filename friendly format.;;
;;  Note: This replaces the illegal characters with a <space>  ;;
;;-------------------------------------------------------------;;

(DEFUN gtstrings:tofriendlyfilename	($string)
  (SETQ $illegal (LIST "\\" "/" ":" "*" "?" "<" ">" "|" "\""))
  (FOREACH $a $illegal
	(SETQ $string (gtstrings:replace2 $string $a " "))
  )
  $string
)

(DEFUN gt$stringings:findindrawing ($search_pattern
									/
									$object
									$found
									$i
									$selection
									$entity
									$string
								   )
  (SETQ $found nil)

  (IF (SETQ $selection (SSGET "X" '((0 . "TEXT,MTEXT,DIMENSION,INSERT"))))
	(PROGN
	  (SETQ $i -1)
	  (WHILE (AND (NOT $found)
				  (< (SETQ $i (1+ $i)) ($selectionlength $selection))
			 )
		(SETQ $entity ($entityget ($selectionname $selection $i))
			  $object (VLAX-ENAME->VLA-OBJECT (CDR (CAR $entity)))
		)

		(COND

		  ((= (CDR (ASSOC 0 $entity)) "TEXT")
		   (PROGN
			 (SETQ $string (CDR (ASSOC 1 $entity)))
			 (IF (VL-STRING-SEARCH $search_pattern $string)
			   (SETQ $found T)
			 )
		   )
		  )

		  ((= (CDR (ASSOC 0 $entity)) "DIMENSION")
		   (PROGN
			 (SETQ $string (CDR (ASSOC 1 $entity)))
			 (IF (VL-STRING-SEARCH $search_pattern $string)
			   (SETQ $found T)
			 )
		   )
		  )

		  ((= (CDR (ASSOC 0 $entity)) "MTEXT")
		   (PROGN
			 (SETQ $string (vla-get-text$stringing $object))
			 (IF (VL-STRING-SEARCH $search_pattern $string)
			   (SETQ $found T)
			 )
		   )
		  )

		  (T
		   (PROGN
			 (IF (= (VLA-GET-HASATTRIBUTES $object) :VLAX-TRUE)
			   (PROGN
				 (SETQ atts (VLA-GETATTRIBUTES $object))
				 (FOREACH x	(VLAX-SAFEARRAY->LIST (VLAX-VARIANT-VALUE atts))
				   (SETQ $string (vla-get-text$stringing x))
				   (IF (VL-STRING-SEARCH $search_pattern $string)
					 (SETQ $found T)
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
  $found
)