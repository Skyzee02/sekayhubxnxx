local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Sekay Hub",
    Footer = "Version: 1.0.2", --small text in the bottom of page
    ToggleKeybind = Enum.KeyCode.RightControl,
    Center = true,
    AutoShow = true,
    Resizable = false, --not rezizeable
    Size = UDim2.fromOffset(700, 500) -- size of ui
})

local KeyTab = Window:AddKeyTab("Login")
local InfoTab = Window:AddTab("Info", "info")
local Analytics = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hwid = Analytics:GetClientId()
local username = player and player.Name or "Unknown"
local userid = player and player.UserId or "Unknown"

-- !!! MODIFIKASI: Mengubah nama file penyimpanan lokal
local LOCAL_SAVE_FILE = "whitelist.json" 

-- Ganti dengan link GitHub kamu untuk Whitelist (contoh URL mentah)
local REMOTE_WHITELIST_URL = "https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/whitelist.json"

-- Variabel global lokal untuk menyimpan data KeyWhitelist yang dimuat dari REMOTE_WHITELIST_URL
local KeyWhitelist = {} 

KeyTab:AddLabel({
    Text = "Welcome To\nSekay Hub",
    DoesWrap = true,
    Size = 36,
})

local function GetCurrentTimeInSeconds()
    return os.time()
end

-- Definisikan Durasi dalam Detik untuk setiap Tipe Akses
local DURATIONS = {
    ["30M"] = 30 * 60,                -- 30 minutes
    ["1D"] = 24 * 60 * 60,            -- 1 day
    ["7D"] = 7 * 24 * 60 * 60,        -- 7 days
    ["30D"] = 30 * 24 * 60 * 60,      -- 30 days (Approximate)
}

-- -----------------------------------------------------------
-- !!! START MODIFIKASI: FUNGSI UNTUK MEMUAT KEYWHITELIST DARI URL
-- -----------------------------------------------------------
local function FetchKeyWhitelist()
    print("Fetching KeyWhitelist from remote URL: " .. REMOTE_WHITELIST_URL)
    local success, result = pcall(function()
        request = request or http_request or syn and syn.request
        if request then
            return request({
                Url = REMOTE_WHITELIST_URL,
                Method = "GET"
            })
        end
        return nil
    end)

    if success and result and result.Success and result.Body and result.StatusCode == 200 then
        local decodeSuccess, decodedData = pcall(function() 
            return HttpService:JSONDecode(result.Body) 
        end)
        
        if decodeSuccess and decodedData and decodedData.keys then
            -- Set KeyWhitelist ke tabel 'keys' yang diambil
            KeyWhitelist = decodedData.keys
            print("Successfully loaded " .. tostring(#KeyWhitelist) .. " keys from remote.")
            return true
        end
    end
    
    warn("FATAL: Failed to fetch or decode KeyWhitelist from remote URL.")
    return false
end
-- -----------------------------------------------------------
-- !!! END MODIFIKASI
-- -----------------------------------------------------------

-- MODIFIED: Implements a local whitelist check supporting multiple expiry durations and Lifetime.
local function ValidateKey(Key)
    local keyData = KeyWhitelist[Key]
    
    if keyData then
        local durationType = keyData.type

        if durationType == "lifetime" or DURATIONS[durationType] then
             -- TIDAK PERLU HITUNG expire_at DI SINI LAGI
             
            local response_data = {
                key = Key,
                success = true,
                -- expire_at DIHAPUS, AKAN DIHITUNG DI BAWAH
                level = keyData.level,
                uplink = "V1.0",
                blacklist = 0,
                message = "Login Successfully (" .. keyData.level .. ")"
            }
            
            return true, response_data
        else
            return false, "Invalid Key Type Configuration. Check remote whitelist.json structure."
        end
    else
        return false, "Key Not Found or Invalid."
    end
end

-- Tambahkan checkbox "Remember this Key"
local isRememberMeChecked = false

-- Ganti dengan webhook Discord kamu
local WebhookUrl = "https://canary.discord.com/api/webhooks/1432014189567672351/SQ8Ozl5j5ZMbs5p3jKN2HZvnAKJT-ShQrfzf3vyiZZYaT7-Jl3xP-PeaSb1DlKWtywEj"

-- Fungsi untuk kirim webhook
local function SendWebhook(data)
    local body = {
        ["username"] = "Sekay Hub Logger",
        ["embeds"] = {{
            ["title"] = "New Login Success ✅",
            ["color"] = 65280, -- hijau
            ["fields"] = {
                {["name"] = "Key", ["value"] = data.Key or "Unknown", ["inline"] = true}, -- Menggunakan 'value' bukan 'Sekayzee'
                {["name"] = "HWID", ["value"] = data.HWID or "Unknown", ["inline"] = true},
                {["name"] = "Roblox User", ["value"] = data.RobloxUser or "Unknown", ["inline"] = true},
                {["name"] = "Roblox ID", ["value"] = tostring(data.RobloxID) or "Unknown", ["inline"] = true},
                {["name"] = "Level", ["value"] = data.Level or "Unknown", ["inline"] = true},
                {["name"] = "Expire At", ["value"] = data.ExpireAt or "Unknown", ["inline"] = true}
            },
            ["footer"] = {
                ["text"] = "Sekay Hub Auth Logger"
            },
            ["timestamp"] = os.date("%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local headers = {["Content-Type"] = "application/json"}
    local encoded = HttpService:JSONEncode(body)
    request = request or http_request or syn and syn.request
    if request then
        request({
            Url = WebhookUrl,
            Method = "POST",
            Headers = headers,
            Body = encoded
        })
    end
end

-- Bagian KeyTab (Login Logic)
-- Bagian KeyTab (Login Logic)
KeyTab:AddKeyBox(function(Success, RecivedKey)
    local isValid, dataOrMsg = ValidateKey(RecivedKey)

    if isValid then
        -- >>> START MODIFIKASI INTI: Menggunakan Waktu Pembuatan Key dari Remote <<<
        
        -- Ambil data Key secara lengkap (termasuk created_at) dari KeyWhitelist global
        local remoteKeyData = KeyWhitelist[RecivedKey]
        
        -- Defaultkan created_at ke waktu saat ini jika tidak ada di remote (untuk kompatibilitas)
        local InitialTime = remoteKeyData.created_at or GetCurrentTimeInSeconds() 
        
        local durationType = dataOrMsg.level -- Asumsi level sama dengan type
        local durationSeconds = DURATIONS[durationType]

        local expire_at_str
        local Level = dataOrMsg.level or "Unknown"

        if durationType == "lifetime" then
            -- Untuk kunci Lifetime, set tanggal kedaluwarsa ke masa depan yang sangat jauh
            local farFutureTime = InitialTime + (365 * 24 * 60 * 60 * 10)
            expire_at_str = os.date("%Y-%m-%d %H:%M:%S", farFutureTime)
        
        elseif durationSeconds then
            -- Hitung kedaluwarsa DARI WAKTU PEMBUATAN (InitialTime)
            local expireTime = InitialTime + durationSeconds
            expire_at_str = os.date("%Y-%m-%d %H:%M:%S", expireTime)
        else
            -- Tipe tidak dikenal, fallback
            expire_at_str = os.date("%Y-%m-%d %H:%M:%S", GetCurrentTimeInSeconds() + 3600)
            Level = "Unknown Duration"
        end
        -- >>> END MODIFIKASI INTI <<<

        local currentData = {
            Key = RecivedKey,
            HWID = hwid,
            RobloxUser = username,
            RobloxID = userid,
            ExpireAt = expire_at_str, -- Menggunakan waktu yang baru dihitung
            Level = Level,
            Uplink = dataOrMsg.uplink or "Unknown",
            Blacklist = dataOrMsg.blacklist or 0,
            Message = dataOrMsg.message or "",
            -- SIMPAN WAKTU AWAL DARI REMOTE (atau waktu saat ini)
            InitialLoginTime = InitialTime -- InitialLoginTime di sini adalah waktu dibuat/ditemukan pertama kali
        }

        _G.SIREN_Data = currentData

        -- Simpan ke file JSON lokal kalau remember diaktifkan
        if isRememberMeChecked then
           local jsonString = HttpService:JSONEncode(currentData)
           writefile(LOCAL_SAVE_FILE, jsonString)
        end

        SendWebhook(currentData)

        task.delay(3, function()
            Library:Unload()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
        end)
    else
        Library:Notify("Incorrect Key! " .. tostring(dataOrMsg), 5)
    end
end)

-- Checkbox Remember Me
KeyTab:AddCheckbox("Remember this Key", {
    Text = "Remember this Key",
    Tooltip = "Save your key for future sessions",
    Default = false,
    Callback = function(Value)
        isRememberMeChecked = Value
    end,
})

KeyTab:AddButton({
    Text = "Don't have the key? Go to the <font color='rgb(0, 195, 255)'>Info</font> Tab!",
    Func = function()
        Window:SelectTab(InfoTab)
    end,
    DoubleClick = false
})

----------------------------------------------------------------------------------------------------
-- INFO TAB UI DEFINITION
----------------------------------------------------------------------------------------------------

local LeftGroupbox = InfoTab:AddLeftGroupbox("How To Get Key", "key")

local WrappedLabel = LeftGroupbox:AddLabel({
    Text = "You can get a key in two ways:\n\n1️⃣ Buy a key from authorized sellers.\n2️⃣ Get a free key valid for 30 minutes with limited features.\n\nUse the buttons below to copy key links or access the free trial! (Note: copying only prints the key link here in this demo)",
    DoesWrap = true
})

local Button = LeftGroupbox:AddButton({
    Text = "<font color='rgb(0, 123, 255)'>Discord</font>",
    Func = function()
        print("Copied Discord link: https://dsc.gg/sekayhub")
        setclipboard("https://dsc.gg/sekayhub") -- optional, jika mau auto-copy
    end,
    DoubleClick = false
})

-- OPTIONAL: Additional button for Linktree
Button:AddButton({
    Text = "<font color='rgb(255, 165, 0)'>Safelinku</font>",
    Func = function()
        print("Copied Linktree link: https://sfl.gl/qjUTr")
        setclipboard("https://sfl.gl/qjUTr") -- optional, jika mau auto-copy
    end
})


local RightGroupbox = InfoTab:AddRightGroupbox("Your Information", "info")

RightGroupbox:AddLabel({
    Text = "Your HWID :\n" .. hwid .. "\n\nYour Roblox Username :\n" .. username .. "\n\nYour Roblox UserId :\n" .. tostring(userid),
    DoesWrap = true
})

local Button = RightGroupbox:AddButton({
    Text = "Copy HWID",
    Func = function()
        setclipboard(hwid)
        Library:Notify("HWID copied to clipboard!", 5)
    end,
    DoubleClick = false
})

local Button = RightGroupbox:AddButton({
    Text = "Copy Username",
    Func = function()
        setclipboard(username)
        Library:Notify("Username copied to clipboard!", 5)
    end,
    DoubleClick = false
})

local Button = RightGroupbox:AddButton({
    Text = "Copy RobloxID",
    Func = function()
        setclipboard(userid)
        Library:Notify("RobloxID copied to clipboard!", 5)
    end,
    DoubleClick = false
})

local UIGroupbox = InfoTab:AddLeftGroupbox("Menu", "settings")

local KeyLabel = UIGroupbox:AddLabel("Menu Bind") --creates a label to attach keybind since it cant be standalone

local Keybind = KeyLabel:AddKeyPicker("MyKeybind", {
    Default = "K",
    Text = "Menu Bind",
    Mode = "Toggle", -- Options: "Toggle", "Hold", "Always"
    
    -- Sets the toggle's value according to the keybind state if Mode is Toggle
    SyncToggleState = false,
    
    Callback = function(Value)
        Library:Unload()
    end
})

local Button = UIGroupbox:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end,
    DoubleClick = false -- Requires double-click for risky actions
})

-- [[ START: LOGIKA AUTO-LOGIN & CEK KEDALUWARSA (dengan nama file baru) ]]
-- Fungsi untuk memuat data lokal dan memeriksa kedaluwarsa
-- Fungsi untuk memuat data lokal dan memeriksa kedaluwarsa
-- Fungsi untuk memuat data lokal dan memeriksa kedaluwarsa
local function LoadAndCheckKey()
    local savedData = nil
    
    -- !!! PERBAIKI: Implementasikan pembacaan file lokal di sini !!!
    local success, content = pcall(function() return readfile(LOCAL_SAVE_FILE) end)
    if success and content and HttpService then
        pcall(function() savedData = HttpService:JSONDecode(content) end)
    end
    -- !!! END PERBAIKI !!!

    if savedData then
        local currentTime = GetCurrentTimeInSeconds()
        local expire_time = 0
        local initial_login_time = savedData.InitialLoginTime -- Ambil waktu awal login

        local durationType = savedData.Level or "Unknown" -- Ambil Level yang tersimpan (diasumsikan = type)
        local durationSeconds = DURATIONS[durationType]

        -- Logika Perhitungan Expire Time (sudah benar)
        if durationType == "Owner/Admin (Remote)" or durationType == "lifetime" then 
             -- Owner/Admin atau lifetime dianggap lifetime
             local farFutureTime = initial_login_time + (365 * 24 * 60 * 60 * 10)
             expire_time = farFutureTime
        elseif durationSeconds then
            -- HITUNG ULANG KEDALUWARSA DARI INITIAL_LOGIN_TIME YANG TERSIMPAN
            expire_time = initial_login_time + durationSeconds
        else
            -- Fallback jika tipe tidak dikenal. Coba gunakan format ExpireAt lama (jika ada)
            local year, month, day, hour, min, sec = tostring(savedData.ExpireAt or ""):match("^(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)$")
            if year then
                expire_time = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
            else
                expire_time = 0 -- Jika format lama gagal atau tidak ada InitialLoginTime
            end
        end
        
        -- HANYA SATU KALI Cek apakah kunci sudah kedaluwarsa
        if expire_time > currentTime then
            -- Kunci masih valid.
            savedData.ExpireAt = os.date("%Y-%m-%d %H:%M:%S", expire_time) -- Update ExpireAt di savedData
            
            print("Auto-Login: Key still valid until " .. savedData.ExpireAt)
            Library:Notify("Auto-Login Success! Level: " .. savedData.Level, 5)

            _G.SIREN_Data = savedData -- Set data global

            -- Muat Menu utama
            task.delay(3, function()
                Library:Unload()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
            end)
            return true -- Auto-login berhasil
        else
            -- Kunci sudah kedaluwarsa
            print("Auto-Login: Saved key is expired.")
            Library:Notify("Your saved key has expired! Please enter a new one.", 5)
            
            -- Hapus file kunci yang kedaluwarsa (disarankan)
            pcall(function() deletefile(LOCAL_SAVE_FILE) end) 
        end
    end
    
    return false -- Tidak ada data tersimpan atau kedaluwarsa
end

-- Fungsi untuk mengecek apakah user adalah Owner/Admin dari remote whitelist
local function CheckRemoteWhitelist()
    -- NOTE: Fungsi ini sekarang seharusnya merujuk ke file remote whitelist lain (misalnya admin_ids.json)
    -- Namun, karena Anda hanya menyediakan satu file remote whitelist (yang sekarang digunakan untuk KeyWhitelist),
    -- saya mempertahankan fungsi ini tetapi mencatat bahwa ini mungkin perlu disesuaikan jika remote whitelist
    -- Admin/Owner adalah file yang berbeda.
    
    local isAllowed = false
    
    -- Ambil data dari remote whitelist (yang diasumsikan isinya daftar user ID Admin)
    local success, result = pcall(function()
        request = request or http_request or syn and syn.request
        if request then
            return request({
                Url = REMOTE_WHITELIST_URL, -- Menggunakan URL yang sama (REMOTE_WHITELIST_URL)
                Method = "GET"
            })
        end
        return nil
    end)

    if success and result and result.Success and result.Body and result.StatusCode == 200 then
        local decodeSuccess, decodedData = pcall(function() 
            return HttpService:JSONDecode(result.Body) 
        end)
        
        -- Asumsi: Admin/Owner ID ada di dalam field "allowed" atau sejenisnya di file JSON tersebut.
        -- Namun, file whitelist.json yang Anda berikan HANYA memiliki field "keys".
        -- Agar kode tetap berfungsi, saya akan mengasumsikan file remote ini SEKARANG hanya untuk KeyWhitelist
        -- dan menonaktifkan Remote Whitelist Admin/Owner berdasarkan User ID untuk menghindari error.
        -- Jika Remote Whitelist Admin/Owner adalah file yang berbeda, Anda harus mengganti REMOTE_WHITELIST_URL di fungsi ini.
        print("Remote Whitelist (Admin/Owner Check) skipped to avoid conflict with KeyWhitelist loading.")
    end
    
    return isAllowed -- Selalu false karena pengecekan dinonaktifkan
end


-- Jalankan pengecekan Remote KeyWhitelist sebelum melanjutkan
if not FetchKeyWhitelist() then
    -- Jika gagal memuat daftar kunci, hentikan eksekusi
    Library:Notify("FATAL ERROR: Failed to load KeyWhitelist from server. Unloading.", 10)
    Library:Unload()
    return -- Hentikan script
end


-- Jalankan pengecekan login
if CheckRemoteWhitelist() then
    -- Jika user ada di Remote Whitelist (Admin/Owner), berikan akses penuh
    print("User is a whitelisted Admin/Owner. Skipping Key Check.")
    Library:Notify("Admin/Owner Access Granted!", 5)
    
    -- Setup data global layaknya login master key
    _G.SIREN_Data = {
        Key = "REMOTE-WHITELIST",
        HWID = hwid,
        RobloxUser = username,
        RobloxID = userid,
        ExpireAt = os.date("%Y-%m-%d %H:%M:%S", GetCurrentTimeInSeconds() + (365 * 24 * 60 * 60 * 10)), -- Lifetime
        Level = "Owner/Admin (Remote)",
        Uplink = "V1.0",
        Blacklist = 0,
        Message = "Login Successfully (Owner/Admin)"
    }

    Window:Hide() -- Sembunyikan UI Login
    task.delay(1, function()
        Library:Unload()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
    end)

elseif LoadAndCheckKey() then
    -- Jika auto-login Key lokal berhasil, UI sudah disembunyikan di dalam LoadAndCheckKey()
    Window:Hide()
else
    -- Tampilkan UI login jika tidak ada auto-login, kunci kedaluwarsa, atau bukan Admin/Owner
    Window:Show() 
end
-- [[ END: LOGIKA AUTO-LOGIN & CEK KEDALUWARSA ]]