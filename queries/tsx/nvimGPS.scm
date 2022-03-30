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

; JSX
((jsx_element
	open_tag: (jsx_opening_element
    name: (identifier) @tag-name
  )) @scope-root)

((jsx_element
	open_tag: (jsx_opening_element
    name: (nested_identifier) @tag-name
  )) @scope-root)

((jsx_self_closing_element
    name: (identifier) @tag-name
  ) @scope-root)

((jsx_self_closing_element
    name: (nested_identifier) @tag-name
  ) @scope-root)
