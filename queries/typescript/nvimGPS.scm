
; Class
((class_declaration
	name: (type_identifier) @class-name
	body: (class_body)) @scope-root)

; Interface
((interface_declaration
	name: (type_identifier) @class-name
	body: (object_type)) @scope-root)

; Function
((function_declaration
	name: (identifier) @function-name
	body: (statement_block)) @scope-root)

; Anonymous function
((variable_declarator
	name: (identifier) @function-name
	value: (function
		body: (statement_block))) @scope-root)

; Method
((method_definition
	name: (property_identifier) @method-name
	body: (statement_block)) @scope-root)

; Arrow function
((variable_declarator
	name: (identifier) @function-name
	value: (arrow_function)) @scope-root)

; Describe blocks
((expression_statement
	(call_expression
		function: (identifier)
		arguments: (arguments
			(string) @method-name
			(arrow_function)))) @scope-root)

; Arrow function methods
((public_field_definition
	name: (property_identifier) @method-name
	value: (arrow_function)) @scope-root)
