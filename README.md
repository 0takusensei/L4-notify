# L4-Notify System

### Description
A modern FiveM notification system with different types, animations and sound effects.

### Features
- 5 different notification types (success, error, warning, info, neutral)
- Modern animations
- Sound effect
- Customizable duration
- Easy integration

### Installation
1. Copy the `l4-notify` folder to your `resources` folder
2. Configure your framework in `server.lua` line 1-9:
   - For QBCore: Uncomment the QBCore export line
   - For ESX: Uncomment the ESX export line
   - For Standalone: Uncomment the admins list
3. Add `ensure l4-notify` to your `server.cfg`

#### In-Game test Command

/notify [type] [message]

## Success Notification ##

exports['l4-notify']:Show({
    type = 'success',
    message = 'Action completed successfully!',
    length = 5000 -- Optional (default: 5000ms)
})

## Error Notification ##

exports['l4-notify']:Show({
    type = 'error',
    message = 'An error has occurred!',
    length = 5000
})

## Warning Notification ##

exports['l4-notify']:Show({
    type = 'warning',
    message = 'Warning! Low health!',
    length = 5000
})

## Info Notification ##

exports['l4-notify']:Show({
    type = 'info',
    message = 'New mission available!',
    length = 5000
})

## Neutral Notification

exports['l4-notify']:Show({
    type = 'neutral',
    message = 'Server restart in 5 minutes',
    length = 5000
})

## ESX Example ##
