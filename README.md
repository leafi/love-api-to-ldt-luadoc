# love-api-to-ldt-luadoc

Probably the most important part of an Eclipse LDT Execution Environment is the api.zip file.

This utility creates all the files needed for a LOVE2D api.zip and puts them in api/, provided you feed it the definitions from https://github.com/love2d-community/love-api.

**This project currently only outputs the last definition for a function when imported in LDT.** Every variant gets exported, though. But metalua implementation in LDT only sets the last seen function as its spec.

**Enum definitions aren't encoded.**

We do output types fairly completely, and all the functions on them, though.

## Credits

This project uses parts wholesale from the original (hand-written?) LuaDoc for Koneki: https://github.com/mkosler/LOVELuaDoc, https://github.com/RamiLego4Game/LOVELuaDoc-0.9.0. However, we produce all the LOVE API files automatically.

Obviously https://github.com/love2d-community/love-api is incredibly important, too.

## How to use

1. Grab https://github.com/love2d-community/love-api. This build of love-api-to-ldt-luadoc is tested against https://github.com/love2d-community/love-api/tree/d8d9524e199411760f4e7230acc3563a1de69adb.

2. Checkout/download this repository (love-api-to-ldt-luadoc).

3. Copy love_api.lua and modules/ from the love-api project next to main.lua in this project.

4. Run main.lua.

5. Hopefully, it succeeded. (File an issue if not and the built-in diagnostics don't help.)

6. Given that it succeeded: Go **inside** the api/ folder and zip up everything in there. That's your api.zip!

## Pre-built downloads

Go see https://github.com/leafi/love-eclipse-ldt for that sort of thing. That'll give you the whole execution environment.
