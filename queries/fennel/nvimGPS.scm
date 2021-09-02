
; Functions
((function_definition
	name: (identifier) @function-name) @scope-root)

; Lambda
((lambda_definition
	name: (identifier) @function-name) @scope-root)

; Methods
((function_definition
	name: (field_expression) @method-name) @scope-root)

; Lambda Methods
((lambda_definition
	name: (field_expression) @method-name) @scope-root)
