# love-api-to-ldt-luadoc

Probably the most important part of an Eclipse LDT Execution Environment is the api.zip file.

This utility creates all the files needed for a LOVE2D api.zip and puts them in out/, provided you feed it the definitions from https://github.com/rm-code/love-api.

**This project currently only outputs the first definition for a function.** Any overloading is ignored.

We do output types fairly completely, and all the functions on them, though.

## Credits

This project uses parts wholesale from the original (hand-written?) LuaDoc for Koneki: https://github.com/mkosler/LOVELuaDoc, https://github.com/RamiLego4Game/LOVELuaDoc-0.9.0. However, we produce all the LOVE API files automatically.

Obviously https://github.com/rm-code/love-api/ is incredibly important, too.

## How to use

1. Grab https://github.com/rm-code/love-api/. Latest version works for me, but grab the 0.9.2d release if you have any trouble.

2. Checkout/download this repository (love-api-to-ldt-luadoc).

3. Copy love_api.lua and modules/ from the love-api project next to main.lua in this project.

4. Run main.lua.

5. Hopefully, it succeeded. (File an issue if not and the built-in diagnostics don't help.)

6. Given that it succeeded: Go **inside** the out/ folder and zip up everything in there. That's your api.zip!

## Pre-built downloads

Go see https://github.com/leafi/love-eclipse-ldt for that sort of thing. That'll give you the whole execution environment.
