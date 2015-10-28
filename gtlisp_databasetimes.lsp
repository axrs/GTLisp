(DEFUN c:gt_timesentry (/ $reworklist $showinserted	_load_odcl_runtime _load_odcl_stream _main)

  (SETQ $reworklist (LIST "N" "I" "X"))
  (SETQ $currenttimes '())
  (SETQ $showinserted nil)


  (DEFUN _load_odcl_runtime	(/)
	(OR	DCL_GETVERSIONEX
		(AND
		  (= 2 (BOOLE 1 (GETVAR "DEMANDLOAD") 2))
		  (VL-CATCH-ALL-APPLY 'VL-CMDF '("OPENDCL"))
		  DCL_GETVERSIONEX
		)
		(PRINC "Error: OpenDCL Runtime could not be loaded.\n")
	)
	DCL_GETVERSION
  )

  (DEFUN _load_odcl_stream (/ project rtype)
	(SETQ project
		   '("YWt6A3dWAAD2MwH2BuKTJCXSIDtrIIVEzZFBXox+WNNqU8Mnbs5b+Pl8VAxVaRF6/fmtaHT5KKQ0"
			 "72lgAo8wAq95j/tmM3KcWyD2MfNk3PdPQoQe3Mogbj8DTrj2iMao5OfDGZihGYGBAbAXBdTjCOEB"
			 "seCnTZXly8DLqLKBSfVZaX/RVZH/FZ8gBkmic8m+Mw5pkvgLzmvRZR5RQvipfGL68bxdBgl+8B6x"
			 "eY6RfJL5vYaKQMKhsRP5C4VfhkZAQ3YFHmAFE71PFzriWZGVZ36+9Xxe3WWSyh9goH+FnhQCh1SS"
			 "CEF0zOlB0b7F1R5wCLxwwuW9YKmOzWOGx2NZpfUB0b9gpZ+ThpAIHg71Spyrpshxod4JCBy1KJI/"
			 "EZGbb5mLpqoEe6jInKHjBgFriKb/zLIfwUOGqDBW3t4/N65iUcZmGn5flsxqPodhNgvp/iDpMUWL"
			 "tZgPj4XpzoGXkwYBQzQLfhtbqyKxlN9AjE8R2FnChNwpgcspQZSqSVI5zOWOpLGTDRJcMe4iIYyY"
			 "h9IpMX3JgMSpgMYpgWfiESgjUcHCbRyN9opd4ZpxUFHda7ZhPXwo75kJkyWOMDj/hYBxxQiQgQPR"
			 "gH2Rg5ELi5Vc0oGl7ZksuS6gqrnLRyLIR0q4RyCoC6a9UoxExs9N2eFFXSNGw/yauDC4wZ1mErKV"
			 "P2WNUKHm7RByhx85f6UYS/KQ10zsIwaBfkBF/hU+9rfyETrs75+2vC2INS7kxPq3O4C/k8FG37ah"
			 "XNGTgFlpuxDqhV5C+gyz3TqKmngCTHk5J5h5ljcSyv2Ju3PyE2CFkjnxNhZxHEEkvaOO3qhZqKxF"
			 "j41WyGP8+ccwGt/IPRRoB11CsCCL9uA5QJHTu5EZuggCuIBRvWUYJJVBvHtNi4HjVTGkDW/N8+e0"
			 "bRCB5Y+k/anrqNnHxgGb06kDMAO1NJPoJsbZsRhpJMjNlowf0YA2dVeGedONP9GDX9EAwfmd7SCD"
			 "fSCDLSCDTSCDrSADmquRi5TRy+A+qzEIjM9JhfVZkdVe4oR4kYPBCIbHw7n/+a4k7gK7DagBlGKp"
			 "lcoC6A2Baaud0EH1CQWpMBhcwZhHnaLVhb+f/p12tSWvM9G9lT8ohHxFlXvcmQnDD9LejCvUIX4n"
			 "RbDcgtyphZUgg7yQk8EvAwkp8S9gBzkpWRO3oQqRzapRBl+UZ3Gr4WMqXlGVhBHeiKXExNruCA0p"
			 "GYcQj7jBqxUB0amQeNT16TlChygR69JeCEyuP3J90AycJYJe6JDJItJSY02hRtVFzrlMB2abRo2W"
			 "sFc56vfpuQK13atJw4QNIIMn0cCkELsJdRnmmGgzl98yI6unry8ApU2IkQaLq9zKO581lkPhymg3"
			 "4XAj7ABuIuxM2H+sT7cQjTZGPkTQce7wlZ6bz1B3USfQx3GvDkkmSpoGQzC9BxW9zCxkpB3j3Z9X"
			 "2d/DqSL1SgLxOb0Zv9ufww4Ira7fsEpK2udUBMwT8vgjlAT7Mb0NyufvSIB3PZLnxDvVVGbdq/sJ"
			 "z2SqcK2SgBepAXqJ+RjBMcCJpD+s0xREhd0wnKl27zs8pJi3s6DGaHenDyZaAqs1JkFvcO3uvPgz"
			 "vAsgfLQNclreImEwPhlc4z3qf6yTeTPEeBEUBAynpt+eYNOlvei4KeNikeXOvQXBLaFCFbKTvd4c"
			 "0RO5GeTsgMCRajpdoKlzOt0gXKKTO3n1Zrt6HDKk54/N628dozRzH/ZeUf9YdjtaXHfCrVk2z+Xt"
			 "yV2OT+IdUZI8eYYGIQKMcQmoBMLki26ZDW1wC4ItCkFghNmUgN+xmcOELSCDPSCD4MsDNmoHLw/4"
			 "BrKvmAo7K7UHLvQYRXFgGeyNxsYjSJuqGA5gUfyVQkZrICOZzwBomc96r9kPYUqZ9uByW8sp4DUU"
			 "MSEsNafw6arcU2M67QFp1OccvafvxDBEFYMrTjLMXA43yGD4ifFCgX63KMQhCpZOPtNTHi+VQgRM"
			 "ONMM/4vHMZUN32OHquSvJx9I6XrQp87nJhgNgFdIZRBhSOVJsRxINdQEvvog3oRH8UWWD+ccinht"
			 "mIzPltsoIpOLKQRMFPGrBUyU2a4Zh6SwlPj4ozA7cJxeYjuJHgGLvnUJxGKwvrCMa7GfmuC9B3Ao"
			 "mA5muTSxR6Gc07V0nOY98n9ZOjdT7VKr9Xap8++SToHK+GyxvZ1wFOw91KmmQA+R+gOe6bGOwBOh"
			 "miEVp1oD5WmVyVGDNdA3IYgR+uuTlcYAICmZg6YM18O97b3chHCW34TSV5Ro8cQlw4RYEYDhBguB"
			 "mXqVQ6nP0xWBme290JtpnsTo8b5UmkxFw4sn/1UPlkGfeXu009fDCH5nugngVsCOqlGxhbR3hnii"
			 "goJjdTl+0KNyzpUohDWbdy7oiWwgpYdTG6K5SH+Cyihpm6kKE6QGVxK4Fa24c4bHf0gj8AvCSCPw"
			 "C8LwQYQ4Rv+pjzlRvLH1noZf0p0Lgm6oj0QIkmbygKl10K3naP80KCj7YpCsSivrUxWOy//P1JYx"
			 "Q6rbEpaRzD6IHBLWtsS01BhHHbAgdItP2jejGw5j6FadZo3U0FS4JjL7ztQNy2oz70t7t67KnKon"
			 "qKpr9SaZyxdm68sUk/rpzO8npUDUGyjVTyvjQOTEEBSUo8qxhxH/zJTvtNhXpDjnXfjMcR0jmKbo"
			 "n4HMt1lOOsG+TO+MB6SkZiogljkaG/JtL/D2LCs3lvOkjDjB5Un7Z80ovOUb3m90ZMvf8KrJFE+M"
			 "RQt109fie7bVD/L20BRuG7Ne2c6A2GMuJS8XGlEUNXWU8E6U4CcThBtzddip3m0RGgrYWK8JJINT"
			 "uNII2RYhrB2bQLh4i/VKshv7aOhlbWZS49RFPjRjBxBkVI3WLlTf27UTfvNF+jiuc/FEUqKLLLEV"
			 "5eGANZQfnx9SZ93SFFf12OqzSmDZlSxHPNZb0e7UklANTQfr1eAaOtNM8t7TYPccazOhHEqNNuXx"
			 "Rui60EZ3rDToOs9s2a1iPiUaZchPHH5UdLomtOKg6jNNe7iowPL+7LPrek0CkujcLwTaCMzPKPFY"
			 "SuTPSlENTWoI10VDzNfl9JCk6tNjNwMZthMdslt8OYvrM1O30UgbSPOxF+vfUsVIYPobmTkHF4ms"
			 "BFB1RZoLyp3cZOQC2uckCbjvVfJTweupGGhIiGIkYkiPcB1b5cLWlWSLVlsldWQVLUpnb02xjMRN"
			 "BnldU8xaJVppu9Bv6dY+OdD7VVS7wAgA4tvcmzhFVUzae7W8LegYLojwKj2s3lvMxhb4VjbXTiwu"
			 "VGd1VPiiqDazU2vCOB0oxiXyZuGm4LXsOLwQtrkIMM36Nd5KlkVZ6+s4XSCILEvowFZQyElQTxqF"
			 "JEWEtotxuAQ5I/JVJLXdVw436jdl8nr3aijf05j27zz5ubkYZK3jKmQXhdetLSTyM7M4tyYLAtIi"
			 "ldKMK27Qr7DMJLRUWOkAsHJq829DF9tiM7PPffNh/fbK82sXxALHsBavZkcsLgApHHxeVcwt8utL"
			 "BHvyTxbFR8torXrtSyYYpiVrDLeacDx/N5RCdJxa8Chcp5TrJ06YzKGVOnw6ats82twFVnq6r6R+"
			 "106MKHST6zMsJ1sEqVjtGs+W/rT88yeI/zpOH3ZvdlKu/zJuDWbT+3PGuCbe5ddPZSE8L/1baNPE"
			 "btrdR+/QX/Jz+bgCxGPdJbxakw7/Dj+n9EMNu6ZU1E4laDgjOjwBfZ8c9N1nT/R+ypV0u6bVF2py"
			 "c/nibx8hfR3a6k65Cm5L9/cd62kCqC8Pkr4zDSAeklaO4ZJBg3YcWl3aWip8XyQSVfduz8dpyAIP"
			 "NkRxxG/KwO02+m5W0nfsXmDL3Vs2EX/YGLM/7a58/jbuZc+eS/SSuxvymih2XZkMVHkWpoEa+u9M"
			 "fbw2mV0DR3j07FpWfrP1Jq+zyJ15b2ZeVv+DdI9GF5XfvGbZL+ys1N718C3qZp3vSAlv+j80Ndji"
			 "yUskPGbPaUVD0q6m3U6KT/DURF2DD2Qek2F1wjnm5qWvQdJoQ2atutJnu27qPjpYLNwu729Y8+K+"
			 "PASSYPp3ZeePL1483dAqjgXW3CbRcEn7U7jqK/RGq/Q7b1H0Zq1dW4lnO/Ckp0HU5VS9TiyqEtWL"
			 "BmwehSx/WgakdPFcye1HyDTC91OB2q37LhlzKCF+9EH/SL/Iz5s+aq0mXJI8zRRxnU/yal9PaYmI"
			 "8YbnXRhygEtjTmgHcWFduVQOnxfXcwIgH13Jmww3E9j/oS3eHDOvyu1m6rZIg9ZPqwTyKvWTpedV"
			 "qOQmBzDYDQwVgTaIJJnmeJors3lf55Jwbgr3XbmBz9P4rlxYJfREvlO4qsurJh8yywgc1VcrdasP"
			 "6SPGNhLz2R1ARnC4TtStREfIAepbx6ZCUU+X16+D8mGq/0VCH/JLYS2bU4r02fcZ1bzMKxPi2PHt"
			 "Ud84/Lq5XmrSPsdKT2jcBIbW7JOkpUHc7V9tE6admiuvSh0Uit1CpfdI8zq/qVAuJt/8AzASe03z"
			 "T09mPalKfR/P9TVUlifW8117grlA60JVOyhPkCmlfeHYVDWVAmtLJR8qEokonVB5ourqWDOrhjfe"
			 "0iplHpRaku/FquTxuJhsFZ8Wul7KMitRNGo9FJJhvXKEYFoGZD5q3J099c6gFoPURNDX1dQSsSln"
			 "aTkza2EbMXieRk6MCW9HR1viqO3MJ3ndtH9SwdROZN3Ox+XMYPt57PJdNvOFa9fD0W3wEZFO8E5S"
			 "1CMAI60Jf8OPzwn1koZsoh1/O27opeb1NBz6m+L6joLU6Eio4LqpXdSzfD8V3TmuoM2LDBROjJMf"
			 "Eif3uCavD9T0jmvj7p2Bz4ZGsLhve1ZFbG9Omw1SOM7m1+vF/7QbRDvYlKiWpFgHNFQyv5xQS/wk"
			 "yS6VqY8hvofoZrm2uenrQIvQWnjs3A+cHS2ogyEB+sgAOjIVNnwnD+IiXdTUDb8+z+DsecNC98il"
			 "SGUzUms5ykpf2NGEI/sv82CWSfoWyYT8WdhyVUoVpBzq1snywF2uK8MjuM6xj88StFsw0lzKvFab"
			 "KmuN/zq5OW8KxD7XPApD1ltTIXpqnKx24e4RNv4s23ah3qGY2tBFLFQ09wJPGwgU2zrcf56oMBbu"
			 "6u9ZPLuoRlruJOWjJzko1Iame3aM2uxsDZsphV+sGP+IgjwZSxbVmg2cpjAV7gT8+vF+rr1VGGxh"
			 "y8WZ5v8+1/dTs5jdLDlWHCwk3FOgpLFWYv+uPVe7rMBdM+3uF50C2b15YMt9Wdki/g2K/x2z9oNI"
			 "L/3+TmFtWU1fiWxWHmq+ag4AX9wTPdJofJFcSERJC0w3A/bkNxzbwXCddjJimByezkn2qli7QM3c"
			 "Bv9HR7g5pzKLAzABNxmjZgkR8JH16VYcDsmSa4lFKBrjpEEYYkUYbM7lAadZK5eqOV21ubahhp6w"
			 "vZJhrzDVpwGkX76xwthTD0yTH1sy04+vhocUu1kpBIHWMF3NX1SI6kYi0GC7JpDDKnf9Z/AQubDu"
			 "Nby2/9rfjavCtBiDNzJshqebyru32vkF0DrxKgy0Kc0y1AOMih3Tq8yqCX/mmeqbp4drsCYnZcHp"
			 "RcubgXqdAX+XpC71"
			)
	)
	(COND
	  ((NULL DCL_PROJECT_IMPORT)
	   (PRINC "OpenDCL version 5.0 or newer is required.\n")
	   nil
	  )
	  ((DCL_PROJECT_IMPORT project))
	)
  )
  ;;------------------------------------------------------------------------
  (DEFUN _main (/ odclprojname)
	(IF
	  (AND
		(_load_odcl_runtime)
		(_load_odcl_stream)
	  )
	   (IF
		 (NULL
		   (DCL_FORM_SHOW timesentry_timesentry)
		 )
		  (PRINC "Failed to show form: DistSample_MainForm\n")
	   )
	)
	(PRINC)
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry_times_onbeginlabeledit</function>
  <sumary>
  Updates an entry within the $currenttimes list.
  Only used for checkbox changed event.
  </sumary>
  <param name="row">Associated row index</param>
  <param name="column">Associated column index</param>
  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN c:timesentry_timesentry_times_onbeginlabeledit	(row column /)
	(IF	(= column 6)
	  (gtlisp_databasetime_adjustcurrentlist row)
	)
	(PRINC)
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry_times_onendlabeledit</function>
  <sumary>
  Updates an entry within the $currenttimes list.
  Used for any text cell alteration.
  </sumary>
  <param name="row">Associated row index</param>
  <param name="column">Associated column index</param>
  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN c:timesentry_timesentry_times_onendlabeledit (row column /)
	(IF	(NOT (= column 6))
	  (gtlisp_databasetime_adjustcurrentlist row)
	)
	(PRINC)
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>gtlisp_databasetime_adjustcurrentlist</function>
  <summary>Adjusts an entry within the current time list as edited within the view.</sumary>
  <param name="row">Associated row index</param>
  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtlisp_databasetime_adjustcurrentlist (row / $iterator $oldentry $newentry)
	;;(alert "rowalteration")
	;;Find the adjusted row in comparision to the times list
	(IF	$showinserted
	  (SETQ $iterator row)
	  (PROGN
		(SETQ $iterator -1)
		(WHILE (< $iterator row)
		  (IF (= (ASSOC "EXISTING" (NTH (+ 1 $iterator) $currenttimes))
				 "1"
			  )
			(SETQ $iterator (- 1 $iterator))
			(SETQ $iterator (+ 1 $iterator))
		  )
		)
	  )
	)
	;;Adjust the times list
	(SETQ $oldentry (NTH $iterator $currenttimes))
	(SETQ $row (DCL_GRID_GETROWCELLS timesentry_timesentry_times row))
	;;(ALERT (ITOA (DCL_GRID_GETCELLCHECKSTATE timesentry_timesentry_times row 6)))
	(SETQ $newentry	(APPEND	(LIST
							  (CONS "JOB" (NTH 0 $row))
							  (CONS "DWG" (NTH 1 $row))
							  (CONS "TIME" (NTH 2 $row))
							  (CONS "DESCRIPTION" (NTH 3 $row))
							  (CONS "PHASE" (NTH 4 $row))
							  (CONS "REWORK" (NTH 5 $row))
							  (CONS "EXISTING" (NTH 7 $row))
							  (CONS	"INSERT"
									(ITOA (DCL_GRID_GETCELLCHECKSTATE
											timesentry_timesentry_times
											row
											6
										  )
									)
							  )
							)
					)
	)
	(SETQ $currenttimes (SUBST $newentry $oldentry $currenttimes))
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry_resave</function>
  <summary>Inserts entries into the database and alters the log files.</summary>
  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN timesentry_timesentry_resave (/ $entry	$file $count $insertflag $employeerate $rate $sql $databaseobject $entrydate $file2)

	;;Create a counter for looping
	(SETQ $count 0)
	;;Attempt to make a connection to the database
	(timesentry_timesentry_appendstatus
	  "Attempting to connect to database..."
	)
	(SETQ $databaseobject (gtdatabase:getdatabase))
	;;If there is a valid database connection
	(IF	(NOT (= $databaseobject nil))
	  (PROGN
		(timesentry_timesentry_appendstatus
		  "Successfully connected to database..."
		)
		;;And if the times entry can be opend for writing
		(timesentry_timesentry_appendstatus
		  (STRCAT "Checking log file: "
				  (timesentry_timesentry:buildlogfilelocation
					(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
				  )
		  )
		)
		(IF	(SETQ $file	(OPEN
						  (timesentry_timesentry:buildlogfilelocation
							(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
						  )
						  "w"
						)
			)
		  (PROGN
			;;Create a backup times log
			(VL-FILE-COPY
			  (timesentry_timesentry:buildlogfilelocation
				(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
			  )
			  (STRCAT
				(timesentry_timesentry:buildlogfilelocation
				  (DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
				)
				".bak"
			  )
			)

			(timesentry_timesentry_appendstatus
			  "Log file is available for writing."
			)
			;;Create a MYSQL date/time string formatted variable
			(SETQ $entrydate (DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect))
			(SETQ $entrydate
				   (STRCAT (ITOA (NTH 0 $entrydate))
						   "-"
						   (ITOA (NTH 1 $entrydate))
						   "-"
						   (ITOA (NTH 2 $entrydate))
				   )
			)
			;;Obtain the base employee rate
			(timesentry_timesentry_appendstatus
			  (STRCAT "Attempting to obtain base employee rate for employee: "
					  (gtconfig:getvalue $gtconfig $gtuserid "EMPLOYEEID")
			  )
			)
			(SETQ $employeerate
				   (NTH	0
						(NTH 1
							 (adolisp_dosql
							   $databaseobject
							   (STRCAT "SELECT rate FROM employee WHERE employee_id="
									   (gtconfig:getvalue $gtconfig $gtuserid "EMPLOYEEID")
							   )
							 )
						)
				   )
			)
			(timesentry_timesentry_appendstatus
			  (STRCAT "Sucessfully set employee rate to : "
					  (RTOS $employeerate)
			  )
			)
			;;Loop through the entries
			(WHILE (< $count (LENGTH $currenttimes))
			  ;;Create an insert flag per entry
			  (SETQ $insertflag nil)
			  (SETQ $entry (NTH $count $currenttimes))
			  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
			  ;;If the entry is no existing AND the insert checkbox was checked AND the time spend was not 0 AND the job ID is not XXX0000
			  (IF (AND (= (CDR (ASSOC "EXISTING" $entry)) "0")
					   (= (CDR (ASSOC "INSERT" $entry)) "1")
					   (NOT (= (CDR (ASSOC "TIME" $entry)) "0"))
					   (NOT (= (CDR (ASSOC "JOB" $entry)) "XXX0000"))
				  )
				(PROGN
				  (timesentry_timesentry_appendstatus
					(STRCAT "Checking for job id: " (CDR (ASSOC "JOB" $entry)))
				  )
				  ;;Check the JOB ID
				  (IF (NTH 1
						   (adolisp_dosql
							 $databaseobject
							 (STRCAT "SELECT job_id FROM jobreg WHERE job_id='"
									 (CDR (ASSOC "JOB" $entry))
									 "'"
							 )
						   )
					  )

					(PROGN
					  ;;Check the variable rate
					  (timesentry_timesentry_appendstatus
						"Checking for rework rate..."
					  )
					  (SETQ	$rate (NTH 1
									   (adolisp_dosql
										 $databaseobject
										 (STRCAT "SELECT var_rate FROM jobrates WHERE employee_id="
												 (gtconfig:getvalue $gtconfig $gtuserid "EMPLOYEEID")
												 " AND job_id='"
												 (CDR (ASSOC "JOB" $entry))
												 "'"
										 )
									   )
								  )
					  )


					  (IF (= $rate nil)
						(PROGN
						  (SETQ $rate $employeerate)
						  (timesentry_timesentry_appendstatus
							(STRCAT "Rate set to: " (RTOS $rate))
						  )
						)
						(PROGN
						  (SETQ $rate (NTH 0 $rate))
						  (timesentry_timesentry_appendstatus
							(STRCAT "Rework rate set to: " (RTOS $rate))
						  )
						)
					  )

					  ;;Create an SQL query
					  (SETQ $sql "INSERT INTO times (employee_id, job_id, hours, date, details, task, rework, rate) VALUES (")
					  (SETQ	$sql (STRCAT $sql
										 (gtconfig:getvalue $gtconfig $gtuserid "EMPLOYEEID")
										 ",'"
										 (CDR (ASSOC "JOB" $entry))
										 "',"
										 (CDR (ASSOC "TIME" $entry))
										 ",'"
										 $entrydate
										 "','"
										 (CDR (ASSOC "DESCRIPTION" $entry))
										 "','"
										 "D"
										 "','"
										 (CDR (ASSOC "REWORK" $entry))
										 "',"
										 (RTOS $rate)
										 ")"
								 )
					  )
					  ;;Attempt the execute the query, adjusting the insert flag as required
					  (timesentry_timesentry_appendstatus
						(STRCAT	"Attempting Job Insert Job: "
								(CDR (ASSOC "JOB" $entry))
								" Time: "
								(CDR (ASSOC "TIME" $entry))
								" Existing: "
								(CDR (ASSOC "EXISTING" $entry))
						)
					  )
					  (IF (NOT (adolisp_dosql $databaseobject $sql))
						(PROGN
						  (timesentry_timesentry_appendstatus
							(STRCAT "MYSQL Error: " $sql)
						  )
						  (timesentry_timesentry_appendstatus
							(STRCAT	"NOTICE - ENTRY NOT INSERTED. Job: "
									(CDR (ASSOC "JOB" $entry))
									" Time: "
									(CDR (ASSOC "TIME" $entry))
									" Existing: "
									(CDR (ASSOC "EXISTING" $entry))
							)
						  )
						)
						(PROGN
						  (SETQ $insertflag T)
						  (timesentry_timesentry_appendstatus
							"Time entry inserted successfully."
						  )
						)
					  )
					)
					(PROGN
					  (timesentry_timesentry_appendstatus
						(STRCAT	"NOTICE - UNKNOWN JOB. ID: "
								(CDR (ASSOC "JOB" $entry))
						)
					  )
					)
				  )
				)
				(PROGN
				  (timesentry_timesentry_appendstatus
					(STRCAT	"NOTICE - INVALID JOB OR TIME. Job: "
							(CDR (ASSOC "JOB" $entry))
							" Time: "
							(CDR (ASSOC "TIME" $entry))
							" Existing: "
							(CDR (ASSOC "EXISTING" $entry))
					)
				  )

				)
			  )
			  ;;End Database Entry
			  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
			  (timesentry_timesentry_appendstatus
				"Adjusting text log entry..."
			  )
			  ;;Adjust the existing log entries
			  (SETQ	$message (STRCAT
							   (CDR (ASSOC "JOB" $entry))
							   "|"
							   (CDR (ASSOC "DWG" $entry))
							   "|"
							   (CDR (ASSOC "TIME" $entry))
							   "|"
							   (CDR (ASSOC "DESCRIPTION" $entry))
							   "|"
							   (CDR (ASSOC "PHASE" $entry))
							   "|"
							   (CDR (ASSOC "REWORK" $entry))
							   "|"
							 )
			  )
			  (IF (AND $insertflag (= (CDR (ASSOC "EXISTING" $entry)) "0"))
				(SETQ $message (STRCAT $message "1"))
				(SETQ $message (STRCAT $message (CDR (ASSOC "EXISTING" $entry))))
			  )
			  (REPEAT 5
				(SETQ $message (gtstrings:replace $message "||" "| |"))
			  )
			  (WRITE-LINE $message $file)
			  ;;Adjust the file
			  (SETQ $count (+ 1 $count))
			)
			(CLOSE $file)
		  )

		)
	  )
	  (timesentry_timesentry_appendstatus
		"MYSQL Error: Unable to connect to the database..."
	  )
	)
	;;Close the Database connection
	(timesentry_timesentry_appendstatus
	  "Closing database connection..."
	)
	(gtdatabase:disconnectdatabase $databaseobject)

	;;Clear and adjust the grid view
	(DCL_GRID_CLEAR timesentry_timesentry_times)
	(SETQ $currenttimes '())
	(timesentry_timesentry:populatetimeslist
	  (timesentry_timesentry:buildlogfilelocation
		(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
	  )
	)
	(timesentry_timesentry:populatetimesgrid)
	(timesentry_timesentry_appendstatus
	  "----------FINISHED----------"
	)
	(SETQ $file2 (OPEN (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
							   "\\times\\" $gtuserid "\\log.txt"
					   )
					   "a"
				 )
	)
	(WRITE-LINE
	  (DCL_CONTROL_GETPROPERTY
		timesentry_timesentry_status
		"Text"
	  )
	  $file2
	)
	(CLOSE $file2)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>c:timesentry_timesentry_oninitializ</function>
  <sumary>Sets up the dialog</sumary>

  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN c:timesentry_timesentry_oninitialize ()
	;;Update the log file label
	(DCL_CONTROL_SETPROPERTY
	  timesentry_timesentry_logfilelabel
	  "Caption"
	  (timesentry_timesentry:buildlogfilelocation
		(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
	  )
	)
	;;populate the gridview from file
	(timesentry_timesentry:populatetimeslist
	  (timesentry_timesentry:buildlogfilelocation
		(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
	  )
	)
	(timesentry_timesentry:populatetimesgrid)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>c:timesentry_timesentry_filter_onclicked</function>
  <summary>Time filter changed.</sumary>

  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN c:timesentry_timesentry_filter_onclicked (value /)
	(IF	(= (DCL_CONTROL_GETVALUE timesentry_timesentry_filter) 1)
	  (SETQ $showinserted T)
	  (SETQ $showinserted nil)
	)
	(DCL_GRID_CLEAR timesentry_timesentry_times)
	(timesentry_timesentry:populatetimesgrid)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>c:timesentry_timesentry_dateselect_onselect</function>
  <summary>Date time selection changed</sumary>

  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN c:timesentry_timesentry_dateselect_onselect ()
	(DCL_GRID_CLEAR timesentry_timesentry_times)
	(SETQ $currenttimes '())
	(DCL_CONTROL_SETPROPERTY
	  timesentry_timesentry_logfilelabel
	  "Caption"
	  (timesentry_timesentry:buildlogfilelocation
		(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
	  )
	)
	(timesentry_timesentry:populatetimeslist
	  (timesentry_timesentry:buildlogfilelocation
		(DCL_CALENDAR_GETCURSEL timesentry_timesentry_dateselect)
	  )
	)
	(timesentry_timesentry:populatetimesgrid)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>c:timesentry_timesentry_insert_onclicked</function>
  <summary>Calles the insert and save function on 'insert' click</sumary>

  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN c:timesentry_timesentry_insert_onclicked ()
	(timesentry_timesentry_resave)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry:timetodouble</function>
  <sumary>Convers a time of the formate hr:min into a double value hr.min</sumary>

  <param name="$time">Time in the format of hrs:mins</param>

  <returns>Time expressed as a double/float.</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN timesentry_timesentry:timetodouble	($time / $return)
	(SETQ $time (gtstrings:split $time ":"))
	(SETQ $return (+ (ATOF (NTH 0 $time)) (/ (ATOF (NTH 1 $time)) 60)))
	(RTOS $return)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry:associatelist</function>
  <summary>Converts a single time entry into an associated list.</summary>

  <param name="$entry">Entry string either pipe or tab separated.</param>
  <returns>Associated List</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN timesentry_timesentry:associatelist ($entry / $return)
	;;Assume tabbed list
	(SETQ $entry (gtstrings:split $fileentry "\t"))

	;;If not tabbed list, pipped list
	(IF	(= (LENGTH $entry) 1)
	  (SETQ $entry (gtstrings:split $fileentry "|"))
	)

	(COND
	  ;;Time spent format
	  ((= (LENGTH $entry) 3)
	   (SETQ $return (APPEND (LIST (CONS "JOB" "XXX0000")) $return))

	   (IF (= (LENGTH (gtstrings:split (NTH 0 $entry) ":")) 2)
		 (SETQ $return (APPEND (LIST
								 (CONS "TIME"
									   (timesentry_timesentry:timetodouble (NTH 0 $entry))
								 )
							   )
							   $return
					   )
		 )
		 (SETQ $return (APPEND (LIST (CONS "TIME" (NTH 0 $entry))) $return))
	   )

	   (SETQ $return (APPEND (LIST (CONS "DWG" (NTH 1 $entry))) $return))
	   (IF (OR (= (NTH 2 $entry) "") (= (NTH 2 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "DESCRIPTION" "")) $return))
		 (SETQ $return (APPEND (LIST (CONS "DESCRIPTION" (NTH 2 $entry))) $return))
	   )
	   (SETQ $return (APPEND (LIST (CONS "PHASE" "")) $return))
	   (SETQ $return (APPEND (LIST (CONS "REWORK" "N")) $return))
	   (SETQ $return (APPEND (LIST (CONS "EXISTING" "0")) $return))
	  )
	  ;;Start/End format
	  ((= (LENGTH $entry) 5)
	   (SETQ $return (APPEND (LIST (CONS "JOB" "XXX0000")) $return))
	   (IF (= (LENGTH (gtstrings:split (NTH 2 $entry) ":")) 2)
		 (SETQ $return (APPEND (LIST
								 (CONS "TIME"
									   (timesentry_timesentry:timetodouble (NTH 2 $entry))
								 )
							   )
							   $return
					   )
		 )
		 (SETQ $return (APPEND (LIST (CONS "TIME" (NTH 2 $entry))) $return))
	   )
	   (SETQ $return (APPEND (LIST (CONS "DWG" (NTH 3 $entry))) $return))
	   (IF (OR (= (NTH 4 $entry) "") (= (NTH 4 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "DESCRIPTION" "")) $return))
		 (SETQ $return (APPEND (LIST (CONS "DESCRIPTION" (NTH 4 $entry))) $return))
	   )
	   (SETQ $return (APPEND (LIST (CONS "PHASE" "")) $return))
	   (SETQ $return (APPEND (LIST (CONS "REWORK" "N")) $return))
	   (SETQ $return (APPEND (LIST (CONS "EXISTING" "0")) $return))
	  )
	  ;;Double Pipe Format
	  ((= (LENGTH $entry) 7)
	   (IF (= (NTH 0 $entry) "")
		 (SETQ $return (APPEND (LIST (CONS "JOB" "XXX0000")) $return))
		 (SETQ $return (APPEND (LIST (CONS "JOB" (NTH 0 $entry))) $return))
	   )
	   (IF (OR (= (NTH 1 $entry) "") (= (NTH 1 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "DWG" "UNKNOWN")) $return))
		 (SETQ $return (APPEND (LIST (CONS "DWG" (NTH 1 $entry))) $return))
	   )
	   (IF (OR (= (NTH 2 $entry) "") (= (NTH 2 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "TIME" "")) $return))
		 (PROGN
		   (IF (= (LENGTH (gtstrings:split (NTH 2 $entry) ":")) 2)
			 (SETQ $return (APPEND (LIST
									 (CONS "TIME"
										   (timesentry_timesentry:timetodouble (NTH 2 $entry))
									 )
								   )
								   $return
						   )
			 )
			 (SETQ $return (APPEND (LIST (CONS "TIME" (NTH 2 $entry))) $return))
		   )

		 )
	   )
	   (IF (OR (= (NTH 3 $entry) "") (= (NTH 3 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "DESCRIPTION" "")) $return))
		 (SETQ $return (APPEND (LIST (CONS "DESCRIPTION" (NTH 3 $entry))) $return))
	   )
	   (IF (OR (= (NTH 4 $entry) "") (= (NTH 4 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "PHASE" "")) $return))
		 (SETQ $return (APPEND (LIST (CONS "PHASE" (NTH 4 $entry))) $return))
	   )
	   (IF (OR (= (NTH 5 $entry) "") (= (NTH 5 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "REWORK" "N")) $return))
		 (SETQ $return (APPEND (LIST (CONS "REWORK" (NTH 5 $entry))) $return))
	   )
	   (IF (OR (= (NTH 6 $entry) "") (= (NTH 6 $entry) " "))
		 (SETQ $return (APPEND (LIST (CONS "EXISTING" "0")) $return))
		 (SETQ $return (APPEND (LIST (CONS "EXISTING" (NTH 6 $entry))) $return))
	   )
	  )
	)
	(REVERSE $return)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry:populatetimesgrid</function>
  <sumary>Populates the data grid view with the times entries. Filter as required.</sumary>

  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN timesentry_timesentry:populatetimesgrid (
												  /
												  $count
												  $entry
												 )
	(SETQ $count 0)
	(WHILE (< $count (LENGTH $currenttimes))
	  (SETQ $entry (NTH $count $currenttimes))
	  (IF (AND (= (CDR (ASSOC "EXISTING" $entry)) "1") $showinserted)

		(DCL_GRID_ADDROW
		  timesentry_timesentry_times
		  (LIST
			(CDR (ASSOC "JOB" $entry))
			(CDR (ASSOC "DWG" $entry))
			(CDR (ASSOC "TIME" $entry))
			(CDR (ASSOC "DESCRIPTION" $entry))
			(CDR (ASSOC "PHASE" $entry))
			(CDR (ASSOC "REWORK" $entry))
			""
			(CDR (ASSOC "EXISTING" $entry))
		  )
		)
	  )
	  (IF (= (CDR (ASSOC "EXISTING" $entry)) "0")
		(DCL_GRID_ADDROW
		  timesentry_timesentry_times
		  (LIST
			(CDR (ASSOC "JOB" $entry))
			(CDR (ASSOC "DWG" $entry))
			(CDR (ASSOC "TIME" $entry))
			(CDR (ASSOC "DESCRIPTION" $entry))
			(CDR (ASSOC "PHASE" $entry))
			(CDR (ASSOC "REWORK" $entry))
			""
			(CDR (ASSOC "EXISTING" $entry))
		  )
		)
	  )
	  (IF (= (CDR (ASSOC "EXISTING" $entry)) "1")
		(DCL_GRID_SETCELLCHECKSTATE
		  timesentry_timesentry_times
		  $count
		  6
		  1
		)
	  )
	  (SETQ $count (+ $count 1))
	)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry:populatetimeslist</function>
  <sumary>Populates the currenttimes variable with log entries from file.</sumary>

  <param name="$logfile">Absolute path to the times log.</param>

  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN timesentry_timesentry:populatetimeslist ($logfile / $fileentry $count)
	(DCL_CONTROL_SETCOLUMNLISTITEMS
	  timesentry_timesentry_times
	  (LIST nil nil nil nil nil $reworklist nil)
	)
	(SETQ $count 0)
	(IF	(SETQ $logfile (OPEN $logfile "r"))
	  (PROGN
		(WHILE (SETQ $fileentry (READ-LINE $logfile))

		  (REPEAT 5
			(SETQ $fileentry (gtstrings:replace $fileentry "||" "| |"))
		  )
		  (SETQ $entry (timesentry_timesentry:associatelist $fileentry))
		  (SETQ $currenttimes (APPEND (LIST $entry) $currenttimes))
		)
		(CLOSE $logfile)
		(SETQ $currenttimes (REVERSE $currenttimes))
	  )
	)
	(PRINC)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry:buildlogfilelocation</function>
  <sumary>Builds a log file path based on the date picker selection.</sumary>

  <param name="$date">List of the selected date (YYYY MM DD)</param>

  <returns>String of the log file</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

  (DEFUN timesentry_timesentry:buildlogfilelocation	($date / $return $formatted)
	(SETQ $return
		   (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
				   "\\times\\" $gtuserid "\\"
		   )
	)
	(SETQ $formatted (ITOA (NTH 0 $date)))

	(IF	(< (NTH 1 $date) 10)
	  (SETQ $formatted (STRCAT $formatted "0" (ITOA (NTH 1 $date))))
	  (SETQ $formatted (STRCAT $formatted (ITOA (NTH 1 $date))))
	)
	(IF	(< (NTH 2 $date) 10)
	  (SETQ $formatted (STRCAT $formatted "0" (ITOA (NTH 2 $date))))
	  (SETQ $formatted (STRCAT $formatted (ITOA (NTH 2 $date))))
	)

	(SETQ $return (STRCAT $return $formatted ".gtl"))
	$return
  )



  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>c:timesentry_timesentry_cancel_onclicked</function>
  <summary>Closes the dialog.</summary>
  <returns>Nothing</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN c:timesentry_timesentry_cancel_onclicked ()
	(DCL_FORM_CLOSE timesentry_timesentry)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>timesentry_timesentry_appendstatus </function>
  <summary>Appends log status messages to the status text area.</summary>

  <param name="$text">Line of text to append to the text area.</param>
  <returns>Nothing.</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN timesentry_timesentry_appendstatus	($text /)
	(DCL_CONTROL_SETPROPERTY
	  timesentry_timesentry_status
	  "text"
	  (STRCAT (DCL_CONTROL_GETPROPERTY
				timesentry_timesentry_status
				"Text"
			  )
			  "\r\n"
			  $text
	  )
	)
	(DCL_TEXTBOX_LINESCROLL
	  timesentry_timesentry_status
	  (DCL_TEXTBOX_GETLINECOUNT timesentry_timesentry_status)
	)
	(PRINC)
  )



  (DEFUN c:timesentry_timesentry_oncancelclose (intisesc)
	(/= initisesc 1)
  )

  (_main)
)
(PRINC)