local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Sekay Hub UI",
   Icon = 0,
   LoadingTitle = "Sekay Hub UI",
   LoadingSubtitle = "by Sekayzee",
   ShowText = "Sekay Hub",
   Theme = "Default",
   ToggleUIKeybind = "K",

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "JCloudHub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Sekay Hub",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"apis"}
   }
})

-------------------------------------------------
-- FUNCTION INVISIBLE
-------------------------------------------------
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

        -- teleport sebentar ke tempat dummy lalu balik lagi
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

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Invisibility ON",
            Duration = 3
        })
    else
        local invisChair = workspace:FindFirstChild("invischair")
        if invisChair then invisChair:Destroy() end
        setTransparency(char, 0)

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Invisibility OFF",
            Duration = 3
        })
    end
end

-- BUAT TAB
local MainTab = Window:CreateTab("Players", nil)
local TeleTab = Window:CreateTab("Teleports", nil)

-------------------------------------------------
-- SECTION FLYING
-------------------------------------------------
MainTab:CreateSection("Flying Section")

-- Default variable
_G.flySpeed = 50
_G.flyActive = false

-- Toggle Fly
local FlyToggle = MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        _G.flyActive = Value

        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        if Value then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Fly Activated!",
                Duration = 5
            })

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
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Fly Deactivated!",
                Duration = 5
            })

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
local FlySlider = MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {0, 200},
    Increment = 10,
    Suffix = " Speed",
    CurrentValue = 50,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        _G.flySpeed = Value
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Fly Speed set to " .. Value,
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- SECTION CHARACTER
-------------------------------------------------
MainTab:CreateSection("Character Section")

-- Infinite Jump Toggle
local InfiniteJumpToggle = MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        _G.InfiniteJumpEnabled = Value

        if Value then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Infinite Jump Activated!",
                Duration = 5
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Infinite Jump Deactivated!",
                Duration = 5
            })
        end
    end,
})

-- Koneksi global supaya tidak dobel
if not _G.InfiniteJumpConnection then
    local UserInputService = game:GetService("UserInputService")
    _G.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if _G.InfiniteJumpEnabled then
            local plr = game:GetService("Players").LocalPlayer
            local char = plr.Character or plr.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-------------------------------------------------
-- Invisible Toggle (client-side trick)
-------------------------------------------------
local InvisibleToggle = MainTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "InvisibleToggle",
    Callback = function(Value)
        toggleInvisibility(Value)
    end,
})

-------------------------------------------------
-- WalkSpeed Slider
-------------------------------------------------
_G.CustomWalkSpeed = 16 -- default Roblox walk speed

local SpeedSlider = MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200}, -- min 16 (default), max 200
    Increment = 2,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        _G.CustomWalkSpeed = Value
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Value
            end
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Walk Speed set to " .. Value,
            Duration = 3
        })
    end,
})

-- Reset WalkSpeed saat respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = _G.CustomWalkSpeed or 16
end)

-------------------------------------------------
-- Teleports Selection
-------------------------------------------------

-------------------------------------------------
-- Dombret
-------------------------------------------------
TeleTab:CreateSection("Mount Dombret")
local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(489.839050, 120.997307, 762.160034) -- koordinat Spawn
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(41.247673, 740.634216, 169.561218) -- koordinat Shop
        end

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- Dombret
-------------------------------------------------
TeleTab:CreateSection("Mount Sibuatan ANTI DELAY")
local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(991.195984, 112.798019, -697.489807) -- koordinat Spawn
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(5386.600586, 8109.058594, 2179.034424) -- koordinat Shop
        end

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- Sibuatan
-------------------------------------------------

TeleTab:CreateSection("Mount Sibuatan")

-- Variabel cooldown
local cooldown = 30 * 60 -- 30 menit (detik)
local lastTeleport = tick() -- awal langsung cooldown

-- Label Cooldown
local CooldownLabel = TeleTab:CreateLabel(
    "Cooldown: Aktif 30m 0s", -- teks awal
    nil, -- icon id
    Color3.fromRGB(255, 255, 255),
    false
)

-- Loop update label tiap 1 detik
task.spawn(function()
    while task.wait(1) do
        local now = tick()
        local remaining = cooldown - (now - lastTeleport)

        if remaining > 0 then
            local minutes = math.floor(remaining / 60)
            local seconds = math.floor(remaining % 60)
            CooldownLabel:Set("Cooldown: " .. minutes .. "m " .. seconds .. "s")
        else
            CooldownLabel:Set("Cooldown: Siap dipakai ✅")
        end
    end
end)

-- Dropdown teleport
local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        -- cek cooldown
        local now = tick()
        if now - lastTeleport < cooldown then
            local remaining = math.floor(cooldown - (now - lastTeleport))
            local minutes = math.floor(remaining / 60)
            local seconds = remaining % 60

            game.StarterGui:SetCore("SendNotification", {
                Title = "Sekay Hub",
                Text = "Teleport cooldown! Tunggu " .. minutes .. "m " .. seconds .. "s lagi.",
                Duration = 5
            })
            return
        end

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(991.195984, 112.798019, -697.489807)
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(5386.600586, 8109.058594, 2179.034424)
        end

        lastTeleport = now -- reset timer cooldown

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- Atin
-------------------------------------------------

TeleTab:CreateSection("Mount Atin")

-- Label informasi
local InfoLabel = TeleTab:CreateLabel(
    "Info: You must go to Pos 23 first before Summit and talk to the NPC.",
    nil, -- icon id (optional)
    Color3.fromRGB(255, 255, 255),
    false
)

local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Pos 23", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(10.996780, 60.998020, -964.791565) -- Spawn
        elseif Options[1] == "Pos 23" then
            root.CFrame = CFrame.new(-423.112488, 1710.612183, 3419.230225) -- Pos 23
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(694.734863, 2195.690430, 4010.594482) -- Summit
        end

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- Lembayana
-------------------------------------------------
TeleTab:CreateSection("Mount Lembayana")
local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(756.916748, 252.982285, 681.168152) -- koordinat Spawn
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(-23508.648438, 6307.981934, -6962.814941) -- koordinat Shop
        end

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- Prau
-------------------------------------------------
TeleTab:CreateSection("Mount Prau")
local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(125.900627, 2.348172, 1243.795044) -- koordinat Spawn
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(-1364.789795, 481.025940, -1552.814941) -- koordinat Shop
        end

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})

-------------------------------------------------
-- Daun
-------------------------------------------------
TeleTab:CreateSection("Mount Daun")
local Dropdown = TeleTab:CreateDropdown({
    Name = "Teleport Menu",
    Options = {"Spawn", "Pos 1", "Pos 2", "Pos 3", "Pos 4", "Summit"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart

        if Options[1] == "Spawn" then
            root.CFrame = CFrame.new(24.289274, 13.024839, -6.883502) -- koordinat Spawn
        elseif Options[1] == "Pos 1" then
            root.CFrame = CFrame.new(-622.821655, 250.330612, -382.938293) -- koordinat Shop
        elseif Options[1] == "Pos 2" then
            root.CFrame = CFrame.new(-1204.497314, 261.701355, -487.193481) -- koordinat Shop
        elseif Options[1] == "Pos 3" then
            root.CFrame = CFrame.new(-1398.959717, 578.441101, -950.643921) -- koordinat Shop
        elseif Options[1] == "Pos 4" then
            root.CFrame = CFrame.new(-1702.220459, 816.613403, -1400.444214) -- koordinat Shop
        elseif Options[1] == "Summit" then
            root.CFrame = CFrame.new(-3230.208740, 1714.455566, -2589.435547) -- koordinat Shop
        end

        game.StarterGui:SetCore("SendNotification", {
            Title = "Sekay Hub",
            Text = "Teleported to " .. Options[1],
            Duration = 3
        })
    end,
})


-------------------------------------------------
-- NOTIFIKASI AWAL
-------------------------------------------------
Rayfield:Notify({
   Title = "Sekay Hub",
   Content = "Thank you for purchase this script!",
   Duration = 6.5,
   Image = 4483362458,
})
