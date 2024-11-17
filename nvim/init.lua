-- Bootstrap lazy.nvim package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = ","  -- Changed to comma for easymotion

-- Core Vim settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = 'unnamedplus'

-- Basic keymaps
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear search' })

-- Create directory for storing LLM plugin
local plugin_dir = vim.fn.stdpath("config") .. "/lua/ding"
vim.fn.mkdir(plugin_dir, "p")

-- Plugin specification
require("lazy").setup({
  -- Theme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'tokyonight'
    end,
  },

  -- File finder
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>f', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>g', '<cmd>Telescope live_grep<cr>', desc = 'Grep files' },
      { '<leader>b', '<cmd>Telescope buffers<cr>', desc = 'Find buffers' },
    },
  },

  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
  },

  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  -- Easymotion
  {
    'easymotion/vim-easymotion',
    config = function()
      -- Easymotion configuration
      vim.g.EasyMotion_do_mapping = 0 -- Disable default mappings
      vim.keymap.set('n', '<localleader><localleader>w', '<Plug>(easymotion-w)', { desc = 'Easymotion forward' })
      vim.keymap.set('n', '<localleader><localleader>b', '<Plug>(easymotion-b)', { desc = 'Easymotion backward' })
    end
  },
})

-- LSP Configuration
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 
    -- Add your needed language servers here
  },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename symbol' })

-- Autocompletion setup
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim-lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
  indent = { enable = true },
  ensure_installed = {
    -- Add your needed languages here
  },
})

-- LLM Plugin Setup
local llm = require('ding.llm')

-- Example function to use Anthropic's Claude
function Claude(opts)
  opts = opts or {}
  opts.url = 'https://api.anthropic.com/v1/messages'
  opts.api_key_name = ''
  opts.model = 'claude-3-5-sonnet-20241022'
  
  vim.notify("Claude function called", vim.log.levels.INFO)
  
  return llm.invoke_llm_and_stream_into_editor(opts, llm.make_anthropic_spec_curl_args, llm.handle_anthropic_spec_data)
end

-- Example function to use OpenAI
function ChatGPT(opts)
  opts = opts or {}
  opts.url = 'https://api.openai.com/v1/chat/completions'
  opts.api_key_name = ''
  opts.model = 'gpt-4'
    
  vim.notify("GPT-4 function called", vim.log.levels.INFO)

  return llm.invoke_llm_and_stream_into_editor(opts, llm.make_openai_spec_curl_args, llm.handle_openai_spec_data)
end

-- Keymaps for LLM functions
vim.keymap.set('n', '<localleader><localleader>c', function() Claude() end, { desc = 'Ask Claude' })
vim.keymap.set('v', '<localleader><localleader>c', function() Claude({ replace = true }) end, { desc = 'Ask Claude (replace)' })
vim.keymap.set('n', '<localleader><localleader>g', function() ChatGPT() end, { desc = 'Ask GPT' })
vim.keymap.set('v', '<localleader><localleader>g', function() ChatGPT({ replace = true }) end, { desc = 'Ask GPT (replace)' })

