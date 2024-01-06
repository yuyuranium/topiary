(stringLiteral) @leaf

"," @append_space

[
  "rule"
  "module"
  "<="
  "<-"
  "="
] @prepend_space @append_space

; Append softlines, unless followed by comments.
(
  [
    ","
    ";"
  ] @append_spaced_softline
  .
  [(comment)]* @do_nothing
)

(moduleDef
  .
  (moduleProto) @append_hardline @append_indent_start
  _
  "endmodule" @prepend_hardline @prepend_indent_end
  .
)

(moduleProto
  (identifier) @append_space
  .
)

(moduleInst
  .
  (type) @append_space
)

(varDecl
  .
  (type) @append_space
)

[
  (rule)
  (moduleStmt)
  (actionStmt)
] @prepend_hardline @allow_blank_line_before

(rule
  ";" @append_hardline @append_indent_start
  _
  "endrule" @prepend_hardline @prepend_indent_end
  .
)
