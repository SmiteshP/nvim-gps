; Class
((class_declaration
	name: (name) @class-name
        body: (declaration_list)) @scope-root)

; Interface
((interface_declaration
    name: (name) @class-name
        body: (declaration_list)) @scope-root)

; Method
((method_declaration
    name: (name) @method-name
        body: (compound_statement)) @scope-root)

((function_definition
    name: (name) @function-name
        body: (compound_statement)) @scope-root)
