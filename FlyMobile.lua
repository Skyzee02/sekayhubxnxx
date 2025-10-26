local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Toggle = Instance.new("TextButton")
local SpeedLabel = Instance.new("TextLabel")
local SpeedValue = Instance.new("TextLabel")
local SpeedUp = Instance.new("TextButton")
local SpeedDown = Instance.new("TextButton")
local Status = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MiniBtn = Instance.new("TextButton")
local MiniFrame = Instance.new("Frame")
local MiniUICorner = Instance.new("UICorner")
local MiniText = Instance.new("TextLabel")
local OpenMiniBtn = Instance.new("TextButton")
local ArrowUp = Instance.new("TextButton")
local ArrowDown = Instance.new("TextButton")
local ArrowUpCorner = Instance.new("UICorner")
local ArrowDownCorner = Instance.new("UICorner")

-- MAIN GUI
main.Name = "Sekay Hub"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- FRAME
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
Frame.Size = UDim2.new(0, 260, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- TITLE
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.05, 0, 0.02, 0)
Title.Size = UDim2.new(0.9, 0, 0.2, 0)
Title.Text = "Sekay Hub"
Title.TextColor3 = Color3.fromRGB(180, 180, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- TOGGLE BUTTON
Toggle.Name = "Toggle"
Toggle.Parent = Frame
Toggle.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
Toggle.Position = UDim2.new(0.05, 0, 0.3, 0)
Toggle.Size = UDim2.new(0.4, 0, 0.2, 0)
Toggle.Text = "TOGGLE"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextScaled = true

-- SPEED LABEL
SpeedLabel.Parent = Frame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0.5, 0, 0.28, 0)
SpeedLabel.Size = UDim2.new(0.45, 0, 0.15, 0)
SpeedLabel.Text = "YOUR SPEED"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextScaled = true

SpeedValue.Parent = Frame
SpeedValue.BackgroundTransparency = 1
SpeedValue.Position = UDim2.new(0.5, 0, 0.45, 0)
SpeedValue.Size = UDim2.new(0.45, 0, 0.2, 0)
SpeedValue.Text = "200"
SpeedValue.TextColor3 = Color3.fromRGB(140, 200, 255)
SpeedValue.Font = Enum.Font.GothamBold
SpeedValue.TextScaled = true

-- SPEED UP
SpeedUp.Parent = Frame
SpeedUp.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
SpeedUp.Position = UDim2.new(0.05, 0, 0.55, 0)
SpeedUp.Size = UDim2.new(0.4, 0, 0.15, 0)
SpeedUp.Text = "SPEED UP"
SpeedUp.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedUp.Font = Enum.Font.GothamBold
SpeedUp.TextScaled = true

-- SPEED DOWN
SpeedDown.Parent = Frame
SpeedDown.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
SpeedDown.Position = UDim2.new(0.05, 0, 0.72, 0)
SpeedDown.Size = UDim2.new(0.4, 0, 0.15, 0)
SpeedDown.Text = "SPEED DOWN"
SpeedDown.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedDown.Font = Enum.Font.GothamBold
SpeedDown.TextScaled = true

-- STATUS
Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0.5, 0, 0.7, 0)
Status.Size = UDim2.new(0.45, 0, 0.2, 0)
Status.Text = "STATUS : OFF"
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.Font = Enum.Font.Gotham
Status.TextScaled = true

-- CLOSE BUTTON
CloseBtn.Parent = Frame
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(0.88, 0, -0.15, 0)
CloseBtn.Size = UDim2.new(0.12, 0, 0.15, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true

-- MINIMIZE BUTTON
MiniBtn.Parent = Frame
MiniBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
MiniBtn.Position = UDim2.new(0.75, 0, -0.15, 0)
MiniBtn.Size = UDim2.new(0.12, 0, 0.15, 0)
MiniBtn.Text = "-"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextScaled = true

-- MINI FRAME
MiniFrame.Parent = main
MiniFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
MiniFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
MiniFrame.Size = UDim2.new(0, 150, 0, 40)
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

-- ARROW UP BUTTON
ArrowUp.Parent = main
ArrowUp.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
ArrowUp.Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset + Frame.Size.X.Offset + 10, Frame.Position.Y.Scale, Frame.Position.Y.Offset)
ArrowUp.Size = UDim2.new(0, 40, 0, 40)
ArrowUp.Text = "↑"
ArrowUp.TextColor3 = Color3.fromRGB(255, 255, 255)
ArrowUp.Font = Enum.Font.GothamBold
ArrowUp.TextScaled = true
ArrowUpCorner.CornerRadius = UDim.new(0, 8)
ArrowUpCorner.Parent = ArrowUp

-- ARROW DOWN BUTTON
ArrowDown.Parent = main
ArrowDown.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
ArrowDown.Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset + Frame.Size.X.Offset + 10, Frame.Position.Y.Scale, Frame.Position.Y.Offset + 50)
ArrowDown.Size = UDim2.new(0, 40, 0, 40)
ArrowDown.Text = "↓"
ArrowDown.TextColor3 = Color3.fromRGB(255, 255, 255)
ArrowDown.Font = Enum.Font.GothamBold
ArrowDown.TextScaled = true
ArrowDownCorner.CornerRadius = UDim.new(0, 8)
ArrowDownCorner.Parent = ArrowDown

-- BUTTON FUNCTIONS
CloseBtn.MouseButton1Click:Connect(function()
	main:Destroy()
end)

MiniBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
	MiniFrame.Visible = true
	ArrowUp.Visible = false
	ArrowDown.Visible = false
end)

OpenMiniBtn.MouseButton1Click:Connect(function()
	Frame.Visible = true
	MiniFrame.Visible = false
	ArrowUp.Visible = true
	ArrowDown.Visible = true
end)

speeds = 1
SpeedValue.Text = tostring(speeds)

local speaker = game:GetService("Players").LocalPlayer

local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

nowe = false

Frame.Active = true -- main = gui
Frame.Draggable = true

Toggle.MouseButton1Down:connect(function()

	if nowe == true then
		nowe = false

        Status.Text = "STATUS : OFF"
		Status.TextColor3 = Color3.fromRGB(255, 100, 100)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true
        Status.Text = "STATUS : ON"
		Status.TextColor3 = Color3.fromRGB(140, 255, 140)



		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
		game.Players.LocalPlayer.Character.Animate.Disabled = true
		local Char = game.Players.LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end




	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then



		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Torso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			--	game.Players.LocalPlayer.Character.Animate.Disabled = true
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false




	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false



	end





end)

local tis

ArrowUp.MouseButton1Down:connect(function()
	tis = ArrowUp.MouseEnter:connect(function()
		while tis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)

ArrowUp.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis

ArrowDown.MouseButton1Down:connect(function()
	dis = ArrowDown.MouseEnter:connect(function()
		while dis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)

ArrowDown.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)


game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
	game.Players.LocalPlayer.Character.Animate.Disabled = false

end)

----------------------------------------------------
-- SPEED UP
----------------------------------------------------
SpeedUp.MouseButton1Down:Connect(function()
	speeds = speeds + 1
	SpeedValue.Text = tostring(speeds)

	if nowe == true then
		tpwalking = false
		for i = 1, speeds do
			spawn(function()
				local hb = game:GetService("RunService").Heartbeat	
				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
	end
end)

----------------------------------------------------
-- SPEED DOWN
----------------------------------------------------
SpeedDown.MouseButton1Down:Connect(function()
	if speeds == 1 then
		SpeedValue.Text = "cannot be less than 1"
		wait(1)
		SpeedValue.Text = tostring(speeds)
	else
		speeds = speeds - 1
		SpeedValue.Text = tostring(speeds)

		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()
					local hb = game:GetService("RunService").Heartbeat	
					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end
				end)
			end
		end
	end
end)