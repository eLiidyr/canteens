_addon.name     = 'Canteens'
_addon.author   = 'Elidyr'
_addon.version  = '1.07142019'
_addon.command  = 'cant'

require('chat')
require('logger')
require('pack')

packets = require('packets')

fetching  = false
injecting = false
poked     = ""

get_canteen = packets.new('outgoing', 0x05B, {
    ['Target']            = 17970040,
    ['Option Index']      = 3,
    ['Target Index']      = 888,
    ['Automated Message'] = false,
    ['Zone']              = 291,
    ['Menu ID']           = 31,
})

windower.register_event('addon command', function(...)

    local args = T{...}
    local cmd = args[1]

    if cmd == 'help' or cmd == 'h' then
        windower.add_to_chat(10, "//canteens [r][rl][reload] to reload addon.")
        windower.add_to_chat(10, "//canteens [get] to purchase a mysical canteen.")

    elseif cmd == 'get' then
        local goblin = windower.ffxi.get_mob_by_id(17970040)

        if goblin then
            poke(goblin)
        end

    elseif cmd == 'reload' or cmd == 'r' or cmd == 'rl' then
        windower.send_command('lua reload canteens')

    end

end)

windower.register_event('incoming chunk',function(id,data,modified,injected,blocked)

    if id == 0x034 and poked == "Incantrix" then
        fetching = true

        local goblin = windower.ffxi.get_mob_by_id(17970040)

        if goblin and math.sqrt(goblin.distance) < 6 then
            injecting = true
            packets.inject(get_canteen)

        end
        return true

    end


end)

windower.register_event('outgoing chunk',function(id,data,modified,injected,blocked)

    if id == 0x05B and poked == "Incantrix" and fetching and injecting then
        poked     = ""
        fetching  = false
        injecting = false

    end

end)

function poke(npc)

    if npc then

        local poke = packets.new('outgoing', 0x1a, {
            ['Target'] = npc.id,
            ['Target Index'] = npc.index,
        })

        packets.inject(poke)
        poked = npc.name

    end

end
