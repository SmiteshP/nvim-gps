; Struct
((TopLevelDecl
	(VarDecl
		variable_type_function: (IDENTIFIER) @class-name)) @scope-root)

; Function
((TopLevelDecl
	(FnProto
		function: (IDENTIFIER) @function-name)) @scope-root)

; Test
((TestDecl
	((STRINGLITERALSINGLE) @function-name)) @scope-root)