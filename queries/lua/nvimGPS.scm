
; Local function
((local_function (identifier) @function-name) @scope-root)

; Local function assigned to variable
(local_variable_declaration
	(variable_declarator (identifier) @function-name) . (function_definition) @scope-root)

; Function
((function
	(function_name) @function-name) @scope-root)

; Function assigned to local variable
((local_variable_declaration
	(variable_declarator
		(identifier) @function-name)
	(function_definition)) @scope-root)

; Function assigned to global variable
((variable_declaration
	(variable_declarator
		(identifier) @function-name)
	(function_definition)) @scope-root)

; Function assigned to field inside table
((field
	(identifier) @method-name
	(function_definition)) @scope-root)

; Function assigned to string field inside table
((field
	(string) @method-name
	(function_definition)) @scope-root)
