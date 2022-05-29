local ts_utils = require("nvim-treesitter.ts_utils")
local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")
local utils = require("nvim-gps.utils")

local M = {}

-- Default configuration that can be overridden by users
local default_config = {
	enabled = true,
	disable_icons = false,
	icons = {
		["class-name"] = ' ',
		["function-name"] = ' ',
		["method-name"] = ' ',
		["container-name"] = 'ﮅ ',
		["tag-name"] = '炙',
	},
	separator = ' > ',
	depth = 0,
	depth_limit_indicator = ".."
}

-- Languages specific default configuration must be added to configs
-- using the `with_default_config` helper.
-- In setup_language_configs function
--
-- Example
--
--    configs = {
--        ["cpp"] = with_default_config({
--            icons = {
--                ["function-name"] = "<F> "
--            }
--        })
--    }
local with_default_config = function(config)
	return vim.tbl_deep_extend("force", default_config, config)
end

-- Placeholder where the configuration will be saved in setup()
local configs = {}

local function setup_language_configs()
	configs = {
		["json"] = with_default_config({
			icons = {
				["array-name"] = ' ',
				["object-name"] = ' ',
				["null-name"] = '[] ',
				["boolean-name"] = 'ﰰﰴ ',
				["number-name"] = '# ',
				["string-name"] = ' '
			}
		}),
		["latex"] = with_default_config({
			icons = {
				["title-name"] = "# ",
				["label-name"] = " ",
			},
		}),
		["norg"] = with_default_config({
			icons = {
				["title-name"] = " ",
			},
		}),
		["toml"] = with_default_config({
			icons = {
				["table-name"] = ' ',
				["array-name"] = ' ',
				["boolean-name"] = 'ﰰﰴ ',
				["date-name"] = ' ',
				["date-time-name"] = ' ',
				["float-name"] = ' ',
				["inline-table-name"] = ' ',
				["integer-name"] = '# ',
				["string-name"] = ' ',
				["time-name"] = ' '
			}
		}),
		["verilog"] = with_default_config({
			icons = {
				["module-name"] = ' '
			}
		}),
		["yaml"] = with_default_config({
			icons = {
				["mapping-name"] = ' ',
				["sequence-name"] = ' ',
				["null-name"] = '[] ',
				["boolean-name"] = 'ﰰﰴ ',
				["integer-name"] = '# ',
				["float-name"] = ' ',
				["string-name"] = ' '
			}
		}),
		["yang"] = with_default_config({
			icons = {
				["module-name"] = " ",
				["augment-path"] = " ",
				["container-name"] = " ",
				["grouping-name"] = " ",
				["typedef-name"] = " ",
				["identity-name"] = " ",
				["list-name"] = "﬘ ",
				["leaf-list-name"] = " ",
				["leaf-name"] = " ",
				["action-name"] = " ",
			}
		}),
		["scss"] = with_default_config({
			icons = {
				["scss-name"] = "",
				["scss-mixin-name"] = "@mixin ",
				["scss-include-name"] = "@include ",
				["scss-keyframes-name"] = "@keyframes ",
			}
		}),
		["tsx"] = with_default_config({
			icons = {
				["hook-name"] = "ﯠ ",
			}
		}),
	}
end

local data_cache_value = nil  -- table
local location_cache_value = ""  -- string
local data_prev_loc = {0, 0}
local location_prev_loc = {0, 0}
local setup_complete = false

local function default_transform(config, capture_name, capture_text)
	return {
		text = capture_text,
		type = capture_name,
		icon = config.icons[capture_name]
	}
end

local transform_lang = {
	["cpp"] = function(config, capture_name, capture_text)
		if capture_name == "multi-class-method" then
			local temp = vim.split(capture_text, "%:%:")
			local ret = {}
			for i = 1, #temp-1  do
				local text = string.match(temp[i], "%s*([%w_]*)%s*<?.*>?%s*")
				table.insert(ret, default_transform(config, "class-name", text))
			end
			table.insert(ret, default_transform(config, "method-name", string.match(temp[#temp], "%s*(~?%s*[%w_]*)%s*")))
			return ret
		elseif capture_name == "multi-class-class" then
			local temp = vim.split(capture_text, "%:%:")
			local ret = {}
			for i = 1, #temp-1  do
				local text = string.match(temp[i], "%s*([%w_]*)%s*<?.*>?%s*")
				table.insert(ret, default_transform(config, "class-name", text))
			end
			table.insert(ret, default_transform(config, "class-name", string.match(temp[#temp], "%s*([%w_]*)%s*<?.*>?%s*")))
			return ret
		else
			return default_transform(config, capture_name, capture_text)
		end
	end,
	["html"] = function(config, capture_name, capture_text)
		if capture_name == "tag-name" then
			local text = string.match(capture_text, "<(.*)>")
			local tag_name, attributes = string.match(text, "([%w-]+)(.*)")
			local ret = tag_name
			local id_name = string.match(attributes, "id%s*=%s*%\"([^%s]+)%\"")
			if id_name ~= nil then
				ret = ret..'#'..id_name
			else
				local class_name = string.match(attributes, "class%s*=%s*%\"([%w-_%s]+)%\"")
				if class_name ~= nil then
					ret = ret..'.'..string.match(class_name, "(%w+)")
				end
			end
			return default_transform(config, "tag-name", ret)
		end
	end,
	["lua"] = function(config, capture_name, capture_text)
		if capture_name == "string-method" then
			return default_transform(config, "method-name", string.match(capture_text, "[\"\'](.*)[\"\']"))
		elseif capture_name == "multi-container" then
			local temp = vim.split(capture_text, "%.")
			local ret = {}
			for i = 1, #temp do
				table.insert(ret, default_transform(config, "container-name", temp[i]))
			end
			return ret
		elseif capture_name == "table-function" then
			local temp = vim.split(capture_text, "%.")
			local ret = {}
			for i = 1, #temp-1  do
				table.insert(ret, default_transform(config, "container-name", temp[i]))
			end
			table.insert(ret, default_transform(config, "function-name", temp[#temp]))
			return ret
		else
			return default_transform(config, capture_name, capture_text)
		end
	end,
	["python"] = function(config, capture_name, capture_text)
		if capture_name == "main-function" then
			return default_transform(config, "function-name", "main")
		else
			return default_transform(config, capture_name, capture_text)
		end
	end,
	["yang"] = function(config, capture_name, capture_text)
		if capture_name == "keyword" then
			return nil
		else
			return default_transform(config, capture_name, capture_text)
		end
	end
}

-- If a language doesn't have a transformation
-- fallback to the default_transform
setmetatable(transform_lang, {
	__index = function()
		return default_transform
	end
})

-- Checks the availability of the plugin for the current buffer
-- The availability is cached in a buffer variable (b:nvim_gps_available)
function M.is_available()
	if setup_complete and vim.b.nvim_gps_available == nil then
		local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
		local config = configs[filelang]

		if config.enabled then
			local has_parser = ts_parsers.has_parser(filelang)
			local has_query = ts_queries.has_query_files(filelang, "nvimGPS")

			vim.b.nvim_gps_available = has_parser and has_query
		else
			vim.b.nvim_gps_available = false
		end
	end

	return vim.b.nvim_gps_available
end

-- Enables the treesitter nvimGPS module and loads the user configuration, or fallback to the
-- default_config.
function M.setup(user_config)
	-- Override default configurations with user definitions
	user_config = user_config or {}
	default_config.separator = user_config.separator or default_config.separator
	default_config.disable_icons = user_config.disable_icons or default_config.disable_icons
	default_config.icons = vim.tbl_extend("force", default_config.icons, user_config["icons"] or {})
	setup_language_configs()
	default_config.depth = user_config.depth or default_config.depth
	default_config.depth_limit_indicator = user_config.depth_limit_indicator or default_config.depth_limit_indicator

	-- Override languages specific configurations with user definitions
	for lang, values in pairs(user_config.languages or {}) do
		if type(values) == "table" then
			configs[lang] = with_default_config(values)
		else
			configs[lang] = with_default_config({ enabled = values })
		end
	end

	-- If a language doesn't have a configuration, fallback to the default_config
	setmetatable(configs, {
		__index = function()
			return default_config
		end
	})

	require("nvim-treesitter.configs").setup({
		nvimGPS = {
			enable = true
		}
	})

	setup_complete = true
end

-- Request treesitter parser to update the syntax tree,
-- when the buffer content has changed.
local update_tree = ts_utils.memoize_by_buf_tick(function(bufnr)
	local filelang = ts_parsers.ft_to_lang(vim.api.nvim_buf_get_option(bufnr, "filetype"))
	local parser = ts_parsers.get_parser(bufnr, filelang)
	return parser:parse()
end)

---@return table|nil  the data in table format, or nil if gps is not available
function M.get_data()
	-- Inserting text cause error nodes
	if vim.api.nvim_get_mode().mode == 'i' then
		return data_cache_value
	end

	-- Avoid repeated calls on same cursor position
	local curr_loc = vim.api.nvim_win_get_cursor(0)
	if data_prev_loc[1] == curr_loc[1] and data_prev_loc[2] == curr_loc[2] then
		return data_cache_value
	end

	data_prev_loc = vim.api.nvim_win_get_cursor(0)

	local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
	local gps_query = ts_queries.get_query(filelang, "nvimGPS")
	local transform = transform_lang[filelang]
	local config = configs[filelang]

	if not gps_query then
		return nil
	end

	-- Request treesitter parser to update the syntax tree for the current buffer.
	update_tree(vim.api.nvim_get_current_buf())

	local current_node = ts_utils.get_node_at_cursor()

	local node_data = {}
	local node = current_node

	local function add_node_data(pos, capture_name, capture_node)
		local text = ""

		if vim.fn.has("nvim-0.7") > 0 then
			text = vim.treesitter.query.get_node_text(capture_node, 0)
			if text == nil then
				return data_cache_value
			end
			text = string.gsub(text, "%s+", ' ')
		else
			text = utils.get_node_text()
			text = table.concat(text, ' ')
		end

		local node_text = transform(
			config,
			capture_name,
			text
		)

		if node_text ~= nil then
			table.insert(node_data, pos, node_text)
		end
	end

	while node do
		local iter = gps_query:iter_captures(node, 0)
		local capture_ID, capture_node = iter()

		if capture_node == node then
			if gps_query.captures[capture_ID] == "scope-root" then

				while capture_node == node do
					capture_ID, capture_node = iter()
				end
				local capture_name = gps_query.captures[capture_ID]
				add_node_data(1, capture_name, capture_node)

			elseif gps_query.captures[capture_ID] == "scope-root-2" then

				capture_ID, capture_node = iter()
				local capture_name = gps_query.captures[capture_ID]
				add_node_data(1, capture_name, capture_node)

				capture_ID, capture_node = iter()
				capture_name = gps_query.captures[capture_ID]
				add_node_data(2, capture_name, capture_node)

			end
		end

		node = node:parent()
	end

	local data = {}
	for _, v in pairs(node_data) do
		if not vim.tbl_islist(v) then
			table.insert(data, v)
		else
			vim.list_extend(data, v)
		end
	end

	data_cache_value = data
	return data_cache_value
end

---@return string|nil  the pretty statusline component, or nil if not available
function M.get_location(opts)
	if vim.api.nvim_get_mode().mode == 'i' then
		return location_cache_value
	end

	local curr_loc = vim.api.nvim_win_get_cursor(0)
	if location_prev_loc[1] == curr_loc[1] and location_prev_loc[2] == curr_loc[2] then
		return location_cache_value
	end

	location_prev_loc = vim.api.nvim_win_get_cursor(0)

	local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
	local config = configs[filelang]
	local data = M.get_data()

	if not data then
		return nil
	end

	local depth = config.depth
	local separator = config.separator
	local disable_icons = config.disable_icons
	local depth_limit_indicator = config.depth_limit_indicator

	if opts ~= nil then
		depth = opts.depth or config.depth
		separator = opts.separator or config.separator
		disable_icons = opts.disable_icons or config.disable_icons
		depth_limit_indicator = opts.depth_limit_indicator or config.depth_limit_indicator
	end

	local context = {}
	for _, v in pairs(data) do
		if not disable_icons then
			table.insert(context, v.icon..v.text)
		else
			table.insert(context, v.text)
		end
	end

	if depth ~= 0 and #context > depth then
		context = vim.list_slice(context, #context-depth+1, #context)
		table.insert(context, 1, depth_limit_indicator)
	end

	context = table.concat(context, separator)

	location_cache_value = context
	return location_cache_value
end

return M
