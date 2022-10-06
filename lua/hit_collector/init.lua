local ev = require("eventize")
local rl = require("raylib").lib
local window = require("blockly_window")
local win32 = require("win32")

local storedHit = false
local hit = false

ev.on(window.before_draw, function()
    hit = false
end)

ev.on(window.after_draw, function()
    if storedHit ~= hit then
        storedHit = hit
        if storedHit then rl.ClearWindowState(rl.FLAG_WINDOW_MOUSE_PASSTHROUGH)
        else rl.SetWindowState(rl.FLAG_WINDOW_MOUSE_PASSTHROUGH) end
    end
end)

return {
    hit = function ()
        hit = true
    end,
    isHit = function ()
        return hit
    end
}
