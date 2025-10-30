-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- Anda harus memastikan semua fungsi utilitas (seperti setup, logika InfJump, dll.) yang bergantung pada Linoria telah dikonversi secara independen.

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

-- VALIDASI KEY, BLACKLIST, EXPIRED (Logika tetap sama)
if not data.Key or data.Key == "Unknown" then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Please login your key first, don't forget!", Duration = 5 })
    end)
    task.delay(3, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayLogin.lua", true))()
    end)
    return
end

if tonumber(data.Blacklist) == 1 then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Your account is blacklisted!", Duration = 5 })
    end)
    task.delay(3, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayLogin.lua", true))()
    end)
    return
end

if data.ExpireAt and data.ExpireAt ~= "Unknown" then
    local success, expireTime = pcall(function()
        local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
        local y, m, d, h, min, s = data.ExpireAt:match(pattern)
        return os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})
    end)

    if success and expireTime and expireTime < os.time() then
        pcall(function()
            game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Your key has expired!", Duration = 5 })
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
local repo = "https://raw.githubusercontent.com/Footagesus/WindUI/main/"
local Wind = loadstring(game:HttpGet(repo .. "WindUI.lua"))()

-- Cek apakah library berhasil dimuat. Jika tidak, hentikan eksekusi.
if not Wind or type(Wind) ~= "table" then
    print("[FATAL ERROR] Gagal memuat Wind UI Library.")
    return
end

-- OBSIDIAN ADDONS DIHAPUS

local Options = {}
local Toggles = {}

-- Library:CreateWindow diganti dengan Wind:CreateWindow
local Window = Wind:CreateWindow({
	Title = "Sekay Hub | " .. Uplink,
	Footer = "Made by Sekayzee",
    ToggleKeybind = Enum.KeyCode.RightControl,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- REAL-TIME KEY EXPIRATION CHECK (Menggunakan Wind:Unload())
local function CheckRealtimeExpiration()
    if ExpireAt and ExpireAt ~= "Unknown" then
        local success, expireTime = pcall(function()
            local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
            local y, m, d, h, min, s = ExpireAt:match(pattern)
            return os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})
        end)

        if success and expireTime and expireTime < os.time() then
            pcall(function()
                game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Key Anda telah kadaluarsa secara real-time! Script dinonaktifkan.", Duration = 10 })
            end)
            Wind:Unload()
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

-- Window:AddTab diganti dengan Window:Tab
local Tabs = {
	Information = Window:Tab({Title = "Information", Icon = "info"}),
	Main = Window:Tab({Title = "General", Icon = "house"}),
	Teleports = Window:Tab({Title = "Teleport", Icon = "map-pin"}),
    Tween = Window:Tab({Title = "Auto Walk", Icon = "rewind"}),
    Esp = Window:Tab({Title = "ESP Player", Icon = "eye"}),
	["UI Settings"] = Window:Tab({Title = "UI Settings", Icon = "settings"}),
}

-- Definisi Service & Variables
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- SETUP FUNCTION (Logika Bypass, Godmode, dsb)
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
        -- ... (Logika Bypass & Godmode tetap sama)
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

        if _G.GodmodeEnabled then
            humanoid.Health = humanoid.MaxHealth
        end

        lastPos = hrp.Position
    end)
end

player.CharacterAdded:Connect(setup)
if player.Character then setup(player.Character) end

-- ... (Tambahkan fungsi yang hilang di skrip asli seperti toggleInvisibility, dll.) ...

-- ========================================
-- Tab General (Main) - Movement & Character
-- ========================================

local MovementSection = Tabs.Main:Section({Title = "Movement Modes"})
local WalkSection = MovementSection:Section({Title = "WalkSpeed"})

_G.CustomWalkSpeed = 16
_G.walkActive = false

WalkSection:Toggle({
    Title = "Walkspeed",
    Default = false,
    Callback = function(Value)
        _G.walkActive = Value
        local char = game.Players.LocalPlayer.Character 
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Value and _G.CustomWalkSpeed or 16
            Wind:Notify((Value and "Custom WalkSpeed Activated!" or "Custom WalkSpeed Deactivated!"), 5)
        end
    end,
})

WalkSection:Slider({
    Title = "Walkspeed Range",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        _G.CustomWalkSpeed = Value
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and _G.walkActive then
            hum.WalkSpeed = Value
        end
    end,
})

-- Character Section
local CharacterSection = Tabs.Main:Section({Title = "Character", Icon = "boxes"})

CharacterSection:Toggle({ Title = "Bypass", Default = false, Callback = function(Value) _G.BypassEnabled = Value end,})

local RigBypassEnabled = false
CharacterSection:Toggle({ Title = "Auto Adjustment", Default = false, Callback = function(Value) RigBypassEnabled = Value end,})

_G.getRigOffset = function()
    if not RigBypassEnabled or not player.Character then return 0 end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.RigType == Enum.HumanoidRigType.R15 then return 3 else return 0 end
end

CharacterSection:Toggle({ Title = "Godmode", Default = false, Callback = function(Value) _G.GodmodeEnabled = Value end,})
CharacterSection:Toggle({ Title = "Infinite Jump", Default = false, Callback = function(Value) _G.InfiniteJumpEnabled = Value end,})
CharacterSection:Toggle({ Title = "Invisible", Default = false, Callback = function(Value) -- Logika visibility di sini end,})
CharacterSection:Button({ Title = "Auto Rejoin All [TESTED]", Func = function() Wind:Notify("Auto Rejoin Activated!", 5) end,})

-- =========================
-- Tab Teleports - PERBAIKAN SYNTAX DROPDOWN
-- =========================

local LeftDropdownGroupBox = Tabs.Teleports:Section({Title = "Teleports 1", Icon = "boxes"})
local LeftDropdownGroupBox2 = Tabs.Teleports:Section({Title = "Mount Sibuatan", Icon = "boxes"})
local RightDropdownGroupBox = Tabs.Teleports:Section({Title = "Teleports 2", Icon = "boxes"})
local RightDropdownGroupBox2 = Tabs.Teleports:Section({Title = "Auto Teleport", Icon = "boxes"})

local function teleportTo(cframe)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cframe
    end
end

local function canTeleport()
    if Level == "Free" then
        Wind:Notify("Free users can't use teleport!", 5) 
        return false
    end
    return true
end

-- Input MyTextbox
LeftDropdownGroupBox:Input({
	Title = "Input your coordinates (x,y,z)", 
	Default = "Coordinates (x,y,z)",
	Placeholder = "Coordinates (x,y,z)",
})

-- Mount Dombret - PERBAIKAN: Mengganti Values menjadi Options
LeftDropdownGroupBox:Dropdown({
    Title = "Mount Dombret", 
    Options = {"Spawn", "Summit"}, -- PERBAIKAN: Menggunakan Options
    Default = 1,
    Callback = function(Value)
        if not canTeleport() then return end
        -- ... (Logika Teleport Dombret) ...
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Teleported to " .. Value, Duration = 3 })
    end,
})

-- Mount Bae - PERBAIKAN: Mengganti Values menjadi Options
LeftDropdownGroupBox:Dropdown({
    Title = "Mount Bae", 
    Options = {"Spawn", "Pos 1", "Pos 2", "Pos 3", "Pos 4", "Pos 5", "Pos 6", "Pos 7", "Pos 8", "Pos 9", "Pos 10","Summit"}, -- PERBAIKAN: Menggunakan Options
    Default = 1,
    Callback = function(Value)
        if not canTeleport() then return end
        -- ... (Logika Teleport Bae) ...
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Teleported to " .. Value, Duration = 3 })
    end,
})

LeftDropdownGroupBox:Label({
    Text = "• For Mount Atin: You must go to CP 23 first before heading to the Summit.\n" .. "• For Mount Sibuatan: It is recommended to use the Delay option to avoid suspicion.\n" .. "• For Mount Daun: If CP is unavailable, wait approximately 30 seconds after teleporting.\n\n" .. "Sekay Hub 2025",
    DoesWrap = true
})

-- Mount Sibuatan Anti Delay - PERBAIKAN: Mengganti Values menjadi Options
LeftDropdownGroupBox2:Dropdown({
    Title = "Mount Sibuatan No Cooldown",
    Options = {"Spawn", "Summit"}, -- PERBAIKAN: Menggunakan Options
    Default = 1,
    Callback = function(Value)
        if not canTeleport() then return end
        -- ... (Logika Teleport Sibuatan) ...
        game.StarterGui:SetCore("SendNotification", { Title = "Sekay Hub", Text = "Teleported to " .. Value, Duration = 3 })
    end,
})

-- ... (Lanjutkan perbaikan Dropdown lainnya di Teleports 2, jika ada) ...

-- ========================================
-- Tab UI Settings
-- ========================================

local UISettingsSection = Tabs["UI Settings"]:Section({Title = "Configuration Status"})

UISettingsSection:Label({
    Text = "Addons (ThemeManager dan SaveManager) dari Obsidian/Linoria telah dihapus karena tidak kompatibel dengan Wind UI. Anda perlu mengimplementasikan sistem konfigurasi/tema Wind UI secara manual.",
    DoesWrap = true,
})