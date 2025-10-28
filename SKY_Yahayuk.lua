-- =========================================================
-- LOGIKA UNTUK MEMBACA DATA CFRAME DARI JSON
-- =========================================================
local HttpService = game:GetService("HttpService")
-- local CFrame = CFrame -- CFrame biasanya sudah global di lingkungan Roblox

-- !!! GANTI DENGAN KONTEN LENGKAP DARI Sekay_Yahayuk.json !!!
-- Jika Anda memuat dari GitHub, Anda harus menggunakan HttpService:GetAsync() 
-- untuk mengambil kontennya terlebih dahulu, lalu mendekode di sini.
local jsonContent = HttpService:GetAsync("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/Yahayuk.json")
local data
local success, errorMessage = pcall(function()
    -- Mendekode string JSON menjadi tabel Lua
    data = HttpService:JSONDecode(jsonContent)
end)

local Replay1 = {}

if success and data and data.path then
    local pathData = data.path
    
    -- Mengkonversi setiap array CFrame numerik (12 angka) menjadi objek CFrame.new()
    for _, frameData in ipairs(pathData) do
        local cframeArray = frameData.CFrame
        
        if #cframeArray == 12 then
            -- CFrame.new(x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
            local cf = CFrame.new(
                cframeArray[1], cframeArray[2], cframeArray[3],
                cframeArray[4], cframeArray[5], cframeArray[6],
                cframeArray[7], cframeArray[8], cframeArray[9],
                cframeArray[10], cframeArray[11], cframeArray[12]
            )
            table.insert(Replay1, cf)
        end
    end
    print("âœ… Berhasil memuat " .. #Replay1 .. " CFrame dari Sekay_Yahayuk.json")
else
    -- Memberi peringatan jika decoding atau data.path gagal
    warn("Gagal memuat CFrame dari JSON. Pesan Error:", errorMessage or "Format JSON salah atau key 'path' tidak ditemukan.")
end
-- =========================================================
-- VARIABEL Replay1 SEKARANG BERISI DATA CFRAME DARI JSON
-- =========================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local hrp = nil

local function refreshHRP(char)
    if not char then
        char = player.Character or player.CharacterAdded:Wait()
    end
    hrp = char:WaitForChild("HumanoidRootPart")
end
if player.Character then refreshHRP(player.Character) end
player.CharacterAdded:Connect(refreshHRP)

local frameTime = 1/30
local playbackRate = 1.0
local isRunning = false
local routes = { MyRoute }


routes = {
    {"CP0 → CP8", Replay1},
}

local function getNearestRoute()
    local nearestIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,data in ipairs(routes) do
            for _,cf in ipairs(data[2]) do
                local d = (cf.Position - pos).Magnitude
                if d < dist then
                    dist = d
                    nearestIdx = i
                end
            end
        end
    end
    return nearestIdx
end

local function getNearestFrameIndex(frames)
    local startIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,cf in ipairs(frames) do
            local d = (cf.Position - pos).Magnitude
            if d < dist then
                dist = d
                startIdx = i
            end
        end
    end
    if startIdx >= #frames then
        startIdx = math.max(1, #frames - 1)
    end
    return startIdx
end

local function lerpCF(fromCF, toCF)
    local rigOffset = 0
    if _G.getRigOffset then
        rigOffset = _G.getRigOffset() or 0
    end

    -- bikin versi offset untuk start & end
    local fromWithOffset = CFrame.new(
        fromCF.Position.X,
        fromCF.Position.Y + rigOffset,
        fromCF.Position.Z
    ) * fromCF.Rotation

    local toWithOffset = CFrame.new(
        toCF.Position.X,
        toCF.Position.Y + rigOffset,
        toCF.Position.Z
    ) * toCF.Rotation

    local duration = frameTime / math.max(0.05, playbackRate)
    local t = 0
    while t < duration do
        if not isRunning then break end
        local dt = task.wait()
        t += dt
        local alpha = math.min(t / duration, 1)
        if hrp and hrp.Parent and hrp:IsDescendantOf(workspace) then
            hrp.CFrame = fromWithOffset:Lerp(toWithOffset, alpha)
        end
    end
end


-- GUI ELEMENTS
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local StopBtn = Instance.new("TextButton")
local ToSummitBtn = Instance.new("TextButton")
local NearestCPBtn = Instance.new("TextButton")
local DiscordBtn = Instance.new("TextButton")
local SpeedLabel = Instance.new("TextLabel")
local SpeedValue = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MiniBtn = Instance.new("TextButton")
local MiniFrame = Instance.new("Frame")
local MiniUICorner = Instance.new("UICorner")
local MiniText = Instance.new("TextLabel")
local OpenMiniBtn = Instance.new("TextButton")

-- Arrow Buttons
local ArrowLeft = Instance.new("TextButton")
local ArrowLeftCorner = Instance.new("UICorner")
local ArrowRight = Instance.new("TextButton")
local ArrowRightCorner = Instance.new("UICorner")

-- MAIN GUI
main.Name = "Sekay Hub"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- FRAME
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
Frame.Size = UDim2.new(0, 220, 0, 240)
Frame.Position = UDim2.new(0.12, 0, 0.35, 0)
Frame.Active = true
Frame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- TITLE
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.05, 0, 0.02, 0)
Title.Size = UDim2.new(0.9, 0, 0.12, 0)
Title.Text = "Sekay Hub"
Title.TextColor3 = Color3.fromRGB(180, 180, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- STOP BUTTON
StopBtn.Parent = Frame
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
StopBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
StopBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
StopBtn.Text = "STOP"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextScaled = true
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

-- TO SUMMIT BUTTON
ToSummitBtn.Parent = Frame
ToSummitBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
ToSummitBtn.Position = UDim2.new(0.05, 0, 0.27, 0)
ToSummitBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
ToSummitBtn.Text = "TO SUMMIT"
ToSummitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToSummitBtn.Font = Enum.Font.GothamBold
ToSummitBtn.TextScaled = true
Instance.new("UICorner", ToSummitBtn).CornerRadius = UDim.new(0, 8)

-- NEAREST CP BUTTON
NearestCPBtn.Parent = Frame
NearestCPBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
NearestCPBtn.Position = UDim2.new(0.05, 0, 0.39, 0)
NearestCPBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
NearestCPBtn.Text = "NEAREST CP"
NearestCPBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
NearestCPBtn.Font = Enum.Font.GothamBold
NearestCPBtn.TextScaled = true
Instance.new("UICorner", NearestCPBtn).CornerRadius = UDim.new(0, 8)

-- DISCORD BUTTON
DiscordBtn.Parent = Frame
DiscordBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
DiscordBtn.Position = UDim2.new(0.05, 0, 0.51, 0)
DiscordBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
DiscordBtn.Text = "DISCORD"
DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextScaled = true
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 8)

-- SPEED LABEL
SpeedLabel.Parent = Frame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0.05, 0, 0.64, 0)
SpeedLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
SpeedLabel.Text = "YOUR SPEED :"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextScaled = true

-- SPEED VALUE
SpeedValue.Parent = Frame
SpeedValue.BackgroundTransparency = 1
SpeedValue.Position = UDim2.new(0.05, 0, 0.72, 0)
SpeedValue.Size = UDim2.new(0.9, 0, 0.08, 0)
SpeedValue.Text = string.format("%.2fx", playbackRate)
SpeedValue.TextColor3 = Color3.fromRGB(140, 200, 255)
SpeedValue.Font = Enum.Font.GothamBlack
SpeedValue.TextScaled = true

-- STATUS
Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0.05, 0, 0.81, 0)
Status.Size = UDim2.new(0.9, 0, 0.08, 0)
Status.Text = "STATUS : OFF"
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.Font = Enum.Font.Gotham
Status.TextScaled = true

-- ARROW LEFT
ArrowLeft.Parent = Frame
ArrowLeft.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
ArrowLeft.Position = UDim2.new(0.15, 0, 0.90, 0)
ArrowLeft.Size = UDim2.new(0, 40, 0, 25)
ArrowLeft.Text = "←"
ArrowLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
ArrowLeft.Font = Enum.Font.GothamBold
ArrowLeft.TextScaled = true
ArrowLeftCorner.CornerRadius = UDim.new(0, 8)
ArrowLeftCorner.Parent = ArrowLeft

-- ARROW RIGHT
ArrowRight.Parent = Frame
ArrowRight.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
ArrowRight.Position = UDim2.new(0.65, 0, 0.90, 0)
ArrowRight.Size = UDim2.new(0, 40, 0, 25)
ArrowRight.Text = "→"
ArrowRight.TextColor3 = Color3.fromRGB(255, 255, 255)
ArrowRight.Font = Enum.Font.GothamBold
ArrowRight.TextScaled = true
ArrowRightCorner.CornerRadius = UDim.new(0, 8)
ArrowRightCorner.Parent = ArrowRight

-- CLOSE BUTTON
CloseBtn.Parent = Frame
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(0.87, 0, -0.12, 0)
CloseBtn.Size = UDim2.new(0.1, 0, 0.12, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true

-- MINIMIZE BUTTON
MiniBtn.Parent = Frame
MiniBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
MiniBtn.Position = UDim2.new(0.73, 0, -0.12, 0)
MiniBtn.Size = UDim2.new(0.1, 0, 0.12, 0)
MiniBtn.Text = "-"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextScaled = true

-- MINI FRAME
MiniFrame.Parent = main
MiniFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
MiniFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
MiniFrame.Size = UDim2.new(0, 140, 0, 30)
MiniFrame.Visible = false

MiniUICorner.CornerRadius = UDim.new(0, 10)
MiniUICorner.Parent = MiniFrame

MiniText.Parent = MiniFrame
MiniText.BackgroundTransparency = 1
MiniText.Size = UDim2.new(1, 0, 1, 0)
MiniText.Text = "Sekay Hub"
MiniText.TextColor3 = Color3.fromRGB(180, 180, 255)
MiniText.Font = Enum.Font.GothamBold
MiniText.TextScaled = true

OpenMiniBtn.Parent = MiniFrame
OpenMiniBtn.BackgroundTransparency = 1
OpenMiniBtn.Size = UDim2.new(1, 0, 1, 0)
OpenMiniBtn.Text = ""

-- BUTTON FUNCTIONS
CloseBtn.MouseButton1Click:Connect(function()
	main:Destroy()
end)

MiniBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
	MiniFrame.Visible = true
end)

OpenMiniBtn.MouseButton1Click:Connect(function()
	Frame.Visible = true
	MiniFrame.Visible = false
end)

-- DISCORD BUTTON FUNCTION
DiscordBtn.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/sekayhub")
	game.StarterGui:SetCore("SendNotification", {
		Title = "Sekay Hub",
		Text = "Discord link copied!",
		Duration = 3
	})
end)

-- FIXED SPEED CONTROL
ArrowLeft.MouseButton1Click:Connect(function()
    playbackRate = math.max(0.25, playbackRate - 0.25)
    SpeedValue.Text = string.format("%.2fx", playbackRate)
end)
ArrowRight.MouseButton1Click:Connect(function()
    playbackRate = math.min(3, playbackRate + 0.25)
    SpeedValue.Text = string.format("%.2fx", playbackRate)
end)

-- LOGIC
local function runRouteOnce()
    if #routes == 0 then return end
    if not hrp then refreshHRP() end
    isRunning = true
    Status.Text = "STATUS : TO NEAREST CP"
    Status.TextColor3 = Color3.fromRGB(255, 200, 100)

    local idx = getNearestRoute()
    print("▶ Start CP:", routes[idx][1])
    local frames = routes[idx][2]
    if #frames < 2 then isRunning = false return end
    local startIdx = getNearestFrameIndex(frames)
    for i = startIdx, #frames - 1 do
        if not isRunning then break end
        lerpCF(frames[i], frames[i+1])
    end
    isRunning = false
end

local function runAllRoutes()
    if #routes == 0 then return end
    if not hrp then refreshHRP() end
    isRunning = true
    Status.Text = "STATUS : TO SUMMIT"
    Status.TextColor3 = Color3.fromRGB(100, 200, 255)

    local idx = getNearestRoute()
    print("⏩ Start To End dari:", routes[idx][1])
    for r = idx, #routes do
        if not isRunning then break end
        local frames = routes[r][2]
        if #frames < 2 then continue end
        local startIdx = getNearestFrameIndex(frames)
        for i = startIdx, #frames - 1 do
            if not isRunning then break end
            lerpCF(frames[i], frames[i+1])
        end
    end
    isRunning = false
end

local function stopRoute()
    if isRunning then
        print("⏹ Stop ditekan")
    end
    isRunning = false
    Status.Text = "STATUS : OFF"
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- CONNECT BUTTONS
StopBtn.MouseButton1Click:Connect(stopRoute)
ToSummitBtn.MouseButton1Click:Connect(runAllRoutes)
NearestCPBtn.MouseButton1Click:Connect(runRouteOnce)