
// L4-Notify
window.addEventListener('message', function(event) {
    const item = event.data;
    if (item.type) {
        showNotification(
            item.type, 
            item.message, 
            item.length, 
            item.playSound, 
            item.position,
            item.iconAnimation
        );
    }
});

function playNotificationSound() {
    const sound = document.getElementById('notifySound');
    sound.volume = 0.5;
    sound.currentTime = 0; 
    sound.play().catch(function(error) {
        console.log("Sound konnte nicht abgespielt werden:", error);
    });
}

let notificationGroups = {};
let notificationHeight = 0;

function showNotification(type, message, duration, playSound = true, position = 'top-left', iconAnimation = true) {
    const notifications = document.getElementById('notifications');
    notifications.className = `position-${position}`;

    const notifyKey = `${type}-${message}`;
    const notification = document.createElement('div');
    
    let slideInAnimation, slideOutAnimation;
    
    if (position.includes('right')) {
        slideInAnimation = 'slideInRight';
        slideOutAnimation = 'slideOutRight';
    } else if (position.includes('left')) {
        slideInAnimation = 'slideInLeft';
        slideOutAnimation = 'slideOutLeft';
    } else if (position.includes('bottom')) {
        slideInAnimation = 'slideInBottom';
        slideOutAnimation = 'slideOutBottom';
    } else {
        slideInAnimation = 'slideInTop';
        slideOutAnimation = 'slideOutTop';
    }

    notification.className = `notification ${type}`;
    notification.style.animation = `${slideInAnimation} 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards`;

    const icons = {
        success: 'fas fa-check',
        error: 'fas fa-exclamation',
        warning: 'fas fa-triangle-exclamation', 
        info: 'fas fa-info',
        neutral: 'fas fa-bell'
    };
    
    const titles = {
        success: 'Success',
        error: 'Error',
        warning: 'Warning',
        info: 'Information',
        neutral: 'Notification',
        undefined: 'Notification'
    };

    const iconClass = type === 'warning' ? 'warning-icon' : 'circle-icon';

    notification.innerHTML = `
        <i class="${icons[type]} ${iconClass}"></i>
        <div class="notification-content-wrapper">
            <div class="notification-header">
                <span class="notification-title">${titles[type]}</span>
            </div>
            <div class="notification-content">${message}</div>
        </div>
    `;
if (iconAnimation) {
    notification.querySelector('i').style.animation = 'iconPulse 2s ease-in-out infinite';
} else {
    notification.querySelector('i').style.animation = 'none';
}
    
    notifications.insertBefore(notification, notifications.firstChild);
    const height = notification.offsetHeight + 10;
    
    Array.from(notifications.children)
        .slice(1)
        .forEach((notif, index) => {
            notif.style.transform = `translateY(${(index + 1) * height}px)`;
        });

    if (playSound) {
        playNotificationSound();
    }

    if (type === 'error') {
        Object.keys(notificationGroups).forEach(key => {
            if (notificationGroups[key].timer) {
                clearTimeout(notificationGroups[key].timer);
            }
            notificationGroups[key].element.remove();
            delete notificationGroups[key];
        });
    }

    const timer = setTimeout(() => {
        notification.style.animation = `${slideOutAnimation} 0.5s forwards`;
        
        setTimeout(() => {
            const index = Array.from(notifications.children).indexOf(notification);
            notification.remove();
            delete notificationGroups[notifyKey];
            
            Array.from(notifications.children)
                .slice(index)
                .forEach((notif, i) => {
                    notif.style.transform = `translateY(${(i + index) * height}px)`;
                });
        }, 500);
    }, duration - 500);

    notificationGroups[notifyKey] = {
        element: notification,
        timer: timer
    };
}

function playNotificationSound() {
    const sound = document.getElementById('notifySound');
    sound.volume = 0.5;
    sound.currentTime = 0;
    sound.play().catch(function(error) {
        console.log("Sound konnte nicht abgespielt werden:", error);
    });
}