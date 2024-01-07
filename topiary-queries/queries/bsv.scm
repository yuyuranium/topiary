(#language! bsv)

; Sometimes we want to indicate that certain parts of our source text should
; not be formatted, but taken as is. We use the leaf capture name to inform the
; tool of this.
(stringLiteral) @leaf

; Allow blank line before
[
  (exportDecl)
  (importDecl)
  (packageStmt)
  (interfaceMemberDecl)
  (moduleStmt)
  (functionBodyStmt)
  (fsmStmt)
  "end"
  "endmethod"
  "endmodule"
  "endpackage"
  (comment)
] @allow_blank_line_before

; Append line breaks. If there is a comment following, we don't add anything,
; because the input softlines and spaces above will already have sorted out the
; formatting.
(
  [
    (exportDecl)
    (importDecl)
    (packageStmt)
    (interfaceMemberDecl)
    (moduleStmt)
    (functionBodyStmt)
    (actionStmt)
    (actionValueStmt)
    (attributeInstance)
    (caseExprItem)
  ] @append_hardline
  .
  [
    "else"
    (comment)
  ]* @do_nothing
)

; Can either have line break or not
[
  (fsmStmt)
  (actionBlock)
  (actionValueBlock)
] @append_input_softline @prepend_input_softline

(comment) @append_hardline

; Surround spaces
[
  ; "BVI"
  ; "C"
  ; "CF"
  ; "E"
  ; "SB"
  ; "SBR"
  ; "ancestor"
  "clocked_by"
  ; "default_clock"
  ; "default_reset"
  "dependencies"
  "deriving"
  "determines"
  ; "e"
  ; "enable"
  "enum"
  ; "ifc_inout"
  ; "inout"
  ; "input_clock"
  ; "input_reset"
  "let"
  "match"
  "matches"
  "numeric"
  ; "output_clock"
  ; "output_reset"
  "parameter"
  ; "path"
  ; "port"
  "provisos"
  "reset_by"
  ; "same_family"
  ; "schedule"
  "struct"
  "tagged"
  ; "type"
  "union"
  "import"
  "export"
  "typedef"
  "while"
  "for"
  "continue"
  "break"
  "if"
  "else"
  "case"
  "return"
  "bit"
  "int"
  "void"
  "matches"
  "Action"
] @prepend_space @append_space

; Opening keywords
[
  "type"
  "package"
  "interface"
  "module"
  "method"
  "function"
  "rule"
  "action"
  "actionvalue"
  "begin"
  "seq"
  "par"
  "typeclass"
  "instance"
  "rules"
  "(*"
] @append_space

; Closing keywords
[
  "noAction"
  "default"
  "endpackage"
  "endinterface"
  "endmodule"
  "endmethod"
  "endfunction"
  "endrule"
  "endaction"
  "endactionvalue"
  "end"
  "endseq"
  "endpar"
  "endtypeclass"
  "endinstance"
  "endrules"
  "*)"
] @prepend_space

(binaryExpr
  binary_operator: _ @prepend_space @append_space
)

(condExpr
  "?" @prepend_space @append_space
  ":" @prepend_space @append_space
)

; Append spaces
[
  ","
  ":"
] @append_space

(
  (type)
  [
    (identifier)
    (varInit)
  ] @prepend_space
)

(moduleProto
  (identifier)
  (moduleFormalParams)?
  .
  "(" @prepend_space
  _?
  ")" @append_indent_start @append_indent_start
  _? @prepend_input_softline
  ";" @prepend_indent_end @prepend_indent_end
)

; Add space between if * begin
(moduleIfStmt
  (moduleStmt
    (moduleBeginEndStmt) @prepend_space
    .
  )
)

(expressionIfStmt
  (expressionStmt
    (expressionBeginEndStmt) @prepend_space
    .
  )
)

(functionBodyIfStmt
  (functionBodyStmt
    (functionBodyBeginEndStmt) @prepend_space
    .
  )
)

(actionIfStmt
  (actionStmt
    (actionBeginEndStmt) @prepend_space
    .
  )
)

(actionValueIfStmt
  (actionValueStmt
    (actionValueBeginEndStmt) @prepend_space
    .
  )
)

(ifFsmStmt
  (fsmStmt) @prepend_space
)

; Input softlines before and after all comments. This means that the input
; decides if a comment should have line breaks before or after. A line comment
; always ends with a line break.
[
  (comment)
] @prepend_input_softline

; Append softlines, unless followed by comments.
(
  [
    ","
    ";"
  ] @append_spaced_softline @prepend_antispace
  .
  [(comment)]* @do_nothing
)

; Prepend space and or line break
[
  "<="
  "<-"
  "="
] @prepend_space @append_space

; Indent when line break
(
  [
    "="
    "<-"
    "="
  ] @append_input_softline @append_indent_start
  _
  ";" @prepend_indent_end
  .
)

; Dirty
(caseExpr
  (caseExprItem
    ":" @append_spaced_softline @append_indent_start
    _
    (returnStmt) @prepend_indent_end
    .
  )
)

; Append hardline and indent
(typedefEnum
  "{" @append_hardline @append_indent_start
  _
  "}" @prepend_hardline @prepend_indent_end
  (Identifier) @prepend_space
)

(typedefStruct
  "{" @append_hardline @append_indent_start
  _
  "}" @prepend_hardline @prepend_indent_end
  (typeDefType) @prepend_space
)

(typedefTaggedUnion
  "{" @append_hardline @append_indent_start
  _
  "}" @prepend_hardline @prepend_indent_end
  (typeDefType) @prepend_space
)

(interfaceDecl
  ";" @append_hardline @append_indent_start
  _
  "endinterface" @prepend_hardline @prepend_indent_end
)

(functionDef
  .
  (functionProto) @append_hardline @append_indent_start
  _
  "endfunction" @prepend_hardline @prepend_indent_end
)

(moduleDef
  .
  (moduleProto) @append_hardline @append_indent_start
  _
  "endmodule" @prepend_hardline @prepend_indent_end
)

(methodDef
  ";" @append_hardline @append_indent_start
  _
  "endmethod" @prepend_hardline @prepend_indent_end
)

(actionBlock
  .
  "action" @append_hardline @append_indent_start
  _
  "endaction" @prepend_hardline @prepend_indent_end
)

(actionValueBlock
  .
  "actionvalue" @append_hardline @append_indent_start
  _
  "endactionvalue" @prepend_hardline @prepend_indent_end
)

(rule
  ";" @append_hardline @append_indent_start
  _
  "endrule" @prepend_hardline @prepend_indent_end
)

(caseExpr
  ")" @append_hardline @append_indent_start
  _
  "endcase" @prepend_hardline @prepend_indent_end
)

(seqFsmStmt
  "seq" @append_hardline @append_indent_start
  _
  "endseq" @prepend_hardline @prepend_indent_end
)

(parFsmStmt
  "par" @append_hardline @append_indent_start
  _
  "endpar" @prepend_hardline @prepend_indent_end
)

; Match all beginEndStmts
(
  "begin" @append_hardline @append_indent_start
  _
  "end" @prepend_hardline @prepend_indent_end
)
