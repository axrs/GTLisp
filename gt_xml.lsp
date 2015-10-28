;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
;| GT_XML - XML Parser for AutoLISP                                           |;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

(DEFUN gtxml:read ($filename / $document $list *error*)
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>gtxml:getattributes</function>
    <summary>Gets a list of attributes from a specified node.</summary>
    <param name="$node">XML node to get attributes from.</param>
    <returns>List of node attributes</returns>
    |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (DEFUN gtxml:getattributes ($node / $attributes $attribute $list)
        (IF (SETQ $attributes (VLAX-GET $node "attributes"))
            (PROGN (WHILE (SETQ $attribute (VLAX-INVOKE $attributes "nextNode"))
                       (SETQ $list (CONS (CONS (VLAX-GET $attribute "nodeName")
                                               (VLAX-GET $attribute "nodeValue")
                                         )
                                         $list
                                   )
                       )
                       (VLAX-RELEASE-OBJECT $attribute)
                   )
                   (VLAX-RELEASE-OBJECT $attributes)
                   (REVERSE $list)
            )
        )
    )
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>gtxml:getchildnodes</function>
    <summary>Recursive function to get a list of child nodes.</summary>
    <param name="$node">XML Node to get child nodes from.</param>
    <returns>List of XML child Nodes</returns>
    Note: As a nested function, only code within the gtxml:read block can use it.
    |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    (DEFUN gtxml:getchildnodes ($node /)
        (IF $node
            (IF (= (VLAX-GET $node "nodeType") 3)
                (VLAX-GET $node "nodeValue")
                (CONS (LIST (VLAX-GET $node "nodeName")
                            (gtxml:getattributes $node)
                            (gtxml:getchildnodes (VLAX-GET $node "firstChild"))
                      )
                      (gtxml:getchildnodes (VLAX-GET $node "nextSibling"))
                )
            )
        )
    )
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;
    ;|
    <function>gtxml:read</function>
    <summary>Parses an XML document (from file or URL) into an associated list.</summary>
    <param name="$filename">URL or directory path of an XML file.</param>
    <returns>XML file as an associated list.</returns>
    Note: As a nested function, only code within the gtxml:read block can use it.
    |;
    ;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;;

    (IF (AND $filename
             (SETQ $document (VLAX-CREATE-OBJECT "MSXML.DOMDocument"))
             (NOT (VLAX-PUT $document "async" 0))
             (IF (= (VLAX-INVOKE $document "load" $filename) -1)
                 T
                 (PROMPT
                     (STRCAT "\nError: "
                             (VLAX-GET (VLAX-GET $document "parseError") "reason")
                     )
                 )
             )
             (= (VLAX-GET $document "readyState") 4)
        )
        (SETQ $list (gtxml:getchildnodes (VLAX-GET $document "firstChild")))
    )
    (AND $document (VLAX-RELEASE-OBJECT $document))
    ;;Forces AutoLISP to GarbageCollect
    (GC)
    $list
)
