/**
 * site.js
 * Global scripts:
 * - Session Inactivity Auto-Logout Monitor (2 minutes with 30s countdown warning)
 * - Session Keep-Alive extension
 */

let sessionIdleSeconds = 0;
let sessionWarningModal = null;
let sessionInterval = null;

function initSessionTimeoutMonitor(timeoutMinutes) {
    if (!timeoutMinutes || timeoutMinutes <= 0) return;

    const totalSeconds = timeoutMinutes * 60;
    const warningSeconds = 30; // Show warning modal 30s before logout
    sessionIdleSeconds = 0;

    // Reset idle timer on user activity
    const activityEvents = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart'];
    function resetActivity() {
        sessionIdleSeconds = 0;
    }

    activityEvents.forEach(function (evt) {
        window.addEventListener(evt, resetActivity, { passive: true });
    });

    if (sessionInterval) {
        clearInterval(sessionInterval);
    }

    sessionInterval = setInterval(function () {
        sessionIdleSeconds++;
        const remaining = totalSeconds - sessionIdleSeconds;

        // Show session warning modal when remaining seconds reach warning threshold
        if (remaining <= warningSeconds && remaining > 0) {
            const modalEl = document.getElementById('sessionTimeoutModal');
            const counterEl = document.getElementById('sessionSecondsRemaining');
            if (modalEl && counterEl) {
                counterEl.textContent = remaining;
                if (!sessionWarningModal) {
                    sessionWarningModal = new bootstrap.Modal(modalEl, { backdrop: 'static', keyboard: false });
                }
                if (!modalEl.classList.contains('show')) {
                    sessionWarningModal.show();
                }
            }
        }

        // Auto logout when timeout is reached
        if (sessionIdleSeconds >= totalSeconds) {
            clearInterval(sessionInterval);
            window.location.href = '/Account/Login?expired=true';
        }
    }, 1000);
}

function extendSession() {
    sessionIdleSeconds = 0;
    if (sessionWarningModal) {
        sessionWarningModal.hide();
    }
    // Ping server to keep ASP.NET Core session alive
    fetch('/Registration/CheckUsername?username=ping')
        .catch(function () {});
}

// Password show/hide toggle with dynamic icon swap
const eyeSvg = `<svg width="16" height="16" fill="currentColor" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>`;
const eyeSlashSvg = `<svg width="16" height="16" fill="currentColor" viewBox="0 0 24 24"><path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/></svg>`;

function togglePwd(inputId, btn) {
    const input = document.getElementById(inputId);
    if (!input) return;
    const isPwd = input.type === 'password';
    input.type = isPwd ? 'text' : 'password';
    if (btn) {
        btn.innerHTML = isPwd ? eyeSlashSvg : eyeSvg;
        btn.setAttribute('title', isPwd ? 'Hide password' : 'Show password');
    }
}
