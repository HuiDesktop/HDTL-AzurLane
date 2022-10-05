local ffi = require("ffi")
local raylib = require("raylib").lib
local C = require("cdef")

local M = {}

local handleType = ffi.typeof("uint32_t")
local ptype = ffi.typeof("void*")

-- Check is something fullscreen
M.isFullscreen = (function()
    local rcApp = ffi.new("RECT")
    local rcDesktop = ffi.new("RECT")
    return function()
        local hwndApp = C.GetForegroundWindow()
        local hwndDesktop = C.GetDesktopWindow()
        C.GetWindowRect(hwndApp, rcApp)
        C.GetWindowRect(hwndDesktop, rcDesktop)
        if hwndApp ~= ffi.cast(handleType, raylib.GetWindowHandle()) and hwndApp ~= hwndDesktop and hwndApp ~= C.GetShellWindow() then
            local s = ffi.new("char[1024]")
            local hwndParent = hwndApp
            while ((hwndParent ~= hwndDesktop) and (hwndParent ~= 0)) do
                C.GetClassNameA(hwndParent, s, 1023)
                if C.strcmp(s, "WorkerW") == 0 then return false end
                hwndParent = C.GetParent(hwndParent)
            end
            return
                rcApp.left <= rcDesktop.left and rcApp.top <= rcDesktop.top and
                    rcApp.right >= rcDesktop.right and rcApp.bottom >=
                    rcDesktop.bottom
        end
        return false
    end
end)()

M.directGetExStyle = function()
    return C.GetWindowLongW(ffi.cast(handleType, raylib.GetWindowHandle()), -20)
end

M.directSetExStyle = function(exStyle)
    return C.SetWindowLongW(ffi.cast(handleType, raylib.GetWindowHandle()), -20, exStyle)
end

M.enableExStyle = function(s)
    local exStyle = M.directGetExStyle()
    exStyle = bit.bor(exStyle, s)
    M.directSetExStyle(exStyle)
end

M.disableExStyle = function(s)
    local exStyle = M.directGetExStyle()
    exStyle = bit.bnot(bit.bor(bit.bnot(exStyle), s))
    M.directSetExStyle(exStyle)
end

M.setTransparent = function(enabled)
    local exStyle = M.directGetExStyle()
    if (bit.band(exStyle, 0x20) == 0) ~= enabled then -- WS_EX_TRANSPARENT 0x20L
        exStyle = bit.bxor(exStyle, 0x20)
        M.directSetExStyle(exStyle)
    end
end

M.getMousePos = (function()
    local mp = ffi.new("POINT")
    local wp = ffi.new("Vector2")
    return function()
        raylib.pGetWindowPosition(wp)
        C.GetCursorPos(mp)
        return {x = mp.x - wp.x, y = mp.y - wp.y}
    end
end)()

M.setDesktopParent = function()
    local programIntPtr = C.FindWindowA("Progman", "Program Manager")
    if programIntPtr ~= 0 then
        C.SendMessageTimeoutA(programIntPtr, 0x52c, ffi.NULL, ffi.NULL, 0, 1000, ffi.NULL);
        local p = 0
        repeat
            p = C.FindWindowExA(0, p, "WorkerW", ffi.NULL);
            if p ~= 0 then
                if 0 ~= C.FindWindowExA(p, 0, "SHELLDLL_DefView", ffi.NULL) then
                    C.ShowWindow(C.FindWindowExA(0, p, "WorkerW", ffi.NULL), 0);
                end
            end
        until (p == 0)
        C.SetParent(raylib.GetWindowHandle(), programIntPtr);
        raylib.MaximizeWindow()
    end
end

M.getGround = function()
    local rect = ffi.new('RECT')
    C.SystemParametersInfoA(0x30, 0, rect, 0)
    return rect.bottom
end

M.setTransparency = function(v)
    C.SetLayeredWindowAttributes(raylib.GetWindowHandle(), 0, v, 2)
end

M.setTopmost = function()
    C.SetWindowPos(raylib.GetWindowHandle(), ffi.cast(ptype, -1), 0, 0, 0, 0, 3)
    C.SetWindowPos(raylib.GetWindowHandle(), ffi.cast(ptype, 0), 0, 0, 0, 0, 3)
end

return M
