;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:Parse</function>
<sumary>Parses a specified INI structured configuration file into an associated list of lists.</summary>

<examples>
	<example sumary="Reading a configuration file into a variable">(SETQ configFile (GTConfig:Parse "C:\\Some\\Configuration\\File"))</example>
	<example sumary="Sample INI File">
		[SOME SECTION]
		UniqueKey=Value of Key
		AnotherKey=Some other value
		[ANOTHER_SECTION]
		UniqueKey=Value of another key
	</example>
</examples>

<param name="$file">System path to the configuration file.</param>
<returns>Associated List, or nil</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtconfig:parse ($file / $line $sub $list $i)
  (SETQ $file (gtstrings:replace2 $file "\\\\" "\\"))
  (IF (AND (SETQ $file (FINDFILE $file)) (SETQ $file (OPEN $file "r")))
    (PROGN
      (WHILE (SETQ $line (READ-LINE $file))
	(COND
	  (
	   (WCMATCH $line "`[*`]")
	   (IF $sub
	     (SETQ $list (CONS (REVERSE $sub) $list))
	   )
	   (SETQ $sub (LIST (SUBSTR $line 2 (- (STRLEN $line) 2))))
	  )

	  (
	   (WCMATCH $line "*=*")
	   (SETQ $i 0)
	   (WHILE (/= "=" (SUBSTR $line (SETQ $i (1+ $i)) 1)))
	   (SETQ $sub (CONS (LIST (SUBSTR $line 1 (1- $i)) (SUBSTR $line (1+ $i))) $sub))
	  )
	  ((SETQ $sub (CONS (LIST $line) $sub)))
	)
      )
      (CLOSE $file)
      (IF $sub
	(SETQ $list (CONS (REVERSE $sub) $list))
      )
    )
  )
  (REVERSE $list)
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:GetValue</function>
<summary>Gets a configuration value from an associated configuration list.</summary>

<examples>
	<example summary="Assigning a value to a configuration value.">(SETQ variable (GTConfig:GetValue configList "HEADER SECTION" "Key"))</example>
</examples>

<param name="$alist">Associated list of the configuration file.</param>
<param name="$section">Section title (string).</param>
<param name="$key">Key (string).</param>

<returns>$key value if the key exists. nil if the key doesn't.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtconfig:getvalue ($alist $section $key)
  (IF (SETQ $section (CDR (ASSOC $section $alist)))
    (CADR (ASSOC $key $section))
    nil
  )
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:HasSection</function>
<summary>Discovers if the configuration list has a specified section.</summary>

<examples>
	<example summary="">(GTConfig:HasSection configList "SOME SECTION")</example>
</examples>

<param name="$alist">Associated list of the configuration file.</param>
<param name="$section">Section title (string).</param>

<returns>T if the section exists. nil if the section doesn't.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtconfig:hassection ($alist $section)
  (IF (CDR (ASSOC $section $alist))
    T
    nil
  )
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:HasKey</function>
<summary>Discovers if the configuration list has a specified key.</summary>

<examples>
<example summary="">(GTConfig:HasKey configList "SomeSection" "Key")</example>
</examples>

<param name="$alist">Associated list of the configuration file.</param>
<param name="$section">Section title (string).</param>
<param name="$key">Key (string).</param>

<returns>T if the key exists. nil if the key doesn't.</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtconfig:haskey ($alist $section $key)
  (IF (SETQ $section (CDR (ASSOC $section $alist)))
    (IF	(CADR (ASSOC $key $section))
      T
      nil
    )
  )
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:SetValue</function>
<summary>
Sets a Section key to a specified value.
Notes:
-All values of the same key (if duplicated within a section) will be changed.
-The section, key and value will be created if required.
-Only the instance of the configuration file in memory will be altered.
</summary>

<examples>
	<example summary="Simple value changing.">(GTConfig:SetValue configList "SECTION" "Key" "new value")</example>
</examples>

<param name="$alist">Associated list of the configuration file.</param>
<param name="$section">Section title (string).</param>
<param name="$key">Key (string).</param>
<param name="$value">New value (string).</param>

<returns>Altered configuration list (associated list).</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtconfig:setvalue ($alist $section $key $value / $subsection)
  (IF (AND (gtconfig:hassection $alist $section)
	   (gtconfig:haskey $alist $section $key)
      )
    (PROGN
      (SETQ $subsection (CDR (ASSOC $section $alist)))
      (SETQ $subsection (SUBST (LIST $key $value) (ASSOC $key $subsection) $subsection))
      (SETQ $alist (SUBST (CONS $section $subsection) (ASSOC $section $alist) $alist))
    )
    (PROGN
      (SETQ $alist (gtconfig:addsection $alist $section $key $value))
    )
  )
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:AddSection</function>
<summary>Appends a new Section to an configuration list.</summary>

<examples>
<example summary="Adding a new section.">(SETQ configList (GTConfig:AddSection configList "NEW_SECTION" "NewKey" "new value"))</example>
</examples>

<param name="$alist">Associated list of the configuration file.</param>
<param name="$section">Section title (string).</param>
<param name="$key">Key (string).</param>
<param name="$value">New value (string).</param>

<returns>Altered Configuration List</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtconfig:addsection ($alist $section $key $value / $sub)
  ;;If the section exists within the config list, append to it.
  (IF (gtconfig:hassection $alist $section)
    (PROGN
      (SETQ $sub (CDR (ASSOC $section $alist)))
      (SETQ $sub (APPEND $sub (LIST (LIST $key $value))))
      (SETQ $sub (CONS $section $sub))
      (SETQ $section (ASSOC $section $alist))
      (SETQ $alist (SUBST $sub $section $alist))
    )
    ;;Else, create the new section
    (PROGN
      (SETQ $sub (LIST (LIST $key $value)))
      (SETQ $sub (CONS $section $sub))
      (SETQ $alist (APPEND $alist (LIST $sub)))
    )
  )
  $alist
)

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;|
<function>GTConfig:Save</function>
<summary>Saves an configuration list to file.
Notes:
-Will create a file if required.
-Will overwrite contents of an existing file.
</summary>

<examples>
<example summary="Saving the configuration.">(GTConfig:save configList "C:\\Some\\path\\to\\file.cfg"</example>
</examples>

<param name="$alist">Associated list of the configuration file.</param>
<param name="$file">Path to configuration file (including file/extension).</param>

<returns>Nothing</returns>
|;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
(DEFUN gtconfig:save ($alist $file / $key $section)
  (IF (SETQ $file (OPEN $file "w"))
    (PROGN
      (FOREACH $section	$alist
	(WRITE-LINE (STRCAT "[" (CAR $section) "]") $file)
	(FOREACH $key (CDR $section)
	  (WRITE-LINE
	    (IF	(CADR $key)
	      (STRCAT (CAR $key) "=" (CADR $key))
	      (CAR $key)
	    )
	    $file
	  )
	)
      )
      (NOT (CLOSE $file))
    )
  )
  (PRINC)
)