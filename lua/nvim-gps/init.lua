local ts_utils = require("nvim-treesitter.ts_utils")
local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")
local gps_utils = require("nvim-gps.utils")

local M = {}

-- Default configuration that can be overridden by users
local default_config = {
	enabled = true,
	icons = {
		["class-name"] = ' ',
		["function-name"] = ' ',
		["method-name"] = ' ',
		["container-name"] = '⛶ ',
		["tag-name"] = '炙'
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
	}
end

local cache_value = ""
local setup_complete = false

local function default_transform(config, capture_name, capture_text)
	if config.icons[capture_name] ~= nil then
		return config.icons[capture_name] .. capture_text
	else
		return capture_text
	end
end

local transform_lang = {
	["cpp"] = function(config, capture_name, capture_text)
		if capture_name == "multi-class-method" then
			local temp = gps_utils.split(capture_text, "%:%:")
			local ret = ""
			for i = 1, #temp-1  do
				local text = string.match(temp[i], "%s*([%w_]*)%s*<?.*>?%s*")
				ret = ret..default_transform(config, "class-name", text)..config.separator
			end
			return ret..default_transform(config, "method-name", string.match(temp[#temp], "%s*(~?%s*[%w_]*)%s*"))
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
			end
			local class_name = string.match(attributes, "class%s*=%s*%\"([%w-_%s]+)%\"")
			if class_name ~= nil then
				ret = ret..'.'..string.gsub(class_name, "%s+", '.')
			end
			return default_transform(config, "tag-name", ret)
		end
	end,
	["lua"] = function(config, capture_name, capture_text)
		if capture_name == "string-method" then
			return default_transform(config, "method-name", string.match(capture_text, "[\"\'](.*)[\"\']"))
		elseif capture_name == "multi-container" then
			return default_transform(config, "container-name", string.gsub(capture_text, "%.", config.separator..default_transform(config, "container-name", '')))
		elseif capture_name == "table-function" then
			local temp = gps_utils.split(capture_text, "%.")
			local ret = ""
			for i = 1, #temp-1  do
				ret = ret..default_transform(config, "container-name", temp[i])..config.separator
			end
			return ret..default_transform(config, "function-name", temp[#temp])
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
	if user_config.disable_icons then
		default_config.icons = {}
	else
		default_config.icons = vim.tbl_extend("force", default_config.icons, user_config["icons"] or {})
		setup_language_configs()
	end
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

function M.get_location()
	-- Inserting text cause error nodes
	if vim.fn.mode() == 'i' then
		return cache_value
	end

	local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
	local gps_query = ts_queries.get_query(filelang, "nvimGPS")
	local transform = transform_lang[filelang]
	local config = configs[filelang]

	if not gps_query then
		return "error"
	end

	local current_node = ts_utils.get_node_at_cursor()

	local node_text = {}
	local node = current_node

	while node do
		local iter = gps_query:iter_captures(node, 0)
		local capture_ID, capture_node = iter()

		if capture_node == node then
			if gps_query.captures[capture_ID] == "scope-root" then

				while capture_node == node do
					capture_ID, capture_node = iter()
				end
				local capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 1, transform(config, capture_name, table.concat(ts_utils.get_node_text(capture_node), ' ')))

			elseif gps_query.captures[capture_ID] == "scope-root-2" then

				capture_ID, capture_node = iter()
				local capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 1, transform(config, capture_name, table.concat(ts_utils.get_node_text(capture_node), ' ')))

				capture_ID, capture_node = iter()
				capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 2, transform(config, capture_name, table.concat(ts_utils.get_node_text(capture_node), ' ')))

			end
		end

		node = node:parent()
	end

	local context = table.concat(node_text, config.separator)

	if config.depth ~= 0 then
		local parts = vim.split(context, config.separator, true)
		if #parts > config.depth then
			local sliced = vim.list_slice(parts, #parts-config.depth+1, #parts)
			context = config.depth_limit_indicator .. config.separator .. table.concat(sliced, config.separator)
		end
	end

	cache_value = context
	return cache_value
end

return M
