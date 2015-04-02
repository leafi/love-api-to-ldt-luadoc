print("If this doesn't work:")
print(" - you should drag love_api.lua & modules/ from love-api-0.9.2d into this directory")
print(" - you also need to make an out/ directory. we'll overwrite if we have to.")

local api = require("love_api")

-- references:
--  original LuaDoc for Koneki (LDT before data format change): https://github.com/RamiLego4Game/LOVELuaDoc-0.9.0
--  love-api (the entire LOVE api in a table): https://github.com/rm-code/love-api/ (make sure you get the -0.9.2d tag!)
--  how to actually write LuaDoc, with functions on tables & custom types: https://wiki.eclipse.org/LDT/User_Area/Documentation_Language

print(tostring(api) .. " OK")

print("Patching API...")
local patchFun = require("patch")
patchFun(api)

-- things to look for: functions, modules, types

-- don't care about callbacks really. they're few and far between.

-- typeFQN format: key: type name, value: fully qualified name (e.g. ["object"] = "love#Object") 
typeFQN = {}
-- add basic lua types
typeFQN["boolean"] = "#boolean"
typeFQN["nil"] = "#nil"
typeFQN["number"] = "#number"
typeFQN["string"] = "#string"
typeFQN["table"] = "#table"
-- ... not the best, but what you gonna do ...
typeFQN["light userdata"] = "#table"
-- ... can't express these well at all.
typeFQN["function"] = "" -- LuaDoc expects the full function contract. We can't give it that.
typeFQN["mixed"] = "" -- this literally means 'whatever', so...

print("PATCH #negativeOne: The erroneous and non-existent SearchOrder should actually be a boolean.")
typeFQN["SearchOrder"] = "#boolean"

print("PATCH #negativeTwo: Scancodes are strings, basically.")
typeFQN["Scancode"] = "#string"

-- Takes only the first line of a string.
function firstLine(s)
  local newlineIdx = string.find(s, "\n")
  if not newlineIdx then
    return s
  else
    return string.sub(s, 1, newlineIdx - 1)
  end
end

function otherLines(s)
  local newlineIdx = string.find(s, "\n")
  if not newlineIdx then
    return nil
  else
    local s2 = string.sub(s, newlineIdx + 1)
    if s2:sub(1, 1) == "\n" then
      s2 = string.sub(s2, 2)
    end
    if s2:sub(1, 1) == "\n" then
      s2 = string.sub(s2, 2)
    end
    return s2
  end
end

function isMultiLine(s)
  local newlineIdx = string.find(s, "\n")
  return newlineIdx and (newlineIdx ~= #s)
end

-- Safely comments out all the lines of the string.
function commentify(s)
  return "-- " .. (s:gsub("\n", "\n-- ")) .. "\n"
end

-- oh jeez oh god oh good christ oh no oh no oh dear
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local dirCmd = "ls "
    local listings = popen(dirCmd .. '"' .. directory .. '"')
    for filename in listings:lines() do
        i = i + 1
        t[i] = filename
    end

    if #t == 0 then
      print("Hm? No listings? OK. We'll try dir /b.")
      dirCmd = "dir /b "
      listings = popen(dirCmd .. '"' .. directory .. '"')
      for filename in listings:lines() do
          i = i + 1
          t[i] = filename
      end
    end
    return t
end

function copyfile(src, dst)
  local srcf = io.open(src, "rb")
  local src_contents = srcf:read("*all")
  srcf:close()
  
  local dstf = io.open(dst, "wb")
  dstf:write(src_contents)
  dstf:close()
end


-- this is the 'main loop', so to speak. except it doesn't loop.
-- what i'm trying to say is this is the bit you probably care about; it's what drives everything.
local function iLoveIt()

  -- let's write out a love.lua, referencing all of the modules.
  print("Writing out/love.lua...")
  
  -- (...and we'll start it with the contents of builtins/love.lua.HEADER)
  local lfhf = io.open("builtins/love.lua.HEADER", "r")
  local love_file_header = lfhf:read("*all")
  lfhf:close()
  
  local love_file = io.open("out/love.lua", "w")
  love_file:write(love_file_header)
  love_file:write("\n")
  
  for _, mod in ipairs(api.modules) do
    love_file:write("---\n")
    love_file:write("-- " .. firstLine(mod.description) .. "\n")
    love_file:write("-- @field [parent = #love] " .. mod.name .. "#" .. mod.name .. " " .. (mod._name or mod.name) .. "\n")
    love_file:write("-- \n\n")
  end
  
  -- learn base love module's type names
  api.name = "love" -- bleh
  learnTypesAndEnums(api)
  
  -- learn types from everything else
  for _, mod in ipairs(api.modules) do
    learnTypesAndEnums(mod)
  end
  
  -- HACK: SearchOrder type is referenced in the source files, but no definition exists!
  if not typeFQN["SearchOrder"] then
    
  end
  
  --local getver1, getver2 = describeFun("#love", api.functions[1])
  love_file:write(describeAllFuncsAndCallbacks(api))
  
  love_file:write("\nreturn nil\n")
  
  love_file:close()
  
  print("Wrote out/love.lua OK")
  
  
  -- now, write out the other modules.
  for _, mod in ipairs(api.modules) do
    print("Writing out/" .. mod.name .. ".lua...")
    local file = io.open("out/" .. mod.name .. ".lua", "w")
    
    file:write("---\n")
    if mod.description then file:write(commentify(mod.description)) end
    file:write("-- \n")
    file:write("-- @module " .. mod.name .. "\n")
    file:write("-- \n\n")
    
    file:write(describeAllFuncsAndCallbacks(mod))
    
    file:write("\nreturn nil\n")
    
    file:close()
    print("Wrote out/" .. mod.name .. ".lua OK")
  end

  
  print("\nEverything's going well! Now for the busywork.")
  print("Copying all files matching builtins/*.lua to out/*.lua...")
  
  local toCopy = {}
  local sawGlobal = false
  for _, maybe in ipairs(scandir("builtins")) do
    if maybe:sub(-4) == ".lua" then
      table.insert(toCopy, maybe:sub(1, -5))
      if maybe:sub(1, -5) == "global" then sawGlobal = true end
    end
  end
  if #toCopy == 0 then
    error("... You do have .lua files in builtins/, right? I can't find anything to copy!")
  end
  
  print("So, that's {" .. table.concat(toCopy, ", ") .. "}.lua.")
  
  if not sawGlobal then
    error("Huh? No global.lua? That's really important for LDT. Please locate it, and stuff it in builtins/!")
  end
  
  for _, fn in ipairs(toCopy) do
    copyfile("builtins/" .. fn .. ".lua", "out/" .. fn .. ".lua")
  end

  print("Copy OK")
  
  print("\nDone! Zip up the *contents* of out/, and that right there is your api.zip.")
  print("One of the two essential herbs and spices of an LDT Execution Environment!")
  
end

function learnTypesAndEnums(mod)
  print("learning types & enums from " .. mod.name)
  if mod.types then
    for _, t in ipairs(mod.types) do
      if typeFQN[t.name] then
        error("Name collision: Can't insert " .. t.name .. " -> " .. mod.name .. "#" .. t.name .. ", because there's already " .. t.name .. " -> " .. typeFQN[t.name])
      end
      typeFQN[t.name] = mod.name .. "#" .. t.name
    end
  end
  
  -- enums are basically types, right?
  if mod.enums then
    for _, t in ipairs(mod.enums) do
      if typeFQN[t.name] then
        error("Name collision: Can't insert " .. t.name .. " -> " .. mod.name .. "#" .. t.name .. ", because there's already " .. t.name .. " -> " .. typeFQN[t.name])
      end
      typeFQN[t.name] = mod.name .. "#" .. t.name
    end
  end
end

function describeAllFuncsAndCallbacks(mod)
  local pn = "#" .. mod.name
  local out = {}
  
  if mod.functions then
    for _, f in ipairs(mod.functions) do
      table.insert(out, describeFun(pn, f))
    end
  end
  
  if mod.callbacks then
    for _, f in ipairs(mod.callbacks) do
      table.insert(out, describeFun(pn, f))
    end
  end
  
  return table.concat(out)
end

function describeFun(parent, fun)
  -- for some ridiculous reason, functions contain a table called functions. i assume this handles function overloading,
  -- but honestly, who knows.
  --
  -- for now (!!!) we'll take only the first definition.
  
  local name = fun.name
  local shortDesc = firstLine(fun.description)
  local longDesc = otherLines(fun.description)
  local def = fun.functions[1]
  
  local sb = {}
  local function push(s) table.insert(sb, s) end
  
  push("---\n")
  
  push("-- ")
  push(shortDesc or name)
  push("\n")
  
  if longDesc then
    push("-- \n")
    push(commentify(longDesc))
  end
  
  push("-- @function [parent = ")
  push(parent)
  push("] ")
  push(name)
  push("\n")
  
  if def.arguments then
    for _, arg in ipairs(def.arguments) do
      push("-- @param ")
      if not typeFQN[arg.type] then error("unknown type at this time: " .. arg.type .. " (while parsing " .. parent .. ")") end
      local typ = typeFQN[arg.type]
      push(typ)
      if typ ~= "" then push(" ") end
      push(arg.name)
      push(" ")
      if arg.description then push(firstLine(arg.description)) end
      push("\n")
    end
  end
  
  if def.returns then
    for _, ret in ipairs(def.returns) do
      push("-- @return ")
      if not typeFQN[ret.type] then error("unknown type at this time: " .. ret.type .. " (while parsing " .. parent .. ")") end
      local typ = typeFQN[ret.type]
      push(typ)
      if typ ~= "" then push(" ") end
      push(ret.name)
      push(" ")
      if ret.description then push(firstLine(ret.description)) end
      push("\n")
    end
  end
  
  push("-- \n\n")
  
  return table.concat(sb)
end

-- Call main function.
iLoveIt()
