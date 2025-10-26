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
main.Name = "SIRENHUB"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- FRAME
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
Frame.Size = UDim2.new(0, 220, 0, 240) -- diperkecil lagi
Frame.Position = UDim2.new(0.12, 0, 0.35, 0)
Frame.Active = true
Frame.Draggable = true -- bisa digeser manual

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- TITLE
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.05, 0, 0.02, 0)
Title.Size = UDim2.new(0.9, 0, 0.12, 0)
Title.Text = "SIRENHUB"
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
SpeedValue.Text = "200"
SpeedValue.TextColor3 = Color3.fromRGB(140, 200, 255)
SpeedValue.Font = Enum.Font.GothamBlack
SpeedValue.TextScaled = true

-- STATUS
Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0.05, 0, 0.81, 0)
Status.Size = UDim2.new(0.9, 0, 0.08, 0)
Status.Text = "STATUS : ON"
Status.TextColor3 = Color3.fromRGB(100, 255, 100)
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
MiniFrame.Size = UDim2.new(0, 140, 0, 30) -- kecilin mini frame
MiniFrame.Visible = false

MiniUICorner.CornerRadius = UDim.new(0, 10)
MiniUICorner.Parent = MiniFrame

MiniText.Parent = MiniFrame
MiniText.BackgroundTransparency = 1
MiniText.Size = UDim2.new(1, 0, 1, 0)
MiniText.Text = "SIRENHUB"
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
	setclipboard("https://discord.gg/q2nhZGbKtE")
	game.StarterGui:SetCore("SendNotification", {
		Title = "SIRENHUB",
		Text = "Discord link copied!",
		Duration = 3
	})
end)
