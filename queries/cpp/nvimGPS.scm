
; Class
((class_specifier
	name: [(type_identifier) @class-name (qualified_identifier) @multi-class-class]
	body: (field_declaration_list)) @scope-root)

; Struct
((struct_specifier
	name: [(type_identifier) @class-name (qualified_identifier) @multi-class-class]
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
			declarator: (identifier) @function-name))) @scope-root)

; Function with reference as return type
((function_definition
	declarator: (reference_declarator
		(function_declarator
			declarator: [(identifier) @function-name (qualified_identifier) @multi-class-method (field_identifier) @method-name]))) @scope-root)

; Lambda function
((declaration
	declarator: (init_declarator
		declarator: (identifier) @function-name
		value: (lambda_expression))) @scope-root)

; Methods
((function_definition
	declarator: (function_declarator
		declarator: [(field_identifier) @method-name (qualified_identifier) @multi-class-method])) @scope-root)

; Methods with pointer as return type
((function_definition
	declarator: (pointer_declarator
		declarator: (function_declarator
			declarator: [(field_identifier) @method-name (qualified_identifier) @multi-class-method]))) @scope-root)

; Methods with reference as return type
((function_definition
	declarator: (reference_declarator
		(function_declarator
			declarator: [(field_identifier) @method-name (qualified_identifier) @multi-class-method]))) @scope-root)
