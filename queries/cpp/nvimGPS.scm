
; Class
((class_specifier
	name: (type_identifier) @class-name
	body: (field_declaration_list)) @scope-root)

; Struct
((struct_specifier
	name: (type_identifier) @class-name
	body: (field_declaration_list)) @scope-root)

; Namespace
((namespace_definition
	name: (identifier) @class-name
	body: (declaration_list)) @scope-root)

; Function
((function_definition
	declarator: (function_declarator
		declarator: (identifier) @function-name)) @scope-root)

; Function with pointer as return type
((function_definition
	declarator: (pointer_declarator
		declarator: (function_declarator
			(identifier) @function-name))) @scope-root)

; Lambda function
((declaration
	declarator: (init_declarator
		declarator: (identifier) @function-name
		value: (lambda_expression))) @scope-root)

; Method
((function_definition
	declarator: (function_declarator
		declarator: (field_identifier) @method-name)) @scope-root)

; Method written outside class
((function_definition
	declarator: (function_declarator
		declarator: (scoped_identifier
			name: (identifier) @method-name))) @scope-root)
