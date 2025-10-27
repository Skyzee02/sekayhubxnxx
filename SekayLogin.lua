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

-- Daftar Whitelist Kunci: Key, Tipe Durasi (diambil dari DURATIONS atau "lifetime")
-- 'type' harus sesuai dengan kunci di tabel DURATIONS, atau "lifetime".
local KeyWhitelist = {
    -- Kunci TRIAL (30 Menit)
    ["SEKAY-TRIAL-30M"] = {
        type = "30M",
        level = "Trial 30 Mins"
    },

    -- Kunci 1 HARI
    ["SEKAY-VIP-1D"] = {
        type = "1D",
        level = "VIP 1 Day"
    },

    -- Kunci 7 HARI
    ["SEKAY-VIP-7D"] = {
        type = "7D",
        level = "VIP 7 Days"
    },
    
    -- Kunci 30 HARI
    ["SEKAY-VIP-30D"] = {
        type = "30D",
        level = "VIP 30 Days"
    },
    
    -- Kunci LIFETIME
    ["SEKAY-LIFETIME-VIP"] = {
        type = "lifetime",
        level = "VIP Lifetime"
    },
    ["ADMIN-MASTER-KEY"] = {
        type = "lifetime",
        level = "Admin Access"
    }
}

-- MODIFIED: Implements a local whitelist check supporting multiple expiry durations and Lifetime.
local function ValidateKey(Key)
    local keyData = KeyWhitelist[Key]
    
    if keyData then
        local expire_at_str
        local currentTime = GetCurrentTimeInSeconds()
        local durationType = keyData.type

        if durationType == "lifetime" then
            -- Untuk kunci Lifetime, set tanggal kedaluwarsa ke masa depan yang sangat jauh (misalnya 10 tahun)
            local farFutureTime = currentTime + (365 * 24 * 60 * 60 * 10)
            expire_at_str = os.date("!%Y-%m-%d %H:%M:%S", farFutureTime)
        
        elseif DURATIONS[durationType] then
            -- Untuk durasi sementara (30M, 1D, 7D, 30D), hitung kedaluwarsa dari waktu login saat ini
            local durationSeconds = DURATIONS[durationType]
            local expireTime = currentTime + durationSeconds
            expire_at_str = os.date("!%Y-%m-%d %H:%M:%S", expireTime)
        
        else
            -- Tipe kunci tidak dikenal, anggap tidak valid
            return false, "Invalid Key Type Configuration. Check KeyWhitelist table."
        end

        local response_data = {
            key = Key,
            success = true,
            expire_at = expire_at_str,
            level = keyData.level,
            uplink = "V1.0",
            blacklist = 0,
            message = "Login Successfully (" .. keyData.level .. ")"
        }
        
        return true, response_data
    else
        -- Kunci tidak ditemukan di whitelist
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
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
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
KeyTab:AddKeyBox(function(Success, RecivedKey)
    local isValid, dataOrMsg = ValidateKey(RecivedKey)

    if isValid then
        Library:Notify("Correct Key!", 5)

        local currentData = {
            Key = RecivedKey, -- Now correctly logs the user-entered key
            HWID = hwid,
            RobloxUser = username,
            RobloxID = userid,
            ExpireAt = dataOrMsg.expire_at or "Unknown",
            Level = dataOrMsg.level or "Unknown",
            Uplink = dataOrMsg.uplink or "Unknown",
            Blacklist = dataOrMsg.blacklist or 0,
            Message = dataOrMsg.message or ""
        }

        _G.SIREN_Data = currentData

        -- Simpan ke file JSON lokal kalau remember diaktifkan
        if isRememberMeChecked then
           local jsonString = HttpService:JSONEncode(currentData)
           -- !!! MODIFIKASI: Menggunakan variabel LOCAL_SAVE_FILE yang baru
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
local function LoadAndCheckKey()
    local savedData = nil
    
    -- Cek apakah file lokal ada (menggunakan nama file baru: LOCAL_SAVE_FILE)
    local fileExists, _ = pcall(function() return readfile(LOCAL_SAVE_FILE) end)
    
    if fileExists then
        local success, content = pcall(function() return readfile(LOCAL_SAVE_FILE) end)
        if success and content then
            local decodedSuccess, decodedData = pcall(function() return HttpService:JSONDecode(content) end)
            -- Pastikan data valid dan punya 'expire_at'
            if decodedSuccess and type(decodedData) == "table" and decodedData.ExpireAt then 
                savedData = decodedData
            end
        end
    end
    
    if savedData then
        -- Konversi string ExpireAt ke waktu epoch (detik)
        -- Format: "!%Y-%m-%d %H:%M:%S"
        local expire_time = 0
        local year, month, day, hour, min, sec = savedData.ExpireAt:match("^(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)$")

        if year then
            -- os.time() bekerja di UTC jika string diawali '!'
            expire_time = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
        end

        local currentTime = GetCurrentTimeInSeconds()
        
        -- Cek apakah kunci sudah kedaluwarsa
        if expire_time > currentTime then
            -- Kunci masih valid, otomatis login dengan data yang tersimpan
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
    local isAllowed = false
    local response = nil
    
    local success, result = pcall(function()
        -- Gunakan request() untuk mengambil data dari link GitHub
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
        
        if decodeSuccess and decodedData and decodedData.allowed then
            for _, entry in pairs(decodedData.allowed) do
                if entry.id and tonumber(entry.id) == userid then
                    isAllowed = true
                    print("Remote Whitelist Check: User is allowed (" .. entry.name .. ")")
                    break
                end
            end
        end
    else
        warn("Failed to fetch or decode remote whitelist.")
    end
    
    return isAllowed
end


-- Jalankan pengecekan
if CheckRemoteWhitelist() then
    -- Jika user ada di Remote Whitelist, berikan akses penuh
    print("User is a whitelisted Admin/Owner. Skipping Key Check.")
    Library:Notify("Admin/Owner Access Granted!", 5)
    
    -- Setup data global layaknya login master key
    _G.SIREN_Data = {
        Key = "REMOTE-WHITELIST",
        HWID = hwid,
        RobloxUser = username,
        RobloxID = userid,
        ExpireAt = os.date("!%Y-%m-%d %H:%M:%S", GetCurrentTimeInSeconds() + (365 * 24 * 60 * 60 * 10)), -- Lifetime
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