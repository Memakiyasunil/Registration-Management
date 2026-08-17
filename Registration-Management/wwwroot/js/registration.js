/**
 * registration.js
 * SaaS Form Interactions:
 * - Real-time debounced username availability check
 * - Cascading State -> City dropdown
 * - Password strength meter & visibility toggle
 * - Selectable Hobby chips & Gender radio card sync
 * - Interactive multi-file drag-and-drop staging & removal
 * - Pincode 6-digit numeric filter
 * - Form submit loading state
 */

function initRegistrationForm() {
    initUsernameCheck();
    initCascadingCity();
    initPasswordStrength();
    initDobValidation();
    initFileDragDrop();
    initPincodeNumeric();
    initHobbyChips();
    initGenderCards();
    initFormSubmit();
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

        if (val.length < 4) {
            status.innerHTML = '<span class="text-muted small">Min 4 characters</span>';
            return;
        }

        timer = setTimeout(function () {
            status.innerHTML = '<span class="text-muted small"><span class="spinner-border spinner-border-sm me-1" style="width:12px;height:12px;"></span>Checking availability...</span>';
            $.getJSON(checkUsernameUrl, { username: val, excludeUserId: typeof excludeUserId !== 'undefined' ? excludeUserId : 0 }, function (data) {
                if (data.available) {
                    status.innerHTML = '<span class="text-success small fw-semibold">✓ ' + data.message + '</span>';
                    input.classList.remove('is-invalid');
                    input.classList.add('is-valid');
                } else {
                    status.innerHTML = '<span class="text-danger small fw-semibold">✗ ' + data.message + '</span>';
                    input.classList.remove('is-valid');
                    input.classList.add('is-invalid');
                }
            }).fail(function () {
                status.innerHTML = '<span class="text-muted small">Could not check username.</span>';
            });
        }, 400);
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
        citySelect.innerHTML = '<option value="0">Loading cities...</option>';
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

    // Enable city if state already selected (edit mode / postback)
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
        if (!val) { bar.innerHTML = ''; return; }

        const score = calcStrength(val);
        const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
        const colors = ['', '#ef4444', '#f59e0b', '#3b82f6', '#16a34a'];
        const widths = ['0%', '25%', '50%', '75%', '100%'];

        bar.innerHTML = `
            <div class="d-flex align-items-center gap-2 mt-1">
                <div style="flex:1; height:4px; background:#e2e8f0; border-radius:999px; overflow:hidden;">
                    <div style="height:100%; width:${widths[score]}; background:${colors[score]}; transition:width .25s ease, background .25s ease; border-radius:999px;"></div>
                </div>
                <small style="color:${colors[score]}; font-size:0.75rem; font-weight:600; width:45px;">${labels[score]}</small>
            </div>`;
    });
}

function calcStrength(p) {
    let s = 0;
    if (p.length >= 8) s++;
    if (/[A-Z]/.test(p)) s++;
    if (/[0-9]/.test(p)) s++;
    if (/[^A-Za-z0-9]/.test(p)) s++;
    return s === 0 ? 1 : s;
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
// 5. File Drag-Drop & Multi-File Staging
// -------------------------------------------------------
let stagedFiles = [];

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
        if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
            handleFiles(e.dataTransfer.files);
        }
    });

    input.addEventListener('change', function () {
        if (input.files && input.files.length > 0) {
            handleFiles(input.files);
        }
    });

    function handleFiles(files) {
        errorEl.innerHTML = '';
        const dt = new DataTransfer();

        const currentFiles = Array.from(files);
        if (currentFiles.length > maxCount) {
            errorEl.innerHTML = 'Maximum ' + maxCount + ' files allowed.';
            return;
        }

        stagedFiles = [];
        for (let i = 0; i < currentFiles.length; i++) {
            const f = currentFiles[i];
            const ext = '.' + f.name.split('.').pop().toLowerCase();
            if (!allowed.includes(ext)) {
                errorEl.innerHTML = 'File "' + f.name + '" has an unsupported format.';
                renderFileList();
                return;
            }
            if (f.size > maxSize) {
                errorEl.innerHTML = 'File "' + f.name + '" exceeds 5 MB.';
                renderFileList();
                return;
            }
            stagedFiles.push(f);
            dt.items.add(f);
        }

        input.files = dt.files;
        renderFileList();
    }

    window.removeStagedFile = function (index) {
        stagedFiles.splice(index, 1);
        const dt = new DataTransfer();
        stagedFiles.forEach(f => dt.items.add(f));
        input.files = dt.files;
        renderFileList();
    };

    function renderFileList() {
        listEl.innerHTML = '';
        if (stagedFiles.length === 0) return;

        let html = '<div class="d-flex flex-column gap-2 mt-3">';
        stagedFiles.forEach((f, idx) => {
            const sizeStr = f.size < 1048576
                ? (f.size / 1024).toFixed(1) + ' KB'
                : (f.size / 1048576).toFixed(1) + ' MB';

            html += `
                <div class="file-preview-card d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center text-truncate me-2">
                        <svg width="18" height="18" fill="#4f46e5" viewBox="0 0 24 24" class="me-2 flex-shrink-0">
                            <path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.89 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13z"/>
                        </svg>
                        <span class="text-truncate fw-medium">${f.name}</span>
                        <span class="text-muted ms-2 small">(${sizeStr})</span>
                    </div>
                    <button type="button" class="btn btn-sm text-danger p-0 border-0" onclick="removeStagedFile(${idx})" title="Remove file">
                        <svg width="16" height="16" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                        </svg>
                    </button>
                </div>`;
        });
        html += '</div>';
        listEl.innerHTML = html;
    }
}

// -------------------------------------------------------
// 6. Pincode — 6-digit numeric only
// -------------------------------------------------------
function initPincodeNumeric() {
    const pin = document.getElementById('Pincode');
    if (!pin) return;
    pin.addEventListener('input', function () {
        pin.value = pin.value.replace(/\D/g, '').slice(0, 6);
    });
}

// -------------------------------------------------------
// 7. Selectable Hobby Chips Sync
// -------------------------------------------------------
function initHobbyChips() {
    document.querySelectorAll('.hobby-chip').forEach(chip => {
        const checkbox = chip.querySelector('input[type="checkbox"]');
        if (!checkbox) return;

        // Initialize state
        if (checkbox.checked) {
            chip.classList.add('selected');
        } else {
            chip.classList.remove('selected');
        }

        // Native change event
        checkbox.addEventListener('change', function () {
            if (this.checked) {
                chip.classList.add('selected');
            } else {
                chip.classList.remove('selected');
            }
        });
    });
}

// -------------------------------------------------------
// 8. Gender Radio Card Sync
// -------------------------------------------------------
function initGenderCards() {
    document.querySelectorAll('.gender-radio-card').forEach(card => {
        const radio = card.querySelector('input[type="radio"]');
        if (!radio) return;

        if (radio.checked) {
            card.classList.add('active');
        } else {
            card.classList.remove('active');
        }

        radio.addEventListener('change', function () {
            document.querySelectorAll('.gender-radio-card').forEach(c => c.classList.remove('active'));
            if (this.checked) {
                card.classList.add('active');
            }
        });
    });
}

// -------------------------------------------------------
// 9. Show/Hide Password Toggle
// -------------------------------------------------------
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

// -------------------------------------------------------
// 10. Form Submit Loading Spinner
// -------------------------------------------------------
function initFormSubmit() {
    const form = document.getElementById('registrationForm');
    const submitBtn = document.getElementById('submitBtn');
    if (!form || !submitBtn) return;

    form.addEventListener('submit', function () {
        if ($(form).valid()) {
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status"></span>Saving...';
            form.submit();
        }
    });
}
