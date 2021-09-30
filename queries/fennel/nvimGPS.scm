
; Functions
((fn
	name: (symbol) @function-name) @scope-root)

; Lambda
((lambda
	name: (symbol) @function-name) @scope-root)

; Methods
((fn
	name: (multi_symbol) @method-name) @scope-root)

; Lambda Methods
((lambda
	name: (multi_symbol) @method-name) @scope-root)
