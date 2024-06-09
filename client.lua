---------------------------------------------------
---[SETTINGS]
---------------------------------------------------
local debug = false ---[PRINTS]
local RENDER = 500 ---[RENDER DISTANCE]
local EDIT = 4 ---[EDIT DISTANCE]
---------------------------------------------------
---[LOCALS NEED IT FOR THE mri_Qdraw]
---------------------------------------------------
local REGISTRY = {}
local R_INT = 0
local tpm1 = {}
local tpm2 = {}
local draw = false
local cache = {}
local cache_int = 0
local devmode = false
local poster = false
local staff = true
---------------------------------------------------
---[SETUP]
---------------------------------------------------
Citizen.CreateThread(function()
   TriggerServerEvent('mri_Qdraw:GetData')
end)
---------------------------------------------------
---[CREATE A NEW CANVAS]
---------------------------------------------------
RegisterCommand("poster", function(source, args, rawCommand)
    if not staff then clmsg("INSUFFICIENT PERMISSIONS") return end
    if poster then clmsg("ACTION CANCELLED") return end

    poster = true 
    tpm1 = getray("[1] CANTO SUPERIOR-ESQUERDA")
    if tpm1 == nil then clmsg("ACTION CANCELLED") poster = false return end
    Citizen.Wait(1000)
    draw = true
    tpm2 = getray("[2] CANTO INFERIOR-DIREITA")
    draw = false
    if tpm2 == nil then clmsg("ACTION CANCELLED") poster = false return end

    local key = randomString(4)
    ---[STAFF INPUT]
    local data = lib.inputDialog("Criar poster in-game - mri_Qdraw", {
        {
            type = "input",
            label = "URL",
            required = true,
            description = "Digite a URL da imagem"
        },
        {
            type = "input",
            label = "Identificação",
            required = true,
            description = "Digite o nome do poster"
        },
        {
            type = "number",
            label = "Largura da Imagem",
            required = true,
            description = "Digite a largura da imagem (em px)"
        },
        {
            type = "number",
            label = "Altura da Imagem",
            required = true,
            description = "Digite a altura da imagem (em px)"
        }
    })
    local url = data[1]
    if url == nil then clmsg("ACTION CANCELLED") poster = false return end
    local name = data[2]
    if name == nil then clmsg("ACTION CANCELLED")  poster = false return end
    local width = tonumber(data[3])
    if width == nil then clmsg("ACTION CANCELLED") poster = false return end
    local height = tonumber(data[4])
    if height == nil then clmsg("ACTION CANCELLED") poster = false return end
    ---------------------------------------------------
    name = key.."_"..name
    cache_int = R_INT + 1
    cache[cache_int] = {}
    cache[cache_int].url = url
    cache[cache_int].width = width
    cache[cache_int].height = height
    cache[cache_int].dtexname = name.."_d"
    cache[cache_int].texname = name

    local topLeft = tpm1
    local bottomRight = tpm2
    local bottomLeft = vector3(topLeft.x,topLeft.y,bottomRight.z)
    local topright = vector3(bottomRight.x,bottomRight.y,topLeft.z)
    cache[cache_int].pos = topLeft
    cache[cache_int].tl = topLeft
    cache[cache_int].tr = topright
    cache[cache_int].bl = bottomLeft
    cache[cache_int].br = bottomRight
    TriggerServerEvent("mri_Qdraw:regnew",cache[cache_int])
    clmsg("NEW POSTER CREATED")
    poster = false 
    -- NewInit(cache[cache_int])
    -- DevUi()
end, false)
---------------------------------------------------
---[FILL REGISTRY]
---------------------------------------------------
function Initialize(data,role)
    staff = role
    local data = data
    for i, v in pairs(data) do
        R_INT = R_INT + 1
        REGISTRY[R_INT] = {}
        REGISTRY[R_INT] = data[i]
        REG_CANVAS(R_INT)
    end
end

function NewInit(data)
    local data = data
    R_INT = R_INT + 1
    REGISTRY[R_INT] = {}
    REGISTRY[R_INT] = data
    REG_CANVAS(R_INT)
end
---------------------------------------------------
---[REGISTER NEW CANVAS]
---------------------------------------------------
function REG_CANVAS(key)
    local url = REGISTRY[key].url
    local width = REGISTRY[key].width
    local height = REGISTRY[key].height
    local texuredicname = REGISTRY[key].dtexname
    local textureName = REGISTRY[key].texname
    ---[LOCALS]
    local textureDict = CreateRuntimeTxd(texuredicname) 
    local duiObj = CreateDui(url, width, height)
    REGISTRY[key].duiObj = duiObj
    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(textureDict, textureName, dui)

    ---[INITIALIZE]
    InitializePoster(key)
end

function InitializePoster(key)
    Citizen.CreateThread(function()
        clmsg("[POSTER]:"..key..":INITIATED")
        local topLeft = REGISTRY[key].tl
        local topright = REGISTRY[key].tr
        local bottomLeft = REGISTRY[key].bl
        local bottomRight = REGISTRY[key].br
        local texuredicname = REGISTRY[key].dtexname
        local textureName = REGISTRY[key].texname
        -----
        local time = 0
        while REGISTRY[key] ~= nil do
            local ped = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(ped)
            if IsPlayerNear(playerCoords,REGISTRY[key].pos,RENDER) then 
                time = 0
                DrawSpritePoly(bottomRight.x, bottomRight.y, bottomRight.z, topright.x, topright.y, topright.z, topLeft.x, topLeft.y, topLeft.z, 255, 255, 255, 255, texuredicname, textureName,
                1.0, 1.0, 1.0,
                1.0, 0.0, 1.0,
                0.0, 0.0, 1.0)
               DrawSpritePoly(topLeft.x, topLeft.y, topLeft.z, bottomLeft.x, bottomLeft.y, bottomLeft.z, bottomRight.x, bottomRight.y, bottomRight.z, 255, 255, 255, 255, texuredicname, textureName,
                0.0, 0.0, 1.0,
                0.0, 1.0, 1.0,
                1.0, 1.0)  
            else 
                time = 1000
            end
            Citizen.Wait(time)
        end
    end)
end
---------------------------------------------------
---[RESET-REMOVE-UPDATE]
---------------------------------------------------

function UpdateImage(texname,url)
    for i, v in pairs(REGISTRY) do
        local name = texname
        if v.texname == name then 
            local duiobj = v.duiObj
            REGISTRY[i].url = url
            SetDuiUrl(duiobj,url)
            clmsg("POSTER UPDATE ID:"..name)
        end
    end
end

function Remove(texname)
    for i, v in pairs(REGISTRY) do
        local name = texname
        if v.texname == name then 
            local duiobj = v.duiObj
            DestroyDui(duiobj)
            REGISTRY[i] = nil
            clmsg("POSTER DELETED ID:"..name)
        end
    end
end

function RESET()
    for i, v in pairs(REGISTRY) do
        local duiobj = v.duiObj
        DestroyDui(duiobj)
    end
end

function DevMode(state)
    devmode = state
    if devmode then 
        DevUi()
    end
end
---------------------------------------------------
---[UTILS]
---------------------------------------------------
function clmsg(data) 
    if debug then 
        print(data)
    end
    lib.notify({title = data, position = 'center-left'})

end

function IsPlayerNear(playerCoords, vector, distance)
    -- print(json.encode( playerCoords))
    -- print(json.encode( vector))

    local playerDistance = GetDistanceBetweenCoords(playerCoords,vector,true)
    return playerDistance <= distance 
end

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

function getray(id)
    local run = true
    while run do
            local Wait = 5
            local color = {r = 0, g = 255, b = 0, a = 255}
            local position = GetEntityCoords(PlayerPedId())
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            Draw2DText('Raycast Coords: ' .. coords.x .. ' ' ..  coords.y .. ' ' .. coords.z, 4, {255, 255, 255}, 0.4, 0.55, 0.650)
            Draw2DText('Pressione   ~g~[   E   ]~w~   para POSICIONAR: ~b~'..id, 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.025)
            Draw2DText('Pressione   ~r~[ DEL ]~w~   para CANCELAR', 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.050)
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            if draw then 
                local topLeft = tpm1
                local bottomRight = coords
                local bottomLeft = vector3(topLeft.x,topLeft.y,bottomRight.z)
                local topright = vector3(bottomRight.x,bottomRight.y,topLeft.z)

                DrawMarker(28, topLeft.x, topLeft.y, topLeft.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)

                DrawPoly(bottomRight,topright,topLeft,0,0,255,200)
                DrawPoly(topLeft,bottomLeft,bottomRight,0,0,255,200)
            end
            if IsControlJustReleased(0, 38) then
                run = false
                return(coords)
            end
            if IsControlJustReleased(0, 178) then ---[DEL CANCEL]
                run = false
                return(nil)
            end
        Citizen.Wait(Wait)
	end
end

function DevUi()
    Citizen.CreateThread(function()
        clmsg("DEVELOPMENT MODE: ENABLED")
        local time = 0
        local found = false
        while devmode do 
            local ped = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(ped)
    
            for i, v in pairs(REGISTRY) do
               
                if IsPlayerNear(playerCoords,v.pos,EDIT) then 
                    DrawMarker(28, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.3, 0.3, 0.3, 255, 0, 0, 255, false, true, 2, nil, nil, false)
                    Draw2DText('Pressione   ~g~[   E   ]~w~   para ALTERAR', 4, {255, 255, 255}, 0.4, 0.55, 0.600)
                    Draw2DText('Pressione   ~r~[ DEL ]~w~   para EXCLUIR', 4, {255, 255, 255}, 0.4, 0.55, 0.622)
                    Draw2DText('Pressione   ~y~[ BACKSPACE ]~w~   para FECHAR', 4, {255, 255, 255}, 0.4, 0.55, 0.644)

                    if IsControlJustReleased(0, 51) then ---[E EDIT]
                        local data = lib.inputDialog("Alterar poster in-game", {
                            {
                                type = "input",
                                label = "URL",
                                required = true,
                                description = "Digite a URL da imagem"
                            }
                        })
                        if data ~= nil then
                            local amount = data[1]
                            if amount then
                                TriggerServerEvent("mri_Qdraw:UpdateImage",v.texname,amount)
                                time = 1000
                            end
                        end
                    end
                    if IsControlJustReleased(0, 178) then ---[DEL DELETE]
                        local alert = lib.alertDialog({
                            header = 'Confirmar exclusão',
                            content = 'Você tem certeza que deseja excluir esse poster? ',
                            centered = true,
                            cancel = true
                        })
                    
                        if alert == "confirm" then
                            TriggerServerEvent("mri_Qdraw:Remove",v.texname)
                            time = 1000
                        else
                            clmsg('[ACTION CANCELLATION NOTICE]')
                        end
                    end

                    if IsControlJustReleased(0, 194) then return end ---[BACKSPACE CLOSE]
               
                end
            end
            Citizen.Wait(time)
            if time ~= 0 then
                time = 0
            end
        end
        clmsg("DEVELOPMENT MODE: DISABLED")
    end)
end

function randomString(length)
    local chars = {}
    for i = 1, length do
      chars[i] = string.char(math.random(65, 90))
    end
    return table.concat(chars)
end
---------------------------------------------------
---[EVENTS]
---------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    RESET()
end)
RegisterNetEvent('mri_Qdraw:Initialize', Initialize) ---[data]
RegisterNetEvent('mri_Qdraw:NewInit', NewInit) ---[data]
RegisterNetEvent('mri_Qdraw:Remove', Remove)  ---[texname]
RegisterNetEvent('mri_Qdraw:UpdateImage', UpdateImage) ---[texname,url]
RegisterNetEvent('mri_Qdraw:DevMode', DevMode) ---[state]