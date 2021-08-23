
; Struct
((struct_specifier
	name: (type_identifier) @class-name
		body: (field_declaration_list)) @scope-root)

; Function
((function_definition
	declarator: (function_declarator
		declarator: (identifier) @function-name )) @scope-root)

; Function with pointer as return type
((function_definition
	declarator: (pointer_declarator
		declarator: (function_declarator
			(identifier) @function-name))) @scope-root)
