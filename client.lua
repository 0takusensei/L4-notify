local sound = false

RegisterNetEvent('l4-notify:show')
AddEventHandler('l4-notify:show', function(data)
    SendNUIMessage({
        type = data.type or 'neutral', 
        message = data.message,
        length = data.length or 5000,
        playSound = data.playSound,
        position = data.position,
        iconAnimation = data.iconAnimation
    })
end)

exports('Show', function(data)
    data.position = data.position or 'top-left'
    data.playSound = (data.playSound == nil) and true or data.playSound
    data.iconAnimation = (data.iconAnimation == nil) and true or data.iconAnimation 

    SendNUIMessage({
        type = data.type or 'notification',
        message = data.message,
        length = data.length or 5000,
        playSound = data.playSound,
        position = data.position,
        iconAnimation = data.iconAnimation
    })
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/notify', 'Show a notification', {
        { name = "type", help = "success/error/warning/info/neutral"},
        { name = "message", help = "The message to display" },
        { name = "position", help = "top/bottom/top-left/top-right/bottom-left/bottom-right/middle-left/middle-right" },
        { name = "sound", help = "true/false" },
        { name = "iconAnimation", help = "true/false" }
    })
end)

RegisterCommand('notify', function(source, args)
    local types = {
        ['error'] = true,
        ['success'] = true,
        ['warning'] = true,
        ['info'] = true,
        ['neutral'] = true 
    }

    local positions = {
        ['top'] = true,
        ['bottom'] = true,
        ['top-left'] = true,
        ['top-right'] = true,
        ['bottom-left'] = true,
        ['bottom-right'] = true,
        ['middle-left'] = true,
        ['middle-right'] = true
    }
    
    if #args < 1 then
        TriggerEvent('l4-notify:show', {
            type = 'error',
            message = 'Usage: /notify [type] [message] [position] [sound]',
            length = 5000
        })
        return
    end
    
    local type = args[1]
    if not types[type] then
        TriggerEvent('l4-notify:show', {
            type = 'error',
            message = 'Invalid type! Available types: success, error, warning, info, notification',
            length = 5000
        })
        return
    end
    
    table.remove(args, 1)
    
    local position = "top-left"
    local sound = true
    local iconAnimation = true
    
    if #args >= 3 then
        if positions[args[#args-2]] then
            position = args[#args-2]
            sound = args[#args-1] == "true"
            iconAnimation = args[#args] == "true"
            table.remove(args, #args)
            table.remove(args, #args)
            table.remove(args, #args)
        end
    end
    
    local message = table.concat(args, " ")
    if message == "" then
        message = "Test Message"
    end
    
    TriggerEvent('l4-notify:show', {
        type = type,
        message = message,
        length = 5000,
        position = position,
        playSound = sound,
        iconAnimation = iconAnimation
    })
end)

RegisterNetEvent('l4-notify:versionCheck')
AddEventHandler('l4-notify:versionCheck', function(outdated, newVersion, currentVersion)
    if outdated then
        exports['l4-notify']:Show({
            type = 'warning',
            message = string.format('Update available!\nCurrent: %s\nNew: %s', currentVersion, newVersion),
            length = 15000,
            position = 'top-left',
            playSound = true,
            iconAnimation = true
        })
    end
end)