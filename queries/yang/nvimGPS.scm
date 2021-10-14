((module module_name: (identifier) @module-name) @scope-root)

((statement
	(statement_keyword "container")
	(argument) @container-name) @scope-root)

((statement
	(statement_keyword "grouping")
	(argument) @grouping-name) @scope-root)

((statement
	(statement_keyword "typedef")
	(argument) @typedef-name) @scope-root)

((statement
	(statement_keyword "list")
	(argument) @list-name) @scope-root)

((statement
	(statement_keyword "leaf-list")
	(argument) @leaf-list-name) @scope-root)

((statement
	(statement_keyword "leaf")
	(argument) @leaf-name) @scope-root)
