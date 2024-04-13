local snippets = {}

snippets.config = require("nvim-snippets.config")
snippets.utils = require("nvim-snippets.utils")

Snippets = snippets

---@class Snippet
---@field prefix string
---@field body string

---@private
---@type table<string, table<string, Snippet>>
snippets.loaded_snippets = {}

---@private
---@type table<string, string|string[]>
snippets.registry = {}

---@type fun(filetype?: string): table<string, table>|nil
function snippets.load_snippets_for_ft(filetype)
	if snippets.utils.is_filetype_ignored(filetype) then
		return nil
	end

	local global_snippets = snippets.utils.get_global_snippets()
	local extended_snippets = snippets.utils.get_extended_snippets(filetype)
	local ft_snippets = snippets.utils.get_snippets_for_ft(filetype)
	snippets.loaded_snippets[filetype] = vim.tbl_deep_extend("force", {}, global_snippets, extended_snippets, ft_snippets)

	return snippets.loaded_snippets[filetype]
end

---@param filetype string
---@param name string
---@param snip Snippet
function snippets.add_snippet(filetype, name, snip)
    snippets.loaded_snippets[filetype] = vim.tbl_extend("keep", snippets.loaded_snippets[filetype] or {}, {[name] = snip})
end

---@param filetype string
---@return table<string, Snippet>
function snippets.get_snippets(filetype)
    return snippets.loaded_snippets[filetype] or {}
end

---@param opts? table  -- Make a better type for this
function snippets.setup(opts)
	snippets.config.new(opts)
	if snippets.config.get_option("friendly_snippets") then
		snippets.utils.load_friendly_snippets()
	end

	snippets.utils.register_snippets()

	if snippets.config.get_option("create_autocmd") then
		snippets.utils.create_autocmd()
	end

	if snippets.config.get_option("create_cmp_source") then
		snippets.utils.register_cmp_source()
	end
end

return snippets
