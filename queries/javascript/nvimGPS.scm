
; Class
((class_declaration
	name: (identifier) @class-name
	body: (class_body)) @scope-root)

; Function
((function_declaration
	name: (identifier) @function-name
	body: (statement_block)) @scope-root)

; Method
((method_definition
	name: (property_identifier) @method-name
	body: (statement_block)) @scope-root)

; Arrow Function
((variable_declarator
	name: (identifier) @function-name
	value: (arrow_function)) @scope-root)

; Function Expression
((variable_declarator
	name: (identifier) @function-name
	value: (function)) @scope-root)

; Tests
((expression_statement
	(call_expression
		function: (identifier)
		arguments: (arguments
			(string) @method-name
			(arrow_function)))) @scope-root)

; Arrow function methods
((field_definition
	property: (property_identifier) @method-name
	value: (arrow_function)) @scope-root)

; object literal
((variable_declarator
	name: (identifier) @object-name
	value: (object)) @scope-root)

; object literal modification
((assignment_expression
	left: (identifier) @object-name
	right: (object)) @scope-root)

; nested objects
((pair
  key: (property_identifier) @object-name
  value: (_)) @scope-root)

; nested objects with computed_property_name e.g. { [bar] : true }
((pair
  key: (computed_property_name) @object-name
  value: (_)) @scope-root)

; object property modification
((assignment_expression
	left: (member_expression) @object-name
	right: (object)) @scope-root)

; array
((variable_declarator
	name: (identifier) @array-name
	value: (array)) @scope-root)

; array modification
((assignment_expression
	left: (identifier) @array-name
	right: (array)) @scope-root)

