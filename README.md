# HDTL-LuaRoot

HDTL Lua modules and conventions
Please download luajit and put `luajit.exe` and `lua51.dll` here. Put jit directory here if you want.

## HuiDesktop modules

Every module is stored in an individual directory in `/lua`. `hdtmodule.lua` should return a function that will be called when the module is using `require` to load a module. The function accepts one argument: the name of the importing module. If the module is a global module (not in the module's directory), the function should return `true`, otherwise `false`.

You should put the entry file in the root directory and `dofile "hdtbase.lua"`.
