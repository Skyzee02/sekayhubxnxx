-- File: SekayLogin.lua (MODIFIED)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Sekay Hub",
    Footer = "Version: 1.0.2", --small text in the bottom of page
    ToggleKeybind = Enum.KeyCode.RightControl,
    Center = true,
    AutoShow = true,
    Resizable = false, --not rezizeable
    Size = UDim2.fromOffset(700, 500) -- size of ui
})

local KeyTab = Window:AddKeyTab("Login")
local InfoTab = Window:AddTab("Info", "info")
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

KeyTab:AddLabel({
    Text = "Welcome To\nSekay Hub",
    Font = "UI_TextBold",
    Size = 25
})

-- Bagian: Key Input Field
local KeyInput = KeyTab:AddInput({
    Title = "Enter Your Key",
    Placeholder = "SEKAY-KEY",
    OnEnter = function(text)
        -- ... (Kode pengecekan kunci tetap sama)
        if text:len() > 0 then
            -- Kirim notifikasi ke user (opsional)
            Library:Notify("Checking Key: " .. text, 3)

            -- Cek kunci di server (fungsi ini akan memanggil API Key System)
            local success, result = pcall(function()
                return game:HttpGet(
                    "https://api-system-key.vercel.app/api/key/check?key=" .. text .. "&hwid=" .. hwid .. "&id=" .. userid,
                    true
                )
            end)

            if success and result then
                local jsonSuccess, data = pcall(function()
                    return HttpService:JSONDecode(result)
                end)

                if jsonSuccess and data and data.status == 200 then
                    -- KUNCI BENAR
                    
                    -- Update Global Data
                    _G.SIREN_Data = {
                        Key = text,
                        HWID = hwid,
                        RobloxUser = username,
                        RobloxID = userid,
                        ExpireAt = data.key.expire_at,
                        Level = data.key.level,
                        Uplink = "V1.0",
                        Blacklist = data.key.blacklist,
                        Message = data.key.message
                    }

                    -- Simpan kunci ke Whitelist Lokal (untuk auto-login berikutnya)
                    writefile(LOCAL_SAVE_FILE, HttpService:JSONEncode({
                        Key = text,
                        HWID = hwid,
                        UserID = userid
                    }))
                    
                    -- Kirim notifikasi sukses
                    Library:Notify("Correct Key! Access Granted. Welcome, " .. data.key.level, 5)

                    -- TUTUP LOGIN DAN BUKA MENU SECARA INSTAN
                    Window:Hide() -- Sembunyikan UI Login
                    -- Menggunakan task.delay(0) untuk memastikan notifikasi muncul sebelum menutup.
                    task.delay(0, function() 
                        Library:Unload()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
                    end)
                    
                else
                    -- KUNCI SALAH/EXPIRED/BLACKISTED
                    local errorMessage = "Invalid Key"
                    if data and data.message then
                        errorMessage = data.message
                    end
                    Library:Notify(errorMessage, 5)
                end
            else
                -- GAGAL KONEKSI/ERROR PANGGILAN API
                Library:Notify("Error: Failed to connect to Key Server.", 5)
            end
        end
    end
})

-- ... (Fungsi-fungsi lain)

-- Function: CheckRemoteWhitelist
-- Mengecek apakah user adalah Owner/Admin berdasarkan UserID di whitelist.json di GitHub
local function CheckRemoteWhitelist()
    -- ... (Implementasi tetap sama)
    -- ...
    
    if isRemoteWhitelisted then
        return true -- User ada di daftar Remote Whitelist
    end
    
    return false -- User tidak ada di daftar Remote Whitelist
end

-- Function: LoadAndCheckKey
-- Memuat kunci tersimpan (auto-login) dan mengeceknya
local function LoadAndCheckKey()
    -- ... (Implementasi tetap sama)
    -- ...
    
    if keyData and data and data.status == 200 then
        -- KUNCI AUTO-LOGIN BERHASIL
        
        -- Update Global Data
        _G.SIREN_Data = {
            Key = keyData.Key,
            HWID = hwid,
            RobloxUser = username,
            RobloxID = userid,
            ExpireAt = data.key.expire_at,
            Level = data.key.level,
            Uplink = "V1.0",
            Blacklist = data.key.blacklist,
            Message = data.key.message
        }
        
        -- Kirim notifikasi sukses
        Library:Notify("Auto-Login Successful! Welcome, " .. data.key.level, 5)
        
        -- TUTUP LOGIN DAN BUKA MENU SECARA INSTAN
        Window:Hide() -- Sembunyikan UI Login
        -- Menggunakan task.delay(0) untuk membuat transisi instan.
        task.delay(0, function()
            Library:Unload()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
        end)
        
        return true
    end
    
    -- ...
    
    return false
end

-- ... (Bagian akhir script)

-- Jalankan pengecekan login
if CheckRemoteWhitelist() then
    -- Jika user ada di Remote Whitelist (Admin/Owner), berikan akses penuh
    print("User is a whitelisted Admin/Owner. Skipping Key Check.")
    Library:Notify("Admin/Owner Access Granted!", 5)
    
    -- Setup data global layaknya login master key
    -- ... (Setup _G.SIREN_Data tetap sama)
    _G.SIREN_Data = {
        Key = "REMOTE-WHITELIST",
        HWID = hwid,
        RobloxUser = username,
        RobloxID = userid,
        ExpireAt = os.date("%Y-%m-%d %H:%M:%S", remoteKeyData.created_at() + (365 * 24 * 60 * 60 * 10)), -- Lifetime
        Level = "Owner/Admin (Remote)",
        Uplink = "V1.0",
        Blacklist = 0,
        Message = "Login Successfully (Owner/Admin)"
    }

    -- TUTUP LOGIN DAN BUKA MENU SECARA INSTAN
    Window:Hide() -- Sembunyikan UI Login
    -- Mengubah task.delay(1, ...) menjadi task.delay(0, ...) untuk instan
    task.delay(0, function() 
        Library:Unload()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skyzee02/sekayhubxnxx/refs/heads/main/SekayMenu.lua", true))()
    end)

elseif LoadAndCheckKey() then
    -- Jika auto-login berhasil, tidak perlu melakukan apa-apa lagi di sini karena sudah dihandle di dalam LoadAndCheckKey()
    print("Auto-Login Succeeded (Local Save).")
else
    -- ... (Jika auto-login gagal, tampilkan UI Login)
    Window:Show()
    print("No valid key found. Showing Login UI.")
end