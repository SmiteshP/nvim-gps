
; Class
((class_definition
	name: (identifier) @class-name) @scope-root)

; Function
((function_definition
	name: (identifier) @function-name) @scope-root)

; Main
((if_statement
	condition: (comparison_operator
		(string) @function-name (#match? @function-name "__main__") )) @scope-root)
