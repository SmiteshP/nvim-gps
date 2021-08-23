
; Struct
((struct_item
	name: (type_identifier) @class-name) @scope-root)

; Impl
((impl_item
	type: (type_identifier) @class-name) @scope-root)

; Impl with generic
((impl_item
	type: (generic_type
		type: (type_identifier) @class-name)) @scope-root)

; Mod
((mod_item
	name: (identifier) @class-name) @scope-root)

; Enum
((enum_item
	name: (type_identifier) @class-name) @scope-root)

; Function
((function_item
	name: (identifier) @function-name
	body: (block)) @scope-root)
