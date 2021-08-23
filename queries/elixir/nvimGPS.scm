
; defmodule
((call
	function: (function_identifier)
	(module) @class-name) @scope-root)

; def
((call
	function: (function_identifier)
	(call
		function: (function_identifier) @method-name)) @scope-root)

; defp
((call
	function: (function_identifier)
	(identifier) @function-name) @scope-root)
