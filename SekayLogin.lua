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
                level = "level",
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

-- TEMPATKAN KODE INI DI DALAM SekayLogin.lua MENGGANTIKAN BLOK LOGIKA SUKSES
KeyTab:AddKeyBox(function(Success, RecivedKey)
    local isValid, dataOrMsg = ValidateKey(RecivedKey)

    if isValid then
        Library:Notify("Correct Key!", 5)

        local remoteKeyData = KeyWhitelist[RecivedKey]
        
        -- Cek ketersediaan data kunci dan waktu pembuatan (created_at)
        if not remoteKeyData or not remoteKeyData.created_at then 
            Library:Notify("FATAL: Key data is corrupted (missing creation time).", 7)
            return 
        end 

        local InitialTime = remoteKeyData.created_at
        local durationType = remoteKeyData.type
        local ExpireTimestamp = 0

        if durationType == "lifetime" then
            -- Lifetime: Atur waktu kadaluarsa jauh di masa depan (e.g., 10 tahun dari waktu pembuatan)
            ExpireTimestamp = InitialTime + (365 * 24 * 60 * 60 * 10) 
        elseif DURATIONS[durationType] then
            -- Durasi normal: Tambahkan durasi ke waktu pembuatan kunci
            ExpireTimestamp = InitialTime + DURATIONS[durationType]
        else
            Library:Notify("Invalid Key Type Configuration.", 7)
            return 
        end
        
        -- Konversi ExpireTimestamp (angka) ke format string yang bisa diproses oleh SekayMenu.lua
        local ExpireAtString = os.date("%Y-%m-%d %H:%M:%S", ExpireTimestamp)

        -- *** PENTING: SET DATA GLOBAL _G.SIREN_Data ***
        _G.SIREN_Data = {
            Key = RecivedKey,
            HWID = hwid,
            RobloxUser = username,
            RobloxID = userid,
            ExpireAt = ExpireAtString, -- Gunakan string format tanggal yang sudah dikoreksi
            Level = remoteKeyData.level,
            Uplink = "V1.0",
            Blacklist = 0,
            Message = "Login Successfully (" .. remoteKeyData.level .. ")"
        }

        -- Kirim webhook (pastikan fungsi SendWebhook ada)
        SendWebhook(_G.SIREN_Data)
        
        -- Checkbox Remember Me
KeyTab:AddCheckbox("Remember this Key", {
    Text = "Remember this Key",
    Tooltip = "Save your key for future sessions",
    Default = false,
    Callback = function(Value)
        isRememberMeChecked = Value
    end,
})

        Window:Hide() -- Sembunyikan UI Login
        task.delay(1, function()
            Library:Unload()
            -- Muat script menu
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
        end)

    else
        -- Login Gagal
        Library:Notify(dataOrMsg, 5)
    end
end)

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

-- Fungsi untuk memuat data lokal dan memeriksa kedaluwarsa
local function LoadAndCheckKey()
    local savedData = nil
    -- --- [PENTING: Implementasi pembacaan file lokal (readfile/JSONDecode)]---
    local success, content = pcall(function() return readfile(LOCAL_SAVE_FILE) end)
    if success and content and HttpService then
        pcall(function() savedData = HttpService:JSONDecode(content) end)
    end
    -- ---------------------------------------------------------------------

    if savedData and savedData.InitialLoginTime then
        local currentTime = GetCurrentTimeInSeconds()
        local expire_time = 0
        local initial_login_time = savedData.InitialLoginTime -- Waktu Pembuatan/Awal yang tersimpan (TIDAK BERUBAH)

        local durationType = savedData.Level -- Asumsi Level = Type
        local durationSeconds = DURATIONS[durationType]

        if durationType == "Owner/Admin (Remote)" or durationType == "lifetime" then
             -- Lifetime dihitung dari Waktu Awal
             local farFutureTime = initial_login_time + (365 * 24 * 60 * 60 * 10)
             expire_time = farFutureTime
        elseif durationSeconds then
            -- HITUNG ULANG KEDALUWARSA DARI INITIAL_LOGIN_TIME (Waktu Pembuatan)
            expire_time = initial_login_time + durationSeconds
        else
            -- Fallback
            expire_time = 0
        end
        
        -- Cek apakah kunci sudah kedaluwarsa
        if expire_time > currentTime then
            -- Kunci masih valid.
            -- Perbarui ExpireAt (string) di savedData, tetapi InitialLoginTime tetap
            savedData.ExpireAt = os.date("%Y-%m-%d %H:%M:%S", expire_time) 

            -- ... (Logika Auto-Login Sukses)
            print("Auto-Login: Key still valid until " .. savedData.ExpireAt)
            Library:Notify("Auto-Login Success! Level: " .. savedData.Level, 5)

            _G.SIREN_Data = savedData -- Set data global

            task.delay(3, function()
                Library:Unload()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
            end)
            return true -- Auto-login berhasil
        else
            -- Kunci sudah kedaluwarsa
            print("Auto-Login: Saved key is expired.")
            Library:Notify("Your saved key has expired! Please enter a new one.", 5)
            
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
        ExpireAt = os.date("%Y-%m-%d %H:%M:%S", remoteKeyData.created_at() + (365 * 24 * 60 * 60 * 10)), -- Lifetime
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