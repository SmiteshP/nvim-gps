; inherits: typescript

; React hook name
((call_expression
	function: (identifier) @hook-name (#match? @hook-name "^use")
	) @scope-root)

; React hook function name
((variable_declarator
  name: (identifier) @function-name
  value: (call_expression
    function: (identifier) @hook-identifier (#match? @hook-identifier "^use")
  )) @scope-root)
