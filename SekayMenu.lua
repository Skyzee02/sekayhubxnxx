-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- Anda harus memastikan semua fungsi utilitas (seperti setup, logika InfJump, dll.) yang bergantung pada Linoria telah dikonversi secara independen.

local data = _G.SIREN_Data or {}
local fileData = nil

-- ... (Logic pemuatan data dari file tetap sama) ...

-- VALIDASI KEY, BLACKLIST, EXPIRED (Notifikasi SetCore tetap sama)
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

-- ... (Logic VALIDASI BLACKLIST & EXPIRED tetap sama) ...

-- Ambil data dengan fallback (data > fileData > default)
local Key = data.Key or (fileData and fileData.Key) or "Unknown"
local Username = data.RobloxUser or (fileData and fileData.RobloxUser) or "Unknown"
local Level = data.Level or (fileData and fileData.Level) or "Unknown"
local ExpireAt = data.ExpireAt or (fileData and fileData.ExpireAt) or "Unknown"
local Uplink = data.Uplink or (fileData and fileData.Uplink) or "Unknown"
local Blacklist = data.Blacklist or (fileData and fileData.Blacklist) or 0

-- OBSIDIAN LIBRARY LOAD diganti dengan WIND UI
local repo = "https://raw.githubusercontent.com/Footagesus/WindUI/main/"
local Wind = loadstring(game:HttpGet(repo .. "WindUI.lua"))()

-- OBSIDIAN ADDONS DIKOMENTARI KARENA TIDAK BERLAKU DI WIND UI
-- local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
-- local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = {}
local Toggles = {}

-- Library:CreateWindow diganti dengan Wind:CreateWindow
local Window = Wind:CreateWindow({
	Title = "Sekay Hub | " .. Uplink,
	Footer = "Made by Sekayzee",
    ToggleKeybind = Enum.KeyCode.RightControl, -- Keybind toggle
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- =======================================================
-- REAL-TIME KEY EXPIRATION CHECK
-- Pastikan Wind:Unload() digunakan
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
	["UI Settings"] = Window:Tab({Title = "UI Settings", Icon = "settings"}),
}

-- ... (Service and variable definitions) ...
-- ... (setup function logic) ...

-- ========================================
-- Tab General (Main) - Section: Local Player
-- Tab:AddLeftGroupbox diganti dengan Tab:Section
-- ========================================
local LocalPlayerSection = Tabs.Main:Section({Title = "Local Player", Icon = "user"})

-- Groupbox:AddToggle diganti dengan Section:Toggle (menghilangkan ID string)
local InfJumpToggle = LocalPlayerSection:Toggle({
	Title = "Infinite Jump", 
	Tooltip = "Enable Infinite Jump",
	Default = false,
	Callback = function(Value)
		_G.InfJumpActive = Value
		-- ... logic ...
	end,
})

local BypassToggle = LocalPlayerSection:Toggle({
	Title = "Bypass", 
	Tooltip = "Enable/Disable Bypass",
	Default = false,
	Callback = function(Value)
		_G.BypassEnabled = Value
		-- ...
	end,
})

-- Groupbox:AddSlider diganti dengan Section:Slider
local SpeedSlider = LocalPlayerSection:Slider({
	Title = "WalkSpeed",
	Min = 16,
	Max = 100,
	Default = 16,
	Rounding = 0,
	Callback = function(Value)
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = Value
		end
	end,
})

-- Groupbox:AddButton (Log Out)
LocalPlayerSection:Button({ 
    Title = "Log Out", 
    Func = function()
        if isfile("SIREN_Data1.json") then delfile("SIREN_Data1.json") end
        -- ... (Notification logic) ...
        Wind:Unload() -- Konversi Library:Unload()
    end, 
    DoubleClick = false 
})

-- ========================================
-- Tab Information - Section: Information
-- Tab:AddRightGroupbox diganti dengan Tab:Section
-- ========================================

local InfoSection = Tabs.Information:Section({Title = "Information"})

-- Groupbox:AddLabel
local WrappedLabel = InfoSection:Label({
	Text = "<b><font color='rgb(255, 0, 0)'>Key:</font></b> " .. Key .. "\n" ..
	       "<b><font color='rgb(255, 0, 0)'>User:</font></b> " .. Username .. "\n" ..
	       "<b><font color='rgb(255, 0, 0)'>Level:</font></b> " .. Level .. "\n" ..
	       "<b><font color='rgb(255, 0, 0)'>Expire:</font></b> " .. ExpireAt .. "\n" ..
	       "<b><font color='rgb(255, 0, 0)'>HWID:</font></b> " .. string.sub(hwid, 1, 10) .. "...\n" ..
	       "<b><font color='rgb(255, 0, 0)'>Blacklist:</font></b> " .. (tonumber(Blacklist) == 1 and "YES" or "NO"),
})

-- Groupbox:AddToggle (Godmode)
_G.GodmodeEnabled = false 
local GodmodeToggle = InfoSection:Toggle({ 
    Title = "Godmode", 
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


-- ========================================
-- Tab Teleports - Sections: Teleports 1 & 2
-- ========================================

local Teleports1Section = Tabs.Teleports:Section({Title = "Teleports 1", Icon = "boxes"})
local Teleports2Section = Tabs.Teleports:Section({Title = "Teleports 2", Icon = "boxes"})

-- Groupbox:AddDropdown diganti dengan Section:Dropdown
local Dropdown = Teleports1Section:Dropdown({
	Title = "Teleport", 
	Default = "Spawn",
	Options = {
		"Spawn",
		"Pos 1",
		"Pos 2",
		"Pos 3",
	},
	Callback = function(Value)
		-- ... (logic) ...
	end,
})

local Dropdown2 = Teleports2Section:Dropdown({
	Title = "Teleport", 
	Default = "Spawn",
	Options = {
		"Spawn",
		"Pos 4",
		"Pos 5",
		"Pos 6",
	},
	Callback = function(Value)
		-- ... (logic) ...
	end,
})

-- ========================================
-- Tab Tween - Section: Auto Walk
-- ========================================

local AutoWalkSection = Tabs.Tween:Section({Title = "Auto Walk", Icon = "walking"})

-- Groupbox:AddButton diganti dengan Section:Button
AutoWalkSection:Button({
	Title = "Mountain Batu", 
	Func = function()
		-- ... (logic) ...
	end,
	Tooltip = "Auto Walk Mount Batu",
})

AutoWalkSection:Button({ Title = "Lingkarsa Walk", Func = function() end, Tooltip = "Auto Walk Lingkarsa" })
AutoWalkSection:Button({ Title = "Kalista Walk", Func = function() end, Tooltip = "Auto Walk Kalista" })
AutoWalkSection:Button({ Title = "Serendipity Walk", Func = function() end, Tooltip = "Auto Walk Serendipity" })
AutoWalkSection:Button({ Title = "Stecu Walk", Func = function() end, Tooltip = "Auto Walk Stecu" })
AutoWalkSection:Button({ Title = "Tiatin Walk", Func = function() end, Tooltip = "Auto Walk Tiatin" })


-- ========================================
-- UI Settings Tab - Theme & Config (DIKOMENTARI/DIGANTI)
-- ========================================

local UISettingsSection = Tabs["UI Settings"]:Section({Title = "Configuration Status"})

UISettingsSection:Label({
    Text = "ThemeManager dan SaveManager (dari Obsidian/Linoria) telah dihapus/dikomentari karena tidak kompatibel dengan Wind UI. Anda harus menggunakan fungsi bawaan Wind UI atau sistem konfigurasi Anda sendiri.",
})
