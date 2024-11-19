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
