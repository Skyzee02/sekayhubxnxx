-- GUI MUsic.lua - Client side (LocalScript)
-- Versi final: tata letak & fungsi disesuaikan sesuai permintaan user.
-- TEMA / WARNA / FONT / STYLE TIDAK DIUBAH.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes (pastikan ada di ReplicatedStorage, server membuatnya)
local RequestSong = ReplicatedStorage:WaitForChild("RequestSong")
local UpdateQueue = ReplicatedStorage:WaitForChild("UpdateQueue")
local PlaySongEvent = ReplicatedStorage:WaitForChild("PlaySongEvent")
local UpdateFavorites = ReplicatedStorage:WaitForChild("UpdateFavorites")
local SkipVote = ReplicatedStorage:WaitForChild("SkipVote")

-- Helper create
local function new(className, props)
	local inst = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

-- Remove old GUI jika ada
local existing = playerGui:FindFirstChild("MusicUI")
if existing then existing:Destroy() end

-- ScreenGui
local screenGui = new("ScreenGui",{Name="MusicUI",ResetOnSpawn=false,Parent=playerGui,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})

-- Main modal frame (centered)
local modal = new("Frame",{Size=UDim2.new(0,920,0,520),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.fromRGB(18,18,22),Parent=screenGui})
new("UICorner",{CornerRadius=UDim.new(0,12)}).Parent=modal
new("UIStroke",{Color=Color3.fromRGB(0,191,165),Thickness=2}).Parent=modal

-- Toggle Button (top-left)
local toggleBtn = new("TextButton",{Size=UDim2.new(0,56,0,56),Position=UDim2.new(0,12,0,12),Text="🎵",Font=Enum.Font.GothamBold,TextSize=26,BackgroundColor3=Color3.fromRGB(0,191,165),Parent=screenGui})
new("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=toggleBtn
modal.Visible = false
toggleBtn.MouseButton1Click:Connect(function() modal.Visible = not modal.Visible end)

-- Close button
local closeBtn = new("TextButton",{Size=UDim2.new(0,34,0,34),Position=UDim2.new(1,-42,0,10),Text="✕",Font=Enum.Font.GothamBold,TextSize=18,BackgroundColor3=Color3.fromRGB(30,30,30),TextColor3=Color3.fromRGB(1,1,1),Parent=modal})
new("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function() modal.Visible = false end)

-- Panels: left, mid, right
local leftPanel = new("Frame",{Size=UDim2.new(0,240,1, -60),Position=UDim2.new(0,16,0,30),BackgroundColor3=Color3.fromRGB(28,28,34),Parent=modal})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=leftPanel

local midPanel = new("Frame",{Size=UDim2.new(0,420,1,-60),Position=UDim2.new(0,272,0,30),BackgroundColor3=Color3.fromRGB(38,34,54),Parent=modal})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=midPanel

-- Right panel width diperbaiki agar tidak overflow (200px)
local rightPanel = new("Frame",{Size=UDim2.new(0,200,1,-60),Position=UDim2.new(0,704,0,30),BackgroundColor3=Color3.fromRGB(28,28,34),Parent=modal})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=rightPanel

-- Bottom now playing panel
local bottomPanel = new("Frame",{Size=UDim2.new(1,-32,0,110),Position=UDim2.new(0,16,1,-112),BackgroundColor3=Color3.fromRGB(8,8,8),Parent=modal})
new("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=bottomPanel
new("UIStroke",{Color=Color3.fromRGB(40,40,40),Thickness=1}).Parent=bottomPanel

-- --- LEFT PANEL: Header & Favorites + Playlist (UI tetap sama style)
local leftHeader = new("TextLabel",{Size=UDim2.new(1,0,0,36),Text="RAVE Social Club",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Parent=leftPanel})

-- Favorites block (kita akan isi ulang favList dengan TextButton items)
local favHeader = new("TextLabel",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,36),Text="♥ Favorites",Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(0,255,128),BackgroundTransparency=1,Parent=leftPanel})
local favCount = new("TextLabel",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,64),Text="0",Font=Enum.Font.Gotham,TextSize=12,TextColor3=Color3.fromRGB(200,200,200),BackgroundTransparency=1,Parent=leftPanel})

-- Make favList a scrolling frame that will hold TextButton items
local favList = new("ScrollingFrame",{
	Size = UDim2.new(1,0,0,60),
	Position = UDim2.new(0,0,0,84),
	BackgroundTransparency=1,
	ScrollBarThickness=6,
	Parent=leftPanel
})
new("UIListLayout",{Padding=UDim.new(0,6)}).Parent=favList

-- Playlist header & list (we'll keep list items as TextButton that populate midList)
local playlistHeader = new("TextLabel",{
	Size=UDim2.new(1,0,0,28),
	Position=UDim2.new(0,0,0,150), -- lebih tinggi dari sebelumnya
	Text="Playlist",
	Font=Enum.Font.GothamBold,
	TextSize=14,
	TextColor3=Color3.fromRGB(255,255,255),
	BackgroundTransparency=1,
	Parent=leftPanel
})
local playlistList = new("ScrollingFrame",{
	Size=UDim2.new(1,0,0,200), -- lebih besar biar muat banyak
	Position=UDim2.new(0,0,0,178),
	BackgroundTransparency=1,
	ScrollBarThickness=6,
	Parent=leftPanel
})
new("UIListLayout",{Padding=UDim.new(0,6)}).Parent=playlistList

-- --- MID PANEL: Catalog, Search, SongID (we remove tabs)
local midHeaderFrame = new("Frame",{Size=UDim2.new(1,0,0,66),BackgroundTransparency=1,Parent=midPanel})
new("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=midHeaderFrame

-- CATALOG title diperbesar
local catTitle = new("TextLabel",{Size=UDim2.new(0.7,0,1,0),Position=UDim2.new(0.02,0,0,0),Text="CATALOG",Font=Enum.Font.GothamBold,TextSize=28,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Parent=midHeaderFrame})
local skipLabel = new("TextLabel",{Size=UDim2.new(0.28, -8, 1, 0),Position=UDim2.new(0.7,8,0,0),Text="SKIP/PASS 0/10",Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(200,200,200),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,Parent=midHeaderFrame})

-- NOTE: tabsFrame *dihapus* (tidak dibuat lagi) sesuai permintaan

-- Search bar (tetap)
local searchBox = new("TextBox",{Size=UDim2.new(1,-24,0,38),Position=UDim2.new(0,12,0,108),PlaceholderText="Search Song",Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(40,40,50),Parent=midPanel})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=searchBox

-- Song list
local midList = new("ScrollingFrame",{Size=UDim2.new(1,-24,1,-170),Position=UDim2.new(0,12,0,156),BackgroundTransparency=1,ScrollBarThickness=6,Parent=midPanel})
new("UIListLayout",{Padding=UDim.new(0,6)}).Parent=midList

-- Song ID input + play button (panel center bottom, above bottomPanel)
local songIdBox = new("TextBox",{Size=UDim2.new(0.7,-12,0,36),Position=UDim2.new(0.02,0,1,-44),PlaceholderText="SONG ID",Font=Enum.Font.Gotham,TextSize=14,BackgroundColor3=Color3.fromRGB(60,60,60),Parent=midPanel})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=songIdBox
local playIdBtn = new("TextButton",{Size=UDim2.new(0.22,0,0,36),Position=UDim2.new(0.74,0,1,-44),Text="▶",Font=Enum.Font.GothamBold,TextSize=18,BackgroundColor3=Color3.fromRGB(0,191,165),Parent=midPanel})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=playIdBtn

-- --- RIGHT PANEL: Playback Queue
local rightHeader = new("TextLabel",{Size=UDim2.new(1,0,0,36),Text="PLAYBACK QUEUE",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Parent=rightPanel})
local queueList = new("ScrollingFrame",{Size=UDim2.new(1,0,1,-36),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1,ScrollBarThickness=6,Parent=rightPanel})
new("UIListLayout",{Padding=UDim.new(0,8)}).Parent=queueList

-- --- BOTTOM PANEL: Now Playing (headshot, title, requester, play toggle, fav, id)
local headshot = new("ImageLabel",{Size=UDim2.new(0,84,0,84),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,Image="rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=100&h=100",Parent=bottomPanel})
new("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=headshot

local songTitle = new("TextLabel",{Size=UDim2.new(0.56,0,0,28),Position=UDim2.new(0.08,0,0,10),Text="No Song",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Parent=bottomPanel})
-- ID di samping judul
local songIdLabel = new("TextLabel",{Size=UDim2.new(0.25,0,0,28),Position=UDim2.new(0.72,0,0,10),Text="ID: -",Font=Enum.Font.Gotham,TextSize=14,BackgroundTransparency=1,TextColor3=Color3.fromRGB(200,200,200),TextXAlignment=Enum.TextXAlignment.Left,Parent=bottomPanel})

-- Requested by label tepat di bawah judul (sudah sesuai)
local requesterLbl = new("TextLabel",{Size=UDim2.new(0.56,0,0,18),Position=UDim2.new(0.08,0,0,40),Text="",Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(180,180,180),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Parent=bottomPanel})

-- Controls group: center controls with Play + Skip
local controls = new("Frame",{Size=UDim2.new(0,160,0,84),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,6),BackgroundTransparency=1,Parent=bottomPanel})

-- Play/Pause toggle
local playBtn = new("TextButton",{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,0,0,6),Text="▶",Font=Enum.Font.GothamBold,TextSize=28,BackgroundColor3=Color3.fromRGB(255,255,255),TextColor3=Color3.fromRGB(0,0,0),Parent=controls})
new("UICorner",{CornerRadius=UDim.new(0,12)}).Parent=playBtn

-- Skip button di sebelah play
local skipBtn = new("TextButton",{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,80,0,6),Text="⏭",Font=Enum.Font.GothamBold,TextSize=28,BackgroundColor3=Color3.fromRGB(200,200,200),TextColor3=Color3.fromRGB(0,0,0),Parent=controls})
new("UICorner",{CornerRadius=UDim.new(0,12)}).Parent=skipBtn

-- Favorite heart (fungsi tetap)
local favBtn = new("TextButton",{Size=UDim2.new(0,38,0,38),Position=UDim2.new(0.5,0,0,64),AnchorPoint=Vector2.new(0.5,0),Text="♡",Font=Enum.Font.GothamBold,TextSize=22,BackgroundColor3=Color3.fromRGB(10,10,10),TextColor3=Color3.fromRGB(0,255,128),Parent=controls})
new("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=favBtn

-- Volume slider (client-only) - visible and functional
local volBar = new("Frame",{Size=UDim2.new(0.6,0,0,8),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,1,-18),BackgroundColor3=Color3.fromRGB(80,80,80),Parent=bottomPanel})
new("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=volBar
local volFill = new("Frame",{Size=UDim2.new(0.6,0,1,0),BackgroundColor3=Color3.fromRGB(0,191,165),Parent=volBar})
local volKnob = new("ImageButton",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-8,0.5,-8),BackgroundColor3=Color3.fromRGB(255,255,255),Parent=volBar})
new("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=volKnob

local timeStart = new("TextLabel",{Size=UDim2.new(0.2,0,0,18),Position=UDim2.new(0.02,0,1,-36),Text="0:00",Font=Enum.Font.Gotham,TextSize=12,BackgroundTransparency=1,TextColor3=Color3.fromRGB(200,200,200),Parent=bottomPanel})
local timeEnd = new("TextLabel",{Size=UDim2.new(0.2,0,0,18),Position=UDim2.new(0.78,0,1,-36),Text="0:00",Font=Enum.Font.Gotham,TextSize=12,BackgroundTransparency=1,TextColor3=Color3.fromRGB(200,200,200),Parent=bottomPanel})

-- Internal state
local nowPlaying = nil
local clientVolume = 1
local draggingVol = false
local myFavorites = {} -- table keyed by id/assetId -> song table
local currentGlobalSound = nil
local localPreviewSound = nil -- optional local preview sound for client-only control
local isLocalPaused = false

-- UTIL: format seconds to M:SS
local function fmtTime(sec)
	sec = math.max(0, math.floor(sec or 0))
	local m = math.floor(sec/60)
	local s = sec % 60
	return string.format("%d:%02d", m, s)
end

-- ===========================
-- UI helper functions
-- ===========================
local function refreshFavoritesUI()
	-- clear isi lama
	for _,c in pairs(favList:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end

	-- hitung jumlah favorit
	local favCount = 0
	for _ in pairs(myFavorites) do
		favCount = favCount + 1
	end

	-- jika tidak ada favorit, tampilkan tombol info
	if favCount == 0 then
		local infoBtn = Instance.new("TextLabel")
		infoBtn.Size = UDim2.new(1,0,0,34)
		infoBtn.Text = "No favorites yet"
		infoBtn.Font = Enum.Font.Gotham
		infoBtn.TextSize = 14
		infoBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
		infoBtn.TextColor3 = Color3.fromRGB(255,255,255)
		infoBtn.Parent = favList
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,6)
		corner.Parent = infoBtn
		return
	end

	-- tombol utama Favorite (count)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,0,0,34)
	btn.Text = "Favorites ("..favCount..")"
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(40,40,48)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Parent = favList
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		local favSongs = {}
		for _, song in pairs(myFavorites) do
			table.insert(favSongs, song)
		end
		populateCatalog(favSongs)
	end)
end



local function populatePlaylist()
	-- clear old
	for _,c in pairs(playlistList:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end

	local genres = {
		"Breakbeat", "Indobounce", "Amapiano",
		"Bailfunk", "RnB", "UKG", "Guaracha"
	}

	for _, name in ipairs(genres) do
		local btn = new("TextButton",{
			Size=UDim2.new(1,0,0,36),
			Text=name,
			Font=Enum.Font.Gotham,
			TextSize=14,
			BackgroundColor3=Color3.fromRGB(35,35,40),
			TextColor3=Color3.fromRGB(255,255,255),
			Parent=playlistList
		})
		new("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=btn

		btn.MouseButton1Click:Connect(function()
			-- contoh isi playlist (dummy IDs, ganti dengan real kalau ada)
			local songs = {}
			for i=1,8 do
				table.insert(songs, {
					title = name .. " Track " .. i,
					assetId = 81624185650299,
					id = "81624185650299"
				})
			end
			populateCatalog(songs)
		end)
	end
end

function populateCatalog(songs)
	for _,c in pairs(midList:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end

	for _, song in ipairs(songs) do
		local row = new("Frame",{
			Size=UDim2.new(1,0,0,48),
			BackgroundColor3=Color3.fromRGB(60,60,70), -- lebih terang biar kelihatan
			Parent=midList
		})
		new("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=row

		local title = new("TextLabel",{
			Size=UDim2.new(0.65,0,1,0),
			Text = song.title or ("Song "..(song.id or "?")),
			Font=Enum.Font.Gotham,
			TextSize=14,
			TextColor3=Color3.fromRGB(255,255,255),
			BackgroundTransparency=1,
			Position=UDim2.new(0.02,0,0,0),
			Parent=row
		})

		local playBtnLocal = new("TextButton",{
			Size=UDim2.new(0.14,0,0,36),
			Position=UDim2.new(0.68,0,0,6),
			Text="▶",
			Font=Enum.Font.GothamBold,
			TextSize=18,
			BackgroundColor3=Color3.fromRGB(0,191,165),
			Parent=row
		})
		new("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=playBtnLocal

		local loveBtn = new("TextButton",{
			Size=UDim2.new(0.14,0,0,36),
			Position=UDim2.new(0.84,0,0,6),
			Text="♡",
			Font=Enum.Font.GothamBold,
			TextSize=18,
			BackgroundColor3=Color3.fromRGB(30,30,30),
			TextColor3=Color3.fromRGB(0,255,128),
			Parent=row
		})
		new("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=loveBtn

		playBtnLocal.MouseButton1Click:Connect(function()
			RequestSong:FireServer(song)
		end)

		loveBtn.MouseButton1Click:Connect(function()
			local key = song.assetId or song.id or song.title
			if myFavorites[key] then
				myFavorites[key] = nil
				UpdateFavorites:FireServer(song, "unlove")
				loveBtn.Text = "♡"
			else
				myFavorites[key] = song
				UpdateFavorites:FireServer(song, "love")
				loveBtn.Text = "♥"
			end
			refreshFavoritesUI()
		end)
	end
end


-- Popular songs default (menggunakan ID contoh user)
local popularSongs = {
	{ title = "Sample Popular 1", assetId = 81624185650299, id = "81624185650299" },
	{ title = "Sample Popular 2", assetId = 81624185650299, id = "81624185650299" },
	{ title = "Sample Popular 3", assetId = 81624185650299, id = "81624185650299" }
}

-- initial populate
populatePlaylist()
populateCatalog(popularSongs) -- default = Popular

-- Search functionality (filter current list by title)
local function filterCatalog(text)
	text = (text or ""):lower()
	local children = midList:GetChildren()
	for _, child in ipairs(children) do
		if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
			local lbl = child:FindFirstChildOfClass("TextLabel")
			if lbl then
				local ok = lbl.Text:lower():find(text) ~= nil
				child.Visible = ok
			end
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	filterCatalog(searchBox.Text)
end)

-- Play by ID button (Panel Center bottom - above bottom panel)
playIdBtn.MouseButton1Click:Connect(function()
	local txt = songIdBox.Text
	if txt and txt ~= "" then
		local song = { id = tostring(txt), title = "Song ID "..tostring(txt), assetId = tostring(txt) }
		RequestSong:FireServer(song)
		songIdBox.Text = ""
	end
end)

-- ===========================
-- Play/Pause (client) + local preview handling + volume slider (client)
-- ===========================
-- We'll attempt to control local hearing by:
-- 1) Trying to find workspace.GlobalMusicSound and letting client pause/resume it (may affect other clients in edge cases).
-- 2) Additionally create a local preview sound under PlayerGui when user toggles local preview (optional).
-- For simplicity: we will pause/resume the workspace sound locally when possible and also adjust volume locally.

local function setLocalVolume(vol)
	clientVolume = math.clamp(vol,0,1)
	-- adjust local perception: if there's a global sound instance, try to set its Volume locally
	local g = workspace:FindFirstChild("GlobalMusicSound")
	if g then
		-- pcall in case of replication restrictions
		pcall(function() g.Volume = clientVolume end)
	end
	-- if we have a local preview, also set its volume
	if localPreviewSound and localPreviewSound:IsA("Sound") then
		pcall(function() localPreviewSound.Volume = clientVolume end)
	end
end

-- volume slider interaction
volKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingVol = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingVol = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingVol and input.UserInputType == Enum.UserInputType.MouseMovement then
		local x = math.clamp(input.Position.X - volBar.AbsolutePosition.X, 0, volBar.AbsoluteSize.X)
		local frac = x / volBar.AbsoluteSize.X
		volFill.Size = UDim2.new(frac,0,1,0)
		volKnob.Position = UDim2.new(frac, -8, 0.5, -8)
		setLocalVolume(frac)
	end
end)

-- Play/Pause client toggle: pause/resume local perception of GlobalMusicSound
local function updatePlayButtonVisual()
	if isLocalPaused then
		playBtn.Text = "▶"
	else
		playBtn.Text = "⏸"
	end
end

playBtn.MouseButton1Click:Connect(function()
	isLocalPaused = not isLocalPaused
	updatePlayButtonVisual()
	-- try to pause/resume workspace sound
	local g = workspace:FindFirstChild("GlobalMusicSound")
	if g then
		pcall(function()
			if isLocalPaused then
				g:Pause()
			else
				g:Resume()
			end
		end)
	end
end)

-- Skip button (client fires skip vote to server)
skipBtn.MouseButton1Click:Connect(function()
	SkipVote:FireServer()
end)

-- Favorite bottom toggles for current nowPlaying
favBtn.MouseButton1Click:Connect(function()
	if not nowPlaying then return end
	local key = nowPlaying.song.assetId or nowPlaying.song.id or nowPlaying.song.title
	if myFavorites[key] then
		myFavorites[key] = nil
		UpdateFavorites:FireServer(nowPlaying.song, "unlove")
		favBtn.Text = "♡"
	else
		myFavorites[key] = nowPlaying.song
		UpdateFavorites:FireServer(nowPlaying.song, "love")
		favBtn.Text = "♥"
	end
	refreshFavoritesUI()
end)

-- Handle queue update from server
UpdateQueue.OnClientEvent:Connect(function(queue)
	-- clear queueList
	for _,c in pairs(queueList:GetChildren()) do
		if c:IsA("TextLabel") or c:IsA("Frame") or c:IsA("TextButton") then
			if not (c == queueList:FindFirstChildOfClass("UIListLayout")) then
				c:Destroy()
			end
		end
	end
	for i, entry in ipairs(queue) do
		local label = new("TextLabel",{Size=UDim2.new(1,0,0,34),Text = tostring(i) .. ". " .. (entry.song.title or tostring(entry.song.id)),Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Parent=queueList})
		label.TextWrapped = true
	end
	-- update canvas size
	local layout = queueList:FindFirstChildOfClass("UIListLayout")
	if layout then
		queueList.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
	end
end)

-- Handle now playing from server: accepts optional skipStatus as second param
PlaySongEvent.OnClientEvent:Connect(function(entry, skipStatus)
	nowPlaying = entry
	if not entry then
		songTitle.Text = "No Song"
		requesterLbl.Text = ""
		songIdLabel.Text = "ID: -"
		timeStart.Text = "0:00"
		timeEnd.Text = "0:00"
		currentGlobalSound = nil
		skipLabel.Text = "SKIP/PASS 0/10"
		return
	end

	-- Update UI
	songTitle.Text = entry.song.title or ("Song "..(entry.song.id or entry.song.assetId or "-"))
	requesterLbl.Text = "Requested by: " .. (entry.requester or "Unknown")
	songIdLabel.Text = "ID: " .. (entry.song.assetId or entry.song.id or "-")

	-- Skip label update (server may send status string)
	if skipStatus and type(skipStatus) == "string" then
		skipLabel.Text = skipStatus
	else
		skipLabel.Text = "SKIP/PASS 0/10"
	end

	-- Try to update headshot (requesterUserId exists)
	if entry.requesterUserId then
		local success, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(entry.requesterUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if success and thumb then
			headshot.Image = thumb
		end
	end

	-- Wait for global sound to appear in workspace (created by server)
	spawn(function()
		local tries = 0
		while tries < 60 do
			local g = workspace:FindFirstChild("GlobalMusicSound")
			if g then
				currentGlobalSound = g
				-- set volume safely
				if currentGlobalSound and typeof(currentGlobalSound.Volume) == "number" then
					currentGlobalSound.Volume = clientVolume
				end
				break
			end
			tries = tries + 1
			task.wait(0.1)
		end
	end)
end)

-- Update favorites list when server sends it
UpdateFavorites.OnClientEvent:Connect(function(favListFromServer)
	for _, s in ipairs(favListFromServer or {}) do
		local key = s.assetId or s.id or s.title
		myFavorites[key] = s  -- menambahkan atau update
	end
	refreshFavoritesUI()
end)

-- RenderStepped: update progress bar/time from the global sound (server-created)
RunService.RenderStepped:Connect(function(dt)
	if currentGlobalSound and nowPlaying then
		local okPos, timePos = pcall(function() return currentGlobalSound.TimePosition end)
		local okLen, timeLen = pcall(function() return currentGlobalSound.TimeLength end)
		timePos = okPos and timePos or 0
		timeLen = okLen and timeLen or 0
		if timeLen > 0 then
			local frac = math.clamp(timePos / timeLen, 0, 1)
			-- progress visual update
			-- we will show progressFill in midPanel or bottomPanel; create if missing
			if not bottomPanel:FindFirstChild("progressFill") then
				-- create a progress bar on bottomPanel if not exists
				local progressBar = new("Frame",{Name="progressBar",Size=UDim2.new(0.6,0,0,6),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,1,-40),BackgroundColor3=Color3.fromRGB(60,60,60),Parent=bottomPanel})
				new("UICorner",{CornerRadius=UDim.new(0,6)}).Parent(progressBar)
				local progressFillLocal = new("Frame",{Name="progressFill",Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(0,191,165),Parent=progressBar})
			end
			local progressFillLocal = bottomPanel:FindFirstChild("progressBar") and bottomPanel.progressBar:FindFirstChild("progressFill")
			if progressFillLocal then progressFillLocal.Size = UDim2.new(frac,0,1,0) end
			timeStart.Text = fmtTime(timePos)
			timeEnd.Text = fmtTime(timeLen)
		else
			timeStart.Text = "0:00"
			timeEnd.Text = fmtTime(timeLen)
		end
	end
end)

-- DO NOT auto-request ping on join (removed accidental ping to server)
-- RequestSong:FireServer("ping") -- removed

-- Final note
print("[MusicUI] Ready (layout adjusted, tabs removed, favorites -> populate center, single play/pause).")