local ts_utils = require("nvim-treesitter.ts_utils")
local parsers = require("nvim-treesitter.parsers")

local M = {}

local config = {
	icons = {
		["class-name"] = ' ',
		["function-name"] = ' ',
		["method-name"] = ' '
	},
	separator = ' > ',
}

local query = {
	["c"] = [[
		; Struct
		((struct_specifier
			name: (type_identifier) @class-name
				body: (field_declaration_list)) @scope-root)

		; Function
		((function_definition
			declarator: (function_declarator
				declarator: (identifier) @function-name )) @scope-root)
	]],
	["cpp"] = [[
		; Namespace
		((class_specifier
			name: (type_identifier) @class-name
			body: (field_declaration_list)) @scope-root)

		; Struct
		((struct_specifier
			name: (type_identifier) @class-name) @scope-root)

		; Class
		((namespace_definition
			name: (identifier) @class-name) @scope-root)

		; Function
		((function_definition
			declarator: (function_declarator
				declarator: (identifier) @function-name)) @scope-root)

		; Lambda function
		((declaration
			declarator: (init_declarator
				declarator: (identifier) @function-name
				value: (lambda_expression))) @scope-root)

		; Method
		((function_definition
			declarator: (function_declarator
				declarator: (field_identifier) @method-name)) @scope-root)

		; Method written outside class
		((function_definition
			declarator: (function_declarator
				declarator: (scoped_identifier
					name: (identifier) @method-name))) @scope-root)
	]],
	["java"] = [[
		; Class
		((class_declaration
			name: (identifier) @class-name
				body: (class_body)) @scope-root)

		; Interface
		((interface_declaration
			name: (identifier) @class-name
				body: (interface_body)) @scope-root)

		; Enum
		((enum_declaration
			name: (identifier) @class-name
				body: (enum_body)) @scope-root)

		; Method
		((method_declaration
			name: (identifier) @method-name
				body: (block)) @scope-root)
	]],
	["javascript"] = [[
		; Class
		((class_declaration
			name: (identifier) @class-name
			body: (class_body)) @scope-root)

		; Function
		((function_declaration
			name: (identifier) @function-name
			body: (statement_block)) @scope-root)

		; Method
		((method_definition
			name: (property_identifier) @method-name
			body: (statement_block)) @scope-root)
	]],
	["lua"] = [[
		; Function
		((function
			(function_name (identifier) @function-name)) @scope-root)

		; Local function
		((local_function (identifier) @function-name) @scope-root)

		; Local function assigned to variable
		(local_variable_declaration
			(variable_declarator (identifier) @function-name) . (function_definition) @scope-root)

		; Method
		((function
			(function_name) @method-name) @scope-root)
	]],
	["python"] = [[
		; Class
		((class_definition
			name: (identifier) @class-name) @scope-root)

		; Function
		((function_definition
			name: (identifier) @function-name) @scope-root)

		; Main
		((if_statement
			condition: (comparison_operator
				(string) @function-name (#match? @function-name "__main__") )) @scope-root)
	]],
	["rust"] = [[
		; Struct
		((struct_item
			name: (type_identifier) @class-name) @scope-root)

		; Impl
		((impl_item
			type: (type_identifier) @class-name) @scope-root)

		; Impl with generic
		((impl_item
			type: (generic_type
				type: (type_identifier) @class-name)) @scope-root)

		; Mod
		((mod_item
			name: (identifier) @class-name) @scope-root)

		; Enum
		((enum_item
			name: (type_identifier) @class-name) @scope-root)

		; Function
		((function_item
			name: (identifier) @function-name
			body: (block)) @scope-root)
	]]
}
-- FIXME: python method query not working
-- ((class_definition
-- 	body: (block
-- 		(function_definition
-- 			name: (identifier) @method-name) @scope-root)))

local cache_value = ""
local gps_query = nil
local bufnr = 0
local setup_complete = false

function M.is_available()
	return setup_complete and parsers.has_parser() and query[vim.bo.filetype] ~= nil
end

function M.update_query()
	gps_query = vim.treesitter.get_query(vim.bo.filetype, "nvimGPS")
	bufnr = vim.fn.bufnr()
end

function M.setup(user_config)
	if user_config then
		if user_config.icons then
			for k, v in pairs(user_config.icons) do
				config[k] = v
			end
		end
		if user_config.separator ~= nil then
			config.separator = user_config.separator
		end
	end

	-- Autocommands to  query
	vim.cmd[[
		augroup nvimGPS
		autocmd!
		autocmd BufEnter * silent! lua require("nvim-gps").update_query()
		autocmd InsertLeave * silent! lua require("nvim-gps").update_query()
		augroup END
	]]

	-- Minimize impact on start up time
	vim.schedule(function()
		for k, v in pairs(query) do
			vim.treesitter.set_query(k, "nvimGPS", v)
		end
		M.update_query()
		setup_complete = true
	end)
end

function M.get_location()
	-- Inserting text cause error nodes
	if vim.fn.mode() == 'i' then
		return cache_value
	end

	if not gps_query then
		return "error"
	end

	local current_node = ts_utils.get_node_at_cursor()
	local icons = config.icons

	local node_text = {}
	local node = current_node

	while node do
		local iter = gps_query:iter_captures(node, bufnr)
		local capture_ID, capture_node = iter()

		if capture_node == node and gps_query.captures[capture_ID] == "scope-root" then
			capture_ID, capture_node = iter()
			local capture_name = gps_query.captures[capture_ID]
			table.insert(node_text, 1, icons[capture_name]..ts_utils.get_node_text(capture_node)[1])
		end

		node = node:parent()
	end

	cache_value = table.concat(node_text, config.separator)
	return cache_value
end

return M
