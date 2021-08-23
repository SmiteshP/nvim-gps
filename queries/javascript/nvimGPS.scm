
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
