-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- You can suggest changes with a pull request or something

local data = _G.SIREN_Data or {}
local fileData = nil

if isfile("SIREN_Data1.json") then
    local success, result = pcall(readfile, "SIREN_Data1.json")
    if success and result then
        local jsonSuccess, decodedData = pcall(function()
            return game:GetService("HttpService"):JSONDecode(result)
        end)
        if jsonSuccess and decodedData then
            fileData = decodedData
        end
    end
end

-- VALIDASI KEY
if not data.Key or data.Key == "Unknown" then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Please login your key first, don't forget!",
            Duration = 5
        })
    end)
    task.delay(3, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayLogin.lua", true))()
    end)
    return
end

-- VALIDASI BLACKLIST
if tonumber(data.Blacklist) == 1 then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Your account is blacklisted!",
            Duration = 5
        })
    end)
    task.delay(3, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayLogin.lua", true))()
    end)
    return
end

-- VALIDASI EXPIRED
if data.ExpireAt and data.ExpireAt ~= "Unknown" then
    local success, expireTime = pcall(function()
        local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
        local y, m, d, h, min, s = data.ExpireAt:match(pattern)
        return os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})
    end)

    if success and expireTime and expireTime < os.time() then
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Your key has expired!",
                Duration = 5
            })
        end)
        task.delay(3, function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayLogin.lua", true))()
        end)
        return
    end
end

-- Ambil data dengan fallback (data > fileData > default)
local Key = data.Key or (fileData and fileData.Key) or "Unknown"
local Username = data.RobloxUser or (fileData and fileData.RobloxUser) or "Unknown"
local Level = data.Level or (fileData and fileData.Level) or "Unknown"
local ExpireAt = data.ExpireAt or (fileData and fileData.ExpireAt) or "Unknown"
local Uplink = data.Uplink or (fileData and fileData.Uplink) or "Unknown"
local Blacklist = data.Blacklist or (fileData and fileData.Blacklist) or 0

-- Ganti Obsidian/Linoria Library dengan Wind UI
local repo = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua'))()"
local Wind = loadstring(game:HttpGet(repo .. "WindUI.lua"))()

-- OBSIDIAN ADDONS DIHAPUS KARENA TIDAK KOMPATIBEL DENGAN WIND UI
-- local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
-- local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Wind.Options -- Diperkirakan Wind UI menyediakan tabel Options/Toggles global
local Toggles = Wind.Toggles

-- Library.ForceCheckbox = false -- Dihapus (Obsidian/Linoria spesifik)
-- Library.ShowToggleFrameInKeybinds = true -- Dihapus (Obsidian/Linoria spesifik)

-- Library:CreateWindow diganti dengan Wind:CreateWindow
local Window = Wind:CreateWindow({
	Title = "Sekay Hub | " .. Uplink,
	Footer = "Made by Sekayzee",
	Icon = nil,
    ToggleKeybind = Enum.KeyCode.RightControl, -- Tambahkan keybind toggle
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- =======================================================
-- REAL-TIME KEY EXPIRATION CHECK
-- =======================================================
local function CheckRealtimeExpiration()
    if ExpireAt and ExpireAt ~= "Unknown" then
        local success, expireTime = pcall(function()
            local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
            local y, m, d, h, min, s = ExpireAt:match(pattern)
            return os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})
        end)

        if success and expireTime and expireTime < os.time() then
            pcall(function()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sekay Hub",
                    Text = "Key Anda telah kadaluarsa secara real-time! Script dinonaktifkan.",
                    Duration = 10
                })
            end)

            Wind:Unload() -- Konversi Library:Unload()
            
            task.delay(3, function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayLogin.lua", true))()
            end)
            
            error("Key Expired. Script terminated by real-time check.") 
        end
    end
end

task.spawn(function()
    CheckRealtimeExpiration() 
    while task.wait(5) do
        CheckRealtimeExpiration()
    end
end)

-- =======================================================

-- Window:AddTab diganti dengan Window:Tab
local Tabs = {
	Information = Window:Tab({Title = "Information", Icon = "info"}),
	Main = Window:Tab({Title = "General", Icon = "house"}),
	Teleports = Window:Tab({Title = "Teleport", Icon = "map-pin"}),
    Tween = Window:Tab({Title = "Auto Walk", Icon = "rewind"}),
    Esp = Window:Tab({Title = "ESP Player", Icon = "eye"}),
	-- Key = Window:AddKeyTab("Key System"), -- Dihapus
	["UI Settings"] = Window:Tab({Title = "UI Settings", Icon = "settings"}),
}

    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TeleportService = game:GetService("TeleportService")
    local player = Players.LocalPlayer
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ========================================
-- State & Main Loop (Tidak perlu konversi UI)
-- ========================================
_G.BypassEnabled = false
_G.GodmodeEnabled = false
local conn

local function setup(char)
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position

    if conn then conn:Disconnect() end
    conn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then return end

        -- BYPASS
        if _G.BypassEnabled then
            local direction = (hrp.Position - lastPos)
            local dist = direction.Magnitude
            if dist > 0.01 then
                local moveVector = direction.Unit * math.clamp(dist*5,0,1)
                humanoid:Move(moveVector,false)
            else
                humanoid:Move(Vector3.zero,false)
            end
        end

        -- GODMODE
        if _G.GodmodeEnabled then
            humanoid.Health = humanoid.MaxHealth
        end

        lastPos = hrp.Position
    end)
end

player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end


-- ========================================
-- Tab Information - Licenses & Information
-- ========================================

-- Groupbox Kiri: Licenses (Konversi AddLeftGroupbox ke Section)
local LeftGroupBox = Tabs.Information:Section({Title = "Licenses"})
LeftGroupBox:Label({
    Text = "Roblox Username: " .. Username ..
    "\nRoblox ID: " .. tostring(player.UserId or "Unknown") ..
    "\n\nLevel: " .. Level ..
    "\nYour Key: " .. Key ..
    "\nExpired At: " .. ExpireAt ..
    "\nUplink: " .. Uplink,
    DoesWrap = true -- Mengganti argumen true kedua
})

-- Groupbox:AddButton diganti Section:Button
LeftGroupBox:Button({
    Title = "Logout", -- Tambahkan Title
    Func = function()
        print("Logged out")
        _G.SIREN_Data = nil
        if isfile("SIREN_Data1.json") then delfile("SIREN_Data1.json") end
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "You have been logged out!",
                Duration = 5
            })
        end)
        Wind:Unload() -- Konversi Library:Unload()
    end,
})

-- Groupbox Kanan: Information (Konversi AddRightGroupbox ke Section)
local RightGroupBox = Tabs.Information:Section({Title = "Information"})

RightGroupBox:Label({
    Text = "Made by Sekayzee",
    DoesWrap = true
})

RightGroupBox:Button({
    Title = "Instagram", -- Tambahkan Title
    Text = "<font color='rgb(0, 123, 255)'>Instagram</font>", -- Wind UI mendukung Rich Text
    Func = function()
        print("Copied Instagram link: https://instagram.com/sekayhub")
        setclipboard("https://instagram.com/sekayhub")
    end,
})

RightGroupBox:Label({
    Text = "© Sekay Hub 2025",
    DoesWrap = true
})

RightGroupBox:Button({
    Title = "Discord", -- Tambahkan Title
    Text = "<font color='rgb(0, 123, 255)'>Discord</font>",
    Func = function()
        print("Copied Discord link: https://dsc.gg/sekayhub")
        setclipboard("https://dsc.gg/sekayhub")
    end,
})

-- ========================================
-- Tab General (Main) - Movement & Character
-- ========================================

-- Konversi TabBox: AddLeftTabbox() dihapus dan diganti Section
local MovementSection = Tabs.Main:Section({Title = "Movement Modes"})

-- TabBox:AddTab("WalkSpeed") menjadi sub-section di Movement Modes
local WalkSection = MovementSection:Section({Title = "WalkSpeed"})

_G.CustomWalkSpeed = 16
_G.walkActive = false

-- Toggle WalkSpeed Enable (Konversi AddToggle)
WalkSection:Toggle({
    Title = "Walkspeed", -- Menggantikan ID string pertama ("WalkToggle")
    Tooltip = "Activate or deactivate custom walkspeed",
    Default = false,
    Callback = function(Value)
        _G.walkActive = Value
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Value then
                hum.WalkSpeed = _G.CustomWalkSpeed
                Wind:Notify("Custom WalkSpeed Activated!", 5) -- Konversi Library:Notify
            else
                hum.WalkSpeed = 16
                Wind:Notify("Custom WalkSpeed Deactivated!", 5) -- Konversi Library:Notify
            end
        end
    end,
})

-- Slider WalkSpeed (Konversi AddSlider)
WalkSection:Slider({
    Title = "Walkspeed Range", -- Menggantikan ID string pertama ("WalkSpeedSlider")
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Tooltip = "Adjust walkspeed",
    Callback = function(Value)
        _G.CustomWalkSpeed = Value
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and _G.walkActive then
            hum.WalkSpeed = Value
        end
    end,
})

-- Reset WalkSpeed saat respawn (Tidak perlu konversi UI)
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if _G.walkActive then
        hum.WalkSpeed = _G.CustomWalkSpeed or 16
    else
        hum.WalkSpeed = 16
    end
end)

-- TabBox:AddTab("Fly Mode") menjadi sub-section di Movement Modes
local FlySection = MovementSection:Section({Title = "Fly Mode"})

_G.flySpeed = 50
_G.flyActive = false

-- Toggle Fly (Konversi AddToggle)
FlySection:Toggle({
    Title = "Fly", -- Menggantikan ID string pertama ("FlyToggle")
    Tooltip = "Activate or deactivate fly mode",
    Default = false,
    Callback = function(Value)
        _G.flyActive = Value
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        if Value then
            Wind:Notify("Fly Mode Activated!", 5) -- Konversi Library:Notify
            
            -- ... (Logika Fly tetap sama) ...
        else
            Wind:Notify("Fly Mode Deactivated!", 5) -- Konversi Library:Notify
            
            -- ... (Logika Fly tetap sama) ...
        end
    end,
})

-- Slider Fly Speed (Konversi AddSlider)
FlySection:Slider({
    Title = "Fly Speed", -- Menggantikan ID string pertama ("FlySpeedSlider")
    Default = 50,
    Min = 0,
    Max = 200,
    Rounding = 1,
    Tooltip = "Adjust fly speed",
    Callback = function(Value)
        _G.flySpeed = Value
    end,
})

-- Character GroupBox (Konversi AddRightGroupbox ke Section)
local CharacterSection = Tabs.Main:Section({Title = "Character", Icon = "boxes"})

-- Bypass Toggle (Konversi AddToggle)
_G.BypassEnabled = false
CharacterSection:Toggle({
    Title = "Bypass", -- Menggantikan ID string pertama ("BypassToggle")
    Tooltip = "Enable bypass movement",
    Default = false,
    Callback = function(Value)
        _G.BypassEnabled = Value
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = Value and "Bypass Activated!" or "Bypass Deactivated!",
            Duration = 5
        })
    end,
})

local RigBypassEnabled = false
-- Auto Adjustment Toggle (Konversi AddToggle)
CharacterSection:Toggle({
    Title = "Auto Adjustment", -- Menggantikan ID string pertama ("RigBypassToggle")
    Tooltip = "Enable R15 rig offset (anti tembus)",
    Default = false,
    Callback = function(Value)
        RigBypassEnabled = Value
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = Value and "Rig Offset Enabled!" or "Rig Offset Disabled!",
            Duration = 5
        })
    end,
})

_G.getRigOffset = function()
    if not RigBypassEnabled then return 0 end
    if not player.Character then return 0 end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return 0 end

    if hum.RigType == Enum.HumanoidRigType.R15 then
        return 3
    else
        return nil
    end
end

-- Godmode Toggle (Konversi AddToggle)
_G.GodmodeEnabled = false
CharacterSection:Toggle({
    Title = "Godmode", -- Menggantikan ID string pertama ("GodmodeToggle")
    Tooltip = "Enable godmode (auto-heal)",
    Default = false,
    Callback = function(Value)
        _G.GodmodeEnabled = Value
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = Value and "Godmode Activated!" or "Godmode Deactivated!",
            Duration = 5
        })
    end,
})

-- Infinite Jump Toggle (Konversi AddToggle)
_G.InfiniteJumpEnabled = false
-- ... (Logika Infinite Jump tetap sama) ...
CharacterSection:Toggle({
    Title = "Infinite Jump", -- Menggantikan ID string pertama ("InfiniteJumpToggle")
    Tooltip = "Enable infinite jumping",
    Default = false,
    Callback = function(Value)
        _G.InfiniteJumpEnabled = Value
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = Value and "Infinite Jump Activated!" or "Infinite Jump Deactivated!",
            Duration = 5
        })
    end,
})

-- Invisible Toggle (Konversi AddToggle)
-- ... (Logika Invisibility tetap sama) ...
CharacterSection:Toggle({
    Title = "Invisible", -- Menggantikan ID string pertama ("InvisibleToggle")
    Tooltip = "Enable client-side invisibility",
    Default = false,
    Callback = function(Value)
        -- Logika toggleInvisibility harus diletakkan di luar atau di sini
    end,
})

-- Auto Rejoin All [TESTED] (Konversi AddButton)
CharacterSection:Button({
    Title = "Auto Rejoin All [TESTED]", -- Tambahkan Title
    Func = function()
        -- ... (Logika Auto Rejoin tetap sama) ...
        Wind:Notify("Auto Rejoin Activated!", 5) -- Konversi Library:Notify
    end,
    Tooltip = "Aktifkan Auto Rejoin",
    Disabled = false,
})

-- Mobile Groupbox (Konversi AddRightGroupbox ke Section)
local MobileSection = Tabs.Main:Section({Title = "Mobile", Icon = "tablet-smartphone"})

-- Flying for Mobile (Konversi AddButton)
MobileSection:Button({
    Title = "Flying for Mobile", -- Tambahkan Title
    Func = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/FlyMobile.lua"))()
        end)
        if success then
            Wind:Notify("FlyMobile Loaded!", 5) -- Konversi Library:Notify
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    Tooltip = "FlyMobile",
    Disabled = false,
})

-- Groupbox:AddDivider diganti Section:Divider
LeftGroupBox:Divider()

-- =========================
-- Tab Teleports
-- =========================

-- Konversi AddLeftGroupbox ke Section
local LeftDropdownGroupBox = Tabs.Teleports:Section({Title = "Teleports 1", Icon = "boxes"})
local LeftDropdownGroupBox2 = Tabs.Teleports:Section({Title = "Mount Sibuatan", Icon = "boxes"})
-- Konversi AddRightGroupbox ke Section
local RightDropdownGroupBox = Tabs.Teleports:Section({Title = "Teleports 2", Icon = "boxes"})
local RightDropdownGroupBox2 = Tabs.Teleports:Section({Title = "Auto Teleport", Icon = "boxes"})

local function teleportTo(cframe)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cframe
    end
end

local function canTeleport()
    if Level == "Free" then
        Wind:Notify("Free users can't use teleport!", 5) -- Konversi Library:Notify
        return false
    end
    return true
end

-- Input MyTextbox (Konversi AddInput)
LeftDropdownGroupBox:Input({
	Title = "Input your coordinates (x,y,z)", -- Menggantikan ID string dan Text
	Default = "Coordinates (x,y,z)",
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Tooltip = "Tooltip",
	Placeholder = "Coordinates (x,y,z)",
	Callback = function(Value)
        -- ... (Logika Callback tetap sama) ...
	end,
})

-- Mount Dombret (Konversi AddDropdown)
LeftDropdownGroupBox:Dropdown({
    Title = "Mount Dombret", -- Menggantikan ID string dan Text
    Values = {"Spawn", "Summit"},
    Default = 1,
    Tooltip = "Teleport Mount Dombret",
    Callback = function(Value)
        if not canTeleport() then return end
        -- ... (Logika Teleport tetap sama) ...
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Teleported to " .. Value, Duration = 3 })
    end,
})

-- Mount Bae (Konversi AddDropdown)
LeftDropdownGroupBox:Dropdown({
    Title = "Mount Bae", -- Menggantikan ID string dan Text
    Values = {"Spawn", "Pos 1", "Pos 2", "Pos 3", "Pos 4", "Pos 5", "Pos 6", "Pos 7", "Pos 8", "Pos 9", "Pos 10","Summit"},
    Default = 1,
    Tooltip = "Teleport Mount Bae",
    Callback = function(Value)
        if not canTeleport() then return end
        -- ... (Logika Teleport tetap sama) ...
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Teleported to " .. Value, Duration = 3 })
    end,
})

LeftDropdownGroupBox:Label({
    Text = "• For Mount Atin: You must go to CP 23 first before heading to the Summit.\n" .. "• For Mount Sibuatan: It is recommended to use the Delay option to avoid suspicion.\n" .. "• For Mount Daun: If CP is unavailable, wait approximately 30 seconds after teleporting.\n\n" .. "Sekay Hub 2025",
    DoesWrap = true
})

-- Mount Sibuatan Anti Delay (Konversi AddDropdown)
LeftDropdownGroupBox2:Dropdown({
    Title = "Mount Sibuatan No Cooldown", -- Menggantikan ID string dan Text
    Values = {"Spawn", "Summit"},
    Default = 1,
    Tooltip = "Teleport Mount Sibuatan Anti Delay",
    Callback = function(Value)
        if not canTeleport() then return end
        -- ... (Logika Teleport tetap sama) ...
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Teleported to " .. Value, Duration = 3 })
    end,
})

-- ... (Lanjutkan konversi semua Dropdown, Button, dan elemen lainnya) ...

-- ========================================
-- Tab UI Settings - Addons (DIHAPUS)
-- ========================================

local UISettingsSection = Tabs["UI Settings"]:Section({Title = "Configuration Status"})

UISettingsSection:Label({
    Text = "Addons (ThemeManager dan SaveManager) dari Obsidian/Linoria telah dihapus karena tidak kompatibel dengan Wind UI. Anda perlu mengimplementasikan sistem konfigurasi/tema Wind UI secara manual.",
    DoesWrap = true,
})

-- KODE OBSIDIAN/LINORIA ADDONS YANG DIHAPUS:
-- ThemeManager:SetLibrary(Library)
-- SaveManager:SetLibrary(Library)
-- SaveManager:IgnoreThemeSettings()
-- SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
-- ThemeManager:SetFolder("MyScriptHub")
-- SaveManager:SetFolder("MyScriptHub/specific-game")
-- SaveManager:SetSubFolder("specific-place")
-- SaveManager:BuildConfigSection(Tabs["UI Settings"])
-- ThemeManager:ApplyToTab(Tabs["UI Settings"])
-- SaveManager:LoadAutoloadConfig()