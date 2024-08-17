lib.addCommand('rw_draw++/draw', {
    help = 'rw_draw++/draw',
    params = { },
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("rw_draw++:cl:action",source,"draw")
end)

lib.addCommand('rw_draw++/dev', {
    help = 'rw_draw++/dev',
    params = { },
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("rw_draw++:cl:action",source,"dev")
end)

lib.addCommand('rw_draw++/img', {
    help = 'rw_draw++/img',
    params = { },
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("rw_draw++:cl:action",source,"img")
end)

lib.addCommand('rw_draw++/rem', {
    help = 'rw_draw++/rem',
    params = { 
        {
            name = 'target',
            type = 'number',
            help = 'Target Draw',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local target = args.target
    if target then
        RemPoster(source, target)
    end
end)