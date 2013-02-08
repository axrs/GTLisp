(VL-LOAD-COM)

;;; In case this file gets compiled into a separate-namespace
;;; VLX, export the functions that should be visible.  The
;;; following has no effect unless the document is compiled
;;; into a separate-namespace VLX.
(VL-DOC-EXPORT 'adolisp_connecttodb)
(VL-DOC-EXPORT 'adolisp_dosql)
(VL-DOC-EXPORT 'adolisp_disconnectfromdb)
(VL-DOC-EXPORT 'adolisp_errorprinter)
(VL-DOC-EXPORT 'adolisp_gettablesandviews)
(VL-DOC-EXPORT 'adolisp_variant-value)

;;; Set up some variables that must be global (within
;;; this file)

;;; Define a VB data type that Visual LISP forgot
(IF (NOT vlax-vbdecimal)
    (SETQ vlax-vbdecimal 14)
)

;;; Set a flag if we are running in AutoCAD 2000 (not 2000i,
;;; 2002, ...)
(IF (< (ATOF (GETVAR "ACADVER")) 15.05)
    (SETQ adolisp_isautocad2000 T)
)

;; Import the ADO type library if it hasn't already been
;; loaded.
(IF (NULL ADOMETHOD-APPEND)
    (COND
        ;; If we can find the library in the registry ...
        ((AND (SETQ adolisp_adodllpath
                       (VL-REGISTRY-READ
                           "HKEY_CLASSES_ROOT\\ADODB.Command\\CLSID"
                       )
              )
              (SETQ adolisp_adodllpath
                       (VL-REGISTRY-READ
                           (STRCAT "HKEY_CLASSES_ROOT\\CLSID\\"
                                   adolisp_adodllpath
                                   "\\InProcServer32"
                           )
                       )
              )
              (PROGN
                  ;; Workaround for bug in AutoCAD 2008 under Vista, returning
                  ;; a dotted pair list containing the string instead of the
                  ;; string
                  (IF (LISTP adolisp_adodllpath)
                      (SETQ adolisp_adodllpath (CDR adolisp_adodllpath))
                  )
                  (FINDFILE adolisp_adodllpath)
              )
         )
         ;; Import it
         (VLAX-IMPORT-TYPE-LIBRARY
             :TLB-FILENAME adolisp_adodllpath :METHODS-PREFIX "ADOMethod-" :PROPERTIES-PREFIX "ADOProperty-" :CONSTANTS-PREFIX "ADOConstant-")
        )
        ;; Or if we can find it where we expect to find it ...
        ((SETQ adolisp_adodllpath
                  (FINDFILE
                      (IF (GETENV "systemdrive")
                          (STRCAT
                              (GETENV "systemdrive")
                              "\\program files\\common files\\system\\ado\\msado15.dll"
                          )
                          "c:\\program files\\common files\\system\\ado\\msado15.dll"
                      )
                  )
         )
         ;; Import it
         (VLAX-IMPORT-TYPE-LIBRARY
             :TLB-FILENAME adolisp_adodllpath :METHODS-PREFIX "ADOMethod-" :PROPERTIES-PREFIX "ADOProperty-" :CONSTANTS-PREFIX "ADOConstant-")
        )
        ;; Can't find the library, tell the user
        (T
         (ALERT
             (STRCAT "Cannot find\n\""
                     (IF adolisp_adodllpath
                         adolisp_adodllpath
                         "msado15.dll"
                     )
                     "\""
             )
         )
        )
    )
)

;;; A routine to connect to a database

;;; Arguments:
;;;     ConnectString:  Either the name of a .UDL file,
;;;                     including the ".UDL", or an
;;;                     OLEDB connection string.
;;;                     If this argument is the name of
;;;                     a UDL file without a full path,
;;;                     it is searched for in the
;;;                     current directory, the
;;;                     AutoCAD search path, and the
;;;                     AutoCAD Data Source Location.
;;;     UserName: The user name to use when connecting.
;;;               May be a null string if the user name is
;;;               specified in the first argument or the
;;;               first argument is a UDL file name.
;;;     Password: The password to use when connecting. 
;;                May be a null string if the password is
;;;               supplied in the first argument or the
;;;               first argument is a UDL file name.

;;; Return value:
;;;  If anything fails, NIL.  Call (ADOLISP_ErrorPrinter) to
;;;  print error messages to the command line.
;;;  Otherwise, an ADO Connection Object.

(DEFUN adolisp_connecttodb (connectstring username password / isudl fulludlfilename connectionobject tempobject returnvalue connectionpropertiesobject connectionparsingpropertyobject)
    ;; Assume no error
    (SETQ adolisp_errorlist nil
          adolisp_lastsqlstatement
             nil
    )

    ;; If the connect string is a UDL file name ...
    (IF (= ".UDL"
           (STRCASE
               (SUBSTR connectstring (- (STRLEN connectstring) 3))
           )
        )
        (PROGN
            ;; Set a flag that it's a UDL file
            (SETQ isudl T)
            ;; Try to find it
            (COND
                ((SETQ fulludlfilename (FINDFILE connectstring)))
                ;; Didn't find it in the current directory or
                ;; the AutoCAD search path, try the AutoCAD
                ;; Data Source location
                ((SETQ fulludlfilename
                          (FINDFILE (STRCAT (VLAX-GET-PROPERTY
                                                (VLAX-GET-PROPERTY
                                                    (VLAX-GET-PROPERTY
                                                        (VLAX-GET-ACAD-OBJECT)
                                                        "Preferences"
                                                    )
                                                    "Files"
                                                )
                                                "WorkspacePath"
                                            )
                                            "\\"
                                            connectstring
                                    )
                          )
                 )
                )
                ;; Didn't find it, store an error message
                (T
                 (SETQ adolisp_errorlist
                          (LIST (LIST (CONS "ADOLISP connection error"
                                            (STRCAT "Can't find \""
                                                    connectstring
                                                    "\""
                                            )
                                      )
                                )
                          )
                 )
                )
            )
        )
    )

    ;; If the first argument is a UDL file name... ...
    (IF isudl
        ;; If we found it ...
        (IF fulludlfilename
            (PROGN
                ;; Create an ADO connection object
                (SETQ connectionobject
                         (VLAX-CREATE-OBJECT
                             "ADODB.Connection"
                         )
                )
                ;; Try to open the connection.  If there is an error
                ;; ...
                (IF (VL-CATCH-ALL-ERROR-P
                        (SETQ tempobject
                                 (VL-CATCH-ALL-APPLY
                                     'VLAX-INVOKE-METHOD
                                     (LIST connectionobject
                                           "Open"
                                           (STRCAT "File Name=" fulludlfilename)
                                           username
                                           password
                                           ADOCONSTANT-ADCONNECTUNSPECIFIED
                                     )
                                 )
                        )
                    )
                    (PROGN
                        ;; Save the error information
                        (SETQ adolisp_errorlist
                                 (adolisp_errorprocessor tempobject connectionobject)
                        )
                        ;; Release the connection object
                        (VLAX-RELEASE-OBJECT connectionobject)
                    )
                    ;; It worked, store the connection object in our
                    ;; return value
                    (SETQ returnvalue connectionobject)
                )
            )
        )
        ;; The connect string is not a UDL file name.
        (PROGN
            ;; Create an ADO connection object
            (SETQ connectionobject
                     (VLAX-CREATE-OBJECT "ADODB.Connection")
            )
            ;; Try to open the connection.  If there is an error ...
            (IF (VL-CATCH-ALL-ERROR-P
                    (SETQ tempobject
                             (VL-CATCH-ALL-APPLY
                                 'VLAX-INVOKE-METHOD
                                 (LIST
                                     connectionobject "Open" connectstring username password ADOCONSTANT-ADCONNECTUNSPECIFIED)
                             )
                    )
                )
                (PROGN
                    ;; Save the error information
                    (SETQ adolisp_errorlist
                             (adolisp_errorprocessor tempobject connectionobject)
                    )
                    ;; Release the connection object
                    (VLAX-RELEASE-OBJECT connectionobject)
                )
                ;; It worked, store the connection object in our
                ;; return value
                (SETQ returnvalue connectionobject)
            )
        )
    )
    ;; If we made a connection ...
    (IF returnvalue
        (PROGN
            ;; If we want to set ODBC Parsing to true ...
            (IF (NOT adolisp_donotforcejetodbcparsing)
                (PROGN
                    ;; Get the properties collection
                    (SETQ connectionpropertiesobject
                             (VLAX-GET-PROPERTY
                                 returnvalue
                                 "Properties"
                             )
                    )
                    ;; If the properties collection has a "Jet OLEDB:ODBC
                    ;; Parsing" item ...
                    (IF (NOT (VL-CATCH-ALL-ERROR-P
                                 (SETQ connectionparsingpropertyobject
                                          (VL-CATCH-ALL-APPLY
                                              'VLAX-GET-PROPERTY
                                              (LIST
                                                  connectionpropertiesobject
                                                  "ITEM"
                                                  "Jet OLEDB:ODBC Parsing"
                                              )
                                          )
                                 )
                             )
                        )
                        ;; Set the "Jet OLEDB:ODBC Parsing" item to
                        ;; "true" so the Jet engine accepts double-quotes
                        ;; around delimited identifiers
                        (VLAX-PUT-PROPERTY
                            connectionparsingpropertyobject
                            "VALUE"
                            :VLAX-TRUE
                        )
                    )
                )
            )
            ;; And release our objects
            (IF (= 'vla-object (TYPE connectionparsingpropertyobject))
                (VLAX-RELEASE-OBJECT connectionparsingpropertyobject)
            )
            (IF (= 'vla-object (TYPE connectionpropertiesobject))
                (VLAX-RELEASE-OBJECT connectionpropertiesobject)
            )
        )
    )
    returnvalue
)


;;; A function to execute an arbitrary SQL statement
;;; (replacable parameters are not supported).

;;; Arguments:
;;;     ConnectionObject: An ADO Connection Object.
;;;     SQLString: the SQL statement to execute.

;;; Return value:

;;;  If anything fails, NIL.  Call (ADOLISP_ErrorPrinter) to
;;;  print error messages to the command line.  Otherwise:

;;;  If the SQL statement is a "select ..." statement that
;;;  could return rows, returns a list of lists.  The first
;;;  is a list of the column names.  If any rows were
;;;  returned, the subsequent sub-lists contain the
;;;  returned rows in the same order as the column names
;;;  in the first sub-list.

;;;  If the SQL statement is a "delete ...", "update ...", or
;;;  "insert ..." that cannot return any rows:
;;;    If the program is running in AutoCAD 2000, T
;;;    If the program is running in AutoCAD 2000i or
;;;    later, the integer number of rows affected.

(DEFUN adolisp_dosql (connectionobject sqlstatement / recordsetobject fieldsobject fieldnumber fieldcount fieldlist recordsaffected tempobject returnvalue commandobject iserror fielditem
                      fieldpropertieslist fieldname)
    ;; Assume no error
    (SETQ adolisp_errorlist nil
          ;; Initialize global variables
          adolisp_lastsqlstatement
             sqlstatement
          adolisp_fieldspropertieslist
             nil
    )
    ;; If we are working in AutoCAD 2000 ...
    (IF adolisp_isautocad2000
        ;; Then we can't use the Execute method of the Command
        ;; object because returning values in parameters (of a
        ;; function loaded from an external library) is broken.
        (PROGN
            ;; Create an ADO Recordset and set the cursor and lock
            ;; types
            (SETQ recordsetobject
                     (VLAX-CREATE-OBJECT "ADODB.RecordSet")
            )
            (VLAX-PUT-PROPERTY
                recordsetobject
                "cursorType"
                ADOCONSTANT-ADOPENKEYSET
            )
            (VLAX-PUT-PROPERTY
                recordsetobject
                "LockType"
                ADOCONSTANT-ADLOCKOPTIMISTIC
            )
            ;; Open the recordset.  If there is an error ...
            (IF (VL-CATCH-ALL-ERROR-P
                    (SETQ tempobject
                             (VL-CATCH-ALL-APPLY
                                 'VLAX-INVOKE-METHOD
                                 (LIST recordsetobject "Open" sqlstatement connectionobject nil nil ADOCONSTANT-ADCMDTEXT)
                             )
                    )
                )
                ;; Save the error information
                (PROGN
                    (SETQ adolisp_errorlist
                             (adolisp_errorprocessor tempobject connectionobject)
                    )
                    (SETQ iserror T)
                    (VLAX-RELEASE-OBJECT recordsetobject)
                )
                ;; Otherwise, set an indicator that it worked
                (SETQ recordsaffected T)
            )
        )
        ;; We're in AutoCAD 2000i or above, we can use the
        ;; Execute method of the Command object and see
        ;; how many records are affected by an UPDATE, INSERT,
        ;; or DELETE
        (PROGN
            ;; Create an ADO command object and store the query
            ;; and connection
            (SETQ commandobject (VLAX-CREATE-OBJECT "ADODB.Command"))
            (VLAX-PUT-PROPERTY
                commandobject
                "CommandText"
                sqlstatement
            )
            (VLAX-PUT-PROPERTY
                commandobject
                "ActiveConnection"
                connectionobject
            )
            (VLAX-PUT-PROPERTY
                commandobject
                "CommandType"
                ADOCONSTANT-ADCMDTEXT
            )

            ;; Create an ADO Recordset
            (SETQ recordsetobject
                     (VLAX-CREATE-OBJECT "ADODB.RecordSet")
            )
            ;; Open the recordset.  If there is an error ...
            (IF (VL-CATCH-ALL-ERROR-P
                    (SETQ tempobject
                             (VL-CATCH-ALL-APPLY
                                 'VLAX-INVOKE-METHOD
                                 (LIST commandobject "Execute" nil nil nil)
                             )
                    )
                )
                ;; Save the error information
                (PROGN
                    (SETQ adolisp_errorlist
                             (adolisp_errorprocessor tempobject connectionobject)
                    )
                    (SETQ iserror T)
                    (VLAX-RELEASE-OBJECT commandobject)
                    (VLAX-RELEASE-OBJECT recordsetobject)
                )
                (PROGN
                    ;; No error, save the recordset
                    (SETQ recordsetobject tempobject)
                )
            )
        )
    )
    ;; If there were no errors ...
    (IF (NOT iserror)
        ;; If the recordset is closed ...
        (IF (= ADOCONSTANT-ADSTATECLOSED
               (VLAX-GET-PROPERTY recordsetobject "State")
            )
            ;; Then the SQL statement was a "delete ..." or an
            ;; "insert ..." or an "update ..." which doesn't
            ;; return any rows.
            (PROGN
                (SETQ returnvalue (NOT iserror))
                ;; And release the recordset and command; we're done.
                (VLAX-RELEASE-OBJECT recordsetobject)
                (IF (NOT adolisp_isautocad2000)
                    (VLAX-RELEASE-OBJECT commandobject)
                )
            )
            ;; The recordset is open, the SQL statement
            ;; was a "select ...".
            (PROGN
                ;; Get the Fields collection, which
                ;; contains the names and properties of the
                ;; selected columns
                (SETQ fieldsobject (VLAX-GET-PROPERTY
                                       recordsetobject
                                       "Fields"
                                   )
                      ;; Get the number of columns
                      fieldcount   (VLAX-GET-PROPERTY fieldsobject "Count")
                      fieldnumber  -1
                )
                ;; For all the fields ...
                (WHILE
                    (> fieldcount (SETQ fieldnumber (1+ fieldnumber)))
                       (SETQ fielditem           (VLAX-GET-PROPERTY fieldsobject "Item" fieldnumber)
                             ;; Get the names of all the columns in a list to
                             ;; be the first part of the return value
                             fieldname           (VLAX-GET-PROPERTY fielditem "Name")
                             fieldlist           (CONS fieldname fieldlist)
                             fieldpropertieslist nil
                       )
                       (FOREACH fieldproperty '("Type" "Precision" "NumericScale" "DefinedSize" "Attributes")
                           (SETQ fieldpropertieslist (CONS (CONS fieldproperty (VLAX-GET-PROPERTY fielditem fieldproperty)) fieldpropertieslist))
                       )
                       ;; Save the list in the global list
                       (SETQ adolisp_fieldspropertieslist (CONS (CONS fieldname fieldpropertieslist) adolisp_fieldspropertieslist))
                )
                ;; Get the FieldsPropertiesList in the right order
                (SETQ adolisp_fieldspropertieslist (REVERSE adolisp_fieldspropertieslist))

                ;; Initialize the return value
                (SETQ returnvalue (LIST (REVERSE fieldlist)))
                ;; If there are any rows in the recordset ...
                (IF
                    (NOT (AND (= :VLAX-TRUE
                                 (VLAX-GET-PROPERTY recordsetobject "BOF")
                              )
                              (= :VLAX-TRUE
                                 (VLAX-GET-PROPERTY recordsetobject "EOF")
                              )
                         )
                    )
                       ;; We're about to get tricky, hang on!  Create the
                       ;; final results list ...
                       (SETQ
                           returnvalue
                              ;; By appending the list of rows to the list of
                              ;; fields.
                              (APPEND
                                  (LIST (REVERSE fieldlist))
                                  ;; Uses Douglas Wilson's elegant
                                  ;; list-transposing code from
                                  ;; http://xarch.tu-graz.ac.at/autocad/lisp/
                                  ;; to create the list of rows, because
                                  ;; GetRows returns items in column order
                                  (APPLY
                                      'MAPCAR
                                      (CONS
                                          'LIST
                                          ;; Set up to convert a list of lists
                                          ;; of variants to a list of lists of
                                          ;; items that AutoLISP understands
                                          (MAPCAR
                                              '(LAMBDA (inputlist)
                                                   (MAPCAR '(LAMBDA (item)
                                                                (adolisp_variant-value item)
                                                            )
                                                           inputlist
                                                   )
                                               )
                                              ;; Get the rows, converting them from
                                              ;; a variant to a safearray to a list
                                              (VLAX-SAFEARRAY->LIST
                                                  (VLAX-VARIANT-VALUE
                                                      (VLAX-INVOKE-METHOD
                                                          recordsetobject
                                                          "GetRows"
                                                          ADOCONSTANT-ADGETROWSREST
                                                      )
                                                  )
                                              )
                                          )
                                      )
                                  )
                              )
                       )
                )
                ;; Close the recordset and release it and the
                ;; command
                (VLAX-INVOKE-METHOD recordsetobject "Close")
                (VLAX-RELEASE-OBJECT recordsetobject)
                (IF (NOT adolisp_isautocad2000)
                    (VLAX-RELEASE-OBJECT commandobject)
                )
            )
        )
    )
    ;; And return the results
    returnvalue
)

;;; A function to close a connection and release
;;; the connection object.

;;; Argument:
;;;    An ADO Connection Object.

;;; Return value:
;;;    Always returns T

(DEFUN adolisp_disconnectfromdb (connectionobject)
    (SETQ adolisp_errorlist nil
          adolisp_lastsqlstatement
             nil
    )
    (VLAX-INVOKE-METHOD connectionobject "Close")
    (VLAX-RELEASE-OBJECT connectionobject)
    T
)

;;; ------------------------------------------------------------

;;; ADOLISP utility functions

;;; A function to print the list of errors generated
;;; by the ADOLISP_ErrorProcessor function.  The functions
;;; are separate so ADOLISP_ErrorProcessor can be called
;;; while a DCL dialog box is displayed and then
;;; ADOLISP_ErrorPrinter can be called after the dialog
;;; box has been removed.

;;; No arguments, no return value.

(DEFUN adolisp_errorprinter ()
    (IF adolisp_lastsqlstatement
        (PROMPT (STRCAT "\nLast SQL statement:\n\""
                        adolisp_lastsqlstatement
                        "\"\n\n"
                )
        )
    )
    (FOREACH errorlist adolisp_errorlist
        (PROMPT "\n")
        (FOREACH erroritem errorlist
            (PROMPT
                (STRCAT (CAR erroritem) "\t\t" (CDR erroritem) "\n")
            )
        )
    )
    (PRIN1)
)

;;; A function to obtain the names of all
;;; the tables and views in a database.
;;; (Views are called "Queries" in Microsoft Access.)

;;; Argument:
;;;     ConnectionObject: An ADO Connection Object

;; Return value:
;;;  A list of two lists.
;;;  The first list contains the table names.
;;;  The second list contains the view names.

(DEFUN adolisp_gettablesandviews (connectionobject / tempobject tableslist templist viewslist)
    (SETQ adolisp_errorlist nil
          adolisp_lastsqlstatement
             nil
    )
    (SETQ recordsetobject (VLAX-CREATE-OBJECT "ADODB.RecordSet"))
    ;; If we fail getting a recordset of the tables and views
    ;; ...
    (IF (VL-CATCH-ALL-ERROR-P
            (SETQ recordsetobject
                     (VL-CATCH-ALL-APPLY
                         'VLAX-INVOKE-METHOD
                         (LIST
                             connectionobject
                             "OpenSchema"
                             ADOCONSTANT-ADSCHEMATABLES
                         )
                     )
            )
        )
        ;; Save the error information
        (SETQ adolisp_errorlist
                 (adolisp_errorprocessor recordsetobject connectionobject)
        )
        (PROGN
            ;; Got the recordset!
            ;; We're about to get tricky, hang on!  Convert the
            ;; recordset object to a LISP list ...
            (SETQ
                templist
                   ;; Uses Douglas Wilson's elegant
                   ;; list-transposing code from
                   ;; http://xarch.tu-graz.ac.at/autocad/lisp/
                   ;; to create the list of rows, because
                   ;; GetRows returns items in column order
                   (APPLY
                       'MAPCAR
                       (CONS
                           'LIST
                           ;; Set up to convert a list of lists
                           ;; of variants to a list of lists of
                           ;; items that AutoLISP understands
                           (MAPCAR
                               '(LAMBDA (inputlist)
                                    (MAPCAR '(LAMBDA (item)
                                                 (adolisp_variant-value item)
                                             )
                                            inputlist
                                    )
                                )
                               ;; Get the rows, converting them from
                               ;; a variant to a safearray to a list
                               (VLAX-SAFEARRAY->LIST
                                   (VLAX-VARIANT-VALUE
                                       (VLAX-INVOKE-METHOD
                                           recordsetobject
                                           "GetRows"
                                           ADOCONSTANT-ADGETROWSREST
                                       )
                                   )
                               )
                           )
                       )
                   )
            )
            ;; Now filter out the system tables and
            ;; sort the tables and views into the
            ;; correct lists
            (FOREACH item templist
                (COND
                    ((= (NTH 3 item) "VIEW")
                     (SETQ viewslist (CONS (NTH 2 item) viewslist))
                    )
                    ((= (NTH 3 item) "TABLE")
                     (SETQ tableslist (CONS (NTH 2 item) tableslist))
                    )
                )
            )
            ;; Close the recordset
            (VLAX-INVOKE-METHOD recordsetobject "Close")
        )
    )
    (VLAX-RELEASE-OBJECT recordsetobject)
    (LIST tableslist viewslist)
)

;;; A function to obtain the properties
;;; of the columns in a table.

;;; Arguments:
;;;     ConnectionObject: An ADO Connection Object
;;;     TableName: A string containing the table name.
;;;                Not case sensitive.

;;; Return value:
;;;  If nothing was found, NIL.
;;;  If columns were found for that table, a
;;;  list of lists, one sub-list for each column.
;;;  Each sub-list contains:
;;;     Column name
;;;      dotted-pair lists:
;;;         "Type" . OLEDB DataTypeEnum
;;;         "DefinedSize" . Maximum length
;;;                         (character data only)
;;;                         (0 if no maximum)
;;;         "Attributes" . OLEDB FieldAttributeEnum
;;;         "Precision" . number of digits (numerical
;;;                       columns only)
;;;         "Ordinal" . number of the column in the
;;;                     table (the first column is 1)

;;; The sub-lists in the return value will be in
;;; the same order as the ordinal values of the columns.


(DEFUN adolisp_getcolumns (connectionobject tablename / tempobject templist returnvalue)
    (SETQ adolisp_errorlist
             nil
          adolisp_lastsqlstatement
             nil
          tablename (STRCASE tablename)
    )
    (SETQ recordsetobject (VLAX-CREATE-OBJECT "ADODB.RecordSet"))
    ;; If we fail getting a recordset of all
    ;; the columns in the database ...
    (IF (VL-CATCH-ALL-ERROR-P
            (SETQ recordsetobject
                     (VL-CATCH-ALL-APPLY
                         'VLAX-INVOKE-METHOD
                         (LIST
                             connectionobject
                             "OpenSchema"
                             ADOCONSTANT-ADSCHEMACOLUMNS
                         )
                     )
            )
        )
        ;; Save the error information
        (SETQ adolisp_errorlist
                 (adolisp_errorprocessor
                     recordsetobject
                     connectionobject
                 )
        )
        (PROGN
            ;; Got the recordset!
            ;; We're about to get tricky, hang on!  Convert the
            ;; recordset object to a LISP list ...
            (SETQ
                templist
                   ;; Uses Douglas Wilson's elegant
                   ;; list-transposing code from
                   ;; http://xarch.tu-graz.ac.at/autocad/lisp/
                   ;; to create the list of rows, because
                   ;; GetRows returns items in column order
                   (APPLY
                       'MAPCAR
                       (CONS
                           'LIST
                           ;; Set up to convert a list of lists
                           ;; of variants to a list of lists of
                           ;; items that AutoLISP understands
                           (MAPCAR
                               '(LAMBDA (inputlist)
                                    (MAPCAR '(LAMBDA (item)
                                                 (adolisp_variant-value item)
                                             )
                                            inputlist
                                    )
                                )
                               ;; Get the rows, converting them from
                               ;; a variant to a safearray to a list
                               (VLAX-SAFEARRAY->LIST
                                   (VLAX-VARIANT-VALUE
                                       (VLAX-INVOKE-METHOD
                                           recordsetobject
                                           "GetRows"
                                           ADOCONSTANT-ADGETROWSREST
                                       )
                                   )
                               )
                           )
                       )
                   )
            )
            ;; Close the recordset
            (VLAX-INVOKE-METHOD recordsetobject "Close")
            ;; Loop over all the columns
            (FOREACH columnlist templist
                ;; If this column belongs to the correct table ...
                (IF (= tablename (STRCASE (NTH 2 columnlist)))
                    ;; Store its information
                    (SETQ returnvalue
                             (CONS
                                 (LIST (NTH 3 columnlist)
                                       (CONS "Type" (NTH 11 columnlist))
                                       (CONS "DefinedSize"
                                             (IF (NTH 13 columnlist)
                                                 (FIX (NTH 13 columnlist))
                                                 0
                                             )
                                       )
                                       (CONS "Attributes"
                                             (IF (NTH 9 columnlist)
                                                 (FIX (NTH 9 columnlist))
                                                 0
                                             )
                                       )
                                       (CONS "Precision"
                                             (IF (NTH 15 columnlist)
                                                 (NTH 15 columnlist)
                                                 255
                                             )
                                       )
                                       (CONS "Ordinal"
                                             (FIX (NTH 6 columnlist))
                                       )
                                 )
                                 returnvalue
                             )
                    )
                )
            )
        )
    )
    (VLAX-RELEASE-OBJECT recordsetobject)

    ;; The reverse of the return value list is probably in order, but make sure ....
    (IF returnvalue
        (VL-SORT (REVERSE returnvalue)
                 '(LAMBDA (x y)
                      (< (CDR (ASSOC "Ordinal" (CDR x)))
                         (CDR (ASSOC "Ordinal" (CDR y)))
                      )
                  )
        )
        nil
    )
)


;;; ------------------------------------------------------------

;;; ADOLISP Support functions

;;; A function to assemble all errors into a list of lists of
;;; dotted pairs of strings ("name" . "value")

(DEFUN adolisp_errorprocessor (vlerrorobject connectionobject / errorsobject errorobject errorcount errornumber errorlist errorvalue)
    ;; First get Visual LISP's error message
    (SETQ returnlist   (LIST
                           (LIST
                               (CONS
                                   "Visual LISP message"
                                   (VL-CATCH-ALL-ERROR-MESSAGE vlerrorobject)
                               )
                           )
                       )
          ;; Get the ADO errors object and quantity
          errorobject  (VLAX-CREATE-OBJECT "ADODB.Error")
          errorsobject (VLAX-GET-PROPERTY connectionobject "Errors")
          errorcount   (VLAX-GET-PROPERTY errorsobject "Count")
          errornumber  -1
    )
    ;; Loop over all the ADO errors ...
    (WHILE (< (SETQ errornumber (1+ errornumber)) errorcount)
        ;; Get the error object of the current error
        (SETQ errorobject
                          (VLAX-GET-PROPERTY errorsobject "Item" errornumber)
              ;; Clear the list of items for this error
              errorlist   nil
        )
        ;; Loop over all possible error items of this error
        (FOREACH errorproperty '("Description" "HelpContext" "HelpFile" "NativeError" "Number" "SQLState" "Source")
            ;; Get the value of the current item.  If it's a number
            ;; ...
            (IF (NUMBERP (SETQ errorvalue
                                  (VLAX-GET-PROPERTY errorobject errorproperty)
                         )
                )
                ;; Convert it to a string for consistency
                (SETQ errorvalue (ITOA errorvalue))
            )
            ;; And store it
            (SETQ errorlist (CONS (CONS errorproperty errorvalue)
                                  errorlist
                            )
            )
        )
        ;; Add the list for the current error to the return value
        (SETQ returnlist (CONS (REVERSE errorlist) returnlist))
    )
    ;; Set up the return value in the correct order
    (REVERSE returnlist)
)

;;; A function to convert a variant to a value.  Knows
;;; about more variant types than vlax-variant-value

(DEFUN adolisp_variant-value (variantitem / varianttype)
    (COND
        ;; If it's a Currency data type or a Decimal data type ...
        ((OR (= VLAX-VBCURRENCY
                (SETQ varianttype (VLAX-VARIANT-TYPE variantitem))
             )
             ;; Note that I defined vlax-vbDecimal
             ;; at the beginning of the file
             (= vlax-vbdecimal varianttype)
         )
         ;; Convert it to a double before getting its value
         (VLAX-VARIANT-VALUE
             (VLAX-VARIANT-CHANGE-TYPE variantitem VLAX-VBDOUBLE)
         )
        )
        ;; If it's a date, time, or date/time variable type ...
        ((= VLAX-VBDATE varianttype)
         ;; Convert it to a string (assuming it's a Microsoft
         ;; Access type Julian date)
         (1900basedjuliantocalender
             (VLAX-VARIANT-VALUE variantitem)
         )
        )
        ;; If it's a boolean value (yes/no, true/false, ...) ...
        ((= VLAX-VBBOOLEAN varianttype)
         ;; Convert it to the string "True" or "False"
         (IF (= :VLAX-TRUE (VLAX-VARIANT-VALUE variantitem))
             "True"
             "False"
         )
        )
        ;; If it's an OLE_COLOR data type ...
        ((= vlax-vbole_color varianttype)
         ;; Convert it to a long integer before getting its value
         (VLAX-VARIANT-VALUE
             (VLAX-VARIANT-CHANGE-TYPE variantitem VLAX-VBLONG)
         )
        )
        ;; Otherwise, just turn vlax-variant-value loose on it
        (T (VLAX-VARIANT-VALUE variantitem))
    )
)

;;; A function to convert a "1900-based"Julian-like
;;; date, time, or date/time to a string.

;;; Argument:  A real number, containing a Julian-type date
;;; based on January 1, 1900 (e.g. a Microsoft Access date)
;;; in the integer portion and a time (as a fraction of a
;;; day) in the fractional portion.  Note that this
;;; algorithm considers a number with no fractional
;;; portion to be the day _starting_ at midnight.

;;; Return Value:  A string:
;;;  Containing just the date if there was no fractional
;;;    portion.
;;;  Containing just the time if there was no integer portion
;;;    or the input number was 0.0
;;;  Otherwise, containing the date and the time.

;;; Times are returned as hour:minutes:seconds, 24-hour
;;; format, with leading zeros if necessary to make
;;; two digits per element

;;; Dates are returned in US format (month/day/year) but this
;;; is easily changed.  The year is given as four digits.
;;; The month and day are supplied as two digits (possibly
;;; with leading zeros)

(DEFUN 1900basedjuliantocalender (juliandate / a b c d e y z month day year hours minutes seconds calendertime notime nodate returnvalue)
    ;; Initialize the return value
    (SETQ returnvalue "")
    ;; If the input date has no time component ...
    (IF (EQUAL 0.0
               (FLOAT (- juliandate (FLOAT (FIX juliandate))))
               1E-9
        )
        ;; It has no time component ... if it has no date
        ;; component ...
        (IF (ZEROP (FIX juliandate))
            ;; It must be a timestamp of 0:00.00.  Set the flag that
            ;; we don't have a date but leave the "No Time" flag
            ;; unset
            (SETQ nodate T)
            ;; It has a date component but has no time component.
            ;; Shift the date to a real Julian date
            (SETQ juliandate (+ 2415019 (FIX juliandate))
                  ;; Set a flag so we know we don't have to
                  ;; calculate the time
                  notime     T
            )
        )
        ;; It has a time component.  If it has no date component
        ;; ...
        (IF (ZEROP (FIX juliandate))
            ;; Set a flag so we know we don't want to calculate a
            ;; date
            (SETQ nodate T)
            ;; Otherwise, just shift it to be based like a standard
            ;; Julian date
            (SETQ juliandate (+ 2415019 juliandate))
        )
    )
    ;; If we want to calculate the date ...
    (IF (NOT nodate)
        ;; It's magic, don't even ask (because I don't know).
        ;; Some things we weren't meant to know.
        (SETQ z           (FIX juliandate)
              a           (FIX (/ (- z 1867216.25) 36524.25))
              a           (+ z 1 a (- (FIX (/ a 4))))
              b           (+ a 1524)
              c           (FIX (/ (- b 122.1) 365.25))
              d           (floor (* 365.25 c))
              e           (FIX (/ (- b d) 30.6001))
              day         (FIX (- b d (floor (* 30.6001 e))))
              e           (- e
                             (IF (< e 14)
                                 2
                                 14
                             )
                          )
              month       (1+ e)
              year        (IF (> e 1)
                              (- c 4716)
                              (- c 4715)
                          )
              year        (IF (= year 0)
                              (1- year)
                              year
                          )
              ;; This uses US format for the date, you might want
              ;; to change it.
              returnvalue (STRCAT (IF (< month 10)
                                      (STRCAT "0" (ITOA month))
                                      (ITOA month)
                                  )
                                  "/"
                                  (IF (< day 10)
                                      (STRCAT "0" (ITOA day))
                                      (ITOA day)
                                  )
                                  "/"
                                  (ITOA year)
                          )
        )
    )
    ;; If we want to calculate the time ...
    (IF (NOT notime)
        ;; First strip the date portion from the input
        (SETQ y            (- juliandate (FLOAT (FIX juliandate)))
              ;; Round to the nearest second
              y            (/ (FLOAT (FIX (+ 0.5 (* y 86400.0)))) 86400.0)
              ;; Number of hours since midnight
              hours        (FIX (* y 24))
              ;; Number of minutes since midnight the hour
              ;; (1440 minutes per day)
              minutes      (FIX (- (* y 1440.0) (* hours 60.0)))
              ;; Number of seconds since the minute (86400
              ;; seconds per day)
              seconds      (FIX (- (* y 86400.0)
                                   (* hours 3600.0)
                                   (* minutes 60.0)
                                )
                           )
              calendertime (STRCAT (IF (< hours 10)
                                       (STRCAT "0" (ITOA hours))
                                       (ITOA hours)
                                   )
                                   ":"
                                   (IF (< minutes 10)
                                       (STRCAT "0" (ITOA minutes))
                                       (ITOA minutes)
                                   )
                                   ":"
                                   (IF (< seconds 10)
                                       (STRCAT "0" (ITOA seconds))
                                       (ITOA seconds)
                                   )
                           )
              returnvalue  (IF (< 0 (STRLEN returnvalue))
                               (STRCAT returnvalue " " calendertime)
                               calendertime
                           )

        )
    )
    returnvalue
)

;;; Floor function, rounds down to the next integer.
;;; Identical with FIX for positive numbers, but
;;; rounds away from zero for negative numbers.

(DEFUN floor (number /)
    (IF (> number 0)
        (FIX number)
        (FIX (- number 1))
    )
)

;;(PROMPT "\nADOLISP library loaded")

(DEFUN gtdatabase:getdatabase (/)
    (adolisp_connecttodb (STRCAT "Driver={MySQL ODBC 5.1 Driver};Server="
                                 (gtconfig:getvalue $gtconfig "DATABASE" "SERVER")
                                 ";Database="
                                 (gtconfig:getvalue $gtconfig "DATABASE" "DATABASE")
                                 ";UID=anonymous;"
                         )
                         nil
                         nil
    )
)

(DEFUN gtdatabase:disconnectdatabase ($database /)
    (adolisp_disconnectfromdb $database)
)