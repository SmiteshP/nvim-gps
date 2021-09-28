local ts_utils = require("nvim-treesitter.ts_utils")
local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")
local gps_utils = require("nvim-gps.utils")

local M = {}

local config = {
	icons = {
		["class-name"] = ' ',
		["function-name"] = ' ',
		["method-name"] = ' ',
		["container-name"] = '⛶ ',
		["tag-name"] = '炙'
	},
	languages = {
		["bash"] = true,       -- bash and zsh
		["c"] = true,
		["cpp"] = true,
		["elixir"] = true,
		["fennel"] = true,
		["go"] = true,
		["html"] = true,
		["java"] = true,
		["jsx"] = true,
		["javascript"] = true,
		["lua"] = true,
		["ocaml"] = true,
		["python"] = true,
		["ruby"] = true,
		["rust"] = true,
		["tsx"] = true,
		["typescript"] = true,
	},
	separator = ' > ',
}

local cache_value = ""
local setup_complete = false

local function default_transform(capture_name, capture_text)
	if config.icons[capture_name] ~= nil then
		return config.icons[capture_name] .. capture_text
	end
end

local transform_lang = {
	["cpp"] = function(capture_name, capture_text)
		if capture_name == "multi-class-method" then
			local temp = gps_utils.split(capture_text, "%:%:")
			local ret = ""
			for i = 1, #temp-1  do
				local text = string.match(temp[i], "%s*([%w_]*)%s*<?.*>?%s*")
	 			ret = ret..config.icons["class-name"]..text..config.separator
			end
			return ret..config.icons["method-name"]..string.match(temp[#temp], "%s*([%w_]*)%s*")
		else
			return default_transform(capture_name, capture_text)
		end
	end,
	["html"] = function(capture_name, capture_text)
		if capture_name == "tag-name" then
			local text = string.match(capture_text, "<(.*)>")
			local tag_name, attributes = string.match(text, "(%w+)(.*)")
			local ret = tag_name
			local id_name = string.match(attributes, "id%s*=%s*%\"([^%s]+)%\"")
			if id_name ~= nil then
				ret = ret..'#'..id_name
			end
			local class_name = string.match(attributes, "class%s*=%s*%\"([%w-_%s]+)%\"")
			if class_name ~= nil then
				ret = ret..'.'..string.gsub(class_name, "%s+", '.')
			end
			return config.icons["tag-name"]..ret
		end
	end,
	["lua"] = function(capture_name, capture_text)
		if capture_name == "string-method" then
			return config.icons["method-name"]..string.match(capture_text, "[\"\'](.*)[\"\']")
		elseif capture_name == "multi-container" then
			return config.icons["container-name"]..string.gsub(capture_text, "%.", config.separator..config.icons["container-name"])
		elseif capture_name == "table-function" then
			local temp = gps_utils.split(capture_text, "%.")
			local ret = ""
			for i = 1, #temp-1  do
				ret = ret..config.icons["container-name"]..temp[i]..config.separator
			end
			return ret..config.icons["function-name"]..temp[#temp]
		else
			return default_transform(capture_name, capture_text)
		end
	end,
	["python"] = function(capture_name, capture_text)
		if capture_name == "main-function" then
			return config.icons["function-name"].."main"
		else
			return default_transform(capture_name, capture_text)
		end
	end
}

function M.is_available()
	return setup_complete and (config.languages[ts_parsers.ft_to_lang(vim.bo.filetype)] == true)
end

function M.setup(user_config)
	-- By default enable all languages
	for k, _ in pairs(config.languages) do
		config.languages[k] = ts_parsers.has_parser(k)
		if transform_lang[k] == nil then
			transform_lang[k] = default_transform
		end
	end

	-- Override default with user settings
	if user_config then
		if user_config.icons then
			for k, v in pairs(user_config.icons) do
				config.icons[k] = v
			end
		end
		if user_config.languages then
			for k, v in pairs(user_config.languages) do
				if config.languages[k] then
					config.languages[k] = v
				end
			end
		end
		if user_config.separator ~= nil then
			config.separator = user_config.separator
		end
	end

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
				table.insert(node_text, 1, transform(capture_name, ts_utils.get_node_text(capture_node)[1]))

			elseif gps_query.captures[capture_ID] == "scope-root-2" then

				capture_ID, capture_node = iter()
				local capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 1, transform(capture_name, ts_utils.get_node_text(capture_node)[1]))

				capture_ID, capture_node = iter()
				capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 2, transform(capture_name, ts_utils.get_node_text(capture_node)[1]))

			end
		end

		node = node:parent()
	end

	cache_value = table.concat(node_text, config.separator)
	return cache_value
end

return M
