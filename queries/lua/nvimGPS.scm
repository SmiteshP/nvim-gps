
; Functions
((function_declaration
	name: (identifier) @function-name) @scope-root)

((function_declaration
	name: (dot_index_expression) @table-function) @scope-root)

; Function assined to variables
((assignment_statement
	(variable_list
		name: (identifier) @function-name)
	(expression_list
		value: (function_definition))) @scope-root)

((assignment_statement
	(variable_list
		name: (dot_index_expression) @table-function)
	(expression_list
		value: (function_definition))) @scope-root)

; Methods
((field
	name: (identifier) @method-name
	value: (function_definition)) @scope-root)

((field
	name: (string) @string-method
	value: (function_definition)) @scope-root)

; Tables
((assignment_statement
	(variable_list
		name: (_) @multi-container)
	(expression_list
		value: (table_constructor))) @scope-root)

; Table inside table
((field
	name: (identifier) @container-name
	value: (table_constructor)) @scope-root)

