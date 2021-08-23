
; Struct and Interface
((type_declaration
	(type_spec
		name: (type_identifier) @class-name )) @scope-root)

; Function
((function_declaration
	name: (identifier) @function-name) @scope-root)

; Method
((method_declaration
	name: (field_identifier) @method-name) @scope-root)
