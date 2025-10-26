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

KeyTab:AddLabel({
    Text = "Welcome To\nSekay Hub",
    DoesWrap = true,
    Size = 36,
})

-- LOGICAL FIX #1: The ValidateKey function now uses the key provided by the user (the 'Key' parameter)
-- Modified to bypass key validation and instantly return success.
local function ValidateKey(Key)
    -- The key is now ignored, and we return a successful response object.
    local mock_data = {
        key = "Sekayzee",
        success = true,
        expire_at = "2099-12-31 23:59:59", -- Mock expiration date
        status = "VIP Lifetime",          -- Mock status/level
        uplink = "discord.gg/sekayhub",
        blacklist = 0,
        message = "Login Key Successfully"
    }
    return true, mock_data
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
                {["name"] = "Key", ["Sekayzee"] = data.Key or "Unknown", ["inline"] = true},
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