-- Konversi dari Obsidian/Linoria Library menjadi Wind UI Library
local Wind = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/WindUI.lua"))()

local Window = Wind:CreateWindow({
    Title = "Sekay Hub",
    Footer = "Version: 1.0.2", -- small text in the bottom of page
    ToggleKeybind = Enum.KeyCode.RightControl, -- Keybind untuk membuka/menutup
    Center = true,
    AutoShow = true,
    Resizable = false, -- not rezizeable
    Size = UDim2.fromOffset(700, 500) -- size of ui
})

-- Konversi Window:AddKeyTab & Window:AddTab menjadi Window:Tab
local KeyTab = Window:Tab({Title = "Login", Icon = "key"})
local InfoTab = Window:Tab({Title = "Info", Icon = "info"})

local Analytics = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hwid = Analytics:GetClientId()
local username = player and player.Name or "Unknown"
local userid = player and player.UserId or "Unknown"

-- !!! MODIFIKASI: Mengubah nama file penyimpanan lokal
local LOCAL_SAVE_FILE = "whitelist.json" 

-- Ganti dengan link GitHub kamu untuk Whitelist (contoh URL mentah)
local REMOTE_WHITELIST_URL = "https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/whitelist.json"

-- Variabel global lokal untuk menyimpan data KeyWhitelist yang dimuat dari REMOTE_WHITELIST_URL
local KeyWhitelist = {} 

-- Semua elemen perlu diletakkan di dalam Section
local LoginSection = KeyTab:Section({Title = "Key Login"})
local InfoSection = InfoTab:Section({Title = "Information"})

-- KeyTab:AddLabel diganti dengan Section:Label
LoginSection:Label({
    Text = "Welcome To\nSekay Hub",
})

-- KeyTab:AddInput diganti dengan Section:Input (menghilangkan ID string pertama)
local KeyInput = LoginSection:Input({
    Title = "Key", -- Menggantikan ID string pertama
    Text = "Enter your key here...",
    Default = "",
})

-- KeyTab:AddButton diganti dengan Section:Button
LoginSection:Button({
    Title = "Login", -- Tambahkan properti Title
    Func = function()
        local key = KeyInput.Value or ""

        if key == "" then
            Wind:Notify("Key cannot be empty.", 5) -- Konversi Library:Notify
            return
        end
        
        -- Fungsi LoadAndCheckKey, FetchKeyWhitelist, dan CheckRemoteWhitelist yang asli harus dimuat di sini,
        -- dan semua panggilan Library:Notify harus diganti dengan Wind:Notify.
        
        -- Contoh ketika sukses:
        -- if LoadAndCheckKey() then
        --     Window:SetVisible(false) -- Konversi Window:Hide()
        --     task.delay(1, function()
        --         Wind:Unload() -- Konversi Library:Unload
        --         loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
        --     end)
        -- end
    end,
})

-- InfoTab:AddLabel
InfoSection:Label({
    Text = "Informasi Hub:\n\nSekay Hub V1.0.2\nDiscord: discord.gg/xxxxx\nDeveloper: Sekayzee",
})

-- InfoTab:AddButton
InfoSection:Button({
    Title = "Join Discord",
    Func = function()
        Wind:Notify("Coming Soon!", 5) -- Konversi Library:Notify
    end
})