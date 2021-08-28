
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
