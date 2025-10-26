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
        loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SIRENLogin.lua", true))()
    end)
    return
end

-- VALIDASI EXPIRED
if data.ExpireAt and data.ExpireAt ~= "Unknown" then
    local success, expireTime = pcall(function()
        -- ubah format tanggal dari PHP (contoh: "2025-09-25 02:00:00") jadi os.time()
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
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SIRENLogin.lua", true))()
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

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

local Window = Library:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Set Resizable to true if you want to have in-game resizable Window
	-- Set MobileButtonsSide to "Left" or "Right" if you want the ui toggle & lock buttons to be on the left or right side of the window
	-- Set ShowCustomCursor to false if you don't want to use the Linoria cursor
	-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)

	Title = "SIREN HUB | " .. Uplink,
	Footer = "Made by Sekayzee",
	Icon = nil,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
-- You can find more icons in https://lucide.dev/
local Tabs = {
	-- Creates a new tab titled Main
	Information = Window:AddTab("Information", "info"),
	Main = Window:AddTab("General", "house"),
	Teleports = Window:AddTab("Teleport", "map-pin"),
    Tween = Window:AddTab("Auto Walk", "rewind"),
    Aimbot = Window:AddTab("ESP & Aimbot", "crosshair"),
	-- Key = Window:AddKeyTab("Key System"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
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
-- State
-- ========================================
_G.BypassEnabled = false
_G.GodmodeEnabled = false
local conn

-- ========================================
-- Main Loop
-- ========================================
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


--[[
Example of how to add a warning box to a tab; the title AND text support rich text formatting.

local WarningTab = Tabs["UI Settings"]:AddTab("Warning Box", "user")

WarningTab:UpdateWarningBox({
	Visible = true,
	Title = "Warning",
	Text = "This is a warning box!",
})

]]

-- Groupbox Kiri: License Info
-- Tampilkan informasi
local LeftGroupBox = Tabs.Information:AddLeftGroupbox("Licenses")
LeftGroupBox:AddLabel(
    "Roblox Username: " .. Username ..
    "\nRoblox ID: " .. tostring(player.UserId or "Unknown") ..
    "\n\nLevel: " .. Level ..
    "\nYour Key: " .. Key ..
    "\nExpired At: " .. ExpireAt ..
    "\nUplink: " .. Uplink,
    true
)

local Button = LeftGroupBox:AddButton({
    Text = "Logout",
    Func = function()
        print("Logged out")

        -- Hapus semua data session
        _G.SIREN_Data = nil
        if isfile("SIREN_Data1.json") then
            delfile("SIREN_Data1.json")
        end

        -- Notifikasi
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "You have been logged out!",
                Duration = 5
            })
        end)

        -- Unload menu
        Library:Unload()
    end,
    DoubleClick = false
})




local RightGroupBox = Tabs.Information:AddRightGroupbox("Information")

local WrappedLabel = RightGroupBox:AddLabel({
    Text = "Made by Sekayzee",
    DoesWrap = true
})

local Button = RightGroupBox:AddButton({
    Text = "<font color='rgb(0, 123, 255)'>Instagram</font>",
    Func = function()
        print("Copied Instagram link: https://instagram.com/sekayhub")
        setclipboard("https://instagram.com/sekayhub") -- optional, automatically copies the link
    end,
    DoubleClick = false
})

local WrappedLabel = RightGroupBox:AddLabel({
    Text = "© Sekay Hub 2025",
    DoesWrap = true
})

local Button = RightGroupBox:AddButton({
    Text = "<font color='rgb(0, 123, 255)'>Discord</font>",
    Func = function()
        print("Copied Discord link: https://dsc.gg/sekayhub")
        setclipboard("https://dsc.gg/sekayhub") -- optional, automatically copies the link
    end,
    DoubleClick = false
})



-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(Name))
local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on right side

-- ===============================
-- Tab 1: WalkSpeed
-- ===============================
local WalkTab = TabBox:AddTab("WalkSpeed")

-- Default WalkSpeed
_G.CustomWalkSpeed = 16
_G.walkActive = false

-- Toggle WalkSpeed Enable
WalkTab:AddToggle("WalkToggle", {
    Text = "Walkspeed",
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
                Library:Notify("Custom WalkSpeed Activated!", 5)
            else
                hum.WalkSpeed = 16
                Library:Notify("Custom WalkSpeed Deactivated!", 5)
            end
        end
    end,
})

-- Slider WalkSpeed
WalkTab:AddSlider("WalkSpeedSlider", {
    Text = "Walkspeed Range",
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

-- Reset WalkSpeed saat respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if _G.walkActive then
        hum.WalkSpeed = _G.CustomWalkSpeed or 16
    else
        hum.WalkSpeed = 16
    end
end)

-- ===============================
-- Tab 2: Fly Mode
-- ===============================
local FlyTab = TabBox:AddTab("Fly Mode")

_G.flySpeed = 50
_G.flyActive = false

-- Toggle Fly
FlyTab:AddToggle("FlyToggle", {
    Text = "Fly",
    Tooltip = "Activate or deactivate fly mode",
    Default = false,
    Callback = function(Value)
        _G.flyActive = Value
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        if Value then
            Library:Notify("Fly Mode Activated!", 5)

            local BodyGyro = Instance.new("BodyGyro")
            local BodyVel = Instance.new("BodyVelocity")

            BodyGyro.P = 9e4
            BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.CFrame = root.CFrame
            BodyGyro.Parent = root

            BodyVel.Velocity = Vector3.new(0, 0, 0)
            BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVel.Parent = root

            _G.flyLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not _G.flyActive then return end
                local camera = workspace.CurrentCamera
                local control = Vector3.new()

                if game.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    control = control + camera.CFrame.LookVector
                end
                if game.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    control = control - camera.CFrame.LookVector
                end
                if game.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    control = control - camera.CFrame.RightVector
                end
                if game.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    control = control + camera.CFrame.RightVector
                end
                if game.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    control = control + camera.CFrame.UpVector
                end
                if game.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    control = control - camera.CFrame.UpVector
                end

                BodyVel.Velocity = control * _G.flySpeed
                BodyGyro.CFrame = camera.CFrame
            end)
        else
            Library:Notify("Fly Mode Deactivated!", 5)

            if _G.flyLoop then
                _G.flyLoop:Disconnect()
                _G.flyLoop = nil
            end

            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end,
})

-- Slider Fly Speed
FlyTab:AddSlider("FlySpeedSlider", {
    Text = "Fly Speed",
    Default = 50,
    Min = 0,
    Max = 200,
    Rounding = 1,
    Tooltip = "Adjust fly speed",
    Callback = function(Value)
        _G.flySpeed = Value
    end,
})

local RightGroupBox = Tabs.Main:AddRightGroupbox("Character", "boxes")

-- ========================================
-- Bypass Toggle
-- ========================================
_G.BypassEnabled = false

local BypassToggle = RightGroupBox:AddToggle("BypassToggle", {
    Text = "Bypass",
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

local RigBypassEnabled = false -- khusus untuk toggle ini

-- toggle baru
local RigBypassToggle = RightGroupBox:AddToggle("RigBypassToggle", {
    Text = "Auto Adjustment",
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

-- fungsi offset, dipakai di file lain
_G.getRigOffset = function()
    if not RigBypassEnabled then
        return 0 -- toggle OFF, jangan kasih offset
    end

    if not player.Character then return 0 end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return 0 end

    if hum.RigType == Enum.HumanoidRigType.R15 then
        return 3 -- kalau R15, kasih offset
    else
        return nil -- R6 biar ditangani di lerpCF
    end
end

-- ========================================
-- Godmode Toggle
-- ========================================
_G.GodmodeEnabled = false

local GodmodeToggle = RightGroupBox:AddToggle("GodmodeToggle", {
    Text = "Godmode",
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
-- Infinite Jump Toggle
-- ========================================
_G.InfiniteJumpEnabled = false
if not _G.InfiniteJumpConnection then
    local UserInputService = game:GetService("UserInputService")
    _G.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if _G.InfiniteJumpEnabled then
            local plr = game.Players.LocalPlayer
            local char = plr.Character or plr.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local InfiniteJumpToggle = RightGroupBox:AddToggle("InfiniteJumpToggle", {
    Text = "Infinite Jump",
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

-- ========================================
-- Invisible Toggle
-- ========================================
local function setTransparency(character, transparency)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = transparency
        end
    end
end

local function toggleInvisibility(on)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    if not char then return end

    if on then
        local savedpos = char.HumanoidRootPart.CFrame
        char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
        task.wait(0.15)

        local Seat = Instance.new("Seat", workspace)
        Seat.Anchored = false
        Seat.CanCollide = false
        Seat.Name = "invischair"
        Seat.Transparency = 1
        Seat.Position = Vector3.new(-25.95, 84, 3537.55)

        local weld = Instance.new("Weld", Seat)
        weld.Part0 = Seat
        weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

        task.wait()
        Seat.CFrame = savedpos

        setTransparency(char, 0.5)
        Library:Notify("Invisibility Activated!", 5)
    else
        local invisChair = workspace:FindFirstChild("invischair")
        if invisChair then invisChair:Destroy() end
        setTransparency(char, 0)
        Library:Notify("Invisibility Activated!", 5)
    end
end

local InvisibleToggle = RightGroupBox:AddToggle("InvisibleToggle", {
    Text = "Invisible",
    Tooltip = "Enable client-side invisibility",
    Default = false,
    Callback = function(Value)
        toggleInvisibility(Value)
    end,
})

local AutoRejoin = RightGroupBox:AddButton({
    Text = "Auto Rejoin All [TESTED]",
    Func = function()
        local success, err = pcall(function()
            local PlaceId = game.PlaceId
            local JobId = game.JobId
            local PrivateId = game.PrivateServerId

            -- Jika private server tersedia, langsung teleport pakai Teleport biasa
            if PrivateId and PrivateId ~= "" then
                local ok, e = pcall(function()
                    TeleportService:Teleport(PlaceId, player)
                end)
                if not ok then
                    warn("[AutoRejoin] Teleport Private gagal:", e)
                end
                return
            end

            -- Jika sendirian di server -> kick lalu teleport ke Place (rejoin)
            if #Players:GetPlayers() <= 1 then
                pcall(function() player:Kick("\nRejoining...") end)
                task.wait(1)
                local ok2, e2 = pcall(function()
                    TeleportService:Teleport(PlaceId, player)
                end)
                if not ok2 then
                    warn("[AutoRejoin] Teleport ke Place gagal:", e2)
                end
                return
            end

            -- Jika server ramai -> coba teleport ke instance yang sama (JobId)
            local ok3, e3 = pcall(function()
                -- beberapa lingkungan menerima player langsung; jika perlu, ubah jadi {player}
                TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
            end)
            if not ok3 then
                warn("[AutoRejoin] TeleportToPlaceInstance gagal:", e3)
                -- fallback ke public place
                local ok4, e4 = pcall(function()
                    TeleportService:Teleport(PlaceId, player)
                end)
                if not ok4 then
                    warn("[AutoRejoin] Fallback Teleport gagal:", e4)
                end
            end
        end)

        if not success then
            warn("[Sekay Hub] Gagal aktifkan Auto Rejoin:", err)
        else
            Library:Notify("Auto Rejoin Activated!", 5)
        end
    end,
    DoubleClick = false,
    Tooltip = "Aktifkan Auto Rejoin",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

local Right2 = Tabs.Main:AddRightGroupbox("Mobile", "tablet-smartphone")

local FlyMobile = Right2:AddButton({
    Text = "Flying for Mobile",
    Func = function()

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/FlyMobile.lua"))()
        end)
        if success then
            Library:Notify("FlyMobile Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "FlyMobile",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})




-- Options is a table added to getgenv() by the library
-- You index Options with the specified index, in this case it is 'SecondTestLabel' & 'TestLabel'
-- To set the text of the label you do label:SetText

-- Options.TestLabel:SetText("first changed!")
-- Options.SecondTestLabel:SetText("second changed!")

-- Groupbox:AddDivider
-- Arguments: None
LeftGroupBox:AddDivider()

--[[
	Groupbox:AddSlider
	Arguments: Idx, SliderOptions

	SliderOptions: {
		Text = string,
		Default = number,
		Min = number,
		Max = number,
		Suffix = string,
		Rounding = number,
		Compact = boolean,
		HideMax = boolean,
	}

	Text, Default, Min, Max, Rounding must be specified.
	Suffix is optional.
	Rounding is the number of decimal places for precision.

	Compact will hide the title label of the Slider

	HideMax will only display the value instead of the value & max value of the slider
	Compact will do the same thing
]]

-- =========================
-- Teleports
-- =========================
local LeftDropdownGroupBox = Tabs.Teleports:AddLeftGroupbox("Teleports 1", "boxes")
local LeftDropdownGroupBox2 = Tabs.Teleports:AddLeftGroupbox("Mount Sibuatan", "boxes")
local RightDropdownGroupBox = Tabs.Teleports:AddRightGroupbox("Teleports 2", "boxes")
local RightDropdownGroupBox2 = Tabs.Teleports:AddRightGroupbox("Auto Teleport", "boxes")

local function teleportTo(cframe)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cframe
    end
end

-- Function to check level before teleport
local function canTeleport()
    if Level == "Free" then
        Library:Notify("Free users can't use teleport!", 5)
        return false
    end
    return true
end

-- =========================
-- LEFT GROUPBOX TELEPORTS
-- =========================
LeftDropdownGroupBox:AddInput("MyTextbox", {
	Default = "Coordinates (x,y,z)",
	Numeric = false, -- true / false, only allows numbers
	Finished = false, -- true / false, only calls callback when you press enter
	ClearTextOnFocus = true, -- true / false, if false the text will not clear when textbox focused

	Text = "Input your coordinates (x,y,z)", -- Title of the textbox
	Tooltip = "Tooltip", -- Information shown when you hover over the textbox

	Placeholder = "Coordinates (x,y,z)", -- placeholder text when the box is empty
	-- MaxLength is also an option which is the max length of the text

	Callback = function(Value)
        local coords = {}
        for num in string.gmatch(Value, "[^,]+") do
            num = num:match("^%s*(.-)%s*$") -- hapus spasi depan-belakang
            table.insert(coords, tonumber(num))
        end
        if #coords == 3 then
            teleportTo(CFrame.new(coords[1], coords[2], coords[3]))
        else
            warn("Invalid input! Format: x,y,z")
        end
    end,
})

-- Mount Dombret
LeftDropdownGroupBox:AddDropdown("DombretDropdown", {
    Values = {"Spawn", "Summit"},
    Default = 1,
    Text = "Mount Dombret",
    Tooltip = "Teleport Mount Dombret",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(489.839050, 120.997307, 762.160034))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(-605.963806, 742.720215, 209.833572))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Bae
LeftDropdownGroupBox:AddDropdown("BaeDropdown", {
    Values = {"Spawn", "Pos 1", "Pos 2", "Pos 3", "Pos 4", "Pos 5", "Pos 6", "Pos 7", "Pos 8", "Pos 9", "Pos 10","Summit"},
    Default = 1,
    Text = "Mount Bae",
    Tooltip = "Teleport Mount Bae",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(-956.970276, 12.988224, -40.118973))
        elseif Value == "Pos 1" then
            teleportTo(CFrame.new(-332.356598, 8.425612, 843.595337))
        elseif Value == "Pos 2" then
            teleportTo(CFrame.new(14.968253, -78.669571, 903.435791))
        elseif Value == "Pos 3" then
            teleportTo(CFrame.new(653.461731, -57.040031, 898.096802))
        elseif Value == "Pos 4" then
            teleportTo(CFrame.new(735.625488, -63.313019, 869.999817))
        elseif Value == "Pos 5" then
            teleportTo(CFrame.new(899.848022, -89.086182, 703.965515))
        elseif Value == "Pos 6" then
            teleportTo(CFrame.new(870.410706, -191.344238, 204.041626))
        elseif Value == "Pos 7" then
            teleportTo(CFrame.new(376.631134, -108.507935, 44.201252))
        elseif Value == "Pos 8" then
            teleportTo(CFrame.new(-128.079926, 22.572203, 121.887970))
        elseif Value == "Pos 9" then
            teleportTo(CFrame.new(1.519313, -8.436832, -153.418976))
        elseif Value == "Pos 10" then
            teleportTo(CFrame.new(122.552444, 91.255173, -674.180603))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(156.748718, 827.008911, -1026.950317))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

LeftDropdownGroupBox:AddLabel(
    "• For Mount Atin: You must go to CP 23 first before heading to the Summit.\n" ..
    "• For Mount Sibuatan: It is recommended to use the Delay option to avoid suspicion.\n" ..
    "• For Mount Daun: If CP is unavailable, wait approximately 30 seconds after teleporting.\n\n" ..
    "Sekay Hub 2025",
    true
)

-- Mount Sibuatan Anti Delay
LeftDropdownGroupBox2:AddDropdown("SibuatanAntiDelayDropdown", {
    Values = {"Spawn", "Summit"},
    Default = 1,
    Text = "Mount Sibuatan No Cooldown",
    Tooltip = "Teleport Mount Sibuatan Anti Delay",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(991.195984, 112.798019, -697.489807))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(5386.600586, 8109.058594, 2179.034424))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Sibuatan (with 30-minute cooldown)
do
    local cooldown = 50 * 60
    local lastTeleport = 0
    local CooldownLabel = LeftDropdownGroupBox2:AddLabel("Cooldown: Ready ✅")

    task.spawn(function()
        while task.wait(1) do
            local now = tick()
            local remaining = cooldown - (now - lastTeleport)
            if remaining > 0 then
                local minutes = math.floor(remaining / 60)
                local seconds = math.floor(remaining % 60)
                CooldownLabel:Set("Cooldown: Active " .. minutes .. "m " .. seconds .. "s")
            else
                CooldownLabel:Set("Cooldown: Ready ✅")
            end
        end
    end)

    LeftDropdownGroupBox2:AddDropdown("SibuatanDropdown", {
        Values = {"Spawn", "Summit"},
        Default = 1,
        Text = "Mount Sibuatan",
        Tooltip = "Teleport Mount Sibuatan",
        Callback = function(Value)
            if not canTeleport() then return end
            local now = tick()
            if now - lastTeleport < cooldown then
                local remaining = math.floor(cooldown - (now - lastTeleport))
                local minutes = math.floor(remaining / 60)
                local seconds = remaining % 60
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sekay Hub",
                    Text = "Teleport cooldown! Wait " .. minutes .. "m " .. seconds .. "s.",
                    Duration = 5
                })
                return
            end

            if Value == "Spawn" then
                teleportTo(CFrame.new(991.195984, 112.798019, -697.489807))
            elseif Value == "Summit" then
                teleportTo(CFrame.new(5386.600586, 8109.058594, 2179.034424))
            end

            lastTeleport = now
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Teleported to " .. Value,
                Duration = 3
            })
        end,
    })
end

LeftDropdownGroupBox2:AddButton({
    Text = "Teleport Mount Sibuatan [SAFE]",
    Func = function()
        if not canTeleport() then return end

        local checkpoints = {
            CFrame.new(-310.764954, 158.360062, -325.530396),   -- CP 1
            CFrame.new(-732.508362, 592.381042, -121.523430),
            CFrame.new(-885.880737, 996.181091, -205.180374),
            CFrame.new(-1636.254150, 996.466370, 285.153931),
            CFrame.new(-1646.729736, 998.474792, 633.988892),
            CFrame.new(-1637.100220, 1116.381104, 2151.866699),
            CFrame.new(-520.828979, 1452.381104, 3279.551514),
            CFrame.new(-707.082031, 1896.381104, 2382.717773),
            CFrame.new(-861.456299, 1944.181152, 2070.890137),
            CFrame.new(-868.243286, 2104.380859, 1669.271851),
            CFrame.new(-900.984253, 2344.380615, 1442.063599),
            CFrame.new(-848.414551, 2768.380859, 1505.385498),
            CFrame.new(-616.392334, 3288.380615, 1919.596558),
            CFrame.new(-238.524368, 3407.580566, 2577.954102),
            CFrame.new(308.427917, 3544.380859, 3045.345703),
            CFrame.new(441.245544, 3600.380859, 3563.178467),
            CFrame.new(910.216248, 3668.380615, 4150.360840),
            CFrame.new(1422.986206, 3908.380615, 4997.069824),
            CFrame.new(1667.531006, 4288.380859, 5191.079102),
            CFrame.new(1722.025391, 4472.180664, 5171.277832),
            CFrame.new(1866.061401, 4656.327148, 5199.937012),
            CFrame.new(1902.885742, 4964.380371, 5157.607910),
            CFrame.new(2848.757568, 5076.380371, 5242.172363),
            CFrame.new(3460.068115, 5244.380859, 5122.323730),
            CFrame.new(4577.907227, 5480.380371, 5265.410645),
            CFrame.new(4880.519043, 3988.052490, 5179.996582),
            CFrame.new(5829.640137, 4000.136719, 5741.727051),
            CFrame.new(6631.949707, 4225.780273, 5577.625000),
            CFrame.new(7477.726562, 4225.587402, 5306.537109),
            CFrame.new(8213.287109, 4332.380371, 4893.226562),
            CFrame.new(8694.331055, 4484.380371, 4544.761230),
            CFrame.new(8786.682617, 4540.380859, 4346.211914),
            CFrame.new(9200.066406, 5076.380859, 2465.798828),
            CFrame.new(9190.503906, 5324.114746, 2461.249512),
            CFrame.new(9075.838867, 5892.380371, 2043.035034),   -- CP 36
            CFrame.new(9187.802734, 6219.541504, 1985.755371),
            CFrame.new(9063.084961, 6500.786621, 1827.403320),
            CFrame.new(8694.529297, 6532.208984, 1293.362061),
            CFrame.new(8395.609375, 6560.329590, 1138.290161),
            CFrame.new(7141.187988, 6776.380371, 376.131805),
            CFrame.new(6572.685059, 6969.239746, 255.105209),
            CFrame.new(6040.210449, 6968.380371, 253.225739),
            CFrame.new(4872.932617, 7148.380859, 680.238403),
            CFrame.new(-2065.570557, 1870.457275, -275.846008), -- Summit
        }

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Cari CP terdekat
        local nearestIndex = 1
        local nearestDist = math.huge
        for i, pos in ipairs(checkpoints) do
            local dist = (hrp.Position - pos.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestIndex = i
            end
        end

        -- Mulai teleport dari CP terdekat
        for i = nearestIndex, #checkpoints do
            local pos = checkpoints[i]
            teleportTo(pos)

            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Teleported to Sibuatan CP " .. i,
                Duration = 5
            })

            if i < #checkpoints then
                for t = 60, 1, -1 do
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Sekay Hub",
                        Text = "Arrived at CP " .. i .. ". Waiting " .. t .. "s...",
                        Duration = 60
                    })
                    task.wait(1)
                end
            else
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sekay Hub",
                    Text = "Arrived at Summit!",
                    Duration = 10
                })
            end
        end
    end,
    DoubleClick = false,
    Tooltip = "Teleport ke semua CP Sibuatan (mulai dari CP terdekat, berhenti 1 menit tiap CP)",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})


-- =========================
-- RIGHT GROUPBOX TELEPORTS
-- =========================
-- Mount Atin
RightDropdownGroupBox:AddDropdown("AtinDropdown", {
    Values = {"Spawn", "Pos 23", "Summit"},
    Default = 1,
    Text = "Mount Atin",
    Tooltip = "Teleport Mount Atin",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(10.996780, 60.998020, -964.791565))
        elseif Value == "Pos 23" then
            teleportTo(CFrame.new(-423.112488, 1710.612183, 3419.230225))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(830.440979, 2183.325928, 3948.415527))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Sumbing
RightDropdownGroupBox:AddDropdown("SumbingDropdown", {
    Values = {"Spawn", "Pos 1", "Pos 2", "Pos 3", "Pos 4", "Summit"},
    Default = 1,
    Text = "Mount Sumbing",
    Tooltip = "Teleport Mount Sumbing",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(-335.664490, 5.006538, 28.927597))
        elseif Value == "Pos 1" then
            teleportTo(CFrame.new(-227.561844, 441.000031, 2143.701904))
        elseif Value == "Pos 2" then
            teleportTo(CFrame.new(-426.891113, 848.999939, 3205.731934))
        elseif Value == "Pos 3" then
            teleportTo(CFrame.new(39.400356, 1268.999878, 4040.747314))
        elseif Value == "Pos 4" then
            teleportTo(CFrame.new(-1140.206177, 1552.999878, 4899.074219))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(-939.110962, 1926.974365, 5407.520508))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Merapi
RightDropdownGroupBox:AddDropdown("MerapiDropdown", {
    Values = {"Spawn", "Summit"},
    Default = 1,
    Text = "Mount Merapi",
    Tooltip = "Teleport Mount Merapi",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(-4242.708496, 16.117191, 2315.105957))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(-2065.570557, 1870.457275, -275.846008))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Arunika
-- Button: Tween ke 6 koordinat Arunika berurutan, berhenti 1 menit di setiap titik
RightDropdownGroupBox2:AddButton({
    Text = "Teleport Arunika [MT]",
    Func = function()
        if not canTeleport() then return end
        local checkpoints = {
            Vector3.new(136.385025, 142.925339, -174.941727), -- Pos 1
            Vector3.new(326.884338, 90.939461, -433.000580),  -- Pos 2
            Vector3.new(476.540344, 170.957611, -939.659912), -- Pos 3
            Vector3.new(930.922485, 134.529999, -626.021545), -- Pos 4
            Vector3.new(923.322021, 102.815964, 278.812378),  -- Pos 5
            Vector3.new(255.383560, 326.390808, 707.520874),  -- Summit
        }
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local TweenService = game:GetService("TweenService")
        for i, pos in ipairs(checkpoints) do
            local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)})
            tween:Play()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Tweening to Arunika CP " .. i,
                Duration = 3
            })
            tween.Completed:Wait()
            if i < #checkpoints then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sekay Hub",
                    Text = "Arrived at CP " .. i .. ". Waiting 15s...",
                    Duration = 5
                })
                task.wait(60)
            else
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sekay Hub",
                    Text = "Arrived at Summit!",
                    Duration = 5
                })
            end
        end
    end,
    DoubleClick = false,
    Tooltip = "Tween ke semua CP Arunika (berhenti 1 menit tiap CP)",
    DisabledTooltip = "Button ini disabled!",
    Disabled = true,
    Visible = true,
    Risky = true,
})

RightDropdownGroupBox2:AddButton({
    Text = "Teleport Daun Loop [SAFE]",
    Func = function()
        if not canTeleport() then return end

        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        -- Daftar koordinat checkpoint
        local coordsList = {
            {x=-622.3467, y=250.1038, z=-384.3970},
            {x=-1203.1849, y=261.4581, z=-487.1641},
            {x=-1399.0914, y=578.1970, z=-949.7464},
            {x=-1700.6145, y=816.4534, z=-1399.3834},
            {x=-3199.8823, y=1721.9829, z=-2620.9255}
        }

        local active = true
        local currentIndex = 1
        local respawnDelay = 10
        local connection

        -- Fungsi handler saat respawn
        local function onRespawn(char)
            if not active then return end
            task.spawn(function()
                local hrp = char:WaitForChild("HumanoidRootPart")
                task.wait(0.3)

                local c = coordsList[currentIndex]
                hrp.CFrame = CFrame.new(c.x, c.y, c.z)

                if char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = 0 -- auto bunuh biar next cp
                end

                currentIndex += 1
                if currentIndex > #coordsList then
                    currentIndex = 1
                end

                task.wait(respawnDelay)
            end)
        end

        -- Connect ulang biar tidak double
        if connection then connection:Disconnect() end
        connection = LocalPlayer.CharacterAdded:Connect(onRespawn)

        -- Trigger respawn pertama kali
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end

        -- Stop logic kalau tombol dipencet lagi
        task.spawn(function()
            repeat task.wait() until not active
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = "Auto respawn teleport antar CP Arunika",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

RightDropdownGroupBox2:AddButton({
    Text = "Teleport Mount Appalachia [LOOP]",
    Func = function()
        if not canTeleport() then return end

        local checkpoints = {
            CFrame.new(-3139.848633, -103.994087, 1579.492920),   -- Spawn
            CFrame.new(-1960.469849, -183.623337, 481.183502),   -- CP 1
            CFrame.new(-1072.655029, -103.622375, 909.639221),   -- CP 2
            CFrame.new(-138.137558, 29.074762, 133.168182),      -- CP 3
            CFrame.new(462.227661, 159.196304, 108.149254),      -- CP 4
            CFrame.new(689.799316, 326.962585, 94.362259),       -- CP 5
            CFrame.new(913.861816, 496.912781, 149.628586),      -- CP 6
            CFrame.new(1236.079956, 633.668030, 690.652710),     -- CP 7
            CFrame.new(1321.624512, 748.380005, 884.601990),     -- CP 8
            CFrame.new(1943.653809, 1012.377441, 709.145142),    -- CP 9
            CFrame.new(3288.517578, 1468.313599, 1146.380127),   -- CP 10
            CFrame.new(3444.609619, 1672.161377, 452.475372),    -- CP 11
            CFrame.new(3434.738037, 1680.537842, 234.758804),    -- CP 12
            CFrame.new(2714.192627, 2207.560791, -476.728027),   -- CP 13
            CFrame.new(2387.079834, 2228.367920, -249.139877),   -- CP 14
            CFrame.new(2404.903320, 2079.395508, -300.585571),   -- CP 15
            CFrame.new(2316.580811, 1992.376953, -625.893799),   -- CP 16
            CFrame.new(1995.381348, 2223.697998, -1527.036865),  -- CP 17
            CFrame.new(2500.243896, 2322.546143, -1517.932007),  -- CP 18
            CFrame.new(2943.685303, 2096.069336, -1551.756836),  -- CP 19
            CFrame.new(3025.204834, 2121.420166, -806.423706),   -- CP 20
            CFrame.new(3319.573730, 1988.215210, -600.209229),   -- CP 21
            CFrame.new(3385.005127, 1625.598877, -606.827393),   -- CP 22
            CFrame.new(3520.323730, 1645.817627, -671.475342),   -- CP 23
            CFrame.new(3568.521484, 1726.868530, -667.429871),   -- CP 24
            CFrame.new(3578.215820, 1967.892334, -627.463989),   -- CP 25
            CFrame.new(3939.582520, 1985.478271, -624.222961),   -- CP 26
            CFrame.new(4046.189941, 2288.346680, -1491.441772),  -- CP 27
            CFrame.new(3926.152832, 2376.370117, -1544.739990),  -- CP 28
            CFrame.new(3458.777588, 2424.908936, -1564.814575),  -- CP 29
            CFrame.new(3142.999512, 2551.509521, -1619.767700),  -- CP 30
            CFrame.new(3319.823486, 2844.088623, -1565.731323),  -- CP 31 (Summit)
        }

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        task.spawn(function()
            while true do
                -- cari checkpoint terdekat dulu
                local nearestIndex = 1
                local nearestDist = math.huge
                for i, cf in ipairs(checkpoints) do
                    local dist = (hrp.Position - cf.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestIndex = i
                    end
                end

                -- teleport mulai dari CP terdekat → summit
                for i = nearestIndex, #checkpoints do
                    teleportTo(checkpoints[i])
                    task.wait(3) -- delay antar CP
                end

                -- selesai summit → balik spawn
                teleportTo(checkpoints[1])
                task.wait(3)
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = "Loop teleport Spawn → Summit (lanjut dari CP terdekat)",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})


RightDropdownGroupBox2:AddButton({
    Text = "Teleport Mount Akhirat [SAFE]",
    Func = function()
        if not canTeleport() then return end

        local checkpoints = {
            CFrame.new(-241.980637, 128.206482, 207.637131),   -- Spawn
            CFrame.new(-135.961273, 427.258820, -216.604691),  -- CP 1
            CFrame.new(-1.554094, 950.330994, -1053.890381),   -- CP 2
            CFrame.new(107.897079, 1202.220337, -1358.704590), -- CP 3
            CFrame.new(107.920502, 1465.389404, -1804.381592), -- CP 4
            CFrame.new(303.097900, 1865.610107, -2328.142822), -- CP 5
            CFrame.new(562.355835, 2090.103271, -2554.968018), -- CP 6
            CFrame.new(753.346558, 2191.057617, -2499.703857), -- CP 7
            CFrame.new(792.993103, 2335.919189, -2642.583252), -- CP 8
            CFrame.new(967.765747, 2515.228027, -2632.786621), -- CP 9
            CFrame.new(1237.864136, 2695.098633, -2801.676270), -- CP 10
            CFrame.new(1619.952759, 3058.907959, -2752.929443), -- CP 11
            CFrame.new(1812.628784, 3577.859863, -3245.521484), -- CP 12
            CFrame.new(2804.170410, 4425.997559, -4791.402344), -- CP 13
            CFrame.new(3468.630371, 4857.867188, -4183.347656), -- CP 14
            CFrame.new(3481.758057, 5108.886230, -4279.166992), -- CP 15
            CFrame.new(3975.620361, 5670.194336, -3976.219971), -- CP 16
            CFrame.new(4494.729492, 5902.268555, -3790.993164), -- CP 17
            CFrame.new(5064.448730, 6372.560059, -2983.655518), -- CP 18
            CFrame.new(5540.715332, 6595.614258, -2492.391357), -- CP 19
            CFrame.new(5551.272461, 6875.716309, -1048.943237), -- CP 20
            CFrame.new(4327.784180, 7642.542480, 130.932922),  -- CP 21
            CFrame.new(3456.578613, 7711.466797, 939.831238),  -- CP 22
            CFrame.new(3055.463135, 7879.695801, 1035.636230), -- CP 23
        }

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- cari checkpoint terdekat
        local nearestIndex = 1
        local nearestDist = math.huge
        for i, cf in ipairs(checkpoints) do
            local dist = (hrp.Position - cf.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestIndex = i
            end
        end

        task.spawn(function()
            for i = nearestIndex, #checkpoints do
                teleportTo(checkpoints[i])
                task.wait(10) -- delay antar CP
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = "Teleport Spawn → Summit (lanjut dari CP terdekat)",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

RightDropdownGroupBox2:AddButton({
    Text = "Teleport Mount Stecu [SAFE]",
    Func = function()
        if not canTeleport() then return end

        local checkpoints = {
            CFrame.new(-7.700585, 668.673401, -927.156067),    -- CP 1
            CFrame.new(-141.955765, 776.475098, -1162.751831), -- CP 2
            CFrame.new(-482.242737, 872.673462, -1226.027588), -- CP 3
            CFrame.new(253.589081, 872.643677, -1543.582642),  -- CP 4
            CFrame.new(-498.156219, 1352.090698, -1912.288086),-- CP 5
            CFrame.new(-277.948242, 1439.824219, -2027.488525),-- CP 6
            CFrame.new(304.287659, 1631.728760, -1981.505249), -- CP 7
            CFrame.new(875.226318, 1780.826782, -2000.770996), -- CP 8
            CFrame.new(899.083557, 1808.339722, -2290.927734), -- CP 9
            CFrame.new(888.508545, 1904.348877, -2826.030029), -- CP 10
            CFrame.new(-276.961060, 2104.673340, -2957.711182),-- CP 11
            CFrame.new(-443.058075, 2416.112793, -3046.271729),-- CP 12
            CFrame.new(-431.140686, 2448.339355, -3564.587891),-- CP 13
            CFrame.new(-1202.022949, 2468.140381, -4253.435059),-- CP 14
            CFrame.new(-1183.381348, 2508.205811, -4797.556641),-- CP 15
            CFrame.new(-1168.140625, 2584.206055, -5265.692383),-- CP 16
            CFrame.new(-1190.188477, 2764.252197, -5878.654785),-- CP 17
            CFrame.new(-1207.759155, 3188.468994, -6201.933594),-- CP 18
            CFrame.new(-1217.837158, 3188.558594, -6726.416504),-- CP 19
            CFrame.new(-1137.742310, 3240.839355, -7339.087402), -- CP 20
            CFrame.new(-1202.304565, 3291.895996, -7649.035645),  -- CP 21
            CFrame.new(-1184.733643, 3300.339355, -7986.355469),-- CP 22
            CFrame.new(-1147.364990, 3368.524414, -8467.226562),-- CP 23
            CFrame.new(-1639.803589, 3448.673340, -8537.044922),-- CP 24
            CFrame.new(-1653.426880, 3512.673340, -8991.009766),-- CP 25
            CFrame.new(-1688.215454, 3685.247070, -9511.807617),-- Summit
        }

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- cari checkpoint terdekat
        local nearestIndex = 1
        local nearestDist = math.huge
        for i, cf in ipairs(checkpoints) do
            local dist = (hrp.Position - cf.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestIndex = i
            end
        end

        task.spawn(function()
            for i = nearestIndex, #checkpoints do
                teleportTo(checkpoints[i])
                task.wait(10) -- delay antar CP
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = "Teleport Spawn → Summit (lanjut dari CP terdekat)",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})


RightDropdownGroupBox2:AddButton({
    Text = "Teleport Mount Sumbing [LOOP]",
    Func = function()
        if not canTeleport() then return end

        local checkpoints = {
            CFrame.new(-335.664490, 5.006538, 28.927597),       -- Spawn
            CFrame.new(-227.561844, 441.000031, 2143.701904),   -- CP 1
            CFrame.new(-426.891113, 848.999939, 3205.731934),   -- CP 2
            CFrame.new(39.400356, 1268.999878, 4040.747314),    -- CP 3
            CFrame.new(-1140.206177, 1552.999878, 4899.074219), -- CP 4
            CFrame.new(-939.110962, 1926.974365, 5407.520508),  -- CP 5
        }

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        task.spawn(function()
            while true do
                -- cari checkpoint terdekat tiap loop (biar kalau DC / respawn tetap aman)
                local nearestIndex = 1
                local nearestDist = math.huge
                for i, cf in ipairs(checkpoints) do
                    local dist = (hrp.Position - cf.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestIndex = i
                    end
                end

                -- mulai teleport dari CP terdekat sampai akhir
                for i = nearestIndex, #checkpoints do
                    teleportTo(checkpoints[i])
                    task.wait(5) -- delay antar CP
                end

                -- habis sampai summit → balik lagi ke spawn
                teleportTo(checkpoints[1])
                task.wait(5)
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = "Loop teleport Spawn → Summit terus-menerus",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

RightDropdownGroupBox2:AddButton({
    Text = "Teleport Mount Merapi [LOOP]",
    Func = function()
        if not canTeleport() then return end

        local checkpoints = {
            CFrame.new(-4242.708496, 16.117191, 2315.105957),       -- Spawn
            CFrame.new(-2065.570557, 1870.457275, -275.846008),   -- CP 1
        }

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        task.spawn(function()
            while true do
                -- cari checkpoint terdekat tiap loop (biar kalau DC / respawn tetap aman)
                local nearestIndex = 1
                local nearestDist = math.huge
                for i, cf in ipairs(checkpoints) do
                    local dist = (hrp.Position - cf.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestIndex = i
                    end
                end

                -- mulai teleport dari CP terdekat sampai akhir
                for i = nearestIndex, #checkpoints do
                    teleportTo(checkpoints[i])
                    task.wait(5) -- delay antar CP
                end

                -- habis sampai summit → balik lagi ke spawn
                teleportTo(checkpoints[1])
                task.wait(5)
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = "Loop teleport Spawn → Summit terus-menerus",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})



-- Mount Arunika Teleport


-- Mount Lembayana
RightDropdownGroupBox:AddDropdown("LembayanaDropdown", {
    Values = {"Spawn", "Summit"},
    Default = 1,
    Text = "Mount Lembayana",
    Tooltip = "Teleport Mount Lembayana",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(756.916748, 252.982285, 681.168152))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(-23508.648438, 6307.981934, -6962.814941))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Prau
RightDropdownGroupBox:AddDropdown("PrauDropdown", {
    Values = {"Spawn", "Summit"},
    Default = 1,
    Text = "Mount Prau",
    Tooltip = "Teleport Mount Prau",
    Callback = function(Value)
        if not canTeleport() then return end
        if Value == "Spawn" then
            teleportTo(CFrame.new(125.900627, 2.348172, 1243.795044))
        elseif Value == "Summit" then
            teleportTo(CFrame.new(-1364.789795, 481.025940, -1552.814941))
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Value,
            Duration = 3
        })
    end,
})

-- Mount Daun with 1-minute cooldown
do
    local cooldown = 60
    local lastTeleport = 0
    RightDropdownGroupBox:AddDropdown("DaunDropdown", {
        Values = {"Spawn", "Pos 1", "Pos 2", "Pos 3", "Pos 4", "Summit"},
        Default = 1,
        Text = "Mount Daun",
        Tooltip = "Teleport Mount Daun",
        Callback = function(Value)
            if not canTeleport() then return end
            local now = tick()
            if now - lastTeleport < cooldown then
                local remaining = math.floor(cooldown - (now - lastTeleport))
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sekay Hub",
                    Text = "Teleport cooldown! Wait " .. remaining .. "s.",
                    Duration = 3
                })
                return
            end

            if Value == "Spawn" then
                teleportTo(CFrame.new(24.289274, 13.024839, -6.883502))
            elseif Value == "Pos 1" then
                teleportTo(CFrame.new(-622.821655, 250.330612, -382.938293))
            elseif Value == "Pos 2" then
                teleportTo(CFrame.new(-1204.497314, 261.701355, -487.193481))
            elseif Value == "Pos 3" then
                teleportTo(CFrame.new(-1398.959717, 578.441101, -950.643921))
            elseif Value == "Pos 4" then
                teleportTo(CFrame.new(-1702.220459, 816.613403, -1400.444214))
            elseif Value == "Summit" then
                teleportTo(CFrame.new(-3230.208740, 1714.455566, -2589.435547))
            end

            lastTeleport = now
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Teleported to " .. Value,
                Duration = 3
            })
        end,
    })
end


--===============================
-- Tabbox Auto Walk Mount Atin
--===============================
local LeftGroupBox = Tabs.Tween:AddLeftGroupbox("Auto Walk", "boxes")

-- ========================================
-- Auto Walk Atin
-- ========================================
local function canWalk()
    if Level == "Free" then
        Library:Notify("Free users can't use autowalk!", 5)
        return false
    end
    return true
end

local Atin = LeftGroupBox:AddButton({
    Text = "Mountain Atin",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Atin.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Atin",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

-- ========================================
-- Auto Walk Atin
-- ========================================

-- Function to check level before teleport

local Antartika = LeftGroupBox:AddButton({
    Text = "Mountain Antartika",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Antartika.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Antartika",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Arunika = LeftGroupBox:AddButton({
    Text = "Mountain Arunika",
    Func = function()
        if not canWalk() then return end
        
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SKY_Antartika.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Arunika",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Batu = LeftGroupBox:AddButton({
    Text = "Mountain Batu",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Batu.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Batu",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Ckptw = LeftGroupBox:AddButton({
    Text = "Mountain Ckptw",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Ckptw.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Ckptw",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Daun = LeftGroupBox:AddButton({
    Text = "Mountain Daun",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Daun.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Daun",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Hana = LeftGroupBox:AddButton({
    Text = "Mountain Hana",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Hana.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Hana",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Lembayana = LeftGroupBox:AddButton({
    Text = "Mountain Lembayana",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Lembayana.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Lembayana",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Lingkarsa = LeftGroupBox:AddButton({
    Text = "Mountain Lingkarsa",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Lingkarsa.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Lingkarsa",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

-- Kalista
local Kalista = LeftGroupBox:AddButton({
    Text = "Mountain Kalista",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Kalista.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,
    Tooltip = "Auto Walk Mount Kalista",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

-- Kaliya
local Kaliya = LeftGroupBox:AddButton({
    Text = "Mountain Kaliya",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Kaliya.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,
    Tooltip = "Auto Walk Mount Kaliya",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

-- Pargoy
local Pargoy = LeftGroupBox:AddButton({
    Text = "Mountain Pargoy",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Pargoy.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,
    Tooltip = "Auto Walk Mount Pargoy",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

-- Sakahayang
local Sakahayang = LeftGroupBox:AddButton({
    Text = "Mountain Sakahayang",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Sakahayang.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,
    Tooltip = "Auto Walk Mount Sakahayang",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

-- Serendipity
local Serendipity = LeftGroupBox:AddButton({
    Text = "Mountain Serendipity",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Serendipity.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,
    Tooltip = "Auto Walk Mount Serendipity",
    DisabledTooltip = "Button ini disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})


local Yahayuk = LeftGroupBox:AddButton({
    Text = "Mountain Yahayuk",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Yahayuk.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Yahayuk",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Ravika = LeftGroupBox:AddButton({
    Text = "Mountain Ravika",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Ravika.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Ravika",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Sibuatans = LeftGroupBox:AddButton({
    Text = "Mountain Sibuatan",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Sibuatan.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Sibuatan",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local StecuWalk = LeftGroupBox:AddButton({
    Text = "Mountain Stecu",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Stecu.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Stecu",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

local Yntkts = LeftGroupBox:AddButton({
    Text = "Mountain Yntkts",
    Func = function()
        if not canWalk() then return end

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/apies13/AutoWalk/refs/heads/main/SRN_Yntkts.lua"))()
        end)
        if success then
            Library:Notify("Autowalk Loaded!", 5)
        else
            warn("[Sekay Hub] Gagal load script:", err)
        end
    end,
    DoubleClick = false,

    Tooltip = "Auto Walk Mount Yntkts",
    DisabledTooltip = "Button ini disabled!",

    Disabled = false,
    Visible = true,
    Risky = false,
})

-- Info kanan
local RightGroupBox = Tabs.Tween:AddRightGroupbox("Tween Information")
RightGroupBox:AddLabel(
    "Red = Risk / MT features (use with caution)\n" ..
    "Gray = Safe / Usable features (safe to use without restrictions)",
    true
)
-- Long text label to demonstrate UI scrolling behaviour.
local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox("Information")
LeftGroupBox2:AddLabel(
	"This feature should be used responsibly to avoid being banned by Roblox admins or staff.\n\nSekay Hub 2025",
	true
)

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place") -- if the game has multiple places inside of it (for example: DOORS)
-- you can use this to save configs for those places separately
-- The path in this script would be: MyScriptHub/specific-game/settings/specific-place
-- [ This is optional ]

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()