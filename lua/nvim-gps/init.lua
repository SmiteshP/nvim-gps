local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require("nvim-treesitter.locals")
local parsers = require("nvim-treesitter.parsers")

local M = {}

local config = {
	icons = {
		["class-name"] = ' ',
		["function-name"] = ' ',
		["method-name"] = ' '
	},
	query = {
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

			; Functions
			((function_definition
				declarator: (function_declarator
					declarator: (identifier) @function-name)) @scope-root)

			; Lambda functions
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
		["python"] = [[
			((class_definition
				name: (identifier) @class-name) @scope-root)
			((function_definition
				name: (identifier) @function-name) @scope-root)
		]]
			-- FIXME: method query not working
			-- ((class_definition
			-- 	body: (block
			-- 		(function_definition
			-- 			name: (identifier) @method-name) @scope-root)))
	},
	separator = ' > ',
}

function M.is_available()
	return parsers.has_parser() and config.query[vim.bo.filetype] ~= nil
end

function M.setup()
	for k, v in pairs(config.query) do
		vim.treesitter.set_query(k, "nvimGPS", v)
	end
end

M.setup() -- TODO: Remove

local cache_value = ""

function M.get_context()
	if vim.fn.mode() == 'i' then
		return cache_value
	end

	local gps_query = vim.treesitter.get_query(vim.bo.filetype, "nvimGPS")
	local current_node = ts_utils.get_node_at_cursor()
	local icons = config.icons

	local node_text = {}

	local node = current_node
	while node do
		local iter = gps_query:iter_captures(node)
		local capture_ID, capture_node = iter()
		if capture_node == node and gps_query.captures[capture_ID] == "scope-root" then
			capture_ID, capture_node = iter()
			local capture_name = gps_query.captures[capture_ID]
			table.insert(node_text, 1, icons[capture_name]..ts_utils.get_node_text(capture_node)[1])
		end
		node = node:parent()
	end

	-- for node in ts_locals.iter_scope_tree(current_node) do
	-- 	local iter = gps_query:iter_captures(node)
	-- 	local capture_ID, capture_node = iter()
	-- 	if capture_node == node and gps_query.captures[capture_ID] == "scope-root" then
	-- 		capture_ID, capture_node = iter()
	-- 		local capture_name = gps_query.captures[capture_ID]
	-- 		table.insert(node_text, 1, icons[capture_name]..ts_utils.get_node_text(capture_node)[1])
	-- 	end
	-- end

	cache_value = table.concat(node_text, config.separator)
	return cache_value
end

return M
