-- There seems to be some inconsistencies in the API here and there.
-- Does nothing at the moment. If you find inconsitencies, open an 
-- Issue or a Pull Request at github.

return function(api)
  local modules = {}
  
  for _, mod in ipairs(api.modules) do
    modules[mod._name] = mod
  end
  
  return api
end