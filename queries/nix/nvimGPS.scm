; Functions
((binding
   attrpath: (attrpath) @function-name
   expression: (function_expression)))  @scope-root

((binding
   attrpath: (attrpath) @function-name
   expression: (parenthesized_expression expression: (function_expression)))  @scope-root)

; Bindings
((binding
   attrpath: (attrpath) @container-name) @scope-root)

