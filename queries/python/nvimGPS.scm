
; Class
((class_definition
	name: (identifier) @class-name) @scope-root)

; Method
((function_definition
	name: (identifier) @method-name
	parameters: (parameters
		(identifier) @self-capture (#eq? @self-capture "self"))) @scope-root)

; Function
((function_definition
	name: (identifier) @function-name) @scope-root)

; Main
((if_statement
	condition: (comparison_operator
		(string) @main-function (#match? @main-function "[\"\']__main__[\"\']"))) @scope-root)
