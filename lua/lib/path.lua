local path = {}

path.home = vim.loop.os_homedir()
path.sep = package.config:sub(1, 1)
path.root = (function()
  if path.sep == "/" then
    return function() return "/" end
  else
    return function(base)
      base = base or vim.loop.cwd()
      return base:sub(1, 1) .. ":\\"
    end
  end
end)()

local function is_root(pathname)
  if path.sep == "\\" then
    return string.match(pathname, "^[A-Z]:\\?$")
  end
  return pathname == "/"
end

return path
