-- ==========================================
-- Nova Flick v35 | FOV Fill Fix + BulletHandler Silent Aim
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local scriptStartTime = os.time()

local FOV_Circle, FOV_Fill
local ESP_Objects = {}
local Bot_ESP_Objects = {}
local CreateESP
local RemoveESP
local ApplyWeaponSkin
local closest
local ToggleMenu
local Watermark

local Settings = {
    ESP_Enabled = false, Bot_ESP_Enabled = false, Aimbot_Enabled = false,
    Aimbot_FOV = 150, Aimbot_Smoothness = 0.25, Menu_Open = true,
    CurrentTab = "Combat", CurrentSkin = "Default",
    Speed_Enabled = false, Speed_Value = 16,
    Fullbright = false, NightMode = false,
    Hitbox_Enabled = false, Hitbox_Size = 3, Hitbox_Show = false,
    Watermark_Enabled = true, Menu_Key = "S",
    ESP_FillColor = "Red", ESP_FillTransparency = 0.5, ESP_OutlineColor = "White",
    Aimbot_TargetPart = "Head", Aimbot_Prediction = 0,
    AutoLoad_Enabled = true,
    Watermark_Color = "Red",
    Watermark_Position = "TopRight",
    Watermark_ShowFPS = true,
    SilentAim_Enabled = false,
    SilentAim_FOV = 150,
    SilentAim_TargetPart = "Head",
    SkinTransparency = 0,
    FOV_Circle_Show = true,
    FOV_Circle_Transparency = 0.8
}

local Colors = {
    Background = Color3.fromRGB(15, 15, 20), Sidebar = Color3.fromRGB(10, 10, 15),
    Secondary = Color3.fromRGB(25, 25, 35), Accent = Color3.fromRGB(170, 0, 0),
    AccentLight = Color3.fromRGB(220, 50, 50), Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150), Green = Color3.fromRGB(0, 200, 100)
}

local ColorMap = {
    Red = Color3.fromRGB(255, 0, 0), Green = Color3.fromRGB(0, 255, 0),
    Blue = Color3.fromRGB(0, 100, 255), White = Color3.fromRGB(255, 255, 255),
    Orange = Color3.fromRGB(255, 140, 0), Purple = Color3.fromRGB(180, 0, 255),
    Cyan = Color3.fromRGB(0, 255, 255)
}

-- ==========================================
-- AUTO-LOAD CONFIG
-- ==========================================
local function LoadConfigSilent()
    if isfile and isfile("NovaHub_Config.json") then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("NovaHub_Config.json"))
        end)
        if ok and data then
            for k, v in pairs(data) do
                if Settings[k] ~= nil then Settings[k] = v end
            end
            print("[Nova] Config auto-loaded")
        end
    end
end
LoadConfigSilent()

-- ==========================================
-- 0. ЗАГРУЗОЧНЫЙ ЭКРАН
-- ==========================================
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "NovaSplash"; SplashGui.IgnoreGuiInset = true; SplashGui.DisplayOrder = 9999; SplashGui.Parent = game.CoreGui

local SplashBg = Instance.new("Frame", SplashGui)
SplashBg.Size = UDim2.new(1, 0, 1, 0); SplashBg.BackgroundColor3 = Colors.Background; SplashBg.BorderSizePixel = 0; SplashBg.ZIndex = 1

local SplashLogo = Instance.new("TextLabel", SplashBg)
SplashLogo.Size = UDim2.new(1, 0, 0, 50); SplashLogo.Position = UDim2.new(0, 0, 0.4, 0)
SplashLogo.BackgroundTransparency = 1; SplashLogo.Text = "NOVA HUB"; SplashLogo.TextColor3 = Colors.Text; SplashLogo.Font = Enum.Font.GothamBlack; SplashLogo.TextSize = 40; SplashLogo.TextTransparency = 1; SplashLogo.ZIndex = 2

local SplashBarBg = Instance.new("Frame", SplashBg)
SplashBarBg.Size = UDim2.new(0.4, 0, 0, 6); SplashBarBg.Position = UDim2.new(0.3, 0, 0.55, 0)
SplashBarBg.BackgroundColor3 = Colors.Secondary; SplashBarBg.BorderSizePixel = 0; SplashBarBg.ZIndex = 2
Instance.new("UICorner", SplashBarBg).CornerRadius = UDim.new(1, 0)

local SplashBarFill = Instance.new("Frame", SplashBarBg)
SplashBarFill.Size = UDim2.new(0, 0, 1, 0); SplashBarFill.BackgroundColor3 = Colors.Accent; SplashBarFill.BorderSizePixel = 0; SplashBarFill.ZIndex = 3
Instance.new("UICorner", SplashBarFill).CornerRadius = UDim.new(1, 0)

local SplashStatus = Instance.new("TextLabel", SplashBg)
SplashStatus.Size = UDim2.new(1, 0, 0, 20); SplashStatus.Position = UDim2.new(0, 0, 0.6, 0)
SplashStatus.BackgroundTransparency = 1; SplashStatus.Text = "Загрузка..."; SplashStatus.TextColor3 = Colors.TextDim; SplashStatus.Font = Enum.Font.Gotham; SplashStatus.TextSize = 14; SplashStatus.ZIndex = 2

task.spawn(function()
    task.wait(0.2)
    TweenService:Create(SplashLogo, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(SplashBarFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.5); SplashStatus.Text = "Загрузка модулей..."
    task.wait(0.5); SplashStatus.Text = "Внедрение..."
    task.wait(0.5); SplashStatus.Text = "Готово!"
    task.wait(0.5)
    TweenService:Create(SplashBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashLogo, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(SplashBarBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashBarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashStatus, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.6)
    SplashGui:Destroy()
end)

-- ==========================================
-- 1. UI КАРКАС
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 390); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -195)
MainFrame.BackgroundColor3 = Colors.Background; MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ZIndex = 1; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = Colors.Accent; MainStroke.Transparency = 0.3

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0); Sidebar.BackgroundColor3 = Colors.Sidebar; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 2
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 40); Title.BackgroundTransparency = 1; Title.Text = "NOVA HUB"; Title.TextColor3 = Colors.Text; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 14; Title.ZIndex = 3

local Indicator = Instance.new("Frame", Sidebar)
Indicator.Size = UDim2.new(0, 3, 0, 35); Indicator.Position = UDim2.new(0, 0, 0, 40)
Indicator.BackgroundColor3 = Colors.Accent; Indicator.BorderSizePixel = 0; Indicator.ZIndex = 4
Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)

local function CreateTabButton(name, yPos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundColor3 = Colors.Sidebar
    btn.Text = "  " .. name; btn.TextColor3 = Colors.TextDim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 3
    return btn
end

local TabCombat = CreateTabButton("Combat", 40)
local TabVisuals = CreateTabButton("Visuals", 75)
local TabPlayer = CreateTabButton("Player", 110)
local TabHitbox = CreateTabButton("Hitbox", 145)
local TabMisc = CreateTabButton("Misc", 180)
local TabSettings = CreateTabButton("Settings", 215)
local TabInfo = CreateTabButton("Info", 250)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -120, 1, 0); ContentArea.Position = UDim2.new(0, 120, 0, 0); ContentArea.BackgroundTransparency = 1; ContentArea.ZIndex = 2

local function CreateScrollPage()
    local scroll = Instance.new("ScrollingFrame", ContentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Colors.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ZIndex = 3
    return scroll
end

local CombatPage = CreateScrollPage()
local VisualsPage = CreateScrollPage()
local PlayerPage = CreateScrollPage()
local HitboxPage = CreateScrollPage()
local MiscPage = CreateScrollPage()
local SettingsPage = CreateScrollPage()
local InfoPage = CreateScrollPage()
CombatPage.Visible = true

local allTabButtons = {TabCombat, TabVisuals, TabPlayer, TabHitbox, TabMisc, TabSettings, TabInfo}
local allPages = {CombatPage, VisualsPage, PlayerPage, HitboxPage, MiscPage, SettingsPage, InfoPage}

local function SwitchTab(tabName, targetY)
    TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, targetY)}):Play()
    for _, btn in pairs(allTabButtons) do btn.TextColor3 = Colors.TextDim end
    for _, page in pairs(allPages) do page.Visible = false end

    local targetPage, targetBtn
    if tabName == "Combat" then targetPage = CombatPage; targetBtn = TabCombat
    elseif tabName == "Visuals" then targetPage = VisualsPage; targetBtn = TabVisuals
    elseif tabName == "Player" then targetPage = PlayerPage; targetBtn = TabPlayer
    elseif tabName == "Hitbox" then targetPage = HitboxPage; targetBtn = TabHitbox
    elseif tabName == "Misc" then targetPage = MiscPage; targetBtn = TabMisc
    elseif tabName == "Settings" then targetPage = SettingsPage; targetBtn = TabSettings
    elseif tabName == "Info" then targetPage = InfoPage; targetBtn = TabInfo end

    targetPage.Visible = true; targetBtn.TextColor3 = Colors.Text
end

TabCombat.MouseButton1Click:Connect(function() SwitchTab("Combat", 40) end)
TabVisuals.MouseButton1Click:Connect(function() SwitchTab("Visuals", 75) end)
TabPlayer.MouseButton1Click:Connect(function() SwitchTab("Player", 110) end)
TabHitbox.MouseButton1Click:Connect(function() SwitchTab("Hitbox", 145) end)
TabMisc.MouseButton1Click:Connect(function() SwitchTab("Misc", 180) end)
TabSettings.MouseButton1Click:Connect(function() SwitchTab("Settings", 215) end)
TabInfo.MouseButton1Click:Connect(function() SwitchTab("Info", 250) end)
SwitchTab("Combat", 40)

-- ==========================================
-- 2. ЭЛЕМЕНТЫ УПРАВЛЕНИЯ
-- ==========================================
local function CreateToggle(parent, text, yPos, initialState, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, -20, 0, 30); frame.Position = UDim2.new(0, 10, 0, yPos); frame.BackgroundColor3 = Colors.Secondary; frame.ZIndex = 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -50, 1, 0); label.Position = UDim2.new(0, 10, 0, 0); label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Colors.Text; label.Font = Enum.Font.GothamSemibold; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 4
    local switchBg = Instance.new("Frame", frame); switchBg.Size = UDim2.new(0, 30, 0, 16); switchBg.Position = UDim2.new(1, -40, 0.5, -8); switchBg.BackgroundColor3 = Colors.Background; switchBg.ZIndex = 4
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", switchBg); knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = initialState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6); knob.BackgroundColor3 = initialState and Colors.Accent or Colors.TextDim; knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local isOn = initialState
    local clickBtn = Instance.new("TextButton", frame); clickBtn.Size = UDim2.new(1, 0, 1, 0); clickBtn.BackgroundTransparency = 1; clickBtn.Text = ""; clickBtn.ZIndex = 6
    clickBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = isOn and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = isOn and Colors.Accent or Colors.TextDim}):Play()
        if callback then callback(isOn) end
    end)
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, initialVal, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, -20, 0, 40); frame.Position = UDim2.new(0, 10, 0, yPos); frame.BackgroundColor3 = Colors.Secondary; frame.ZIndex = 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -10, 0, 15); label.Position = UDim2.new(0, 10, 0, 5); label.BackgroundTransparency = 1; label.Text = text .. ": " .. initialVal; label.TextColor3 = Colors.Text; label.Font = Enum.Font.GothamSemibold; label.TextSize = 11; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 4
    local barBg = Instance.new("Frame", frame); barBg.Size = UDim2.new(1, -20, 0, 4); barBg.Position = UDim2.new(0, 10, 0, 25); barBg.BackgroundColor3 = Colors.Background; barBg.ZIndex = 4
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", barBg); fill.Size = UDim2.new((initialVal - minVal) / (maxVal - minVal), 0, 1, 0); fill.BackgroundColor3 = Colors.Accent; fill.ZIndex = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function Update(percent)
        percent = math.clamp(percent, 0, 1); local val = math.floor(minVal + percent * (maxVal - minVal))
        label.Text = text .. ": " .. val; fill.Size = UDim2.new(percent, 0, 1, 0); if callback then callback(val) end
    end
    barBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; Update((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local function CreateDropdown(parent, text, yPos, options, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, -20, 0, 60); frame.Position = UDim2.new(0, 10, 0, yPos); frame.BackgroundColor3 = Colors.Secondary; frame.ZIndex = 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -10, 0, 20); label.Position = UDim2.new(0, 10, 0, 5); label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Colors.Text; label.Font = Enum.Font.GothamSemibold; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 4
    local selectedDisplay = Instance.new("TextButton", frame); selectedDisplay.Size = UDim2.new(1, -20, 0, 25); selectedDisplay.Position = UDim2.new(0, 10, 0, 25); selectedDisplay.BackgroundColor3 = Colors.Background; selectedDisplay.Text = "Default"; selectedDisplay.TextColor3 = Colors.Text; selectedDisplay.Font = Enum.Font.Gotham; selectedDisplay.TextSize = 12; selectedDisplay.ZIndex = 4
    local dropFrame = Instance.new("Frame", frame); dropFrame.Size = UDim2.new(1, 0, 0, #options * 25); dropFrame.Position = UDim2.new(0, 0, 1, 5); dropFrame.BackgroundColor3 = Colors.Background; dropFrame.Visible = false; dropFrame.ZIndex = 10
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIListLayout", dropFrame)
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropFrame); optBtn.Size = UDim2.new(1, 0, 0, 25); optBtn.BackgroundColor3 = Colors.Background; optBtn.Text = opt; optBtn.TextColor3 = Colors.Text; optBtn.Font = Enum.Font.Gotham; optBtn.TextSize = 12; optBtn.ZIndex = 11
        optBtn.MouseButton1Click:Connect(function() selectedDisplay.Text = opt; dropFrame.Visible = false; if callback then callback(opt) end end)
    end
    selectedDisplay.MouseButton1Click:Connect(function() dropFrame.Visible = not dropFrame.Visible end)
end

local function CreateButton(parent, text, yPos, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -20, 0, 30); btn.Position = UDim2.new(0, 10, 0, yPos); btn.BackgroundColor3 = Colors.Accent; btn.Text = text; btn.TextColor3 = Colors.Text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 3. НАПОЛНЕНИЕ ВКЛАДОК
-- ==========================================

FOV_Fill = Instance.new("Frame", ScreenGui)
FOV_Fill.BackgroundColor3 = Colors.AccentLight
FOV_Fill.BackgroundTransparency = Settings.FOV_Circle_Transparency
FOV_Fill.BorderSizePixel = 0
FOV_Fill.Visible = false
FOV_Fill.ZIndex = 998
Instance.new("UICorner", FOV_Fill).CornerRadius = UDim.new(1, 0)

FOV_Circle = Instance.new("Frame", ScreenGui)
FOV_Circle.BackgroundTransparency = 1
FOV_Circle.BorderSizePixel = 2
FOV_Circle.BorderColor3 = Colors.Accent
FOV_Circle.Visible = false
FOV_Circle.ZIndex = 999
Instance.new("UICorner", FOV_Circle).CornerRadius = UDim.new(1, 0)

-- --- COMBAT ---
local CombatTitle = Instance.new("TextLabel", CombatPage); CombatTitle.Size = UDim2.new(1, -20, 0, 20); CombatTitle.Position = UDim2.new(0, 10, 0, 10); CombatTitle.BackgroundTransparency = 1; CombatTitle.Text = "Target"; CombatTitle.TextColor3 = Colors.AccentLight; CombatTitle.Font = Enum.Font.GothamBold; CombatTitle.TextSize = 12; CombatTitle.TextXAlignment = Enum.TextXAlignment.Left; CombatTitle.ZIndex = 3
CreateToggle(CombatPage, "Aimbot", 35, Settings.Aimbot_Enabled, function(state) Settings.Aimbot_Enabled = state end)
CreateSlider(CombatPage, "FOV Radius", 70, 50, 300, Settings.Aimbot_FOV, function(val) Settings.Aimbot_FOV = val end)
CreateSlider(CombatPage, "Smoothness", 115, 1, 100, 25, function(val) Settings.Aimbot_Smoothness = val / 100 end)
CreateDropdown(CombatPage, "Target Part", 160, {"Head", "Torso", "Nearest"}, function(part) Settings.Aimbot_TargetPart = part end)
CreateSlider(CombatPage, "Prediction (0 = off)", 205, 0, 100, 0, function(val) Settings.Aimbot_Prediction = val / 100 end)

CreateToggle(CombatPage, "Show FOV Circle", 250, Settings.FOV_Circle_Show, function(state) Settings.FOV_Circle_Show = state end)
CreateSlider(CombatPage, "Circle Transparency", 285, 0, 100, 80, function(val) 
    Settings.FOV_Circle_Transparency = val / 100
    if FOV_Fill then FOV_Fill.BackgroundTransparency = val / 100 end
end)

CreateToggle(CombatPage, "Silent Aim", 330, Settings.SilentAim_Enabled, function(state) Settings.SilentAim_Enabled = state end)
CreateSlider(CombatPage, "Silent FOV", 365, 50, 300, Settings.SilentAim_FOV, function(val) Settings.SilentAim_FOV = val end)
CreateDropdown(CombatPage, "Silent Target", 410, {"Head", "Torso", "HumanoidRootPart"}, function(part) Settings.SilentAim_TargetPart = part end)

-- --- VISUALS ---
local VisualsTitle = Instance.new("TextLabel", VisualsPage); VisualsTitle.Size = UDim2.new(1, -20, 0, 20); VisualsTitle.Position = UDim2.new(0, 10, 0, 10); VisualsTitle.BackgroundTransparency = 1; VisualsTitle.Text = "Visuals & Skins"; VisualsTitle.TextColor3 = Colors.AccentLight; VisualsTitle.Font = Enum.Font.GothamBold; VisualsTitle.TextSize = 12; VisualsTitle.TextXAlignment = Enum.TextXAlignment.Left; VisualsTitle.ZIndex = 3
CreateToggle(VisualsPage, "Player ESP", 35, Settings.ESP_Enabled, function(state) Settings.ESP_Enabled = state; if state then for _, p in ipairs(Players:GetPlayers()) do if CreateESP then CreateESP(p) end end else for p, _ in pairs(ESP_Objects) do if RemoveESP then RemoveESP(p) end end end end)
CreateToggle(VisualsPage, "Bot ESP", 70, Settings.Bot_ESP_Enabled, function(state) Settings.Bot_ESP_Enabled = state; if not state then for b, e in pairs(Bot_ESP_Objects) do if e and e.Parent then e:Destroy() end; Bot_ESP_Objects[b] = nil end end end)
CreateDropdown(VisualsPage, "ESP Fill Color", 105, {"Red", "Green", "Blue", "White", "Orange", "Purple", "Cyan"}, function(c) Settings.ESP_FillColor = c; if CreateESP then for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end end end)
CreateSlider(VisualsPage, "ESP Fill Transparency", 145, 0, 100, 50, function(val) Settings.ESP_FillTransparency = val / 100; if CreateESP then for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end end end)
CreateDropdown(VisualsPage, "ESP Outline Color", 185, {"Red", "Green", "Blue", "White", "Orange", "Purple", "Cyan"}, function(c) Settings.ESP_OutlineColor = c; if CreateESP then for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end end end)
CreateDropdown(VisualsPage, "Weapon Skin", 225, {"Default", "Neon Red", "Gold", "Galaxy", "Invisible"}, function(skinName) Settings.CurrentSkin = skinName; if ApplyWeaponSkin then ApplyWeaponSkin() end end)
CreateSlider(VisualsPage, "Skin Transparency", 265, 0, 100, 0, function(val) Settings.SkinTransparency = val / 100; if ApplyWeaponSkin then ApplyWeaponSkin() end end)

-- --- PLAYER ---
local PlayerTitle = Instance.new("TextLabel", PlayerPage); PlayerTitle.Size = UDim2.new(1, -20, 0, 20); PlayerTitle.Position = UDim2.new(0, 10, 0, 10); PlayerTitle.BackgroundTransparency = 1; PlayerTitle.Text = "Local Player"; PlayerTitle.TextColor3 = Colors.AccentLight; PlayerTitle.Font = Enum.Font.GothamBold; PlayerTitle.TextSize = 12; PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left; PlayerTitle.ZIndex = 3
CreateToggle(PlayerPage, "Enable Speed", 35, Settings.Speed_Enabled, function(state)
    Settings.Speed_Enabled = state
    local char = LocalPlayer.Character
    if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then if state then hum.WalkSpeed = Settings.Speed_Value else hum.WalkSpeed = 16 end end end
end)
CreateSlider(PlayerPage, "Walk Speed", 70, 16, 50, Settings.Speed_Value, function(val)
    Settings.Speed_Value = val
    if Settings.Speed_Enabled then local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = val end end end
end)

-- --- HITBOX ---
local HitboxTitle = Instance.new("TextLabel", HitboxPage); HitboxTitle.Size = UDim2.new(1, -20, 0, 20); HitboxTitle.Position = UDim2.new(0, 10, 0, 10); HitboxTitle.BackgroundTransparency = 1; HitboxTitle.Text = "Hitbox Expander"; HitboxTitle.TextColor3 = Colors.AccentLight; HitboxTitle.Font = Enum.Font.GothamBold; HitboxTitle.TextSize = 12; HitboxTitle.TextXAlignment = Enum.TextXAlignment.Left; HitboxTitle.ZIndex = 3

CreateToggle(HitboxPage, "Enable Hitbox Expander", 35, Settings.Hitbox_Enabled, function(state) Settings.Hitbox_Enabled = state end)
CreateSlider(HitboxPage, "Hitbox Size", 70, 1, 10, Settings.Hitbox_Size, function(val) Settings.Hitbox_Size = val end)
CreateToggle(HitboxPage, "Show Hitbox (Visual)", 105, Settings.Hitbox_Show, function(state) Settings.Hitbox_Show = state end)

local hitboxOriginal = {}
local hitboxVisuals = {}

local function ApplyHitboxToModel(model)
    if not model or not model:FindFirstChildOfClass("Humanoid") then return end
    local parts = {
        model:FindFirstChild("Head"),
        model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso"),
        model:FindFirstChild("HumanoidRootPart")
    }
    for _, part in ipairs(parts) do
        if part and part:IsA("BasePart") then
            if not hitboxOriginal[part] then
                hitboxOriginal[part] = { Size = part.Size, Transparency = part.Transparency, CanCollide = part.CanCollide, Massless = part.Massless }
            end
            local s = Settings.Hitbox_Size
            part.Size = Vector3.new(s, s, s)
            part.CanCollide = false
            part.Massless = true
            part.Transparency = 0.7

            if Settings.Hitbox_Show then
                if not hitboxVisuals[part] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(s, s, s)
                    box.Adornee = part
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.5
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Parent = part
                    hitboxVisuals[part] = box
                else
                    hitboxVisuals[part].Size = Vector3.new(s, s, s)
                end
            else
                if hitboxVisuals[part] then
                    hitboxVisuals[part]:Destroy()
                    hitboxVisuals[part] = nil
                end
            end
        end
    end
end

local function ResetHitbox(model)
    if not model then return end
    for part, data in pairs(hitboxOriginal) do
        if part and part.Parent and part:IsDescendantOf(model) then
            part.Size = data.Size
            part.Transparency = data.Transparency
            part.CanCollide = data.CanCollide
            part.Massless = data.Massless
        end
    end
    for part, box in pairs(hitboxVisuals) do
        if box and box.Parent then box:Destroy() end
    end
    hitboxOriginal = {}
    hitboxVisuals = {}
end

local function GetAllTargets()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            table.insert(targets, player.Character)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local isPlayer = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character == obj then isPlayer = true; break end
            end
            if not isPlayer then table.insert(targets, obj) end
        end
    end
    return targets
end

task.spawn(function()
    while task.wait(1) do
        local targets = GetAllTargets()
        if Settings.Hitbox_Enabled then
            for _, model in ipairs(targets) do
                ApplyHitboxToModel(model)
            end
        else
            for _, model in ipairs(targets) do
                ResetHitbox(model)
            end
        end
    end
end)

-- --- MISC ---
local MiscTitle = Instance.new("TextLabel", MiscPage); MiscTitle.Size = UDim2.new(1, -20, 0, 20); MiscTitle.Position = UDim2.new(0, 10, 0, 10); MiscTitle.BackgroundTransparency = 1; MiscTitle.Text = "Miscellaneous"; MiscTitle.TextColor3 = Colors.AccentLight; MiscTitle.Font = Enum.Font.GothamBold; MiscTitle.TextSize = 12; MiscTitle.TextXAlignment = Enum.TextXAlignment.Left; MiscTitle.ZIndex = 3

Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Size = UDim2.new(0, 230, 0, 26)
Watermark.Position = UDim2.new(1, -240, 0, 10)
Watermark.BackgroundColor3 = Colors.Background
Watermark.BackgroundTransparency = 0.2
Watermark.Text = "NOVA HUB v35"
Watermark.TextColor3 = ColorMap[Settings.Watermark_Color] or Colors.AccentLight
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 12
Watermark.ZIndex = 999
Watermark.Visible = Settings.Watermark_Enabled
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)
local WMStroke = Instance.new("UIStroke", Watermark); WMStroke.Color = Colors.Accent; WMStroke.Transparency = 0.5

local function UpdateWatermarkPosition()
    if Settings.Watermark_Position == "TopRight" then
        Watermark.Position = UDim2.new(1, -240, 0, 10)
    elseif Settings.Watermark_Position == "TopLeft" then
        Watermark.Position = UDim2.new(0, 10, 0, 10)
    elseif Settings.Watermark_Position == "BottomRight" then
        Watermark.Position = UDim2.new(1, -240, 1, -36)
    elseif Settings.Watermark_Position == "BottomLeft" then
        Watermark.Position = UDim2.new(0, 10, 1, -36)
    end
end
UpdateWatermarkPosition()

task.spawn(function()
    local frames, lastTime = 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTime >= 1 then
            local fps = frames; frames = 0; lastTime = tick()
            if Settings.Watermark_ShowFPS then
                Watermark.Text = string.format("NOVA HUB v35 | FPS: %d", fps)
            else
                Watermark.Text = "NOVA HUB v35"
            end
        end
    end)
end)

CreateToggle(MiscPage, "Fullbright", 35, Settings.Fullbright, function(state)
    Settings.Fullbright = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3; Lighting.ClockTime = 12; Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 2; Lighting.GlobalShadows = true
    end
end)

CreateToggle(MiscPage, "Night Mode", 70, Settings.NightMode, function(state)
    Settings.NightMode = state
    if state then
        Lighting.ClockTime = 0
        Lighting.Ambient = Color3.fromRGB(15, 15, 30)
        Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 20)
        Lighting.Brightness = 2.5
    else
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 2
    end
end)

CreateToggle(MiscPage, "Watermark", 105, Settings.Watermark_Enabled, function(state)
    Settings.Watermark_Enabled = state
    Watermark.Visible = state
end)

CreateDropdown(MiscPage, "Watermark Color", 140, {"Red", "Green", "Blue", "White", "Orange", "Purple", "Cyan"}, function(c)
    Settings.Watermark_Color = c
    Watermark.TextColor3 = ColorMap[c] or Colors.AccentLight
end)

CreateDropdown(MiscPage, "Watermark Position", 180, {"TopRight", "TopLeft", "BottomRight", "BottomLeft"}, function(pos)
    Settings.Watermark_Position = pos
    UpdateWatermarkPosition()
end)

CreateToggle(MiscPage, "Watermark Show FPS", 220, Settings.Watermark_ShowFPS, function(state)
    Settings.Watermark_ShowFPS = state
end)

-- --- SETTINGS ---
local SettingsTitle = Instance.new("TextLabel", SettingsPage); SettingsTitle.Size = UDim2.new(1, -20, 0, 20); SettingsTitle.Position = UDim2.new(0, 10, 0, 10); SettingsTitle.BackgroundTransparency = 1; SettingsTitle.Text = "Config & Menu"; SettingsTitle.TextColor3 = Colors.AccentLight; SettingsTitle.Font = Enum.Font.GothamBold; SettingsTitle.TextSize = 12; SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left; SettingsTitle.ZIndex = 3

local function SaveConfig()
    if writefile then
        local ok, err = pcall(function()
            writefile("NovaHub_Config.json", HttpService:JSONEncode(Settings))
        end)
        print(ok and "[Nova] Config saved" or ("[Nova] Save error: " .. tostring(err)))
    else
        print("[Nova] writefile недоступен")
    end
end

local function LoadConfig()
    if isfile and isfile("NovaHub_Config.json") then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("NovaHub_Config.json"))
        end)
        if ok and data then
            for k, v in pairs(data) do Settings[k] = v end
            print("[Nova] Config loaded")
        else
            print("[Nova] Load error")
        end
    else
        print("[Nova] Конфиг не найден")
    end
end

CreateToggle(SettingsPage, "Auto-Load Config on Start", 35, Settings.AutoLoad_Enabled, function(state) Settings.AutoLoad_Enabled = state end)
CreateButton(SettingsPage, "Save Config", 70, SaveConfig)
CreateButton(SettingsPage, "Load Config", 105, LoadConfig)
CreateDropdown(SettingsPage, "Menu Key", 145, {"S", "RightShift", "Insert", "F1"}, function(key) Settings.Menu_Key = key end)

-- --- INFO ---
local InfoTitle = Instance.new("TextLabel", InfoPage); InfoTitle.Size = UDim2.new(1, -20, 0, 20); InfoTitle.Position = UDim2.new(0, 10, 0, 10); InfoTitle.BackgroundTransparency = 1; InfoTitle.Text = "Account Info"; InfoTitle.TextColor3 = Colors.AccentLight; InfoTitle.Font = Enum.Font.GothamBold; InfoTitle.TextSize = 12; InfoTitle.TextXAlignment = Enum.TextXAlignment.Left; InfoTitle.ZIndex = 3

local function CreateInfoLabel(parent, title, yPos)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, -20, 0, 30); frame.Position = UDim2.new(0, 10, 0, yPos); frame.BackgroundColor3 = Colors.Secondary; frame.ZIndex = 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local tLabel = Instance.new("TextLabel", frame); tLabel.Size = UDim2.new(0.5, 0, 1, 0); tLabel.Position = UDim2.new(0, 10, 0, 0); tLabel.BackgroundTransparency = 1; tLabel.Text = title; tLabel.TextColor3 = Colors.TextDim; tLabel.Font = Enum.Font.GothamSemibold; tLabel.TextSize = 12; tLabel.TextXAlignment = Enum.TextXAlignment.Left; tLabel.ZIndex = 4
    local vLabel = Instance.new("TextLabel", frame); vLabel.Size = UDim2.new(0.5, -10, 1, 0); vLabel.Position = UDim2.new(0.5, 0, 0, 0); vLabel.BackgroundTransparency = 1; vLabel.Text = "..."; vLabel.TextColor3 = Colors.Text; vLabel.Font = Enum.Font.GothamBold; vLabel.TextSize = 12; vLabel.TextXAlignment = Enum.TextXAlignment.Right; vLabel.ZIndex = 4
    return vLabel
end

local UsernameLabel = CreateInfoLabel(InfoPage, "Username", 35)
local DisplayNameLabel = CreateInfoLabel(InfoPage, "Display Name", 70)
local UserIDLabel = CreateInfoLabel(InfoPage, "User ID", 105)
local AccountAgeLabel = CreateInfoLabel(InfoPage, "Account Age", 140)
local KillsLabel = CreateInfoLabel(InfoPage, "Kills (Flick)", 175)
local TimeLabel = CreateInfoLabel(InfoPage, "Time with Cheat", 210)

CreateButton(InfoPage, "View My Avatar", 250, function()
    local url = "https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile"
    if setclipboard then setclipboard(url); print("Ссылка на профиль: " .. url) end
end)

task.spawn(function()
    while task.wait(1) do
        UsernameLabel.Text = LocalPlayer.Name
        DisplayNameLabel.Text = LocalPlayer.DisplayName
        UserIDLabel.Text = tostring(LocalPlayer.UserId)
        AccountAgeLabel.Text = tostring(LocalPlayer.AccountAge) .. " days"
        local kills = "N/A"
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local killStat = leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("KillsCount") or leaderstats:FindFirstChild("Eliminations")
            if killStat then kills = tostring(killStat.Value) end
        end
        KillsLabel.Text = kills
        local secondsPassed = os.time() - scriptStartTime
        TimeLabel.Text = string.format("%02d:%02d", math.floor(secondsPassed / 60), secondsPassed % 60)
    end
end)

-- ==========================================
-- 5. FOV CIRCLE RENDER (FIXED)
-- ==========================================
task.spawn(function()
    local pulse = true
    while task.wait(0.5) do
        if FOV_Circle.Visible then
            if pulse then TweenService:Create(FOV_Circle, TweenInfo.new(0.5), {BorderColor3 = Color3.fromRGB(255, 100, 100)}):Play()
            else TweenService:Create(FOV_Circle, TweenInfo.new(0.5), {BorderColor3 = Colors.Accent}):Play() end
            pulse = not pulse
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if FOV_Circle and FOV_Fill then
        local s = Settings.Aimbot_FOV
        FOV_Circle.Size = UDim2.new(0, s * 2, 0, s * 2)
        FOV_Circle.Position = UDim2.new(0.5, -s, 0.5, -s)
        FOV_Fill.Size = UDim2.new(0, s * 2, 0, s * 2)
        FOV_Fill.Position = UDim2.new(0.5, -s, 0.5, -s)
        
        FOV_Fill.BackgroundTransparency = Settings.FOV_Circle_Transparency
        
        local visible = Settings.Aimbot_Enabled and Settings.Menu_Open and Settings.FOV_Circle_Show
        FOV_Circle.Visible = visible
        FOV_Fill.Visible = visible
    end
end)

local S_Button = Instance.new("TextButton", ScreenGui); S_Button.Size = UDim2.new(0, 0, 0, 0); S_Button.Position = UDim2.new(0, 20, 0, 80); S_Button.BackgroundColor3 = Colors.Background; S_Button.Text = "S"; S_Button.TextColor3 = Colors.AccentLight; S_Button.Font = Enum.Font.GothamBlack; S_Button.TextSize = 20; S_Button.Visible = false; S_Button.ZIndex = 1000; S_Button.BackgroundTransparency = 1
Instance.new("UICorner", S_Button).CornerRadius = UDim.new(1, 0)
local SStroke = Instance.new("UIStroke", S_Button); SStroke.Color = Colors.Accent; SStroke.Transparency = 1

function ToggleMenu()
    Settings.Menu_Open = not Settings.Menu_Open
    if Settings.Menu_Open then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0); MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 390), BackgroundTransparency = 0.1}):Play()
        TweenService:Create(S_Button, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(SStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        task.wait(0.2)
        if not Settings.Menu_Open then return end
        S_Button.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        if Settings.Menu_Open then return end
        MainFrame.Visible = false
        S_Button.Visible = true
        S_Button.Size = UDim2.new(0, 0, 0, 0); S_Button.BackgroundTransparency = 1; S_Button.TextTransparency = 1
        TweenService:Create(S_Button, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 0, TextTransparency = 0}):Play()
        TweenService:Create(SStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end
end

local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -50, 0, 5)
MinimizeBtn.BackgroundColor3 = Colors.Secondary
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Colors.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 5
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

local CloseX = Instance.new("TextButton", MainFrame)
CloseX.Size = UDim2.new(0, 20, 0, 20)
CloseX.Position = UDim2.new(1, -25, 0, 5)
CloseX.BackgroundColor3 = Colors.Accent
CloseX.Text = "x"
CloseX.TextColor3 = Colors.Text
CloseX.Font = Enum.Font.GothamBold
CloseX.TextSize = 12
CloseX.ZIndex = 5
Instance.new("UICorner", CloseX).CornerRadius = UDim.new(0, 4)

local IsMinimized = false
local OriginalSize = UDim2.new(0, 500, 0, 390)

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 120, 0, 40)
        }):Play()
        Sidebar.Visible = false
        ContentArea.Visible = false
        MinimizeBtn.Text = "+"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = OriginalSize
        }):Play()
        Sidebar.Visible = true
        ContentArea.Visible = true
        MinimizeBtn.Text = "_"
    end
end)

CloseX.MouseButton1Click:Connect(ToggleMenu)
S_Button.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = Enum.KeyCode[Settings.Menu_Key]
    if key and input.KeyCode == key then ToggleMenu() end
end)

-- ==========================================
-- 6. ESP ЛОГИКА
-- ==========================================
RemoveESP = function(player)
    if ESP_Objects[player] then ESP_Objects[player]:Destroy(); ESP_Objects[player] = nil end
end

CreateESP = function(player)
    if player == LocalPlayer or not player.Character then return end
    RemoveESP(player)
    local Highlight = Instance.new("Highlight", player.Character)
    Highlight.FillColor = ColorMap[Settings.ESP_FillColor] or Colors.AccentLight
    Highlight.OutlineColor = ColorMap[Settings.ESP_OutlineColor] or Colors.Text
    Highlight.FillTransparency = Settings.ESP_FillTransparency
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Adornee = player.Character
    ESP_Objects[player] = Highlight
end

local function SetupPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then CreateESP(player) end
    player.CharacterAdded:Connect(function() task.wait(0.3); if Settings.ESP_Enabled then CreateESP(player) end end)
end

for _, p in ipairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer); Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

local function ScanForBots()
    if not Settings.Bot_ESP_Enabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart then
                local isPlayer = false
                for _, plr in ipairs(Players:GetPlayers()) do if plr.Character == obj then isPlayer = true; break end end
                if not isPlayer and not Bot_ESP_Objects[obj] then
                    local Highlight = Instance.new("Highlight", obj)
                    Highlight.FillColor = Color3.fromRGB(255, 100, 0); Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.FillTransparency = 0.5; Highlight.Adornee = obj
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Bot_ESP_Objects[obj] = Highlight
                end
            end
        end
    end
end
task.spawn(function() while task.wait(2) do ScanForBots() end end)

-- ==========================================
-- 7. SKIN CHANGER (FIXED)
-- ==========================================
local skinCache = {}
ApplyWeaponSkin = function()
    if Settings.CurrentSkin == "Default" then
        for part, data in pairs(skinCache) do
            if part and part.Parent then
                part.Color = data.Color; part.Material = data.Material; part.Transparency = data.Transparency
                local light = part:FindFirstChild("SkinLight"); if light then light:Destroy() end
                local tex = part:FindFirstChild("GalaxyTexture"); if tex then tex:Destroy() end
            end
        end
        skinCache = {}
        return
    end
    local function ProcessWeapon(obj)
        if (obj:IsA("BasePart") or obj:IsA("MeshPart")) then
            if obj.Size.Y > 5 or obj.Size.X > 5 then return end
            if obj:IsDescendantOf(game.CoreGui) then return end -- Защита GUI

            if not skinCache[obj] then skinCache[obj] = { Color = obj.Color, Material = obj.Material, Transparency = obj.Transparency } end
            obj.Transparency = Settings.SkinTransparency
            local oldLight = obj:FindFirstChild("SkinLight"); if oldLight then oldLight:Destroy() end
            local oldTex = obj:FindFirstChild("GalaxyTexture"); if oldTex then oldTex:Destroy() end
            if Settings.CurrentSkin == "Neon Red" then
                obj.Material = Enum.Material.Neon; obj.Color = Color3.fromRGB(255, 0, 0)
            elseif Settings.CurrentSkin == "Gold" then
                obj.Material = Enum.Material.Foil; obj.Color = Color3.fromRGB(255, 215, 0)
            elseif Settings.CurrentSkin == "Galaxy" then
                obj.Material = Enum.Material.Metal; obj.Color = Color3.fromRGB(20, 5, 50)
                local light = Instance.new("PointLight", obj); light.Name = "SkinLight"; light.Color = Color3.fromRGB(120, 0, 255); light.Range = 5; light.Brightness = 2
                local tex = Instance.new("Texture", obj); tex.Name = "GalaxyTexture"; tex.Texture = "rbxassetid://803103859"; tex.Face = Enum.NormalId.Front; tex.Transparency = 0.4
            elseif Settings.CurrentSkin == "Invisible" then
                obj.Transparency = 1
            end
        end
    end
    for _, obj in ipairs(Camera:GetDescendants()) do ProcessWeapon(obj) end
    if LocalPlayer.Character then for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do ProcessWeapon(obj) end end
end
task.spawn(function() while task.wait(0.5) do if Settings.CurrentSkin ~= "Default" then ApplyWeaponSkin() end end end)

-- ==========================================
-- 8. AIMBOT
-- ==========================================
local function IsVisible(targetPart, targetCharacter)
    local origin = Camera.CFrame.Position; local direction = targetPart.Position - origin
    local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    local result = workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetCharacter)
end

local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Physics then return false end
    return true
end

local function GetTargetPart(character)
    if not character then return nil end
    if Settings.Aimbot_TargetPart == "Head" then
        return character:FindFirstChild("Head")
    elseif Settings.Aimbot_TargetPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    else
        local best, bestDist = nil, math.huge
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local parts = {
            character:FindFirstChild("Head"),
            character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
            character:FindFirstChild("HumanoidRootPart")
        }
        for _, part in ipairs(parts) do
            if part and part:IsA("BasePart") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < bestDist then bestDist = dist; best = part end
                end
            end
        end
        return best
    end
end

RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot_Enabled then closest = nil; return end
    local shortestDist = Settings.Aimbot_FOV
    closest = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsAlive(player.Character) then
            local targetPart = GetTargetPart(player.Character)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist <= Settings.Aimbot_FOV and IsVisible(targetPart, player.Character) then
                        if dist < shortestDist then shortestDist = dist; closest = targetPart end
                    end
                end
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
            local isPlayer = false
            for _, plr in ipairs(Players:GetPlayers()) do if plr.Character == obj then isPlayer = true; break end end
            if not isPlayer and IsAlive(obj) then
                local targetPart = GetTargetPart(obj)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist <= Settings.Aimbot_FOV and IsVisible(targetPart, obj) then
                            if dist < shortestDist then shortestDist = dist; closest = targetPart end
                        end
                    end
                end
            end
        end
    end

    if closest then
        local targetPos = closest.Position
        if Settings.Aimbot_Prediction > 0 and closest.Parent then
            local root = closest.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                targetPos = targetPos + (root.Velocity * Settings.Aimbot_Prediction)
            end
        end
        local mainPos = Camera.CFrame.Position
        local direction = (targetPos - mainPos).Unit
        local newCFrame = CFrame.new(mainPos, mainPos + direction)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.Aimbot_Smoothness)
    end
end)

-- ==========================================
-- 9. SILENT AIM (BulletHandler Hook)
-- ==========================================
local BulletHandler
local success = pcall(function()
    BulletHandler = require(game:GetService("ReplicatedStorage"):WaitForChild("ModuleScripts"):WaitForChild("GunModules"):WaitForChild("BulletHandler"))
end)

if success and BulletHandler and BulletHandler.Fire then
    local oldFire = BulletHandler.Fire
    BulletHandler.Fire = function(args)
        if Settings.SilentAim_Enabled and not checkcaller() then
            local targetPart = nil
            local shortestDist = Settings.SilentAim_FOV
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and IsAlive(player.Character) then
                    local part = player.Character:FindFirstChild(Settings.SilentAim_TargetPart)
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                targetPart = part
                            end
                        end
                    end
                end
            end

            if targetPart then
                local origin = args.Origin
                if not origin then origin = Camera.CFrame.Position end
                args.Direction = (targetPart.Position - origin).Unit
            end
        end
        return oldFire(args)
    end)
    print("[Nova] Silent Aim успешно захукан через BulletHandler!")
else
    print("[Nova] ОШИБКА: Не удалось найти BulletHandler. Silent Aim не будет работать.")
end

print("Nova Flick v35 (FOV Fill Fix + BulletHandler Silent Aim) успешно загружен!")
