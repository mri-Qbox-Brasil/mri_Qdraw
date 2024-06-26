local Table = {}
local MASTER = {}
local M_INT = 0
---------------------------------------------------
---[SETUP]
---------------------------------------------------
Citizen.CreateThread(function()
    Table = load()
    if Table ~= nil then 
        for i, v in pairs(Table) do
            M_INT = M_INT + 1
            MASTER[M_INT] = {}
            MASTER[M_INT] = Table[i]
            ---[FIXING VECTORS BECOUSE JSON BREAKS IT]
            MASTER[M_INT].tl = vector3(MASTER[M_INT].tl.x,MASTER[M_INT].tl.y,MASTER[M_INT].tl.z)
            MASTER[M_INT].tr = vector3(MASTER[M_INT].tr.x,MASTER[M_INT].tr.y,MASTER[M_INT].tr.z)
            MASTER[M_INT].bl = vector3(MASTER[M_INT].bl.x,MASTER[M_INT].bl.y,MASTER[M_INT].bl.z)
            MASTER[M_INT].br = vector3(MASTER[M_INT].br.x,MASTER[M_INT].br.y,MASTER[M_INT].br.z)
            MASTER[M_INT].pos = vector3(MASTER[M_INT].pos.x,MASTER[M_INT].pos.y,MASTER[M_INT].pos.z)

        end
    else
        save()
    end
end)
---------------------------------------------------
---[PLAYER]
---------------------------------------------------
RegisterNetEvent('mri_Qdraw:GetData')
AddEventHandler('mri_Qdraw:GetData', function()
    local player = source
    local staff = false
    while MASTER == nil do 
        Citizen.Wait(1000)
    end
    staff = perms(player)
    TriggerClientEvent('mri_Qdraw:Initialize',player,MASTER,staff)
end)

RegisterNetEvent('mri_Qdraw:UpdateImage')
AddEventHandler('mri_Qdraw:UpdateImage', function(texname,url)
    local player = source
    if perms(player) then
        for i, v in pairs(MASTER) do
            if texname == v.texname then
                MASTER[i].url = url
                UpdateImage(i)
            end
        end
    end
end)

RegisterNetEvent('mri_Qdraw:Remove')
AddEventHandler('mri_Qdraw:Remove', function(texname)
    local player = source
    if perms(player) then
        for i, v in pairs(MASTER) do
            if texname == v.texname then
                Remove(i)
            end
        end
    end
end)

RegisterNetEvent('mri_Qdraw:regnew')
AddEventHandler('mri_Qdraw:regnew', function(data)
    local player = source
    if perms(player) then
        M_INT = M_INT + 1
        MASTER[M_INT] = data
        update(M_INT)
    end
end)

RegisterCommand("draw_dev", function(source, args, rawCommand)
    if args[1] ~= nil then
        local send = false
        local tmp = args[1]
        if tmp == "on" then 
            send = true
        else
            send = false
        end
        player = source
        if perms(player) and send ~= nil then 
            TriggerClientEvent('mri_Qdraw:DevMode',-1,send)
        end
    end
end, false)
---------------------------------------------------
---[FUNCTIONS]
---------------------------------------------------
function update(id)
    TriggerClientEvent('mri_Qdraw:NewInit',-1,MASTER[id])
    save()
end

function UpdateImage(id)
    TriggerClientEvent('mri_Qdraw:UpdateImage',-1,MASTER[id].texname,MASTER[id].url)
    save()
end

function Remove(id)
    TriggerClientEvent('mri_Qdraw:Remove',-1,MASTER[id].texname)
    MASTER[id] = nil
    save()
end
---------------------------------------------------
---[UTILS]
---------------------------------------------------

function playerloaded(id)
    DoesEntityExist(GetPlayerPed(id))
end

function load()
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./data.json")
    return (json.decode(loadFile))
end

function save()
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(MASTER), -1)
end

---------------------------------------------------
---[PERMS]
---------------------------------------------------

function perms(player)
    return true
end