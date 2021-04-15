QBCore = nil
PlayerJob = {}
isLoggedIn = false

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(200)
	end
end)

local isInMenu = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function DrawText3D(v, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(v, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 0)
    ClearDrawOrigin()
end

CreateThread(function()
    while true do
        Citizen.Wait(5)
        if PlayerJob.name ~= nil then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(QBCore.Shared.Jobs[PlayerJob.name]) do
                v = QBCore.Shared.Jobs[PlayerJob.name]["bossmenu"]
                if #(pos - v) < 2 then
                    if #(pos - v) < 1.0 then
                        DrawText3D(v, "~g~E~w~ - Boss Menu")
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent("qb-bossmenu:server:openMenu")
                        end
                    elseif #(pos - v) < 1.5 then
                        DrawText3D(v, "Boss Menu")
                    end
                else
                    Wait(100)
                end
            end
        else
            Wait(7500)
        end
    end
end)

RegisterNetEvent('qb-bossmenu:client:openMenu')
AddEventHandler('qb-bossmenu:client:openMenu', function(employees, jobdata)
    local employeesHTML, gradesHTML, recruitHTML = '', '', ''
    for _, player in pairs(employees) do
        if player.name then
            if player.grade ~= nil and player.grade.name then
                if player.isboss == true then
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow option-enabled' id="player-]] .. player.source  .. [["><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                else
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]] .. player.source  .. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                end
            end
        end
    end

    local max = 0
    for k, v in pairs(jobdata.grades) do
        if tonumber(k) then
            if tonumber(k) > max then
                max = tonumber(k)
            end
        end
    end

    for level = 0, max do
        local grade = jobdata.grades[tostring(level)]
        if grade.isboss then
            gradesHTML = gradesHTML .. [[<div class='grade-box box-shadow option-enabled' id="grade-]] .. tostring(level) .. [["><span id='option-text'>]] .. grade.name .. [[</span></div>]]
        else
            gradesHTML = gradesHTML .. [[<div class='grade-box box-shadow' id="grade-]] .. tostring(level) .. [["><span id='option-text'>]] .. grade.name .. [[</span></div>]]
        end
    end

    isInMenu = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        open = true,
        class = 'open',
        employees = employeesHTML,
        grades = gradesHTML,
    })
end)


function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end 
RegisterNetEvent('qb-bossmenu:client:refreshPage')
AddEventHandler('qb-bossmenu:client:refreshPage', function(data, list)
    if data == 'employee' then
        local employeesHTML = ''
        for _, player in pairs(list) do
            if player.name and player.grade ~= nil and player.grade.name then
                if player.isboss == true then
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow option-enabled' id="player-]] .. player.source  .. [["><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                else
                    employeesHTML = employeesHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-angle-double-up gradeschange"></i>  <i id="player-]] .. player.source  .. [[" class="fas fa-user-slash fireemployee"></i></span></span><span id='option-text'>]] .. player.name .. ' [' .. player.grade.name .. [[]</span></div>]]
                end
            end
        end
        
        isInMenu = true
        SendNUIMessage({
            open = true,
            class = 'refresh-players',
            employees = employeesHTML,
        })
    elseif data == 'recruits' then
        local recruitsHTML = ''

        if #list > 0 then
            for _, player in pairs(list) do
                recruitsHTML = recruitsHTML .. [[<div class='player-box box-shadow' id="player-]] .. player.source  .. [["><span class='hoster-options' id="playeroptions-]] .. player.source  .. [["><span style="position: relative; top: 15%; margin-left: 27%;"><i id="player-]] .. player.source  .. [[" class="fas fa-user-tag givejob"></i></span></span><span id='option-text'>]] .. player.name .. '</span></div>'
            end
        else
            recruitsHTML = [[<div class='player-box box-shadow option-enabled'><span class='hoster-options'"><span style="position: relative; top: 15%; margin-left: 27%;"></span></span><span id='option-text'>There is no players nearby.</span></div>]]
        end
        
        isInMenu = true
        SendNUIMessage({
            open = true,
            class = 'refresh-recruits',
            recruits = recruitsHTML,
        })
    end
end)

RegisterNetEvent('qb-bossmenu:client:refreshSociety')
AddEventHandler('qb-bossmenu:client:refreshSociety', function(job, data)
    if QBCore and QBCore.Functions.GetPlayerData().job.name == job then
        SendNUIMessage({
            open = true,
            class = 'refresh-society',
            amount = data,
         })
    end
end)

RegisterNUICallback('openStash', function(data)
    isInMenu = false
    SendNUIMessage({open = false})
    SetNuiFocus(false, false)
    
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. QBCore.Functions.GetPlayerData().job.name, {
        maxweight = 4000000,
        slots = 500,
    })

    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. QBCore.Functions.GetPlayerData().job.name)
end)

RegisterNUICallback('outfit', function(data)
    isInMenu = false
    SendNUIMessage({open = false})
    SetNuiFocus(false, false)
   
    TriggerEvent('qb-clothing:client:openOutfitMenu')
    
end)

RegisterNUICallback('giveJob', function(data)
    TriggerServerEvent('qb-bossmenu:server:giveJob', data)
end)

RegisterNUICallback('openRecruit', function(data)
    CreateThread(function()
        local playerPed = PlayerPedId()
        local players = { GetPlayerServerId(PlayerId()) }
        for k,v in pairs(QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(playerPed), 10.0)) do
            if v and v ~= PlayerId() then
                table.insert(players, GetPlayerServerId(v))
            end
        end

        TriggerServerEvent("qb-bossmenu:server:updateNearbys", players)
    end)
end)

RegisterNUICallback('changeGrade', function(data)
    TriggerServerEvent('qb-bossmenu:server:updateGrade', data)
end)

RegisterNUICallback('fireEmployee', function(data)
    TriggerServerEvent('qb-bossmenu:server:fireEmployee', data)
end)

RegisterNUICallback('closeNUI', function()
    isInMenu = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('withdraw', function(data)
    local amount = tonumber(data.amount)
    TriggerServerEvent("qb-bossmenu:server:withdrawMoney", amount)
end)

RegisterNUICallback('deposit', function(data)
    local amount = tonumber(data.amount)
    TriggerServerEvent("qb-bossmenu:server:depositMoney", amount)
end)

RegisterCommand('closeboss', function()
    isInMenu = false
    SendNUIMessage({
        open = false,
    })
    SetNuiFocus(false, false)
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end 

