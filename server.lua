-- server/version.lua
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version') or '1.0.0'
local repositoryOwner = "Linux5real"
local repositoryName = "L4-notify"
local checkTimeout = 10000 -- 10 seconds timeout

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

-- Verzögerter Start des Version-Checks
CreateThread(function()
    Wait(5000) -- Warte 5 Sekunden nach Serverstart
    pcall(function()
        checkVersion()
    end)
end)

-- Export für manuelle Prüfung
exports('checkVersion', function()
    pcall(function()
        checkVersion()
    end)
end)

-- Konsolen-Kommando
RegisterCommand('checknotifyversion', function(source, args)
    if source == 0 then -- Nur Konsole
        pcall(function()
            checkVersion()
        end)
    end
end, true)