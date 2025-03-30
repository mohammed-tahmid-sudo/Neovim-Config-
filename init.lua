-- init.lua
-- Enable both absolute and relative line numbers
vim.o.number = true
vim.o.relativenumber = true


-- Ensure packer.nvim is installed and loaded
vim.cmd [[packadd packer.nvim]]

-- Plugin Setup with packer.nvim
require('packer').startup(function(use)
  -- Let packer manage itself
  use 'wbthomason/packer.nvim'
  
  -- LSP configurations
  use 'neovim/nvim-lspconfig'
  
  -- Completion engine and sources
  use 'hrsh7th/nvim-cmp'               -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'           -- LSP completion source
  use 'hrsh7th/cmp-buffer'             -- Buffer completions
  use 'hrsh7th/cmp-path'               -- Filesystem paths completions
  
  -- Snippet support (optional but recommended)
  use 'L3MON4D3/LuaSnip'               -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'       -- Snippet completions
end)

-- LSP Setup
local lspconfig = require('lspconfig')

-- Python LSP using pyright
lspconfig.pyright.setup{}

-- C/C++ LSP using clangd
lspconfig.clangd.setup{}

-- Setup nvim-cmp for autocompletion
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),  -- trigger completion
    ['<Up>']    = cmp.mapping.select_prev_item(),  -- select previous item
    ['<Down>']  = cmp.mapping.select_next_item(),  -- select next item
    ['<Tab>']   = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>']    = cmp.mapping.confirm({ select = true }), -- confirm selection
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})


vim.api.nvim_set_keymap('n', 'j', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'l', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ';', 'l', { noremap = true, silent = true })

vim.api.nvim_create_augroup("file_saved_group", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = "file_saved_group",
  pattern = "*", -- Applies to all files, adjust as needed
  callback = function()
    print("File saved!")
  end,
})


-- Create a custom `:Run` command to execute the current file and show the output
vim.api.nvim_create_user_command('Run', function()
  local file = vim.fn.expand('%')  -- Get the current file's path
  local filetype = vim.bo.filetype -- Get the filetype to decide how to run it

  local output = ""

  -- Run different commands based on the file type
  if filetype == 'python' then
    -- If it's a Python file, run it with `python3` and capture the output
    output = vim.fn.system('python3 ' .. file)
  elseif filetype == 'c' then
    -- If it's a C file, compile and run it using gcc
    local exe = file:match("(.+)%..+$")  -- Get file name without extension
    vim.fn.system('gcc ' .. file .. ' -o ' .. exe)  -- Compile the C file
    output = vim.fn.system(exe)  -- Run the compiled executable
  else
    output = "Unsupported file type: " .. filetype
  end

  -- Print the output (or error) in the command line
  print(output)
end, {})

