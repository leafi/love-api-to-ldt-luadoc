-- There seems to be some inconsistencies in the API here and there.
-- So we swallow it and try to recreate missing Types and Enums and whatnot.

return function(api)
  local modules = {}
  
  -- build table of all modules with their internal name
  for _, mod in ipairs(api.modules) do
    modules[mod._name] = mod
  end
  
  -- Patching up love.graphics
  if modules["graphics"] then
    local graphicsEnums = {}
    for _, v in ipairs(modules.graphics.enums) do
      graphicsEnums[v.name] = v
    end
    
    -- Patch #1
    -- sub-enum love.graphics.texture#PixelFormat is missing in love-api
    if not graphicsEnums["PixelFormat"] then
      print("PATCH #1: APPLYING: PixelFormat missing from love.graphics. I'll just add it.")
      table.insert(modules.graphics.enums, {
        name = 'PixelFormat',
        description = 'Pixel formats for Textures, ImageData, and CompressedImageData.',
        constants = {
          {
              name = 'rgba8',
              description = '8 bits per channel (32 bpp) RGBA. Color channel values range from 0-255 (0-1 in shaders).'
          },
          {
              name = 'rgba4',
              description = '4 bits per channel (16 bpp) RGBA.'
          },
          {
              name = 'rgb5a1',
              description = 'RGB with 5 bits each, and a 1-bit alpha channel (16 bpp).'
          },
          {
              name = 'rgb565',
              description = 'RGB with 5, 6, and 5 bits each, respectively (16 bpp). There is no alpha channel in this format.'
          },
          {
              name = 'rgb10a2',
              description = 'RGB with 10 bits per channel, and a 2-bit alpha channel (32 bpp).'
          },
          {
              name = 'rgba16f',
              description = 'Floating point RGBA with 16 bits per channel (64 bpp). Color values can range from [-65504, +65504].'
          },
          {
              name = 'rgba32f',
              description = 'Floating point RGBA with 32 bits per channel (128 bpp).'
          },
          {
              name = 'rg11b10f',
              description = 'Floating point RGB with 11 bits in the red and green channels, and 10 bits in the blue channel (32 bpp). There is no alpha channel. Color values can range from [0, +65024].'
          },
          {
              name = 'srgb',
              description = 'The same as rgba8, but the Canvas is interpreted as being in the sRGB color space. Everything drawn to the Canvas will be converted from linear RGB to sRGB. When the Canvas is drawn (or used in a shader), it will be decoded from sRGB to linear RGB. This reduces color banding when doing gamma-correct rendering, since sRGB encoding has more precision than linear RGB for darker colors.'
          },
          {
              name = 'r8',
              description = 'Single-channel (red component) format (8 bpp).'
          },
          {
              name = 'rg8',
              description = 'Two channels (red and green components) with 8 bits per channel (16 bpp).'
          },
          {
              name = 'r16f',
              description = 'Floating point single-channel format (16 bpp). Color values can range from [-65504, +65504].'
          },
          {
              name = 'rg16f',
              description = 'Floating point two-channel format with 16 bits per channel (32 bpp). Color values can range from [-65504, +65504].'
          },
          {
              name = 'r32f',
              description = 'Floating point single-channel format (32 bpp).'
          },
          {
              name = 'rg32f',
              description = 'Floating point two-channel format with 32 bits per channel (64 bpp).'
          },
          {
              name = 'DXT1',
              description = 'The DXT1 format. RGB data at 4 bits per pixel (compared to 32 bits for ImageData and regular Images.) Suitable for fully opaque images. Suitable for fully opaque images on desktop systems.',
          },
          {
              name = 'DXT3',
              description = 'The DXT3 format. RGBA data at 8 bits per pixel. Smooth variations in opacity do not mix well with this format.',
          },
          {
              name = 'DXT5',
              description = 'The DXT5 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on desktop systems.',
          },
          {
              name = 'BC4',
              description = 'The BC4 format (also known as 3Dc+ or ATI1.) Stores just the red channel, at 4 bits per pixel.',
          },
          {
              name = 'BC4s',
              description = 'The signed variant of the BC4 format. Same as above but the pixel values in the texture are in the range of [-1, 1] instead of [0, 1] in shaders.',
          },
          {
              name = 'BC5',
              description = 'The BC5 format (also known as 3Dc or ATI2.) Stores red and green channels at 8 bits per pixel.',
          },
          {
              name = 'BC5s',
              description = 'The signed variant of the BC5 format.',
          },
          {
              name = 'BC6h',
              description = 'The BC6H format. Stores half-precision floating-point RGB data in the range of [0, 65504] at 8 bits per pixel. Suitable for HDR images on desktop systems.',
          },
          {
              name = 'BC6hs',
              description = 'The signed variant of the BC6H format. Stores RGB data in the range of [-65504, +65504].',
          },
          {
              name = 'BC7',
              description = 'The BC7 format (also known as BPTC.) Stores RGB or RGBA data at 8 bits per pixel.',
          },
          {
              name = 'ETC1',
              description = 'The ETC1 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on older Android devices.'
          },
          {
              name = 'ETC2rgb',
              description = 'The RGB variant of the ETC2 format. RGB data at 4 bits per pixel. Suitable for fully opaque images on newer mobile devices.'
          },
          {
              name = 'ETC2rgba',
              description = 'The RGBA variant of the ETC2 format. RGBA data at 8 bits per pixel. Recommended for images with varying opacity on newer mobile devices.'
          },
          {
              name = 'ETC2rgba1',
              description = 'The RGBA variant of the ETC2 format where pixels are either fully transparent or fully opaque. RGBA data at 4 bits per pixel.'
          },
          {
              name = 'EACr',
              description = 'The single-channel variant of the EAC format. Stores just the red channel, at 4 bits per pixel.'
          },
          {
              name = 'EACrs',
              description = 'The signed single-channel variant of the EAC format. Same as above but pixel values in the texture are in the range of [-1, 1] instead of [0, 1] in shaders.'
          },
          {
              name = 'EACrg',
              description = 'The two-channel variant of the EAC format. Stores red and green channels at 8 bits per pixel.'
          },
          {
              name = 'EACrgs',
              description = 'The signed two-channel variant of the EAC format.'
          },
          {
              name = 'PVR1rgb2',
              description = 'The 2 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 2 bits per pixel. Textures compressed with PVRTC1 formats must be square and power-of-two sized.'
          },
          {
              name = 'PVR1rgb4',
              description = 'The 4 bit per pixel RGB variant of the PVRTC1 format. Stores RGB data at 4 bits per pixel.'
          },
          {
              name = 'PVR1rgba2',
              description = 'The 2 bit per pixel RGBA variant of the PVRTC1 format.'
          },
          {
              name = 'PVR1rgba4',
              description = 'The 4 bit per pixel RGBA variant of the PVRTC1 format.'
          },
          {
              name = 'ASTC4x4',
              description = 'The 4x4 pixels per block variant of the ASTC format. RGBA data at 8 bits per pixel.'
          },
          {
              name = 'ASTC5x4',
              description = 'The 5x4 pixels per block variant of the ASTC format. RGBA data at 6.4 bits per pixel.'
          },
          {
              name = 'ASTC5x5',
              description = 'The 5x5 pixels per block variant of the ASTC format. RGBA data at 5.12 bits per pixel.'
          },
          {
              name = 'ASTC6x5',
              description = 'The 6x5 pixels per block variant of the ASTC format. RGBA data at 4.27 bits per pixel.'
          },
          {
              name = 'ASTC6x6',
              description = 'The 6x6 pixels per block variant of the ASTC format. RGBA data at 3.56 bits per pixel.'
          },
          {
              name = 'ASTC8x5',
              description = 'The 8x5 pixels per block variant of the ASTC format. RGBA data at 3.2 bits per pixel.'
          },
          {
              name = 'ASTC8x6',
              description = 'The 8x6 pixels per block variant of the ASTC format. RGBA data at 2.67 bits per pixel.'
          },
          {
              name = 'ASTC8x8',
              description = 'The 8x8 pixels per block variant of the ASTC format. RGBA data at 2 bits per pixel.'
          },
          {
              name = 'ASTC10x5',
              description = 'The 10x5 pixels per block variant of the ASTC format. RGBA data at 2.56 bits per pixel.'
          },
          {
              name = 'ASTC10x6',
              description = 'The 10x6 pixels per block variant of the ASTC format. RGBA data at 2.13 bits per pixel.'
          },
          {
              name = 'ASTC10x8',
              description = 'The 10x8 pixels per block variant of the ASTC format. RGBA data at 1.6 bits per pixel.'
          },
          {
              name = 'ASTC10x10',
              description = 'The 10x10 pixels per block variant of the ASTC format. RGBA data at 1.28 bits per pixel.'
          },
          {
              name = 'ASTC12x10',
              description = 'The 12x10 pixels per block variant of the ASTC format. RGBA data at 1.07 bits per pixel.'
          },
          {
              name = 'ASTC12x12',
              description = 'The 12x12 pixels per block variant of the ASTC format. RGBA data at 0.89 bits per pixel.'
          }
        }
      })
    else
      print("PATCH #1: Not applying. graphics module already has a PixelFormat enum.")
    end
    
    -- Patch #2
    -- sub-enum love.graphics.texture#PixelFormat is missing in love-api
    if not graphicsEnums["TextureType"] then
      print("PATCH #2: APPLYING: TextureType missing from love.graphics. I'll just add it.")
      table.insert(modules.graphics.enums, {
        name = 'TextureType',
        description = 'Types of textures (2D, cubemap, etc.)',
        constants = {
          {
              name = '2d',
              description = 'Regular 2D texture with width and height.'
          },
          {
              name = 'array',
              description = 'Several same-size 2D textures organized into a single object. Similar to a texture atlas / sprite sheet, but avoids sprite bleeding and other issues.'
          },
          {
              name = 'cube',
              description = 'Cubemap texture with 6 faces. Requires a custom shader (and Shader:send) to use. Sampling from a cube texture in a shader takes a 3D direction vector instead of a texture coordinate.'
          },
          {
              name = 'volume',
              description = '3D texture with width, height, and depth. Requires a custom shader to use. Volume textures can have texture filtering applied along the 3rd axis.'
          }
        }
      })
    else
      print("PATCH #2: Not applying. graphics module already has a TextureType enum.")
    end
    
    -- Patch #3
    -- enum love.graphics#VertexWinding is missing in love-api (is a red link at the wiki, so...)
    if not graphicsEnums["VertexWinding"] then
      print("PATCH #3: APPLYING: VertexWinding missing from love.graphics. I'll just add it.")
      table.insert(modules.graphics.enums, {
        name = 'VertexWinding',
        description = 'The winding mode being used. The default winding is counterclockwise ("ccw").',
        constants = {
          {
              name = 'cw',
              description = 'clockwise'
          },
          {
              name = 'ccw',
              description = 'counterclockwise'
          }
        }
      })
    else
      print("PATCH #3: Not applying. graphics module already has a VertexWinding enum.")
    end
    
    -- Patch #4
    -- enum love.graphics#CullMode is missing in love-api 
    if not graphicsEnums["CullMode"] then
      print("PATCH #4: APPLYING: CullMode missing from love.graphics. I'll just add it.")
      table.insert(modules.graphics.enums, {
        name = 'CullMode',
        description = 'How Mesh geometry is culled when rendering.',
        constants = {
          {
              name = 'back',
              description = 'Back-facing triangles in Meshes are culled (not rendered). The vertex order of a triangle determines whether it is back- or front-facing.'
          },
          {
              name = 'front',
              description = 'Front-facing triangles in Meshes are culled.'
          },
          {
              name = 'none',
              description = 'Both back- and front-facing triangles in Meshes are rendered.'
          }
        }
      })
    else
      print("PATCH #4: Not applying. graphics module already has a CullMode enum.")
    end
  end
   
  return api
end