-- Choose your framework (Remove -- before the framework you want to use)
-- QBCore = exports['qb-core']:GetCoreObject()
ESX = exports['es_extended']:getSharedObject()

-- Standalone (No frameworks)
-- local admins = {
--     'steam:110000112345678', -- Example Steam Hex
--     'steam:110000187654321'  -- Add more admin IDs here
-- }

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version') or '1.0.0'
local repositoryOwner = "Linux5real"
local repositoryName = "L4-notify"
local checkTimeout = 10000

local function debugPrint(message, type)
    local prefix = '^3[L4-Notify]^7 '
    if type == 'error' then prefix = '^1[L4-Notify]^7 ' 
    elseif type == 'success' then prefix = '^2[L4-Notify]^7 ' end
    print(prefix .. message)
end

local function compareVersions(latest, current)
    local function parseVersion(str)
        local major, minor, patch = str:match("(%d+)%.(%d+)%.(%d+)")
        return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
    end
    
    local l1, l2, l3 = parseVersion(latest)
    local c1, c2, c3 = parseVersion(current)
    
    if l1 > c1 then return true end
    if l1 < c1 then return false end
    if l2 > c2 then return true end
    if l2 < c2 then return false end
    return l3 > c3
end

function checkVersion()
    debugPrint('Checking version...', 'info')
    
    local hasResponded = false
    local timeoutTimer = nil
    
    timeoutTimer = SetTimeout(checkTimeout, function()
        if not hasResponded then
            debugPrint('Version check timed out!', 'error')
            hasResponded = true
        end
    end)

    PerformHttpRequest(
        ('https://api.github.com/repos/%s/%s/releases/latest'):format(repositoryOwner, repositoryName),
        function(statusCode, responseText, headers)
            if hasResponded then return end
            hasResponded = true
            
            if timeoutTimer then
                clearTimeout(timeoutTimer)
            end

            if statusCode ~= 200 then
                return debugPrint('Failed to check version: HTTP ' .. tostring(statusCode), 'error')
            end

            local success, data = pcall(json.decode, responseText)
            if not success or not data then
                return debugPrint('Failed to parse version data', 'error')
            end

            local latestVersion = data.tag_name and data.tag_name:gsub("^v", "") or nil
            if not latestVersion then
                return debugPrint('Invalid version format received', 'error')
            end

            if compareVersions(latestVersion, currentVersion) then
                debugPrint('Update available!', 'info')
                debugPrint('Current version: ' .. currentVersion, 'error')
                debugPrint('New version: ' .. latestVersion, 'success')
                debugPrint('Download: ' .. data.html_url, 'info')
                
                TriggerClientEvent('l4-notify:versionCheck', -1, true, latestVersion, currentVersion)
            else
                debugPrint('Version ' .. currentVersion .. ' - Up to date!', 'success')
            end
        end,
        'GET',
        '',
        {['User-Agent'] = 'L4-Notify/1.0.0'}
    )
end

CreateThread(function()
    Wait(5000) 
    pcall(function()
        checkVersion()
    end)
end)

exports('checkVersion', function()
    pcall(function()
        checkVersion()
    end)
end)

RegisterCommand('checknotifyversion', function(source, args)
    if source == 0 then
        pcall(function()
            checkVersion()
        end)
    end
end, true)

local function isAdmin(source)
    local group = nil

    if QBCore then
        group = QBCore.Functions.GetPermission(source)
    end

    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local group = xPlayer.getGroup()
            return group == 'admin' or group == 'superadmin'
        end
    end

    if not group then
        group = 'user'
    end
    return group == 'admin'
end

RegisterCommand('notify', function(source, args, rawCommand)
    local adminStatus = isAdmin(source)
    if not adminStatus then
        print("^1[ERROR]^7 Access denied for source: " .. tostring(source))
        TriggerClientEvent('l4-notify:show', source, {
            type = 'error',
            message = 'You must be an admin to use this command!',
            length = 5000
        })
        return
    end

    if #args < 2 then
        TriggerClientEvent('l4-notify:show', source, {
            type = 'error', 
            message = 'Usage: /notify [type] [message] [position] [sound] [iconAnimation]',
            length = 5000
        })
        return
    end

    local type = args[1]
    local validTypes = {error = true, success = true, warning = true, info = true, neutral = true}
    
    if not validTypes[type] then
        TriggerClientEvent('l4-notify:show', source, {
            type = 'error',
            message = 'Invalid type! Available types: success, error, warning, info, neutral',
            length = 5000
        })
        return
    end

    table.remove(args, 1)
    
    local position = "top-left"
    local sound = true
    local iconAnimation = true
    
    if #args >= 3 then
        local validPositions = {
            ['top'] = true, ['bottom'] = true, 
            ['top-left'] = true, ['top-right'] = true,
            ['bottom-left'] = true, ['bottom-right'] = true,
            ['middle-left'] = true, ['middle-right'] = true
        }
        
        if validPositions[args[#args-2]] then
            position = args[#args-2]
            sound = args[#args-1] == "true"
            iconAnimation = args[#args] == "true"
            table.remove(args, #args)
            table.remove(args, #args)
            table.remove(args, #args)
        end
    end
    
    local message = table.concat(args, " ")
    if message == "" then message = "Test Message" end

    TriggerClientEvent('l4-notify:show', -1, {
        type = type,
        message = message,
        length = 5000,
        position = position,
        playSound = sound,
        iconAnimation = iconAnimation
    })
end, false)
