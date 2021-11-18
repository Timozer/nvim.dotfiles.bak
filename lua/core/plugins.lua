local plugins = {}

function plugins:init()
	self.install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if vim.fn.empty(vim.fn.glob(self.install_path)) > 0 then
		self.bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', self.install_path})
	end
end

function plugins:load_plugins(plgs)
    require('packer').startup(function(use)
        for key, val in pairs(plgs) do
            use(val)
        end
    end)
	if plugins.bootstrap then
		require('packer').sync()
	end
end

plugins:init()

return plugins
