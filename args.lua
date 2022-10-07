local start = 1
local ipc
local args = {}

if #arg > 1 and string.find(arg[1], '=') == nil and  string.find(arg[2], '=') == nil then
    ipc = { arg[1], arg[2] }
    start = 3
end

for i = start, #arg do
    local p, q = string.find(arg[i], '=')
    if p ~= nil then
        args[string.sub(arg[i], 1, p - 1)] = string.sub(arg[i], p + 1, #arg[i])
    end
end

args['model'] = args['model'] and args['model'] .. '/app/' or './'
args['audio'] = args['audio'] and args['audio'] .. '/app/' or './'
args['config'] = args['config'] or '.'

return {
    ipc = ipc,
    args = args
}
