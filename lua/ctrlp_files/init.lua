local files = {}

local ctrlp = require('core.ctrlp')

files.name = 'files'
files.version = 'v0.1'
files.cmds = {}
files.cmds.grep = ctrlp.require_on_exported_call('ctrlp_files.files').grep

function files.setup()
    ctrlp.register(files)
end

return files
