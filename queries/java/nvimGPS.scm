
; Class
((class_declaration
	name: (identifier) @class-name
		body: (class_body)) @scope-root)

; Interface
((interface_declaration
	name: (identifier) @class-name
		body: (interface_body)) @scope-root)

; Enum
((enum_declaration
	name: (identifier) @class-name
		body: (enum_body)) @scope-root)

; Method
((method_declaration
	name: (identifier) @method-name
		body: (block)) @scope-root)
