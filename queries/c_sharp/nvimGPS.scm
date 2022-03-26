; Class
((class_declaration
	name: (identifier) @class-name
	body: (declaration_list)) @scope-root)

; Struct
((struct_declaration
	name: (identifier) @class-name
	body: (declaration_list)) @scope-root)

; Interface
((interface_declaration
	name: (identifier) @method-name
	body: (declaration_list)) @scope-root)

; Record
((record_declaration
	name: (identifier) @method-name
	body: (declaration_list)) @scope-root)

; Namespace
((namespace_declaration
	name: (identifier) @class-name
	body: (declaration_list)) @scope-root)

; Method
((method_declaration
	name: (identifier) @method-name
	body: (block)) @scope-root)
((method_declaration
	name: (identifier) @method-name
	body: (arrow_expression_clause)) @scope-root)

; Property
((property_declaration
	name: (identifier) @method-name
	accessors: (accessor_list)) @scope-root)
((property_declaration
	name: (identifier) @method-name
	value: (arrow_expression_clause)) @scope-root)

; Lambda function
((variable_declaration
	(variable_declarator
		(identifier) @function-name
		(equals_value_clause
			(lambda_expression)))) @scope-root)

