# L4-Notify System

### Description
A modern FiveM notification system with different types, animations and sound effects.

### Features
- 5 different notification types (success, error, warning, info, neutral)
- 8 different positions
- Modern animations
- Sound effects (optional)
- Icon animations (optional)
- Customizable duration
- Works with ESX/QBCore/Standalone

### Installation ##
1. Copy the `l4-notify` folder to your `resources` folder
2. Add `ensure l4-notify` to your `server.cfg`

## Client Side Usage ## 

## Using Export

exports['l4-notify']:Show({
    type = 'success', -- success, error, warning, info, neutral
    message = 'Example Message',
    length = 5000, -- Duration in ms (optional, default: 5000)
    position = 'top-left', -- Position (optional, default: top-left)
    playSound = true, -- Play sound (optional, default: true)
    iconAnimation = true -- Animate icon (optional, default: true)
})

## Using Event

-- Basic Event Usage
TriggerEvent('l4-notify:show', {
    type = 'error',
    message = 'Error Message',
    length = 3000,
    position = 'top-right',
    playSound = true,
    iconAnimation = true
})

## Command Usage ##

/notify [type] [message] [position] [sound] [iconAnimation]

## Server Side Usage ## 

## Using Export

-- Send to specific player
exports['l4-notify']:ShowToPlayer(source, {
    type = 'success',
    message = 'Server Message',
    length = 5000,
    position = 'top-left',
    playSound = true,
    iconAnimation = true
})

-- Send to all players
exports['l4-notify']:ShowToAll({
    type = 'info',
    message = 'Broadcast Message'
})

## Integration Example ## 

-- ESX Example
ESX.ShowNotification = function(message, type)
    exports['l4-notify']:Show({
        type = type or 'neutral',
        message = message
    })
end

-- QBCore Example
QBCore.Functions.Notify = function(message, type)
    exports['l4-notify']:Show({
        type = type or 'neutral',
        message = message
    })
end

## Available Positions ##
top-left
top-right
bottom-left
bottom-right
top
bottom
middle-left
middle-right

## Notification Types ##
success (green)
error (red)
warning (yellow)
info (blue)
neutral (grey)
