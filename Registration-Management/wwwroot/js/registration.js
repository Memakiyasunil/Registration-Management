/**
 * registration.js
 * Handles: AJAX username check, cascading city dropdown,
 * password strength, DOB validation, file drag-drop preview.
 */

// -------------------------------------------------------
// Main init (called from view after DOM ready)
// -------------------------------------------------------
function initRegistrationForm() {
    initUsernameCheck();
    initCascadingCity();
    initPasswordStrength();
    initDobValidation();
    initFileDragDrop();
    initPincodeNumeric();
}

// -------------------------------------------------------
// 1. AJAX Username Availability Check
// -------------------------------------------------------
function initUsernameCheck() {
    const input = document.getElementById('Username');
    const status = document.getElementById('usernameStatus');
    if (!input || !status) return;

    let timer;
    input.addEventListener('input', function () {
        clearTimeout(timer);
        const val = input.value.trim();
        status.innerHTML = '';

        if (val.length < 4) return;

        timer = setTimeout(function () {
            status.innerHTML = '<span class="text-muted">Checking...</span>';
            $.getJSON(checkUsernameUrl, { username: val, excludeUserId: excludeUserId }, function (data) {
                if (data.available) {
                    status.innerHTML = '<span class="text-success">✓ ' + data.message + '</span>';
                } else {
                    status.innerHTML = '<span class="text-danger">✗ ' + data.message + '</span>';
                }
            }).fail(function () {
                status.innerHTML = '<span class="text-muted">Could not check username.</span>';
            });
        }, 500);
    });
}

// -------------------------------------------------------
// 2. Cascading State → City Dropdown
// -------------------------------------------------------
function initCascadingCity() {
    const stateSelect = document.getElementById('StateId');
    const citySelect = document.getElementById('CityId');
    if (!stateSelect || !citySelect) return;

    stateSelect.addEventListener('change', function () {
        const stateId = parseInt(stateSelect.value);
        citySelect.innerHTML = '<option value="0">Loading...</option>';
        citySelect.disabled = true;

        if (!stateId || stateId <= 0) {
            citySelect.innerHTML = '<option value="0">-- Select State First --</option>';
            return;
        }

        $.getJSON(getCitiesUrl, { stateId: stateId }, function (cities) {
            citySelect.innerHTML = '<option value="0">-- Select City --</option>';
            cities.forEach(function (c) {
                citySelect.innerHTML += '<option value="' + c.cityId + '">' + c.cityName + '</option>';
            });
            citySelect.disabled = false;
        }).fail(function () {
            citySelect.innerHTML = '<option value="0">Error loading cities</option>';
            citySelect.disabled = false;
        });
    });

    // Enable city if state already selected (edit mode)
    if (parseInt(stateSelect.value) > 0 && citySelect.options.length > 1) {
        citySelect.disabled = false;
    }
}

// -------------------------------------------------------
// 3. Password Strength Indicator
// -------------------------------------------------------
function initPasswordStrength() {
    const pwd = document.getElementById('Password');
    const bar = document.getElementById('pwdStrength');
    if (!pwd || !bar) return;

    pwd.addEventListener('input', function () {
        const val = pwd.value;
        const score = calcStrength(val);
        const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
        const colors = ['', '#ef4444', '#f59e0b', '#3b82f6', '#22c55e'];

        if (!val) { bar.innerHTML = ''; return; }

        bar.innerHTML = `
            <div class="d-flex align-items-center gap-2 mt-1">
                <div style="flex:1; height:4px; background:#e2e8f0; border-radius:9px; overflow:hidden;">
                    <div style="height:100%; width:${score * 25}%; background:${colors[score]}; transition:width .3s, background .3s; border-radius:9px;"></div>
                </div>
                <small style="color:${colors[score]}; width:50px;">${labels[score]}</small>
            </div>`;
    });
}

function calcStrength(p) {
    let s = 0;
    if (p.length >= 8) s++;
    if (/[A-Z]/.test(p)) s++;
    if (/[0-9]/.test(p)) s++;
    if (/[^A-Za-z0-9]/.test(p)) s++;
    return s;
}

// -------------------------------------------------------
// 4. DOB Validation (must be past date)
// -------------------------------------------------------
function initDobValidation() {
    const dob = document.getElementById('DateOfBirth');
    if (!dob) return;

    const today = new Date().toISOString().split('T')[0];
    dob.setAttribute('max', today);

    dob.addEventListener('change', function () {
        if (dob.value >= today) {
            dob.setCustomValidity('Date of Birth must be in the past.');
            dob.reportValidity();
        } else {
            dob.setCustomValidity('');
        }
    });
}

// -------------------------------------------------------
// 5. File Drag-Drop & Preview
// -------------------------------------------------------
function initFileDragDrop() {
    const zone = document.getElementById('fileDropZone');
    const input = document.getElementById('documentsInput');
    const listEl = document.getElementById('fileList');
    const errorEl = document.getElementById('fileError');
    if (!zone || !input) return;

    const allowed = ['.pdf', '.jpg', '.jpeg', '.png', '.doc', '.docx'];
    const maxSize = 5 * 1024 * 1024;
    const maxCount = 5;

    zone.addEventListener('dragover', function (e) {
        e.preventDefault();
        zone.classList.add('drag-over');
    });
    zone.addEventListener('dragleave', function () {
        zone.classList.remove('drag-over');
    });
    zone.addEventListener('drop', function (e) {
        e.preventDefault();
        zone.classList.remove('drag-over');
        setFiles(e.dataTransfer.files);
    });

    input.addEventListener('change', function () {
        setFiles(input.files);
    });

    function setFiles(files) {
        errorEl.innerHTML = '';
        listEl.innerHTML = '';

        if (files.length > maxCount) {
            errorEl.innerHTML = 'Maximum ' + maxCount + ' files allowed.';
            return;
        }

        let html = '';
        for (let i = 0; i < files.length; i++) {
            const f = files[i];
            const ext = '.' + f.name.split('.').pop().toLowerCase();
            if (!allowed.includes(ext)) {
                errorEl.innerHTML = 'File "' + f.name + '" has an invalid extension.';
                listEl.innerHTML = '';
                return;
            }
            if (f.size > maxSize) {
                errorEl.innerHTML = 'File "' + f.name + '" exceeds 5 MB.';
                listEl.innerHTML = '';
                return;
            }
            if (f.size === 0) {
                errorEl.innerHTML = 'File "' + f.name + '" is empty.';
                listEl.innerHTML = '';
                return;
            }
            const sizeStr = f.size < 1048576
                ? (f.size / 1024).toFixed(1) + ' KB'
                : (f.size / 1048576).toFixed(1) + ' MB';

            html += `<div class="file-preview-item">
                <svg width="16" height="16" fill="#6366f1" viewBox="0 0 24 24" class="me-2 flex-shrink-0">
                    <path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.89 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13z"/>
                </svg>
                <span class="flex-grow-1 text-truncate">${f.name}</span>
                <small class="text-muted ms-2">${sizeStr}</small>
            </div>`;
        }
        listEl.innerHTML = html;
    }
}

// -------------------------------------------------------
// 6. Pincode — numeric only
// -------------------------------------------------------
function initPincodeNumeric() {
    const pin = document.getElementById('Pincode');
    if (!pin) return;
    pin.addEventListener('input', function () {
        pin.value = pin.value.replace(/\D/g, '').slice(0, 6);
    });
}

// -------------------------------------------------------
// 7. Show/Hide Password toggle
// -------------------------------------------------------
function togglePwd(inputId) {
    const input = document.getElementById(inputId);
    input.type = input.type === 'password' ? 'text' : 'password';
}
