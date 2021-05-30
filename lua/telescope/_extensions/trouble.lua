-- TODO(runiq):
-- - Use start/finish in previewer. The qflist previewer can't do that, but maybe one of the LSP ones can?
-- - Add formatting: Telescope-like or Trouble-like?
--
-- Telescope formatting:
-- - File icon
-- - short filename, lnum, col, line text (shortened to columns)
-- - in previewer: full line highlighted

local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local has_trouble, trouble = pcall(require, 'trouble')
if not has_trouble then
  error('This plugins requires folke/trouble.nvim')
end

local telescope_provider = require("trouble.providers.telescope")

local actions = require'telescope.actions'
local action_state = require'telescope.actions.state'
local builtin = require'telescope.builtin'
local conf = require('telescope.config').values
local finders = require'telescope.finders'
local make_entry = require'telescope.make_entry'
local pickers = require'telescope.pickers'
local previewers  = require'telescope.previewers'
local sorters = require'telescope.sorters'

local M = {}

local function trouble_to_telescope()
  local results = {}
  for _, entry in pairs(trouble.get_items()) do
    if not entry.is_file then
      results[#results + 1] = entry
    end
  end
  return results
end

function M.from_trouble(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Trouble entries',
    finder    = finders.new_table {
      results = trouble_to_telescope(),
	  entry_maker = opts.entry_maker or make_entry.gen_from_lsp_diagnostics(opts),
    --   entry_maker = function(entry)
    --     	return {
    --     		valid = not entry.is_file,
    --     		filename = entry.filename,
    --     		value = entry,
    --     		display = vim.trim(entry.text:gsub("[\n]", "")):sub(0, vim.o.columns),
    --     		-- display = entry.filename .. ':' .. entry.lnum .. ':' .. entry.col .. ':' .. entry.text,
				-- -- This is what's being put in qflist, for example
    --     		text = entry.filename .. ':' .. entry.lnum .. ':' .. entry.col .. ':' .. entry.text,
				-- -- Used for sorting AND matching
    --     		ordinal = entry.full_text,
    --     		start = entry.start,
    --     		finish = entry.finish,
    --     		bufnr = entry.bufnr,
    --     		lnum = entry.lnum,
    --     		col = entry.col,
    --     	}
    --   end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map("n", "<c-ü>", require("trouble.providers.telescope").smart_open_with_trouble)
      map("i", "<c-ü>", require("trouble.providers.telescope").smart_open_with_trouble)
      return true
    end,
	previewer = conf.grep_previewer(opts),
  }):find()
end

return telescope.register_extension{ exports = M }
