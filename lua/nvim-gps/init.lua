local ts_utils = require("nvim-treesitter.ts_utils")
local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")
local gps_utils = require("nvim-gps.utils")

local M = {}

local current_symbols = {
	lang = nil,
	icons = {},
	separator = ''
}

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
	lang_specific = {}
}

local cache_value = ""
local setup_complete = false

local function default_transform(capture_name, capture_text)
	if current_symbols.icons[capture_name] ~= nil then
		return current_symbols.icons[capture_name] .. capture_text
	end
end

local function update_icons(filelang)
	current_symbols.lang = filelang

	-- Reset to default
	current_symbols.icons = config.icons
	current_symbols.separator = config.separator

	-- Override
	local lang_specific = config.lang_specific
	if lang_specific[filelang] ~= nil then
		local override_icons = lang_specific[filelang].icons

		if override_icons ~= nil then
			for k, v in pairs(override_icons) do
				current_symbols.icons[k] = v
			end
		end

		if lang_specific[filelang].separator ~= nil then
			current_symbols.separator = lang_specific[filelang].separator
		end
	end
end

local transform_lang = {
	["cpp"] = function(capture_name, capture_text)
		if capture_name == "multi-class-name" then
			return current_symbols.icons["class-name"]..string.gsub(capture_text, "%s*%:%:%s*", current_symbols.separator..current_symbols.icons["class-name"])
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
			return current_symbols.icons["tag-name"]..ret
		end
	end,
	["lua"] = function(capture_name, capture_text)
		if capture_name == "string-method" then
			return current_symbols.icons["method-name"]..string.match(capture_text, "[\"\'](.*)[\"\']")
		elseif capture_name == "multi-container" then
			return current_symbols.icons["container-name"]..string.gsub(capture_text, "%.", current_symbols.separator..current_symbols.icons["container-name"])
		elseif capture_name == "table-function" then
			local temp = gps_utils.split(capture_text, "%.")
			local ret = ""
			for i = 1, #temp-1  do
				ret = ret..current_symbols.icons["container-name"]..temp[i]..current_symbols.separator
			end
			return ret..current_symbols.icons["function-name"]..temp[#temp]
		else
			return default_transform(capture_name, capture_text)
		end
	end,
	["python"] = function(capture_name, capture_text)
		if capture_name == "main-function" then
			return current_symbols.icons["function-name"].."main"
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

		if user_config.lang_specific ~= nil then
			local lang_specific = user_config.lang_specific

			for lang, override in pairs(lang_specific) do
				if config.lang_specific[lang] == nil then
					config.lang_specific[lang] = {
						icons = {}
					}
				end

				if override.icons ~= nil then
					for k, v in pairs(override.icons) do
						config.lang_specific[lang].icons[k] = v
					end
				end

				if override.separator ~= nil then
					config.lang_specific[lang].separator = override.separator
				end
			end
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

	if current_symbols.lang ~= filelang then
		update_icons(filelang)
	end

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

	cache_value = table.concat(node_text, current_symbols.separator)
	return cache_value
end

return M
