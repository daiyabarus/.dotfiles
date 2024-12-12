-- Plugins: Formatting
-- https://github.com/rafi/vim-config

return {

	-- Import LazyVim's formatting spec in its entirety.
	{ import = 'lazyvim.plugins.formatting' },

	-- Lightweight yet powerful formatter plugin
	{
		'stevearc/conform.nvim',
		keys = {
			{ '<leader>cic', '<cmd>ConformInfo<CR>', silent = true, desc = 'Conform Info' },
		},
			formatters_by_ft = {
		lua = { 'stylua' },
		-- Conform can also run multip
		python = {'black', 'isor'},
		--
		-- You can use a sub-list to tell conform to run *until* a formatter
		-- is found.
		javascript = { { "prettierd", "prettier" } },
	},
},
}
