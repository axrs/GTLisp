(DEFUN gtpublish:publish (/ $folder)
  (gterror:savesettings)
  (SETQ $verror *error*)
  (SETQ *error* gterror:trap)
  (SETVAR "CMDECHO" 0)
  (SETVAR "BACKGROUNDPLOT" 0)

  (gtconfig:save
    nil
    (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
	    "\\"
	    "gtpublish.dsd"
    )
  )
  (gtpublish:create-register)
  (SETQ $folder (STRCAT (GETVAR "dwgprefix") "Current PDFs\\"))
  (gtpublish:create-template $folder)
  (gtsystem:buildpath "Current PDFs")
  (COMMAND "filedia" 0)
  (COMMAND "_.-publish"
	   (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		   "\\"
		   "gtpublish.dsd"
	   )
  )
  (COMMAND "filedia" 1)

  (gterror:restoresettings)
  (SETQ *error* nil)
)

(DEFUN gtpublish:create-register (/	       $path
				  $name	       $config
				  $dwgpath     $dwgname
				  $publishconfig
				  $layouts     $layout
				  $titlefilter
				 )

  (SETQ	$publishconfig
	 (gtconfig:parse
	   (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		   "\\"
		   "gtpublish.dsd"
	   )
	 )
  )

  (SETQ $dwgname (VL-FILENAME-BASE (GETVAR "dwgname")))
  (SETQ $dwgpath (STRCAT (GETVAR "DWGPrefix") (GETVAR "dwgname")))

  (SETQ $name "")
  (SETQ $job nil)

  (PRINC
    (STRCAT
      "\nScanning plot directory for configuration files..."
    )
  )
  (SETQ $path (gtconfig:getvalue $gtconfig "GENERAL" "PLOTPATH"))
  (SETQ $configlist (VL-DIRECTORY-FILES $path "*.cfg" 1))

  (SETQ $layouts (LAYOUTLIST))
  (FOREACH $layout $layouts
    (IF	(NOT (WCMATCH $layout "NA*"))
      (PROGN
	(SETQ $config nil)
	(FOREACH $configfile $configlist

	  (IF (= $config nil)
	    (PROGN
	      ;;Default Filter
	      (SETQ $titlefilter
		     (APPEND
		       (LIST (CONS 410 $layout))
		       (gt:dyn-ssfilter
			 (SUBSTR $configfile 1 (- (STRLEN $configfile) 4))
		       )
		     )
	      )

	      (IF (SSGET "X" $titlefilter)
		(SETQ $config (gtconfig:parse
				(STRCAT $path "\\" $configfile)
			      )
		)
		(PROGN
		  ;;Wildcard Match Filter
		  (SETQ	$titlefilter
			 (LIST (CONS 410 $layout)
			       (CONS 2
				     (STRCAT (SUBSTR $configfile
						     1
						     (- (STRLEN $configfile) 4)
					     )
					     "*"
				     )
			       )
			 )
		  )
		  (IF (SSGET "X" $titlefilter)
		    (SETQ $config (gtconfig:parse
				    (STRCAT $path "\\" $configfile)
				  )
		    )
		  )
		)
	      )
	    )
	  )
	)				;End For Each
	(IF (gtconfig:getvalue $config "PUBLISH" "PARTNAME")
	  (PROGN
	    (PRINC (STRCAT "\nAdding Layout: " $layout))
	    (SETQ $section (STRCAT "DWF6Sheet:" $dwgname "-" $layout))
	    ;;DWG
	    (SETQ $publishconfig
		   (gtconfig:setvalue
		     $publishconfig
		     $section
		     "DWG"
		     $dwgpath
		   )
	    )
	    (SETQ $publishconfig
		   (gtconfig:setvalue
		     $publishconfig
		     $section
		     "OriginalSheetPath"
		     $dwgpath
		   )
	    )
	    (SETQ $publishconfig
		   (gtconfig:setvalue
		     $publishconfig
		     $section
		     "Layout"
		     $layout
		   )
	    )
	    (SETQ $publishconfig
		   (gtconfig:setvalue
		     $publishconfig
		     $section
		     "Setup"
		     ""
		   )
	    )
	    (SETQ $publishconfig
		   (gtconfig:setvalue
		     $publishconfig
		     $section
		     "Has Plot Port"
		     "0"
		   )
	    )
	    (SETQ $publishconfig
		   (gtconfig:setvalue
		     $publishconfig
		     $section
		     "Has3DDWF"
		     "0"
		   )
	    )

	    (SETQ $name
		   (STRCAT
		     $name
		     (gtplot:buildpdfname
		       (gtconfig:getvalue $config "PUBLISH" "PARTNAME")
		       $layout
		     )
		   )
	    )
	    (SETQ $job (gtplot:buildpdfname
			 (gtconfig:getvalue $config "PUBLISH" "JOB")
			 $layout
		       )
	    )
	  )
	)
      )
    )
  )
  (PRINC "\nAppending publish configuration.")

  ;;Update the drawing count.
  (IF (NOT (gtconfig:getvalue $publishconfig "GTCAD" "Drawings"))
    (SETQ $publishconfig
	   (gtconfig:setvalue
	     $publishconfig
	     "GTCAD"
	     "Drawings"
	     (SUBSTR $name 1 (- (STRLEN $name) 1))
	   )
    )
    (SETQ $publishconfig
	   (gtconfig:setvalue
	     $publishconfig
	     "GTCAD"
	     "Drawings"
	     (STRCAT (gtconfig:getvalue $publishconfig "GTCAD" "Drawings")
		     (SUBSTR $name 1 (- (STRLEN $name) 1))
	     )
	   )
    )
  )

  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "GTCAD"
	   "Job"
	   $job
	 )
  )
  (gtconfig:save
    $publishconfig
    (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
	    "\\"
	    "gtpublish.dsd"
    )
  )
  (PRINC)
)

(DEFUN gtpublish:create-template ($output / $publishini $publishconfig)
  (SETQ	$publishini
	 (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		 "\\"
		 "gtpublish.dsd"
	 )
  )

  (SETQ	$publishconfig
	 (gtconfig:parse
	   (STRCAT (gtconfig:getvalue $gtconfig "GENERAL" "BASEPATH")
		   "\\"
		   "gtpublish.dsd"
	   )
	 )
  )

  ;;Add the publish header
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "DWF6Version"
	   "Ver"
	   "1"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "DWF6MinorVersion"
	   "MinorVer"
	   "1"
	 )
  )
  ;;TARGET

  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "Target"
	   "Type"
	   "6"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "Target"
	   "DWF"
	   (STRCAT $output
		   (gtconfig:getvalue $publishconfig "GTCAD" "Job")
		   (gtconfig:getvalue $publishconfig "GTCAD" "Drawings")
		   ".pdf"
	   )
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "Target"
	   "OUT"
	   $output
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue $publishconfig "Target" "PWD" "")
  )
  ;;SheetSet Properties
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "IsSheetSet"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "IsHomogeneous"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "SheetSet Name"
	   ""
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "NoOfCopies"
	   "1"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "PlotStampOn"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "ViewFile"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "JobID"
	   "0"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "SelectionSetName"
	   ""
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "AcadProfile"
	   ""
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "CategoryName"
	   ""
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "LogFilePath"
	   ""
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "IncludeLayer"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "LineMerge"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "CurrentPrecision"
	   ""
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "PromptForDwfName"
	   "TRUE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "PwdProtectPublishedDWF"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "PromptForPwd"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "RepublishingMarkups"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "PublishSheetSetMetadata"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "PublishSheetMetadata"
	   "FALSE"
	 )
  )
  (SETQ	$publishconfig
	 (gtconfig:setvalue
	   $publishconfig
	   "SheetSet Properties"
	   "3DDWFOptions"
	   "0"
	 )
  )

  (gtconfig:save $publishconfig $publishini)
  (PRINC)
)




;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTPlot:Plot</function>
<summary>
Plots the current active drawing (single or multiple layouts) to settings found within a matching plot configuration file.
Note: Layouts with the title prefix 'NA-' or no matching configuration file will be excluded.
</summary>

<examples>
<example summary="Plots the current layout with the 'SINGLE' configuration setting.">(gtplot:plot "SINGLE" nil)</example>
<example summary="Plots the all layouts with the 'PDF' configuration setting.">(gtplot:plot "PDF" T)</example>
</examples>

<param name="$plottype">The plot settings to use (within the plot configuration file).</param>
<param name="$batch">Switch to plot all found layouts or the current one. T = all layouts, nil = current layout.</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtplot:plot ($plottype	  $batch	/
		    $layouts	  $layout	$config
		    $configlist	  $configfile	$filename
		    $folder	  $device	$paper
		    $orientation  $view		$scale
		    $style	  $filename	$path
		    $verror	  $permissionstest
		    $plotbackgroundplot		$plotecho
		    $titlefilter
		   )


  (DEFUN gtplot:trap ($error)
    ;;Restore the system error reporting function
    (SETQ *error* $verror)
    (SETVAR "CMDECHO" $plotecho)
    (SETVAR "BACKGROUNDPLOT" $plotbackgroundplot)
    (PRINC $error)
    (PRINC "\nRestoring System Variables.")
    (PRINC)
  )


  (DEFUN gtplot:savesettings ()
    (SETQ $plotecho (GETVAR "CMDECHO"))
    (SETQ $plotbackgroundplot (GETVAR "BACKGROUNDPLOT"))
    (PRINC)
  )
  (DEFUN gtplot:restoresettings	()
    ;;Restore the system errors and variables reporting function
    (SETVAR "CMDECHO" $plotecho)
    (SETVAR "BACKGROUNDPLOT" $plotbackgroundplot)
    (SETQ *error* $verror)
    (PRINC)
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:TitleBlockFilter</function>
  <summary>Builds a selection filter for a specified layout and title block.</summary>

  <param name="$layout">Layout tab</param>
  <param name="$titleblock">Title block to find</param>
  <param name="$dynamic">Include dynamic blocks?</param>
  <returns>Filter List for use in SSGET</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:titleblockfilter
	 ($layout $titleblock $dynamic / $filter)
    (SETQ $filter (LIST (CONS 410 $layout)))
    (IF	(= $dynamic T)
      (SETQ $filter
	     (APPEND
	       $filter
	       (gt:dyn-ssfilter $titleblock)
	     )
      )
      (SETQ $filter
	     (APPEND
	       $filter
	       (LIST (CONS 2 $titleblock))
	     )
      )
    )
    $filter
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:FindConfig</function>
  <summary>Identifies an appropriate configuration file to use for the specified layout.</summary>

  <param name="$layout">Layout tab to search</param>
  <param name="$configlist">List of configuration files</param>
  <returns>Configuration file to use, or nil</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:findconfig
	 ($layout $configlist / $config $index $count $configfile)

    (SETQ $count (LENGTH $configlist))
    (SETQ $config nil)
    (SETQ $index 0)
    ;;Return Variable
    (WHILE (< $index $count)

      ;;Get next config file.
      ;;Check against blocks on layout
      ;;If match, exit. Else Loop
      (SETQ $configfile (NTH $index $configlist))

      (PRINC (STRCAT (ITOA $index)
		     ". Checking configuration: "
		     $configfile
		     "\n"
	     )
      )

      (IF
	(SSGET "X"
	       (gtplot:titleblockfilter
		 $layout
		 (SUBSTR $configfile 1 (- (STRLEN $configfile) 4))
		 T
	       )
	)
	 (PROGN
	   (SETQ
	     $config (gtconfig:parse (STRCAT $path "\\" $configfile))
	   )
	 )
	 (PROGN
	   (IF
	     (SSGET
	       "X"
	       (gtplot:titleblockfilter
		 $layout
		 (STRCAT (SUBSTR $configfile 1 (- (STRLEN $configfile) 4))
			 "*"
		 )
		 nil
	       )
	     )
	      (SETQ
		$config	(gtconfig:parse (STRCAT $path "\\" $configfile))
	      )
	   )
	 )
      )
      (IF (NOT (= nil $config))
	(PROGN
	  (PRINC
	    (STRCAT "Selected configuration file: " $configfile "\n")
	  )
	  (SETQ $index $count)
	)
      )
      (SETQ $index (1+ $index))
    )

    $config
  )


  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:GetConfigurations</function>
  <summary>Gets a list of plot configurations</summary>

  <param name="$path">Absolute path to configuration directory</param>
  <returns>List of configuration files</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:getconfigurations ($path /)
    (VL-DIRECTORY-FILES $path "*.cfg" 1)
  )

  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:ExitWithWarning</function>
  <summary>Exits a function alerting the user with a specified message.</summary>

  <param name="$message">Alert to display</param>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:exitwithwarning	($message /)
    (ALERT $message)
    (EXIT)
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:ExitWithoutWarning</function>
  <summary>Exits a function without notification.</summary>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:exitwithoutwarning (/) (EXIT))


  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:PlotPaper</function>
  <summary>Begins a hardcopy paper plot</summary>

  <param name="$message">Alert to display</param>
  <param name="$message">Alert to display</param>
  <param name="$message">Alert to display</param>
  <param name="$message">Alert to display</param>
  <param name="$message">Alert to display</param>
  <param name="$message">Alert to display</param>
  <param name="$message">Alert to display</param>  
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:plotpaper ($configuration / $view)
    ;;Plot the current drawing
    (IF	(WCMATCH (CDR (ASSOC "view" $configuration)) "*:*")
      (PROGN
	(PRINC "\nPlotting Type: View...")
	(SETQ $view (gtstrings:split
		      (CDR (ASSOC "view" $configuration))
		      ":"
		    )
	)
	(COMMAND "-PLOT"
		 "YES"
		 (CDR (ASSOC "layout" $configuration))
		 (CDR (ASSOC "device" $configuration))
		 (CDR (ASSOC "paper" $configuration))
		 "MILLIMETERS"
		 (CDR (ASSOC "orientation" $configuration))
		 "NO"
		 (CAR $view)
		 (CADR $view)
		 (STRCAT "1:" (CDR (ASSOC "scale" $configuration)))
		 "CENTER"
		 "YES"
		 (CDR (ASSOC "style" $configuration))
		 "YES"
		 "YES"
		 "NO"
		 "NO"
		 "NO"
		 "NO"
		 "YES"
	)
      )
      (PROGN
	(COMMAND "-PLOT"
		 "YES"
		 (CDR (ASSOC "layout" $configuration))
		 (CDR (ASSOC "device" $configuration))
		 (CDR (ASSOC "paper" $configuration))
		 "MILLIMETERS"
		 (CDR (ASSOC "orientation" $configuration))
		 "NO"
		 (CDR (ASSOC "view" $configuration))
		 (STRCAT "1:" (CDR (ASSOC "scale" $configuration)))
		 "CENTER"
		 "YES"
		 (CDR (ASSOC "style" $configuration))
		 "YES"
		 "YES"
		 "NO"
		 "NO"
		 "NO"
		 "NO"
		 "YES"
	)
      )
    )
    (PRINC)
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:GetPDFFolders</function>
  <summary>Parses a list of PDF folders from a specified string</summary>

  <param name="$folders">String to parse</param>
  <returns>Parsed folder list</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:getpdffolders ($folders /)

    (SETQ $template (gtstrings:template $folders))
    (FOREACH $struct $template
      (COND
	(
	 ;;Case - gttext:gettext Function
	 (= "XGETDATE" (STRCASE (CAR (gtstrings:split $struct ":"))))
	 (SETQ $folders	(gtstrings:replace
			  $folders
			  (STRCAT "<" $struct ">")
			  (gtmisc:getdatecustom
			    (CADR (gtstrings:split $struct ":"))
			  )
			)
	 )

	)
      )
    )
    $folders
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:hasFileAccess</function>
  <summary>Tests write access to a specified file.</summary>

  <param name="$file">Absolute file path</param>

  <returns>T if accessible</returns>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:hasfileaccess ($file / $test $result)
    (SETQ $result nil)
    (IF
      (SETQ $test
	     (OPEN $file "a")
      )
       (PROGN
	 (SETQ $result T)
	 (CLOSE $test)
	 (VL-FILE-DELETE $file)
       )
    )
    $result
  )
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:PlotPDF</function>
  <summary>Plots to PDF</summary>

  <param name="$configuration">Associative configuration list</param>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:plotpdf	($configuration / $filename)
    (SETQ $folders (gtplot:getpdffolders
		     (gtconfig:getvalue
		       $config
		       (CDR (ASSOC "plottype" $configuration))
		       "FOLDER"
		     )
		   )
    )


    (SETQ
      $filename
       (gtplot:buildpdfname
	 (CDR (ASSOC "filename" $configuration))
	 (CDR (ASSOC "layout" $configuration))
       )
    )
    (SETQ $folderlist (gtstrings:split $folders ";"))

    (FOREACH $folder $folderlist
      (SETQ $folder (gtsystem:buildpath $folder))

      ;;Attempt to open an existing PDF file. The plot will be terminated...
      (IF
	(NOT
	  (gtplot:hasfileaccess (STRCAT $folder $filename ".pdf"))
	)
	 (IF (NOT $gtserver)
	   (gtplot:exitwithwarning
	     (STRCAT "The file is currently in use or unavilable:\n`"
		     $folder
		     $filename
		     ".pdf`\nPlotting has been terminated."
	     )
	   )
	   (gtplot:exitwithoutwarning)
	 )
      )

      (IF (WCMATCH (CDR (ASSOC "view" $configuration)) "*:*")
	(PROGN
	  (SETQ	$view (gtstrings:split
			(CDR (ASSOC "view" $configuration))
			":"
		      )
	  )
	  (COMMAND "-PLOT"
		   "YES"
		   (CDR (ASSOC "layout" $configuration))
		   (CDR (ASSOC "device" $configuration))
		   (CDR (ASSOC "paper" $configuration))
		   "MILLIMETERS"
		   (CDR (ASSOC "orientation" $configuration))
		   "NO"
		   (CAR $view)
		   (CADR $view)
		   (STRCAT "1:" (CDR (ASSOC "scale" $configuration)))
		   "CENTER"
		   "YES"
		   (CDR (ASSOC "style" $configuration))
		   "YES"
		   "YES"
		   "NO"
		   "NO"
		   (STRCAT $folder $filename)
		   "NO"
		   "YES"
	  )
	)
	(PROGN
	  (COMMAND "-PLOT"
		   "YES"
		   (CDR (ASSOC "layout" $configuration))
		   (CDR (ASSOC "device" $configuration))
		   (CDR (ASSOC "paper" $configuration))
		   "MILLIMETERS"
		   (CDR (ASSOC "orientation" $configuration))
		   "NO"
		   (CDR (ASSOC "view" $configuration))
		   (STRCAT "1:" (CDR (ASSOC "scale" $configuration)))
		   "CENTER"
		   "YES"
		   (CDR (ASSOC "style" $configuration))
		   "YES"
		   "YES"
		   "NO"
		   "NO"
		   (STRCAT $folder $filename)
		   "NO"
		   "YES"
	  )
	)
      )
    )
  )



  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  ;|
  <function>GTPlot:BeginPlot</function>
  <summary>Application Entry Point.</summary>
  |;
  ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
  (DEFUN gtplot:beginplot (/)
    (gtplot:savesettings)
    (SETQ $verror *error*)
    (SETQ *error* gtplot:trap)
    (SETVAR "CMDECHO" 0)

    (SETQ $path (gtconfig:getvalue $gtconfig "GENERAL" "PLOTPATH"))
    (PRINC
      (STRCAT
	"\nScanning plot directory for configuration files..."
      )
    )

    (SETQ $configlist (gtplot:getconfigurations $path))

    ;;Plot type switch
    (IF	(= T $batch)
      (SETQ $layouts (LAYOUTLIST))
      (SETQ $layouts (LIST (GETVAR "CTAB")))
    )

    (PRINC
      (strcat "\nStarting Plot..." (STRCASE $plottype) "\n")
    )
    (FOREACH $layout $layouts
      (IF (NOT (WCMATCH $layout "NA*"))
	(PROGN
	  (SETQ $config (gtplot:findconfig $layout $configlist))

	  ;;No Configuration file, terminate
	  (IF (= nil $config)
	    (IF	(NOT $gtserver)
	      (gtplot:exitwithwarning
		"Unable to find a matching plot configuration file.\nThe plot cannot proceed."
	      )
	      (gtplot:exitwithoutwarning)
	    )
	  )

	  ;;No Matching plot file, terminate
	  (IF (= nil (gtconfig:hassection $config (STRCASE $plottype)))
	    (IF	(NOT $gtserver)
	      (gtplot:exitwithwarning
		(STRCAT	"Unable to find "
			(STRCASE $plottype)
			"settings within the "
			$configfile
			" configuration file.\nThe plot cannot proceed."
		)
	      )
	      (gtplot:exitwithoutwarning)
	    )
	  )

	  (SETQ	$plotconfiguration
		 (LIST
		   (CONS "layout" $layout)
		   (CONS "plottype" (STRCASE $plottype))
		   (CONS "filename"
			 (gtconfig:getvalue
			   $config
			   (STRCASE $plottype)
			   "FILENAME"
			 )
		   )
		   (CONS "path" $path)
		   (CONS
		     "device"
		     (gtconfig:getvalue $config (STRCASE $plottype) "PLOTTER")
		   )
		   (CONS "paper"
			 (gtconfig:getvalue $config (STRCASE $plottype) "SIZE")
		   )
		   (CONS "orientation"
			 (gtconfig:getvalue
			   $config
			   (STRCASE $plottype)
			   "ORIENTATION"
			 )
		   )
		   (CONS "view"
			 (gtconfig:getvalue
			   $config
			   (STRCASE $plottype)
			   "PLOTAREA"
			 )
		   )
		   (CONS
		     "scale"
		     (gtconfig:getvalue $config (STRCASE $plottype) "SCALE")
		   )
		   (CONS "style"
			 (gtconfig:getvalue
			   $config
			   (STRCASE $plottype)
			   "PLOTSTYLE"
			 )
		   )
		 )
	  )

	  ;;++++++++++++++++++++PDF CONFIGURATION++++++++++++++++++++
	  (IF (WCMATCH (STRCASE $plottype) "*PDF*")
	    (gtplot:plotpdf $plotconfiguration)
	    ;;Hardcopy Plotting
	    (gtplot:plotpaper $plotconfiguration)
	  )
	)
      )
    )
    (gtplot:restoresettings)
    (PRINC)
  )
  (gtplot:beginplot)
)



;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTPlot:BuildPDFName</function>
<summary>Converts a templated string representing block arributes and text entities into a valued string.</summary>

<examples>
<example summary="">(gtplot:buildpdfname "<B1-TITLE:JOB> <B1-TITLE:SHT><xgettext:(LCASE)LAYER=S-TITL-REVN;LOCATION=(LIST 978.58125 23.75 0.0)> - <B1-TITLE:(TCASE)TITLE1> <B1-TITLE:(TCASE)TITLE2>" (GETVAR "CTAB"))</example>
</examples>

<param name="$output">Filename Template (string). Refer to plot configuration.</param>
<param name="$layout">The layout name (string) to build the file name from.</param>

<returns>Windows filename friendly version of the template. (i.e. Illegal file name characters have been removed).</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtplot:buildpdfname ($output	$layout	    /
			    $temp	$case	    $xlayout
			    $xlayer	$xlocation  $xstyle
			    $xcolor	$struct	    $substruct
			    $template	$block	    $attribute
			   )

  (SETQ $template (gtstrings:template $output))

  (FOREACH $struct $template
    (COND
      (
       ;;Case - gttext:gettext Function
       (= "XGETTEXT" (STRCASE (CAR (gtstrings:split $struct ":"))))
       (SETQ $case "")
       (COND
	 ((WCMATCH (STRCASE $struct) "*:(TCASE)*")
	  (SETQ $case "TCASE")
	 )
	 ((WCMATCH (STRCASE $struct) "*:(UCASE)*")
	  (SETQ $case "UCASE")
	 )
	 ((WCMATCH (STRCASE $struct) "*:(LCASE)*")
	  (SETQ $case "LCASE")
	 )
	 (T
	  ()
	 )
       )
       (SETQ $subtemplate
	      (gtstrings:split
		(CADR (gtstrings:split $struct ":"))
		";"
	      )
       )
       (FOREACH	$substruct $subtemplate
	 ;;Set default settings for the filter search
	 ;|                 (SETQ $xlayout nil)
                 (SETQ $xlayer nil)
                 (SETQ $xlocation nil)
                 (SETQ $xstyle nil)
                 (SETQ $xlinetype nil)
                 (SETQ $xcolor nil)
                 |;
	 (SETQ $substruct
		(gtstrings:replace
		  $substruct
		  (STRCAT "(" $case ")")
		  ""
		)
	 )
	 ;;Identify and update settings based on the specified inputs
	 (COND
	   (
	    (= (STRCASE (CAR (gtstrings:split $substruct "=")))
	       "LAYOUT"
	    )
	    (SETQ $xlayout (CADR (gtstrings:split $substruct "=")))
	   )
	   (
	    (= (STRCASE (CAR (gtstrings:split $substruct "="))) "LAYER")
	    (SETQ $xlayer (CADR (gtstrings:split $substruct "=")))
	   )
	   (
	    (= (STRCASE (CAR (gtstrings:split $substruct "=")))
	       "LOCATION"
	    )
	    (SETQ $xlocation (CADR (gtstrings:split $substruct "=")))
	   )
	   (
	    (= (STRCASE (CAR (gtstrings:split $substruct "="))) "STYLE")
	    (SETQ $xstyle (CADR (gtstrings:split $substruct "=")))
	   )
	   (
	    (= (STRCASE (CAR (gtstrings:split $substruct "=")))
	       "LINETYPE"
	    )
	    (SETQ $xlinetype (CADR (gtstrings:split $substruct "=")))
	   )
	   (
	    (= (STRCASE (CAR (gtstrings:split $substruct "="))) "COLOR")
	    (SETQ $xcolor (CADR (gtstrings:split $substruct "=")))
	   )
	 )
       )
       (COND
	 ((= $case "TCASE")
	  (SETQ	$output	(gtstrings:replace
			  $output
			  (STRCAT "<" $struct ">")
			  (gtstrings:totitlecase
			    (gttext:gettext
			      $xlayout	   $xlayer	$xlocation
			      $xstyle	   $xlinetype	$xcolor
			     )
			  )
			)
	  )
	 )
	 ((= $case "LCASE")
	  (SETQ	$output
		 (gtstrings:replace
		   $output
		   (STRCAT "<" $struct ">")
		   (STRCASE (gttext:gettext
			      $xlayout	   $xlayer	$xlocation
			      $xstyle	   $xlinetype	$xcolor
			     )
			    T
		   )

		 )
	  )
	 )
	 ((= $case "UCASE")
	  (SETQ	$output
		 (gtstrings:replace
		   $output
		   (STRCAT "<" $struct ">")
		   (STRCASE (gttext:gettext
			      $xlayout	   $xlayer	$xlocation
			      $xstyle	   $xlinetype	$xcolor
			     )
		   )
		 )
	  )
	 )
	 (T
	  (SETQ	$output	(gtstrings:replace
			  $output
			  (STRCAT "<" $struct ">")
			  (gtstrings:totitlecase
			    (gttext:gettext
			      $xlayout	   $xlayer	$xlocation
			      $xstyle	   $xlinetype	$xcolor
			     )
			  )
			)
	  )
	 )
       )
      )
      (
       ;;Case - No Function, Assumed Block and Attribute
       T
       (SETQ $block (CAR (gtstrings:split $struct ":")))
       (SETQ $attribute (CADR (gtstrings:split $struct ":")))
       (COND
	 ;;Convert to TitleCase
	 (
	  (WCMATCH (STRCASE $attribute) "(TCASE)*")
	  (SETQ	$attribute
		 (gtstrings:replace
		   (STRCASE $attribute)
		   "(TCASE)"
		   ""
		 )
	  )
	  (SETQ	$output	(gtstrings:replace
			  $output
			  (STRCAT "<" $struct ">")
			  (gtstrings:totitlecase
			    (gtblocks:getattribute
			      $block
			      $attribute
			      $layout
			    )
			  )
			)
	  )
	 )
	 ;;Convert to LowerCase
	 (
	  (WCMATCH (STRCASE $attribute) "(LCASE)*")
	  (SETQ	$attribute
		 (gtstrings:replace
		   (STRCASE $attribute)
		   "(LCASE)"
		   ""
		 )
	  )
	  (SETQ	$output	(gtstrings:replace
			  $output
			  (STRCAT "<" $struct ">")
			  (STRCASE (gtblocks:getattribute
				     $block
				     $attribute
				     $layout
				   )
				   T
			  )
			)
	  )
	 )
	 ;;Convert to UpperCase
	 (
	  (WCMATCH (STRCASE $attribute) "(UCASE)*")
	  (SETQ	$attribute
		 (gtstrings:replace
		   (STRCASE $attribute)
		   "(UCASE)"
		   ""
		 )
	  )
	  (SETQ	$output	(gtstrings:replace
			  $output
			  (STRCAT "<" $struct ">")
			  (STRCASE (gtblocks:getattribute
				     $block
				     $attribute
				     $layout
				   )
			  )
			)
	  )
	 )
	 ;;No alterations to the output
	 (T
	  (SETQ	$output
		 (gtstrings:replace
		   $output
		   (STRCAT "<" $struct ">")
		   (gtblocks:getattribute $block $attribute $layout)
		 )
	  )
	 )
       )
      )
    )
  )
  (gtstrings:tofriendlyfilename $output)
)


;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTPlot:Archive</function>
<summary>
Saves a copy of the current drawing to a specified directory with a templated file name where a matching plot configuration is found ('ARCHIVE' settings will be used).
Note: If no ARCHIVE setting exists for the matching configuration, the 'GENERAL_ARCHIVING' section of general application configuration will be used.
-Removes external references matching an exclude filter (DWGDETACH).
-Removes image references matching an exclude filter (IMGDETACH).
-Binds all remaining external references.
-Audits the drawing attempting to resolve any errors.
-Purges the drawing multiple times to ensure removal of unused information.
</summary>

<examples>
<example summary="Calling the archive function">(GTPlot:Archive)</example>
</examples>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtplot:archive (/	    $config	 $filename
		       $currendoc   $path	 $configlist
		       $layouts	    $cfg	 $layout
		       $config	    $configfile	 $imgfilter
		       $dwgfilter   $folder	 $filename
		       $template    $struct
		      )
  (gterror:savesettings)
  (SETQ $verror *error*)
  (SETQ *error* gterror:trap)
  (SETVAR "CMDECHO" 0)

  (SETQ $path (gtconfig:getvalue $gtconfig "GENERAL" "PLOTPATH"))
  (PRINC
    (STRCAT
      "\nScanning plot directory for configuration files..."
    )
  )
  (SETQ $configlist (VL-DIRECTORY-FILES $path "*.cfg" 1))

  (FOREACH $cfg	$configlist
    (PRINC (STRCAT "\nFound: " $cfg))
  )

  (SETQ $layout (GETVAR "CTAB"))

  (SETQ $config nil)
  (FOREACH $configfile $configlist
    (IF
      (SSGET "X"
	     (APPEND (LIST (CONS 410 $layout))
		     (gt:dyn-ssfilter
		       (SUBSTR $configfile 1 (- (STRLEN $configfile) 4))
		     )
	     )
      )
       (SETQ $config (gtconfig:parse (STRCAT $path "\\" $configfile)))
    )
  )
  (IF (= nil $config)
    (PROGN
      (IF (NOT $gtserver)
	(ALERT
	  "Unable to find a matching archiving configuration file.\nAssuming X-Reference."
	)
      )
      (IF (= nil (gtconfig:hassection $gtconfig "GENERAL_ARCHIVING"))
	(PROGN
	  (IF (NOT $gtserver)
	    (ALERT
	      "Unable to find 'GENERAL_ARCHIVING' settings within the general configuration file."
	    )
	  )
	  (EXIT)
	)
      )
      (SETQ $imagefilter (gtconfig:getvalue
			   $gtconfig
			   "GENERAL_ARCHIVING"
			   "IMGDETACH"
			 )
	    $dwgfilter	 (gtconfig:getvalue
			   $gtconfig
			   "GENERAL_ARCHIVING"
			   "DWGDETACH"
			 )
	    $folder	 (gtconfig:getvalue
			   $gtconfig
			   "GENERAL_ARCHIVING"
			   "FOLDER"
			 )
	    $filename	 (GETVAR "DWGNAME")
      )
    )
    (PROGN
      (SETQ $imagefilter (gtconfig:getvalue $config "ARCHIVE" "IMGDETACH")
	    $dwgfilter	 (gtconfig:getvalue $config "ARCHIVE" "DWGDETACH")
	    $folder	 (gtconfig:getvalue $config "ARCHIVE" "FOLDER")
	    $filename	 (gtconfig:getvalue $config "ARCHIVE" "FILENAME")
      )
    )
  )

  (SETQ $template (gtstrings:template $folder))
  (FOREACH $struct $template
    (COND
      (
       (= "XGETDATE" (STRCASE (CAR (gtstrings:split $struct ":"))))
       (SETQ $folder (gtstrings:replace
		       $folder
		       (STRCAT "<" $struct ">")
		       (gtmisc:getdatecustom
			 (CADR (gtstrings:split $struct ":"))
		       )
		     )
       )
      )
    )
  )

  (SETQ $filename (gtplot:buildpdfname $filename $layout))
  (SETQ $folder (gtsystem:buildpath $folder))
  (SETQ $currentdoc (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT)))
  (VLA-SAVEAS
    $currentdoc
    (STRCAT $folder $filename)
    AC2007_DWG
  )

  (COMMAND "_.-IMAGE" "DETACH" $imagefilter)
  (gtblocks:deletereference $dwgfilter)
  (COMMAND "_.-XREF" "DETACH" $dwgfilter)

  (COMMAND "_.-XREF" "BIND" "*")
  (COMMAND "_.AUDIT" "N")
  (REPEAT 5
    (VLA-PURGEALL $currentdoc)
  )
  (IF (NOT $gtserver)
    (ALERT
      (STRCAT "Archive has finished with the drawing now saved at:\n"
	      $folder
	      $filename
	      "\nThe drawing CANNOT be closed programatically..."
      )
    )
  )
  (VLA-SAVE $currentdoc)
  (VLAX-RELEASE-OBJECT $currentdoc)
  (gterror:restoresettings)
  (SETQ *error* nil)
  (PRINC)
)





(DEFUN gtplot:archive ($configurationType /	    $config	 $filename
		       $currendoc   $path	 $configlist
		       $layouts	    $cfg	 $layout
		       $config	    $configfile	 $imgfilter
		       $dwgfilter   $folder	 $filename
		       $template    $struct
		      )
  (gterror:savesettings)
  (SETQ $verror *error*)
  (SETQ *error* gterror:trap)
  (SETVAR "CMDECHO" 0)

  (SETQ $path (gtconfig:getvalue $gtconfig "GENERAL" "PLOTPATH"))
  (PRINC
    (STRCAT
      "\nScanning plot directory for configuration files..."
    )
  )
  (SETQ $configlist (VL-DIRECTORY-FILES $path "*.cfg" 1))

  (FOREACH $cfg	$configlist
    (PRINC (STRCAT "\nFound: " $cfg))
  )

  (SETQ $layout (GETVAR "CTAB"))

  (SETQ $config nil)
  (FOREACH $configfile $configlist
    (IF
      (SSGET "X"
	     (APPEND (LIST (CONS 410 $layout))
		     (gt:dyn-ssfilter
		       (SUBSTR $configfile 1 (- (STRLEN $configfile) 4))
		     )
	     )
      )
       (SETQ $config (gtconfig:parse (STRCAT $path "\\" $configfile)))
    )
  )
  (IF (= nil $config)
    (PROGN
      (IF (NOT $gtserver)
	(ALERT
	  "Unable to find a matching archiving configuration file.\nAssuming X-Reference."
	)
      )
      (IF (= nil (gtconfig:hassection $gtconfig "GENERAL_ARCHIVING"))
	(PROGN
	  (IF (NOT $gtserver)
	    (ALERT
	      "Unable to find 'GENERAL_ARCHIVING' settings within the general configuration file."
	    )
	  )
	  (EXIT)
	)
      )
      (SETQ $imagefilter (gtconfig:getvalue
			   $gtconfig
			   "GENERAL_ARCHIVING"
			   "IMGDETACH"
			 )
	    $dwgfilter	 (gtconfig:getvalue
			   $gtconfig
			   "GENERAL_ARCHIVING"
			   "DWGDETACH"
			 )
	    $folder	 (gtconfig:getvalue
			   $gtconfig
			   "GENERAL_ARCHIVING"
			   "FOLDER"
			 )
	    $filename	 (GETVAR "DWGNAME")
      )
    )
    (PROGN
      (SETQ $imagefilter (gtconfig:getvalue $config $configurationType "IMGDETACH")
	    $dwgfilter	 (gtconfig:getvalue $config $configurationType "DWGDETACH")
	    $folder	 (gtconfig:getvalue $config $configurationType "FOLDER")
	    $filename	 (gtconfig:getvalue $config $configurationType "FILENAME")
      )
    )
  )

  (SETQ $template (gtstrings:template $folder))
  (FOREACH $struct $template
    (COND
      (
       (= "XGETDATE" (STRCASE (CAR (gtstrings:split $struct ":"))))
       (SETQ $folder (gtstrings:replace
		       $folder
		       (STRCAT "<" $struct ">")
		       (gtmisc:getdatecustom
			 (CADR (gtstrings:split $struct ":"))
		       )
		     )
       )
      )
    )
  )

  (SETQ $filename (gtplot:buildpdfname $filename $layout))
  (SETQ $folder (gtsystem:buildpath $folder))
  (SETQ $currentdoc (VLA-GET-ACTIVEDOCUMENT (VLAX-GET-ACAD-OBJECT)))
  (VLA-SAVEAS
    $currentdoc
    (STRCAT $folder $filename)
    AC2007_DWG
  )

  (COMMAND "_.-IMAGE" "DETACH" $imagefilter)
  (gtblocks:deletereference $dwgfilter)
  (COMMAND "_.-XREF" "DETACH" $dwgfilter)

  (COMMAND "_.-XREF" "BIND" "*")
  (COMMAND "_.AUDIT" "N")
  (REPEAT 5
    (VLA-PURGEALL $currentdoc)
  )
  (IF (NOT $gtserver)
    (ALERT
      (STRCAT "Archive has finished with the drawing now saved at:\n"
	      $folder
	      $filename
	      "\nThe drawing CANNOT be closed programatically..."
      )
    )
  )
  (VLA-SAVE $currentdoc)
  (VLAX-RELEASE-OBJECT $currentdoc)
  (gterror:restoresettings)
  (SETQ *error* nil)
  (PRINC)
)