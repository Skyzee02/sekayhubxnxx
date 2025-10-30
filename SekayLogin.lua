-- Mengganti Obsidian/Linoria Library dengan Wind UI Library
local Wind = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/WindUI.lua"))()

local Window = Wind:CreateWindow({
    Title = "Sekay Hub",
    Footer = "Version: 1.0.2",
    ToggleKeybind = Enum.KeyCode.RightControl, -- Keybind untuk membuka/menutup
    Center = true,
    AutoShow = true,
    Resizable = false,
    Size = UDim2.fromOffset(700, 500)
})

-- Konversi Window:AddKeyTab & Window:AddTab menjadi Window:Tab
local KeyTab = Window:Tab({Title = "Login", Icon = "key"})
local InfoTab = Window:Tab({Title = "Info", Icon = "info"})

local Analytics = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hwid = Analytics:GetClientId()
local username = player and player.Name or "Unknown"
local userid = player and player.UserId or "Unknown"

local LOCAL_SAVE_FILE = "whitelist.json" 
local REMOTE_WHITELIST_URL = "https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/whitelist.json"
local KeyWhitelist = {} 

-- Tambahkan Section untuk menampung elemen
local LoginSection = KeyTab:Section({Title = "Key Login"})
local InfoSection = InfoTab:Section({Title = "Information"})


-- KeyTab:AddLabel diganti dengan Section:Label
LoginSection:Label({
    Text = "Welcome To\nSekay Hub",
    -- DoesWrap dan Size dihapus karena properti tersebut spesifik Linoria
})

local function GetCurrentTimeInSeconds()
    return os.time()
end

local DURATIONS = {
    ["30M"] = 30 * 60,
    ["1D"] = 24 * 60 * 60,
    ["7D"] = 7 * 24 * 60 * 60,
    ["30D"] = 30 * 24 * 60 * 60,
}

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
            KeyWhitelist = decodedData.keys
            print("Successfully loaded " .. tostring(#KeyWhitelist) .. " keys from remote.")
            return true
        end
    end
    
    warn("FATAL: Failed to fetch or decode KeyWhitelist from remote URL.")
    return false
end

local function ValidateKey(Key)
    local keyData = KeyWhitelist[Key]
    
    if keyData then
        local durationType = keyData.type

        if durationType == "lifetime" or DURATIONS[durationType] then
            local response_data = {
                key = Key,
                success = true,
                level = keyData.level, -- Menggunakan level dari whitelist
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

local isRememberMeChecked = false
local WebhookUrl = "https://canary.discord.com/api/webhooks/1432014189567672351/SQ8Ozl5j5ZMbs5p3jKN2HZvnAKJT-ShQrfzf3vyiZZYaT7-Jl3xP-PeaSb1DlKWtywEj"

local function getFormattedDateTime()
    return os.date("%A, %d-%m-%Y %H:%M:%S")
end

local function SendWebhook(data)
    local rawKey = data.Key or "Unknown"
    local censoredKey
    if rawKey == "REMOTE-WHITELIST" then
        censoredKey = "Owner/Admin Login"
    elseif #rawKey > 4 then
        local prefix = rawKey:sub(1, 2)
        local suffix = rawKey:sub(-2)
        local censorsLength = #rawKey - 4
        local censors = string.rep("X", censorsLength)
        censoredKey = prefix .. censors .. suffix
    else
        censoredKey = string.rep("X", #rawKey)
    end
    
    local message = data.Message or "No Message"
    local isSuccess = data.Success and "SUCCESS" or "FAILED"
    local color = data.Success and 65280 or 16711680 -- Green or Red

    local content = "**[Sekay Hub - Key Login]**\n" ..
                    "Status: **" .. isSuccess .. "**\n" ..
                    "Message: *" .. message .. "*"

    local embed = {
        title = "Login Attempt",
        description = "**Key:** " .. censoredKey,
        color = color,
        fields = {
            { name = "Username", value = string.format("`%s`", username), inline = true },
            { name = "UserID", value = string.format("`%s`", tostring(userid)), inline = true },
            { name = "HWID", value = string.format("`%s`", string.sub(hwid, 1, 10) .. "..."), inline = false },
            { name = "Time (Local)", value = string.format("`%s`", getFormattedDateTime()), inline = false },
        },
        footer = {
            text = "Sekay Hub Login System",
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
    }

    local payload = HttpService:JSONEncode({
        content = content,
        embeds = {embed}
    })

    pcall(function()
        request = request or http_request or syn and syn.request
        if request then
            request({
                Url = WebhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = payload
            })
        end
    end)
end

local function CalculateExpiry(Key, keyData)
    local durationType = keyData.type
    local current_time = GetCurrentTimeInSeconds()
    
    local expire_time
    if durationType == "lifetime" then
        -- Lifetime: 10 tahun dari sekarang (hanya untuk representasi)
        expire_time = current_time + (365 * 24 * 60 * 60 * 10)
    else
        local duration_seconds = DURATIONS[durationType]
        if duration_seconds then
            -- Expiry = Waktu saat ini + Durasi
            expire_time = current_time + duration_seconds
        else
            -- Harusnya tidak terjadi karena sudah divalidasi
            return nil, "Invalid duration type."
        end
    end
    
    -- Format os.date("%Y-%m-%d %H:%M:%S")
    return os.date("%Y-%m-%d %H:%M:%S", expire_time)
end

-- Load data dari file lokal jika ada
local function LoadAndCheckKey()
    if isfile(LOCAL_SAVE_FILE) then
        local success, savedData = pcall(function()
            local content = readfile(LOCAL_SAVE_FILE)
            return HttpService:JSONDecode(content)
        end)
        
        if success and savedData and savedData.Key and savedData.HWID == hwid then
            local key = savedData.Key
            local _, keyData = ValidateKey(key) -- Cek lagi ke remote whitelist
            
            if keyData then
                -- Key valid, cek status blacklist dan expired (dari data lokal)
                
                -- Cek expired (jika ada data expire time)
                if savedData.ExpireAt and savedData.ExpireAt ~= "Unknown" then
                    local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
                    local y, m, d, h, min, s = savedData.ExpireAt:match(pattern)
                    local expireTime = os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})

                    if expireTime < os.time() then
                        Wind:Notify("Your saved key has expired! Please login again.", 5)
                        return false
                    end
                end
                
                -- Data lokal valid, set _G.SIREN_Data
                _G.SIREN_Data = savedData
                return true
            end
        end
    end
    return false
end

-- Fungsi tambahan untuk mengecek whitelisted user/admin (dari snippet yang hilang)
local function CheckRemoteWhitelist()
    -- Jika ada logika pengecekan user/admin di remote whitelist yang terpisah dari key (misalnya cek user ID)
    -- Ini adalah placeholder, karena logikanya tidak lengkap.
    return false
end

-- KeyTab:AddInput diganti dengan Section:Input (menghilangkan ID string pertama)
local KeyInput = LoginSection:Input({
    Title = "Key", -- Menggantikan ID string pertama ("KeyInput")
    Text = "Enter your key here...",
    Default = "",
})

-- KeyTab:AddCheckbox diganti dengan Section:Toggle
local RememberToggle = LoginSection:Toggle({
    Title = "Remember this Key", -- Menggantikan ID string pertama ("RememberKey")
    Tooltip = "Save key locally for automatic login.",
    Default = false,
    Callback = function(Value)
        isRememberMeChecked = Value
    end,
})

-- KeyTab:AddButton diganti dengan Section:Button
LoginSection:Button({
    Title = "Login", -- Tambahkan properti Title
    Func = function()
        if not FetchKeyWhitelist() then
            Wind:Notify("FATAL ERROR: Failed to load KeyWhitelist from server. Unloading.", 10)
            Wind:Unload()
            return
        end

        local key = KeyInput.Value or ""

        if key == "" then
            Wind:Notify("Key cannot be empty.", 5)
            return
        end
        
        local success, result = ValidateKey(key)

        if success then
            local response_data = result
            local keyData = KeyWhitelist[key]
            local expireAt = CalculateExpiry(key, keyData)
            
            -- Set data global
            _G.SIREN_Data = {
                Key = key,
                HWID = hwid,
                RobloxUser = username,
                RobloxID = userid,
                ExpireAt = expireAt,
                Level = response_data.level,
                Uplink = response_data.uplink,
                Blacklist = response_data.blacklist,
                Message = response_data.message
            }
            
            -- Simpan ke file lokal jika toggle Remember Key aktif
            if isRememberMeChecked then
                pcall(function()
                    local toSave = HttpService:JSONEncode(_G.SIREN_Data)
                    writefile(LOCAL_SAVE_FILE, toSave)
                end)
            end
            
            -- Kirim webhook login sukses
            SendWebhook({Key=key, Success=true, Message="Key Login Successful."})
            Wind:Notify("Login Success! Welcome, " .. username .. "!", 5)
            
            -- Sembunyikan dan Load Menu
            Window:SetVisible(false) -- Konversi Window:Hide()
            task.delay(1, function()
                Wind:Unload() -- Konversi Library:Unload
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
            end)
        else
            -- Kirim webhook login gagal
            SendWebhook({Key=key, Success=false, Message=result})
            Wind:Notify("Login Failed: " .. result, 5)
        end
    end,
})

-- Bagian Info Tab
-- InfoTab:AddLabel
InfoSection:Label({
    Text = "Informasi Hub:\n\nSekay Hub V1.0.2\nDiscord: discord.gg/xxxxx\nDeveloper: Sekayzee",
})

-- InfoTab:AddButton
InfoSection:Button({
    Title = "Join Discord",
    Func = function()
        Wind:Notify("Coming Soon!", 5)
    end
})

-- Pengecekan Login Awal (Auto-login)
task.spawn(function()
    if not FetchKeyWhitelist() then
        Wind:Notify("FATAL ERROR: Failed to load KeyWhitelist from server. Unloading.", 10)
        Wind:Unload()
        return -- Hentikan script
    end

    if CheckRemoteWhitelist() then
        print("User is a whitelisted Admin/Owner. Skipping Key Check.")
        Wind:Notify("Admin/Owner Access Granted! (Remote)", 5)
        
        -- Setup data global layaknya login master key
        -- Logika ini disederhanakan; remoteKeyData harus diambil dari CheckRemoteWhitelist
        _G.SIREN_Data = {
            Key = "REMOTE-WHITELIST",
            HWID = hwid,
            RobloxUser = username,
            RobloxID = userid,
            ExpireAt = os.date("%Y-%m-%d %H:%M:%S", os.time() + (365 * 24 * 60 * 60 * 10)), -- Lifetime
            Level = "Owner/Admin (Remote)",
            Uplink = "V1.0",
            Blacklist = 0,
            Message = "Login Successfully (Owner/Admin)"
        }

        Window:SetVisible(false) -- Konversi Window:Hide()
        task.delay(1, function()
            Wind:Unload()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
        end)
    elseif LoadAndCheckKey() then
        Wind:Notify("Auto-Login Success! Welcome, " .. username .. "!", 5)
        Window:SetVisible(false) -- Konversi Window:Hide()
        task.delay(1, function()
            Wind:Unload()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
        end)
    else
        Wind:Notify("Please login your key.", 5)
    end
end)