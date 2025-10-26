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

-- PERBAIKAN: Mengganti KeyTab dengan WhitelistTab dan menggunakan AddTab biasa
local WhitelistTab = Window:AddTab("Whitelist", "user") 
local InfoTab = Window:AddTab("Info", "info")
local Analytics = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hwid = Analytics:GetClientId()
local username = player and player.Name or "Unknown"
local userid = player and player.UserId or "Unknown"

-- 🔑 WHITELIST CONFIGURATION
-- Tambahkan semua username yang diizinkan di sini (Case-sensitive!)
-- ===================================================
local WhitelistedUsers = {
    "Sekayzee666", -- Ganti dengan username yang benar
    "Sekayzee999"
    -- Tambahkan lebih banyak username di sini...
}

-- Ganti dengan webhook Discord kamu
local WebhookUrl = "https://canary.discord.com/api/webhooks/1432014189567672351/SQ8Ozl5j5ZMbs5p3jKN2HZvnAKJT-ShQrfzf3vyiZZYaT7-Jl3xP-PeaSb1DlKWtywEj"

-- Fungsi untuk kirim webhook (Diperbarui untuk Whitelist)
local function SendWebhook(isSuccess)
    local title = isSuccess and "Whitelist Login Success ✅" or "Whitelist Login Failed ❌"
    local color = isSuccess and 65280 or 16711680 -- Hijau untuk sukses, Merah untuk gagal
    
    local body = {
        ["username"] = "Sekay Hub Logger",
        ["embeds"] = {{
            ["title"] = title,
            ["color"] = color,
            ["fields"] = {
                {["name"] = "Roblox User", ["value"] = username or "Unknown", ["inline"] = true},
                {["name"] = "Roblox ID", ["value"] = tostring(userid) or "Unknown", ["inline"] = true},
                {["name"] = "HWID", ["value"] = hwid or "Unknown", ["inline"] = true},
            },
            ["footer"] = {
                ["text"] = "Sekay Hub Whitelist Logger"
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

-- Fungsi untuk memeriksa Whitelist
local function CheckWhitelist(userName)
    for _, whitelistedName in pairs(WhitelistedUsers) do
        if userName == whitelistedName then
            return true
        end
    end
    return false
end

-- ===================================================
-- Whitelist Tab Logic
-- ===================================================

WhitelistTab:AddLabel({
    Text = "Welcome To\nSekay Hub",
    DoesWrap = true,
    Size = 36,
})

WhitelistTab:AddLabel({
    Text = "Attempting Whitelist Check...",
    DoesWrap = true,
})

WhitelistTab:AddButton({
    Text = "<font color='rgb(0, 255, 0)'>Verify Access</font>",
    Func = function()
        if CheckWhitelist(username) then
            Library:Notify("Access Granted: Whitelisted User!", 5)
            SendWebhook(true)

            -- Data dummy untuk kompatibilitas, karena tidak ada data API
            _G.SIREN_Data = {
                RobloxUser = username,
                RobloxID = userid,
                HWID = hwid,
                Level = "Whitelist", 
            }

            task.delay(3, function()
                Library:Unload()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SIRENMenu.lua", true))()
            end)
        else
            Library:Notify("Access Denied: You are not whitelisted!", 5)
            SendWebhook(false)
        end
    end,
    DoubleClick = false
})
WhitelistTab:AddButton({
    Text = "Check your info in the <font color='rgb(0, 195, 255)'>Info</font> Tab!",
    Func = function()
        Window:SelectTab(InfoTab)
    end,
    DoubleClick = false
})

-- ===================================================
-- Info Tab (Dibersihkan dari referensi "How To Get Key")
-- ===================================================

local LeftGroupbox = InfoTab:AddLeftGroupbox("Information", "info_desc")

local WrappedLabel = LeftGroupbox:AddLabel({
    Text = "This hub uses a Username Whitelist system. Your username is currently: **" .. username .. "**.\n\nOnly users explicitly listed in the script are granted access.",
    DoesWrap = true
})

local Button = LeftGroupbox:AddButton({
    Text = "<font color='rgb(0, 123, 255)'>Discord</font>",
    Func = function()
        print("Copied Discord link: https://dsc.gg/sekayhub")
        setclipboard("https://dsc.gg/sekayhub")
    end,
    DoubleClick = false
})

Button:AddButton({
    Text = "<font color='rgb(255, 165, 0)'>Safelinku</font>",
    Func = function()
        print("Copied Linktree link: https://sfl.gl/qjUTr")
        setclipboard("https://sfl.gl/qjUTr")
    end
})


local RightGroupbox = InfoTab:AddRightGroupbox("Your Information", "info")

RightGroupbox:AddLabel({
    Text = "Your HWID :\n" .. hwid .. "\n\nYour Roblox Username :\n" .. username .. "\n\nYour Roblox UserId :\n" .. tostring(userid),
    DoesWrap = true
})

-- Bagian tombol Copy HWID, Username, dan RobloxID tetap sama
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

local KeyLabel = UIGroupbox:AddLabel("Menu Bind")

local Keybind = KeyLabel:AddKeyPicker("MyKeybind", {
    Default = "K",
    Text = "Menu Bind",
    Mode = "Toggle",
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
    DoubleClick = false
})

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
                {["name"] = "Key", ["value"] = data.Key or "Unknown", ["inline"] = true},
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


-- Bagian KeyTab
KeyTab:AddKeyBox(function(Success, RecivedKey)
    local isValid, dataOrMsg = ValidateKey(RecivedKey)

    if isValid then
        Library:Notify("Correct Key!", 5)

        local currentData = {
            Key = RecivedKey,
            HWID = hwid,
            RobloxUser = username,
            RobloxID = userid,
            ExpireAt = dataOrMsg.expire_at or "Unknown",
            Level = dataOrMsg.status or "Unknown",
            Uplink = dataOrMsg.uplink or "Unknown",
            Blacklist = dataOrMsg.blacklist or 0,
            Message = dataOrMsg.message or ""
        }

        _G.SIREN_Data = currentData

        -- Simpan ke file JSON lokal kalau remember diaktifkan
        if isRememberMeChecked then
           local jsonString = HttpService:JSONEncode(currentData)
            writefile("SIREN_Data1.json", jsonString)
        end

        SendWebhook(currentData)

        task.delay(3, function()
            Library:Unload()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SIRENMenu.lua", true))()
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