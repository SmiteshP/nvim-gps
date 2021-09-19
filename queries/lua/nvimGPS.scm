
; Local function
((local_function (identifier) @function-name) @scope-root)

; Local function assigned to variable
(local_variable_declaration
	(variable_declarator (identifier) @function-name) . (function_definition) @scope-root)

; Function
((function
	(function_name) @table-function) @scope-root)

; Function as table field outside table
((variable_declaration
	(variable_declarator
		(field_expression) @table-function)
	(function_definition)) @scope-root)

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
	(string) @string-method
	(function_definition)) @scope-root)

; Table
((local_variable_declaration
	(variable_declarator) @container-name
	(table)) @scope-root)

; Field Table
((field
	(identifier) @container-name
	(table)) @scope-root)

; Multi tables
((variable_declaration
	(variable_declarator) @multi-container
	(table)) @scope-root)
