local rl = require("raylib").lib

local M = {}
local audios = {}
local volume = 100 / 100
local init = false

M.audios = audios

M.playing = nil

M.single = false

M.register = function(path)
    if not init then
        init = true
        rl.InitAudioDevice()
    end
    local audio = {
        path = path,
        audio = rl.LoadMusicStream(path)
    }
    setmetatable(audio, {
        __index = {
            play = function(self)
                if M.single then
                    if M.playing ~= nil then M.playing:stop() end
                    M.playing = self
                end
                rl.PlayMusicStream(self.audio)
            end,
            stop = function(self)
                rl.StopMusicStream(self.audio)
            end,
            loop = function (self, is)
                self.audio.looping = is
            end,
            isplaying = function (self)
                return rl.IsMusicStreamPlaying(self.audio)
            end
        }
    })
    audios[#audios+1] = audio
    rl.SetMusicVolume(audio.audio, volume)
    return audio
end

M.update = function()
    for i = 1, #audios do
        rl.UpdateMusicStream(audios[i].audio)
    end
end

M.volume = function (s_volume)
    if s_volume == nil then return math.ceil(volume * 100) end
    volume = s_volume / 100
    for i = 1, #audios do
        rl.SetMusicVolume(audios[i].audio, volume)
    end
end

return M
