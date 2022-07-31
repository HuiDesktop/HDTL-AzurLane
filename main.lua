require("hdtbase")
local ev = require("eventize")
local window = require("blockly_window")
local blockly_spine = require("blockly_spine38")
local dragmove = require("dragmove")
local settingsMan = require("settings")
local walkMan = require("walk")
local audio = require("blockly_audio")
local ipc = require("ipc")
local win32 = require("win32")

local modelNameFile = io.open("assets/name.txt", "r")
if modelNameFile == nil then log("failed to load model name") os.exit(1, true) return end
local modelName = modelNameFile:read("l")
modelNameFile:close()

ipc.addPanelItem({ type = "readonly", text = "HuiDesktop Light 碧蓝航线预制 " .. modelName }, function() end, function() end)

-- 工具函数
local function setPropertyValues(self, values)
    for k, v in pairs(values) do
        self[k](v)
    end
end

local state = "idle"
local enterStateThen = {}
local enterState = function(name)
    state = name
    enterStateThen[name]()
end

-- 加载设置
local settings = settingsMan.load("settings.json", true)
settings:default({ walk = true, drag = true, volume = 50, idleAudioProb = 60 ,startDistance = 500, stopDistance = 200, scale = 50, drop = true, transparency = 255, autoHide = true, idleMotion = 1, launchAudio = false })
settings:save()

local def = settingsMan.load("assets/audio.conf.json", false)

-- 新建窗口
window.create { vsync = true, topmost = true, transparent = true, autoHide = true, settings = settings:access("window") }
win32.setTransparency(settings.transparency)
ipc.addPanelItem(
    { type = "single", valueType = "number", prompt = "帧率：", hint = "0为不限制（匹配屏幕刷新率）", min = 0, max = 114514 },
    function(v) settings.window.fps = v window.setFPS(v) settings:save() end,
    function() return settings.window.fps end)
ipc.addPanelItem(
    { type = "bool", prompt = "显示帧率", hint = "左上角数字" },
    function(v) settings.window.drawFps = v settings:save() end,
    function() return settings.window.drawFps end)
ipc.addPanelItem(
    { type = "bool", prompt = "全屏隐藏", hint = "有窗口全屏时是否隐藏自己" },
    function(v) settings.autoHide = v window.param.autoHide = v settings:save() end,
    function() return settings.autoHide end)
ipc.addPanelItem(
    { type = "single", valueType = "number", prompt = "透明度：", hint = "0（透明） ~ 255（不透明） 注意设置为0时窗口仍然响应点击", min = 0, max = 255 },
    function(v) settings.transparency = v win32.setTransparency(v) settings:save() end,
    function() return settings.transparency end)

-- 加载模型
local model = blockly_spine.createFromDefaultConfigFile { hittest = true, pma = false }
setPropertyValues(model, {
    scale = settings.scale / 100,
    defaultMix = 0.2,
    listenEvent = true })
model.setWindowSize() -- 将窗口大小设置为适合模型的状态
ipc.addPanelItem(
    { type = "single", valueType = "number", prompt = "缩放（百分制）：", hint = "100为一倍缩放", min = 0, max = 114514 },
    function(v) settings.scale = v model.keepSetScale(v / 100) model.setWindowSize() settings:save() end,
    function() return settings.scale end)

-- 加载音频
audio.volume(settings.volume)
audio.single = true
local idle_audios_eve = (function()
    local vs = {}
    local lastPlaying = nil

    for i, v in ipairs(def.idle) do vs[i] = audio.register(v) vs[i]:loop(false) end

    return function()
        if state ~= "idle" then return end
        if lastPlaying ~= nil and lastPlaying:isplaying() then return end
        if math.random() * settings.idleAudioProb < window.frameTime() then
            lastPlaying = vs[math.random(#vs)]
            lastPlaying:play()
        end
    end
end)()
local interact_audios = (function()
    local vs = {}
    for i, v in ipairs(def.interact) do vs[i] = audio.register(v) vs[i]:loop(false) end
    return function() vs[math.random(#vs)]:play() end
end)()

ipc.addPanelItem(
    { type = "single", valueType = "number", prompt = "音量大小：", hint = "0 ~ 100", min = 0, max = 100 },
    function(v) settings.volume = v audio.volume(v) settings:save() end,
    function() return settings.volume end)
ipc.addPanelItem(
    { type = "single", valueType = "number", prompt = "随机语音安静值", hint = "默认为60（期望60秒播放一次）。如嫌闹请调大" },
    function(v) settings.idleAudioProb = v settings:save() end,
    function() return settings.idleAudioProb end)

-- 绑定事件
ev.on(window.draw, model.draw)
ev.on(window.after_draw, idle_audios_eve);
ev.on(window.after_draw, audio.update);

-- 处理idle
local special = false
local restoreY = function()
    if settings.drop then
        window.setPosition(window.windowPos().x, settings.ground - model.getRawPosition().y)
    end
end

enterStateThen["idle"] = function()
    if settings.idleMotion == 2 then model.loop("dance")
    elseif settings.idleMotion == 3 then
        model.loop("sit")
        if settings.drop then
            log(math.ceil(settings.ground - 0.9 * settings.scale))
            window.setPosition(window.windowPos().x, settings.ground - model.getRawPosition().y - 0.9 * settings.scale)
        end
    elseif settings.idleMotion == 4 then model.loop("sleep")
    else model.loop("stand2") end
end

ev.on(model.spine_complete, function()
    if state == "idle" then
        if not special and settings.idleMotion ~= 2 then
            if math.random() < 0.05 then
                special = true
                restoreY()
                model.loop("dance")
            end
        elseif math.random() < 0.1 then
            enterState("idle")
        end
    end
end)

ipc.addPanelItem(
    { type = "button", prompt = "切换尬舞、站、坐、躺", hint = "坐和躺请在下面设置一下地面坐标以免看着奇怪" },
    function()
        settings.idleMotion = (settings.idleMotion == 4 and 1 or settings.idleMotion + 1)
        settings:save()
        if state == "idle" then enterState("idle") end
    end,
    function() end);

-- 处理walk
(function()
    local walker = walkMan.createWithWindowDefault({
        checkCanStart = function() return settings.walk and state == "idle" end,
        model = model, startDistance = settings.startDistance, stopDistance = settings.stopDistance, walkSpeed = 80
    })
    ev.on(window.after_draw, walker.trigger) -- 走动

    ev.on(walker.walking, function() enterState("walk") end)
    ev.on(walker.walked, function() enterState("idle") end)
    ev.on(walker.directionChanged, function() model.direction(walker.direction) end)

    enterStateThen["walk"] = function()
        restoreY()
        model.direction(walker.direction)
        model.loop("walk")
    end

    ipc.addPanelItem(
        { type = "bool", prompt = "跟随鼠标", hint = "与鼠标距离太远会接近" },
        function(v) settings.walk = v settings:save() end,
        function() return settings.walk end)
    ipc.addPanelItem(
        { type = "single", valueType = "number", prompt = "最远距离：", hint = "水平超过这个距离，桌宠就会走向鼠标，若不想频繁跟随就调大一些" },
        function(v) settings.startDistance = v walker.startDistance = v settings:save() end,
        function() return settings.startDistance end)
    ipc.addPanelItem(
        { type = "single", valueType = "number", prompt = "停止距离：", hint = "水平小于这个距离，桌宠就会停止走动，调大一点可以避免走得太近" },
        function(v) settings.stopDistance = v walker.stopDistance = v settings:save() end,
        function() return settings.stopDistance end)
end)();

local dragger = nil;

-- 处理drag
(function()
    local updating = false
    dragger = dragmove.createWithWindowDefault {
        checkCanStart = function() return state == "idle" or state == "drop" end,
        key = window.mouseButton.left,
        model = model
    }

    ev.on(window.after_draw, dragger.trigger) -- 拖拽响应
    ev.on(dragger.dragging, function() enterState("drag") end)
    enterStateThen["drag"] = function() model.loop("tuozhuai2") end

    if settings.ground == nil then
        settings.ground = win32.getGround()
        settings:save()
    end
    dragger.ground = settings.ground
    enterStateThen["drop"] = function() model.loop("yun") end
    ev.on(dragger.dragged, function()
        dragger.drop = settings.drop and not updating
        enterState((settings.drop and not updating) and "drop" or "idle")
    end)
    ev.on(dragger.dropped, function() enterState("idle") end)

    ipc.addPanelItem(
        { type = "bool", prompt = "拖动后落地", hint = "地面默认是任务栏" },
        function(v) settings.drop = v settings:save() end,
        function() return settings.drop end)

    local updateGroundPanelItem = { type = "button", prompt = "点击开始设定地面位置", hint = "如果想改变落地的位置，请按此按钮并根据之后提示操作" }
    ipc.addPanelItem(
        updateGroundPanelItem,
        function()
            if updating then
                updating = false
                settings.ground = math.floor(window.windowPos().y + model.getRawPosition().y)
                dragger.ground = settings.ground
                settings:save()
                updateGroundPanelItem.prompt = "点击开始设定地面位置"
                updateGroundPanelItem.hint = "如果想改变落地的位置，请按此按钮并根据之后提示操作"
            else
                updating = true
                updateGroundPanelItem.prompt = "点击结束设定地面位置"
                updateGroundPanelItem.hint = "将小人拖到你觉得合适的地面位置，然后点击结束即可"
            end
        end,
        function() end)

    if settings.drop then
        window.setPosition(window.windowPos().x, settings.ground - model.getRawPosition().y)
    end
end)();

-- 处理互动
(function()
    enterStateThen["interact"] = function () restoreY() model.once("touch") interact_audios() end
    if dragger then ev.on(dragger.clicked, function () enterState("interact") end) end -- fuck!
    ev.on(model.spine_complete, function() if state == "interact" then enterState("idle") end end)
end)();

ipc.addPanelItem(
        { type = "button", prompt = "重置小人坐标", hint = "如屏幕里面找不到小人，请最小化所有窗口然后点击此按钮" },
        function()
            window.setPosition(0, 0)
            settings:save()
            enterState("idle")
        end,
        function() end)

-- 启动语音
if settings.launchAudio then
    local au = audio.register(def.launch[math.random(#def.launch)])
    au:loop(false)
    au:play()
end
ipc.addPanelItem(
    { type = "bool", prompt = "启动时播放问候语音", hint = "默认关闭，以防社死" },
    function(v) settings.launchAudio = v settings:save() end,
    function() return settings.launchAudio end)

-- ipc
if #arg > 1 then
    local rxIpcInst = nil
    local txIpcInst = nil
    -- open ipc
    rxIpcInst = ipc.lib.hiMQ_openIPC(arg[1])
    txIpcInst = ipc.lib.hiMQ_openIPC(arg[2])

    ev.on(window.after_draw, function() ipc.read(rxIpcInst, txIpcInst) end)
    ipc.sendPanelStructure(txIpcInst)
end

enterState("idle")
window.run()
