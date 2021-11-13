; Table
((table
	(_) @table-name) @scope-root)

; Array
((pair
	(_) @array-name
	(array)) @scope-root)

; Boolean
((pair
	(_) @boolean-name
	(boolean)) @scope-root)

; Date
((pair
	(_) @date-name
	(local_date)) @scope-root)

; Date Time
((pair
	(_) @date-time-name
	(offset_date_time)) @scope-root)

((pair
	(_) @date-time-name
	(local_date_time)) @scope-root)

; Float
((pair
	(_) @float-name
	(float)) @scope-root)

; Inline Table
((pair
	(_) @inline-table-name
	(inline_table)) @scope-root)

; Integer
((pair
	(_) @integer-name
	(integer)) @scope-root)

; String
((pair
	(_) @string-name
	(string)) @scope-root)

; Time
((pair
	(_) @time-name
	(local_time)) @scope-root)

