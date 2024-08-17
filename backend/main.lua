local Map = {}
local Loaded = false

Citizen.CreateThread(function ()
    for k,v in pairs(Load()) do 
        v.Vertices = {
            [1] = vector3(v.Vertices[1].x,v.Vertices[1].y,v.Vertices[1].z),
            [2] = vector3(v.Vertices[2].x,v.Vertices[2].y,v.Vertices[2].z),
            [3] = vector3(v.Vertices[3].x,v.Vertices[3].y,v.Vertices[3].z),
            [4] = vector3(v.Vertices[4].x,v.Vertices[4].y,v.Vertices[4].z),
        }
        table.insert(Map,v)
    end
    Loaded = true
end)

function GetNewUid()
    local max = 0
    for k,v in pairs(Map) do
        if max < v.Uid then max = v.Uid end
    end
    return max + 1
end

RegisterNetEvent('rw_draw++:GetData')
AddEventHandler('rw_draw++:GetData', function()
    local src = source
    while not Loaded do
        Citizen.Wait(100)
    end
    TriggerClientEvent('rw_draw++:cl:init',src,Map)
end)

RegisterNetEvent('rw_draw++:new')
AddEventHandler('rw_draw++:new', function(data)
    NewPoster(source, data)
end)

NewPoster = function(pid, data)
    if pid == nil then return end
    ---<<<>>>
    while not Loaded do
        Citizen.Wait(100)
    end
    if not IsPlayerAceAllowed(pid,"command") then return end
    data.Uid = GetNewUid()
    table.insert(Map,data)
    ---<<<>>>
    TriggerClientEvent('rw_draw++:cl:add',pid,data)
    Save(Map)
end

RemPoster = function(pid, uid)
    if pid == nil then return end
    ---<<<>>>
    while not Loaded do
        Citizen.Wait(100)
    end
    for i,v in pairs(Map)do 
        if uid == v.Uid then 
            table.remove(Map,i)
        end
    end
    ---<<<>>>
    TriggerClientEvent('rw_draw++:cl:rem',pid,uid)
    Save(Map)
end

RegisterNetEvent('rw_draw++:img')
AddEventHandler('rw_draw++:img', function(uid, url)
    ImgPoster(source,uid,url)
end)
ImgPoster = function(pid, uid,url)
    if pid == nil then return end
    ---<<<>>>
    local src = source
    while not Loaded do
        Citizen.Wait(100)
    end
    if not IsPlayerAceAllowed(src,"command") then return end
    for k,v in pairs(Map)do 
        if uid == v.Uid then 
            v.Data.Url = url
        end
    end
    ---<<<>>>
    TriggerClientEvent('rw_draw++:cl:update',src,uid,url)
    Save(Map)
end

