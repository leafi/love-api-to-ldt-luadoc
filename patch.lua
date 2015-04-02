-- There seems to be some inconsistencies in the API here and there.

return function(api)
  local modules = {}
  
  for _, v in ipairs(api.modules) do
    modules[v.name] = v
  end
  
  if modules["graphics"] then
    local graphicsTypes = {}
    for _, v in ipairs(modules.graphics.types) do
      graphicsTypes[v.name] = v
    end
    if not graphicsTypes["Texture"] then
      print("PATCH #1: APPLYING: Graphics module should have a Texture type")
      table.insert(modules.graphics.types, {
        name = 'Texture',
        description = 'Superclass for drawable objects which represent a texture. All Textures can be drawn with Quads. This is an abstract type that can\'t be created directly.',
        supertypes = {
          'Drawable',
          'Object'
        }
      })
      print("PATCH #1.1: Patch Canvas, Image to additionally inherit from Texture.")
      table.insert(graphicsTypes["Canvas"].supertypes, 'Texture')
      table.insert(graphicsTypes["Image"].supertypes, 'Texture')
    else
      print("PATCH #1: Not applying. Graphics module already has a Texture type.")
    end
  end
  
  if modules["physics"] then
    local physicsTypes = {}
    for _, v in ipairs(modules.physics.types) do
      physicsTypes[v.name] = v
    end
    if not physicsTypes["WheelJoint"] then
      print("PATCH #2: APPLYING: WheelJoint missing from love.physics! (It *is* on the wiki. Just hiding.)")
      print("!!! There's like 12 unique functions for WheelJoint which I'm going to omit. Sorry.")
      table.insert(modules.physics.types, {
        name = 'WheelJoint',
        description = 'Restricts a point on the second body to a line on the first body.',
        constructors = {
          'newWheelJoint'
        },
        supertypes = {
          'Joint',
          'Object'
        },
        functions = {
          {
            name = 'pleaseConsultTheWiki',
            description = 'WheelJoint is missing from love-api. And I am lazy. Sorry!',
            functions = {{}}
          }
        }
      })
    else
      print("PATCH #2: Not applying. Physics module already has a WheelJoint type.")
    end
  end
  
  if modules["window"] then
    local windowEnums = {}
    for _, v in ipairs(modules.window.enums) do
      windowEnums[v.name] = v
    end
    if not windowEnums["MessageBoxType"] then
      print("PATCH #3: APPLYING: MessageBoxType missing from love.window. I'll just add it.")
      table.insert(modules.window.enums, {
        name = 'MessageBoxType',
        description = 'Types of message box dialogs. Different types may have slightly different looks.',
        constants = {
          {
            name = 'info',
            description = 'Informational dialog.'
          },
          {
            name = 'warning',
            description = 'Warning dialog.'
          },
          {
            name = 'error',
            description = 'Error dialog.'
          }
        }
      })
    else
      print("PATCH #3: Not applying. Window module already has a MessageBoxType enum.")
    end
  end
  
  if modules["math"] then
    print("PATCH #4: APPLYING the patch of ultimate sorrow: namespace clash between Lua's math and love.math.")
    modules.math.name = "LOVEmath"
    modules.math._name = "math"
  end
  
  return api
end