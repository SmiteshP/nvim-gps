
; Struct and Interface
((type_spec
	name: (type_identifier) @class-name) @scope-root)

; Function
((function_declaration
	name: (identifier) @function-name) @scope-root)

; Method
((method_declaration
	receiver: (parameter_list
		(parameter_declaration
			type: (type_identifier) @class-name))
	name: (field_identifier) @method-name) @scope-root-2)

; Method with pointer
((method_declaration
	receiver: (parameter_list
		(parameter_declaration
			type: (pointer_type 
				(type_identifier) @class-name)))
	name: (field_identifier) @method-name) @scope-root-2)
