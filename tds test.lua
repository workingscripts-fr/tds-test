-- ==========================================
-- TDS TEST - AAA COSMIC UNIVERSE UI
-- ==========================================

print("script started")
warn("script started")
pcall(function() game:GetService("TestService"):Message("script started") end)
pcall(function() if type(rconsoleprint) == "function" then rconsoleprint("script started
") end end)
pcall(function() if type(rconsoleinfo) == "function" then rconsoleinfo("script started
") end end)
pcall(function() if type(printconsole) == "function" then printconsole("script started
") end end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

-- Safe, non-blocking LocalPlayer resolution
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        LocalPlayer = Players:FindFirstChildOfClass("Player")
    end)
end

-- Safe, non-blocking PlayerGui / CoreGui resolution
local PlayerGui = nil
if LocalPlayer then
    PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then
        pcall(function()
            PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 3)
        end)
    end
end

local parentContainer = nil
pcall(function()
    parentContainer = game:GetService("CoreGui")
end)
if not parentContainer then
    parentContainer = PlayerGui
end
if not parentContainer and LocalPlayer then
    parentContainer = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
end

-- Singleton cleanup to prevent multiple instances
local EXEC_ENV = (getgenv and getgenv()) or _G
local MENU_STATE_KEY = "__TDSTestSingletonState"

do
    local previousState = EXEC_ENV[MENU_STATE_KEY]
    if previousState then
        if previousState.cleanup then
            pcall(previousState.cleanup)
        end
        if previousState.gui and previousState.gui.Parent then
            pcall(function()
                previousState.gui:Destroy()
            end)
        end
        EXEC_ENV[MENU_STATE_KEY] = nil
    end
end

-- Theme Color Names
local UI_THEME_GREEN_PURPLE = "Green/Purple"
local UI_THEME_RAINBOW = "Rainbow"
local UI_THEME_GREEN_WHITE = "Green/White"
local UI_THEME_ORANGE_YELLOW = "Orange/Yellow"
local UI_THEME_VIOLET_INDIGO = "Violet/Indigo"
local UI_THEME_BLUE_PINK = "Blue/Pink"
local UI_THEME_BLUE_GREEN = "Blue/Green"
local UI_THEME_BLUE_WHITE = "Blue/White"
local UI_THEME_RED_BLUE = "Red/Blue"
local UI_THEME_AMERICA = "America"
local UI_THEME_GREEN_CYAN = "Green/Cyan"

local uiColorTheme = UI_THEME_RAINBOW

local uiThemeOptions = {
    UI_THEME_GREEN_PURPLE,
    UI_THEME_RAINBOW,
    UI_THEME_GREEN_WHITE,
    UI_THEME_ORANGE_YELLOW,
    UI_THEME_VIOLET_INDIGO,
    UI_THEME_BLUE_PINK,
    UI_THEME_BLUE_GREEN,
    UI_THEME_BLUE_WHITE,
    UI_THEME_RED_BLUE,
    UI_THEME_AMERICA,
    UI_THEME_GREEN_CYAN
}

-- Auto Queue Selection Settings
local selectedDifficulty = "Not Chosen"
local selectedSquadSize = "Not Chosen"

local difficultyOptions = {
    { name = "Not Chosen", req = "" },
    { name = "Easy", req = "Level 0" },
    { name = "Casual", req = "Level 0" },
    { name = "Intermediate", req = "Level 5" },
    { name = "Molten", req = "Level 15" },
    { name = "Fallen", req = "Level 30" }
}

local squadSizeOptions = {
    "Not Chosen",
    "Solo",
    "Duo",
    "Trio",
    "Quad"
}

-- Design System Tokens
local OUTLINE_GREEN = Color3.fromRGB(14, 255, 0)
local OUTLINE_PURPLE = Color3.fromRGB(214, 0, 255)
local TEXT_WHITE = Color3.fromRGB(245, 249, 255)
local SUBTLE_BLUE = Color3.fromRGB(174, 204, 236)
local rotatingGradients = {}

local function getThemeColorAt(theme, t)
    t = t % 1
    if theme == "Rainbow" then
        local base = {
            Color3.fromRGB(255, 0, 51),
            Color3.fromRGB(255, 94, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 102),
            Color3.fromRGB(0, 207, 255),
            Color3.fromRGB(61, 0, 255),
            Color3.fromRGB(204, 0, 255),
            Color3.fromRGB(255, 0, 51)
        }
        local n = #base
        local idx = t * (n - 1) + 1
        local low = math.floor(idx)
        local high = math.ceil(idx)
        local frac = idx - low
        if low == high then return base[low] end
        return base[low]:Lerp(base[high], frac)
    elseif theme == "Green/Purple" then
        return Color3.fromRGB(14, 255, 0):Lerp(Color3.fromRGB(214, 0, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Green/White" then
        return Color3.fromRGB(14, 255, 0):Lerp(Color3.fromRGB(245, 249, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Orange/Yellow" then
        return Color3.fromRGB(255, 120, 0):Lerp(Color3.fromRGB(255, 220, 0), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Violet/Indigo" then
        return Color3.fromRGB(140, 0, 255):Lerp(Color3.fromRGB(40, 0, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Blue/Pink" then
        return Color3.fromRGB(0, 180, 255):Lerp(Color3.fromRGB(255, 100, 200), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Blue/Green" then
        return Color3.fromRGB(0, 100, 255):Lerp(Color3.fromRGB(0, 255, 150), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Blue/White" then
        return Color3.fromRGB(0, 150, 255):Lerp(Color3.fromRGB(245, 249, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "Red/Blue" then
        return Color3.fromRGB(255, 40, 40):Lerp(Color3.fromRGB(40, 40, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    elseif theme == "America" then
        if t < 0.33 then
            return Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(255, 255, 255), t / 0.33)
        elseif t < 0.66 then
            return Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(0, 0, 255), (t - 0.33) / 0.33)
        else
            return Color3.fromRGB(0, 0, 255):Lerp(Color3.fromRGB(255, 0, 0), (t - 0.66) / 0.34)
        end
    elseif theme == "Green/Cyan" then
        return Color3.fromRGB(0, 255, 100):Lerp(Color3.fromRGB(0, 200, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    else
        return Color3.fromRGB(0, 255, 255):Lerp(Color3.fromRGB(214, 0, 255), (math.sin(t * math.pi * 2) + 1) / 2)
    end
end

local function getThemeColorSequence(theme)
    local keypoints = {}
    for i = 0, 7 do
        local p = i / 7
        local col = getThemeColorAt(theme, p)
        table.insert(keypoints, ColorSequenceKeypoint.new(p, col))
    end
    return ColorSequence.new(keypoints)
end

local function getShiftedThemeColorSequence(theme, shift)
    local keypoints = {}
    for i = 0, 7 do
        local p = i / 7
        local col = getThemeColorAt(theme, p - shift)
        table.insert(keypoints, ColorSequenceKeypoint.new(p, col))
    end
    return ColorSequence.new(keypoints)
end

local function attachRotatingOutline(strokeOrGrad, speed, initialRotation)
    local grad
    if strokeOrGrad:IsA("UIStroke") then
        grad = Instance.new("UIGradient")
        grad.Color = getThemeColorSequence(uiColorTheme)
        grad.Rotation = initialRotation or 0
        grad.Parent = strokeOrGrad
    elseif strokeOrGrad:IsA("UIGradient") then
        grad = strokeOrGrad
    end
    if grad then
        table.insert(rotatingGradients, { gradient = grad, speed = speed or 20 })
    end
    return grad
end

-- Dynamic real-time outline & theme updater loop
task.spawn(function()
    local lastTime = os.clock()
    while true do
        local now = os.clock()
        local dt = now - lastTime
        lastTime = now
        for _, item in ipairs(rotatingGradients) do
            if item.gradient and item.gradient.Parent then
                item.gradient.Rotation = (item.gradient.Rotation + (item.speed * dt)) % 360
                item.gradient.Color = getShiftedThemeColorSequence(uiColorTheme, now * 0.35)
            end
        end
        task.wait(0.03)
    end
end)

-- ----------------------------------------------------
-- AAA MODERN UI REDESIGN SECTION (COSMIC UNIVERSE THEME)
-- ----------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TDSTestUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 2147483647
pcall(function()
    screenGui.OnTopOfCoreBlur = true
end)
screenGui.Parent = parentContainer

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.new(0.5, 0, 0.5, 0)
root.Size = UDim2.fromOffset(720, 470)
root.BackgroundColor3 = Color3.fromRGB(7, 9, 13)
root.BackgroundTransparency = 0.12
root.BorderSizePixel = 0
root.Active = true
root.Parent = screenGui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 16)
rootCorner.Parent = root

-- Thin neon rotating rainbow border outlines (Full 360 wrap all around the entire menu)
local rootStroke = Instance.new("UIStroke")
rootStroke.Color = Color3.fromRGB(255, 255, 255)
rootStroke.Transparency = 0
rootStroke.Thickness = 2.0
rootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rootStroke.Parent = root
attachRotatingOutline(rootStroke, 22, 0)

local rootGlow = Instance.new("UIStroke")
rootGlow.Color = Color3.fromRGB(255, 255, 255)
rootGlow.Transparency = 0.35
rootGlow.Thickness = 1.2
rootGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rootGlow.Parent = root
attachRotatingOutline(rootGlow, 22, 180)

-- Cosmic Background Layer (Nebulas, twinkling stars, drift dust, shooting stars)
local function createUniverseBackground(parent)
    local bg = Instance.new("Frame")
    bg.Name = "UniverseBackground"
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(7, 9, 13)
    bg.BackgroundTransparency = 0.05
    bg.BorderSizePixel = 0
    bg.ZIndex = -10
    bg.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = bg
    
    -- Nebula layer 1
    local nebula1 = Instance.new("Frame")
    nebula1.Size = UDim2.fromScale(1.4, 1.4)
    nebula1.Position = UDim2.fromScale(-0.2, -0.2)
    nebula1.BackgroundTransparency = 0.78
    nebula1.BorderSizePixel = 0
    nebula1.ZIndex = -9
    nebula1.Parent = bg
    
    local nc1 = Instance.new("UICorner")
    nc1.CornerRadius = UDim.new(0, 16)
    nc1.Parent = nebula1
    
    local grad1 = Instance.new("UIGradient")
    grad1.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 25, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 5, 50))
    })
    grad1.Parent = nebula1
    table.insert(rotatingGradients, { gradient = grad1, speed = 5 })
    
    -- Nebula layer 2
    local nebula2 = Instance.new("Frame")
    nebula2.Size = UDim2.fromScale(1.3, 1.3)
    nebula2.Position = UDim2.fromScale(-0.15, -0.15)
    nebula2.BackgroundTransparency = 0.82
    nebula2.BorderSizePixel = 0
    nebula2.ZIndex = -8
    nebula2.Parent = bg
    
    local nc2 = Instance.new("UICorner")
    nc2.CornerRadius = UDim.new(0, 16)
    nc2.Parent = nebula2
    
    local grad2 = Instance.new("UIGradient")
    grad2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 5, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 40, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 30))
    })
    grad2.Parent = nebula2
    table.insert(rotatingGradients, { gradient = grad2, speed = -8 })
    
    -- 20 Twinkling Stars
    for i = 1, 20 do
        local star = Instance.new("Frame")
        star.Size = UDim2.fromOffset(math.random(10, 20)/10, math.random(10, 20)/10)
        star.Position = UDim2.fromScale(math.random(), math.random())
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = 0.4 + math.random() * 0.4
        star.BorderSizePixel = 0
        star.ZIndex = -7
        star.Parent = bg
        
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = star
        
        task.spawn(function()
            while star and star.Parent do
                local tweenTime = 1.5 + math.random() * 2.5
                TweenService:Create(star, TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.15 + math.random() * 0.75
                }):Play()
                task.wait(tweenTime)
            end
        end)
    end
    
    -- 12 Floating Dust Particles
    for i = 1, 12 do
        local p = Instance.new("Frame")
        p.Size = UDim2.fromOffset(2, 2)
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BackgroundColor3 = Color3.fromRGB(174, 204, 236)
        p.BackgroundTransparency = 0.6 + math.random() * 0.3
        p.BorderSizePixel = 0
        p.ZIndex = -6
        p.Parent = bg
        
        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(1, 0)
        pc.Parent = p
        
        task.spawn(function()
            local speedX = (math.random() - 0.5) * 0.012
            local speedY = (math.random() - 0.5) * 0.012
            while p and p.Parent do
                local nextX = (p.Position.X.Scale + speedX) % 1
                local nextY = (p.Position.Y.Scale + speedY) % 1
                p.Position = UDim2.fromScale(nextX, nextY)
                task.wait(0.06)
            end
        end)
    end
    
    -- Occasional Shooting Star
    task.spawn(function()
        while bg and bg.Parent do
            task.wait(math.random(8, 16))
            if not bg or not bg.Parent then break end
            
            local sStar = Instance.new("Frame")
            sStar.Size = UDim2.fromOffset(50, 1)
            sStar.Position = UDim2.fromScale(-0.1, math.random(0.1, 0.6))
            sStar.Rotation = 12
            sStar.BorderSizePixel = 0
            sStar.ZIndex = -5
            sStar.Parent = bg
            
            local sGrad = Instance.new("UIGradient")
            sGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 9, 13))
            })
            sGrad.Parent = sStar
            
            local startX = -0.2
            local startY = sStar.Position.Y.Scale
            local endX = 1.2
            local endY = startY + 0.3
            
            sStar.Position = UDim2.fromScale(startX, startY)
            
            local t = TweenService:Create(sStar, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.fromScale(endX, endY),
                BackgroundTransparency = 1
            })
            t:Play()
            t.Completed:Connect(function()
                sStar:Destroy()
            end)
        end
    end)
end

createUniverseBackground(root)

-- Top Header Bar
local topBar = Instance.new("Frame")
topBar.Name = "Header"
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.new(1, -32, 0, 68)
topBar.Position = UDim2.fromOffset(16, 12)
topBar.Parent = root

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(0.35, 0, 0, 26)
title.Position = UDim2.fromOffset(0, 4)
title.Font = Enum.Font.GothamBold
title.Text = "TDS TEST"
title.TextSize = 25
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Dedicated rainbow gradient title text (Continuously animated rotating rainbow effect)
local titleGradient = Instance.new("UIGradient")
titleGradient.Name = "TitleGradient"
titleGradient.Color = getThemeColorSequence(uiColorTheme)
titleGradient.Parent = title
attachRotatingOutline(titleGradient, 35, 0)

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(0.35, 0, 0, 16)
subtitle.Position = UDim2.fromOffset(0, 32)
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = "Universal Cosmic Interface v1.0"
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(140, 150, 165)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topBar

-- Header Right Widgets Area
local headerRight = Instance.new("Frame")
headerRight.Name = "RightWidgetArea"
headerRight.AnchorPoint = Vector2.new(1, 0.5)
headerRight.Position = UDim2.new(1, 0, 0.5, 0)
headerRight.Size = UDim2.new(0.6, 0, 1, 0)
headerRight.BackgroundTransparency = 1
headerRight.Parent = topBar

local widgetList = Instance.new("UIListLayout")
widgetList.FillDirection = Enum.FillDirection.Horizontal
widgetList.HorizontalAlignment = Enum.HorizontalAlignment.Right
widgetList.VerticalAlignment = Enum.VerticalAlignment.Center
widgetList.Padding = UDim.new(0, 14)
widgetList.Parent = headerRight

-- Utility helper to style buttons with subtle hover lift and rotating rainbow outline
local function styleInteractiveButton(btn)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn
    attachRotatingOutline(stroke, 26, math.random(0, 359))
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(22, 31, 46),
            Size = UDim2.fromOffset(btn.Size.X.Offset + 2, btn.Size.Y.Offset + 2)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(11, 15, 24),
            Size = UDim2.fromOffset(btn.Size.X.Offset - 2, btn.Size.Y.Offset - 2)
        }):Play()
    end)
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(btn.Size.X.Offset - 4, btn.Size.Y.Offset - 4)
            }):Play()
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(btn.Size.X.Offset + 4, btn.Size.Y.Offset + 4)
            }):Play()
        end
    end)
end

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseBtn"
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextSize = 13
closeButton.TextColor3 = Color3.fromRGB(255, 90, 90)
closeButton.AutoButtonColor = false
closeButton.LayoutOrder = 10
closeButton.Parent = headerRight
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton
styleInteractiveButton(closeButton)

closeButton.MouseButton1Click:Connect(function()
    if screenGui then
        screenGui:Destroy()
    end
end)

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeBtn"
minimizeButton.Size = UDim2.fromOffset(30, 30)
minimizeButton.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "_"
minimizeButton.TextSize = 16
minimizeButton.TextColor3 = Color3.fromRGB(245, 249, 255)
minimizeButton.AutoButtonColor = false
minimizeButton.LayoutOrder = 9
minimizeButton.Parent = headerRight
local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton
styleInteractiveButton(minimizeButton)

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    root.Visible = not isMinimized
end)

-- RightShift hotkey to toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        isMinimized = not isMinimized
        root.Visible = not isMinimized
    end
end)

-- Performance monitor widgets (FPS / Ping / Clock)
local statsContainer = Instance.new("Frame")
statsContainer.Name = "StatsMonitor"
statsContainer.Size = UDim2.fromOffset(190, 30)
statsContainer.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
statsContainer.BorderSizePixel = 0
statsContainer.LayoutOrder = 8
statsContainer.Parent = headerRight
local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsContainer

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = Color3.fromRGB(255, 255, 255)
statsStroke.Thickness = 1.4
statsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
statsStroke.Parent = statsContainer
attachRotatingOutline(statsStroke, 24, 90)

local statsList = Instance.new("UIListLayout")
statsList.FillDirection = Enum.FillDirection.Horizontal
statsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsList.VerticalAlignment = Enum.VerticalAlignment.Center
statsList.Padding = UDim.new(0, 10)
statsList.Parent = statsContainer

local fpsLabel = Instance.new("TextLabel")
fpsLabel.BackgroundTransparency = 1
fpsLabel.Size = UDim2.new(0, 50, 1, 0)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.Text = "60 FPS"
fpsLabel.TextSize = 11
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Parent = statsContainer

local pingLabel = Instance.new("TextLabel")
pingLabel.BackgroundTransparency = 1
pingLabel.Size = UDim2.new(0, 50, 1, 0)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.Text = "0 MS"
pingLabel.TextSize = 11
pingLabel.TextColor3 = Color3.fromRGB(174, 204, 236)
pingLabel.Parent = statsContainer

local clockLabel = Instance.new("TextLabel")
clockLabel.BackgroundTransparency = 1
clockLabel.Size = UDim2.new(0, 50, 1, 0)
clockLabel.Font = Enum.Font.GothamBold
clockLabel.Text = "00:00"
clockLabel.TextSize = 11
clockLabel.TextColor3 = Color3.fromRGB(140, 150, 165)
clockLabel.Parent = statsContainer

-- Live Monitor Stats Loop
task.spawn(function()
    local frameCount = 0
    local lastFpsTime = os.clock()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastFpsTime >= 1 then
            local currentFps = math.floor(frameCount / (now - lastFpsTime))
            fpsLabel.Text = currentFps .. " FPS"
            frameCount = 0
            lastFpsTime = now
            
            pcall(function()
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                pingLabel.Text = ping .. " MS"
            end)
            
            clockLabel.Text = os.date("%H:%M")
        end
    end)
end)

-- Profile Avatar Badge
local profileBadge = Instance.new("Frame")
profileBadge.Name = "UserProfile"
profileBadge.Size = UDim2.fromOffset(30, 30)
profileBadge.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
profileBadge.BorderSizePixel = 0
profileBadge.LayoutOrder = 7
profileBadge.Parent = headerRight

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(1, 0)
profileCorner.Parent = profileBadge

local profileStroke = Instance.new("UIStroke")
profileStroke.Color = Color3.fromRGB(255, 255, 255)
profileStroke.Thickness = 1.4
profileStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
profileStroke.Parent = profileBadge
attachRotatingOutline(profileStroke, 24, 180)

local profileAvatar = Instance.new("ImageLabel")
profileAvatar.Size = UDim2.fromScale(1, 1)
profileAvatar.BackgroundTransparency = 1
profileAvatar.BorderSizePixel = 0
profileAvatar.Parent = profileBadge
local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = profileAvatar

task.spawn(function()
    if LocalPlayer then
        pcall(function()
            local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            if content then
                profileAvatar.Image = content
            end
        end)
    end
end)

-- Main Content Container (Left Sidebar + Right Panel)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.BackgroundTransparency = 1
contentArea.Position = UDim2.fromOffset(16, 84)
contentArea.Size = UDim2.new(1, -32, 1, -100)
contentArea.Parent = root

-- Left Sidebar Container
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
sidebar.Size = UDim2.new(0, 190, 1, 0)
sidebar.BorderSizePixel = 0
sidebar.Parent = contentArea

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 14)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(255, 255, 255)
sidebarStroke.Thickness = 1.4
sidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sidebarStroke.Parent = sidebar
attachRotatingOutline(sidebarStroke, 20, 90)

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.PaddingTop = UDim.new(0, 10)
sidebarPadding.PaddingBottom = UDim.new(0, 10)
sidebarPadding.Parent = sidebar

local sidebarList = Instance.new("UIListLayout")
sidebarList.Padding = UDim.new(0, 8)
sidebarList.Parent = sidebar

-- ----------------------------------------------------
-- RIGHT CONTENT DISPLAY PANELS & TAB NAVIGATION SYSTEM
-- ----------------------------------------------------

local activeTabName = "Auto Matchmaking"
local tabButtonsList = {}
local tabPagesList = {}

local function switchTab(tabName)
    activeTabName = tabName
    for name, data in pairs(tabButtonsList) do
        local isActive = (name == tabName)
        data.button.BackgroundColor3 = isActive and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
        data.stroke.Transparency = isActive and 0 or 0.7
    end
    for name, page in pairs(tabPagesList) do
        page.Visible = (name == tabName)
    end
end

local function createSidebarTabButton(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "TabBtn_" .. name
    tabBtn.Size = UDim2.new(1, 0, 0, 42)
    tabBtn.BackgroundColor3 = Color3.fromRGB(14, 19, 29)
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Text = ""
    tabBtn.Parent = sidebar
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 10)
    tabCorner.Parent = tabBtn
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(255, 255, 255)
    tabStroke.Thickness = 1.4
    tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tabStroke.Parent = tabBtn
    attachRotatingOutline(tabStroke, 24, 0)
    
    local tabText = Instance.new("TextLabel")
    tabText.Name = "TabText"
    tabText.Size = UDim2.new(1, 0, 1, 0)
    tabText.Position = UDim2.fromOffset(0, 0)
    tabText.BackgroundTransparency = 1
    tabText.Font = Enum.Font.GothamBold
    tabText.Text = name
    tabText.TextSize = 13
    tabText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabText.TextXAlignment = Enum.TextXAlignment.Center
    tabText.TextYAlignment = Enum.TextYAlignment.Center
    tabText.Parent = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    tabButtonsList[name] = { button = tabBtn, stroke = tabStroke }
    return tabBtn
end

createSidebarTabButton("Auto Matchmaking")
createSidebarTabButton("Menu Settings")


-- Forward declarations for cross-section variables
local tStatus

do -- Page 1: Auto Matchmaking scope
-- ==========================================================
-- PAGE 1: AUTO MATCHMAKING TAB
-- ==========================================================

local autoMatchPage = Instance.new("Frame")
autoMatchPage.Name = "Page_AutoMatchmaking"
autoMatchPage.AnchorPoint = Vector2.new(1, 0)
autoMatchPage.Position = UDim2.new(1, 0, 0, 0)
autoMatchPage.Size = UDim2.new(1, -204, 1, 0)
autoMatchPage.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
autoMatchPage.BackgroundTransparency = 0.25
autoMatchPage.BorderSizePixel = 0
autoMatchPage.Visible = true
autoMatchPage.ClipsDescendants = false
autoMatchPage.Parent = contentArea

local amCorner = Instance.new("UICorner")
amCorner.CornerRadius = UDim.new(0, 14)
amCorner.Parent = autoMatchPage

local amStroke = Instance.new("UIStroke")
amStroke.Color = Color3.fromRGB(255, 255, 255)
amStroke.Thickness = 1.4
amStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
amStroke.Parent = autoMatchPage
attachRotatingOutline(amStroke, 20, 270)

local amTitle = Instance.new("TextLabel")
amTitle.BackgroundTransparency = 1
amTitle.Position = UDim2.fromOffset(18, 14)
amTitle.Size = UDim2.new(1, -36, 0, 24)
amTitle.Font = Enum.Font.GothamBold
amTitle.Text = "Auto Matchmaking"
amTitle.TextSize = 20
amTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
amTitle.TextXAlignment = Enum.TextXAlignment.Left
amTitle.Parent = autoMatchPage

local amDesc = Instance.new("TextLabel")
amDesc.BackgroundTransparency = 1
amDesc.Position = UDim2.fromOffset(18, 38)
amDesc.Size = UDim2.new(1, -36, 0, 16)
amDesc.Font = Enum.Font.GothamMedium
amDesc.Text = "Automated queue & elevator mode selection system."
amDesc.TextSize = 11
amDesc.TextColor3 = Color3.fromRGB(140, 150, 165)
amDesc.TextXAlignment = Enum.TextXAlignment.Left
amDesc.Parent = autoMatchPage

local amScroll = Instance.new("ScrollingFrame")
amScroll.BackgroundTransparency = 1
amScroll.Position = UDim2.fromOffset(18, 64)
amScroll.Size = UDim2.new(1, -36, 1, -74)
amScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
amScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
amScroll.ScrollBarThickness = 4
amScroll.ScrollBarImageColor3 = Color3.fromRGB(27, 36, 51)
amScroll.ScrollBarImageTransparency = 0.35
amScroll.ScrollingDirection = Enum.ScrollingDirection.Y
amScroll.BorderSizePixel = 0
amScroll.ClipsDescendants = false
amScroll.Parent = autoMatchPage

local amLayout = Instance.new("UIListLayout")
amLayout.Padding = UDim.new(0, 14)
amLayout.SortOrder = Enum.SortOrder.LayoutOrder
amLayout.Parent = amScroll

local amPadding = Instance.new("UIPadding")
amPadding.PaddingLeft = UDim.new(0, 2)
amPadding.PaddingRight = UDim.new(0, 6)
amPadding.PaddingTop = UDim.new(0, 4)
amPadding.PaddingBottom = UDim.new(0, 14)
amPadding.Parent = amScroll

tabPagesList["Auto Matchmaking"] = autoMatchPage

-- TOGGLE CONTROL: AUTO QUEUE WITH CLEAN STATUS LABEL
local autoQueueEnabled = false
local isPlayerQueuedState = false

local toggleCard = Instance.new("Frame")
toggleCard.Name = "ToggleCard_AutoQueue"
toggleCard.Size = UDim2.new(1, 0, 0, 84)
toggleCard.BackgroundColor3 = Color3.fromRGB(16, 23, 34)
toggleCard.BorderSizePixel = 0
toggleCard.LayoutOrder = 1
toggleCard.Parent = amScroll

local tcCorner = Instance.new("UICorner")
tcCorner.CornerRadius = UDim.new(0, 12)
tcCorner.Parent = toggleCard

local tcStroke = Instance.new("UIStroke")
tcStroke.Color = Color3.fromRGB(255, 255, 255)
tcStroke.Thickness = 1.4
tcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tcStroke.Parent = toggleCard
attachRotatingOutline(tcStroke, 22, 45)

local tLabel = Instance.new("TextLabel")
tLabel.Position = UDim2.fromOffset(16, 10)
tLabel.Size = UDim2.new(0.65, 0, 0, 20)
tLabel.BackgroundTransparency = 1
tLabel.Font = Enum.Font.GothamBold
tLabel.Text = "Auto Queue"
tLabel.TextSize = 14
tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tLabel.TextXAlignment = Enum.TextXAlignment.Left
tLabel.Parent = toggleCard

local tSub = Instance.new("TextLabel")
tSub.Position = UDim2.fromOffset(16, 30)
tSub.Size = UDim2.new(0.65, 0, 0, 20)
tSub.BackgroundTransparency = 1
tSub.Font = Enum.Font.GothamMedium
tSub.Text = "Auto queue into selected mode & squad size seamlessly."
tSub.TextSize = 11
tSub.TextColor3 = Color3.fromRGB(140, 150, 165)
tSub.TextXAlignment = Enum.TextXAlignment.Left
tSub.Parent = toggleCard

tStatus = Instance.new("TextLabel")
tStatus.Name = "LiveStatus"
tStatus.Position = UDim2.fromOffset(16, 52)
tStatus.Size = UDim2.new(0.9, 0, 0, 20)
tStatus.BackgroundTransparency = 1
tStatus.Font = Enum.Font.GothamMedium
tStatus.Text = "Status: Disabled"
tStatus.TextSize = 12
tStatus.TextColor3 = Color3.fromRGB(160, 170, 184)
tStatus.TextXAlignment = Enum.TextXAlignment.Left
tStatus.Parent = toggleCard

-- Toggle Switch Control (Right Side)
local switchBtn = Instance.new("TextButton")
switchBtn.Name = "SwitchBtn"
switchBtn.AnchorPoint = Vector2.new(1, 0.5)
switchBtn.Position = UDim2.new(1, -16, 0.4, 0)
switchBtn.Size = UDim2.fromOffset(50, 26)
switchBtn.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
switchBtn.BorderSizePixel = 0
switchBtn.AutoButtonColor = false
switchBtn.Text = ""
switchBtn.Parent = toggleCard

local swCorner = Instance.new("UICorner")
swCorner.CornerRadius = UDim.new(1, 0)
swCorner.Parent = switchBtn

local swStroke = Instance.new("UIStroke")
swStroke.Color = Color3.fromRGB(255, 255, 255)
swStroke.Thickness = 1.4
swStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
swStroke.Parent = switchBtn
attachRotatingOutline(swStroke, 24, 135)

local swKnob = Instance.new("Frame")
swKnob.Name = "Knob"
swKnob.Size = UDim2.fromOffset(20, 20)
swKnob.Position = UDim2.fromOffset(3, 3)
swKnob.BackgroundColor3 = Color3.fromRGB(140, 150, 165)
swKnob.BorderSizePixel = 0
swKnob.Parent = switchBtn

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = swKnob

-- DROPDOWN 1: DIFFICULTY SELECTION CARD
local diffCard = Instance.new("Frame")
diffCard.Name = "DropdownCard_Difficulty"
diffCard.Size = UDim2.new(1, 0, 0, 72)
diffCard.BackgroundColor3 = Color3.fromRGB(16, 23, 34)
diffCard.BorderSizePixel = 0
diffCard.ZIndex = 50
diffCard.LayoutOrder = 2
diffCard.Parent = amScroll

local dcCorner = Instance.new("UICorner")
dcCorner.CornerRadius = UDim.new(0, 12)
dcCorner.Parent = diffCard

local dcStroke = Instance.new("UIStroke")
dcStroke.Color = Color3.fromRGB(255, 255, 255)
dcStroke.Thickness = 1.4
dcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dcStroke.Parent = diffCard
attachRotatingOutline(dcStroke, 22, 90)

local dcTitle = Instance.new("TextLabel")
dcTitle.Position = UDim2.fromOffset(16, 12)
dcTitle.Size = UDim2.new(0.5, 0, 0, 20)
dcTitle.BackgroundTransparency = 1
dcTitle.Font = Enum.Font.GothamBold
dcTitle.Text = "Difficulty"
dcTitle.TextSize = 14
dcTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
dcTitle.TextXAlignment = Enum.TextXAlignment.Left
dcTitle.ZIndex = 51
dcTitle.Parent = diffCard

local dcSub = Instance.new("TextLabel")
dcSub.Position = UDim2.fromOffset(16, 34)
dcSub.Size = UDim2.new(0.5, 0, 0, 24)
dcSub.BackgroundTransparency = 1
dcSub.Font = Enum.Font.GothamMedium
dcSub.Text = "Select game difficulty & level requirement."
dcSub.TextSize = 11
dcSub.TextColor3 = Color3.fromRGB(140, 150, 165)
dcSub.TextXAlignment = Enum.TextXAlignment.Left
dcSub.TextWrapped = true
dcSub.ZIndex = 51
dcSub.Parent = diffCard

local diffTrigger = Instance.new("TextButton")
diffTrigger.Name = "DifficultyTrigger"
diffTrigger.AnchorPoint = Vector2.new(1, 0.5)
diffTrigger.Position = UDim2.new(1, -16, 0.5, 0)
diffTrigger.Size = UDim2.fromOffset(200, 38)
diffTrigger.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
diffTrigger.BorderSizePixel = 0
diffTrigger.AutoButtonColor = false
diffTrigger.Text = ""
diffTrigger.ZIndex = 52
diffTrigger.Parent = diffCard

local dtCorner = Instance.new("UICorner")
dtCorner.CornerRadius = UDim.new(0, 8)
dtCorner.Parent = diffTrigger

local dtStroke = Instance.new("UIStroke")
dtStroke.Color = Color3.fromRGB(255, 255, 255)
dtStroke.Thickness = 1.4
dtStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dtStroke.Parent = diffTrigger
attachRotatingOutline(dtStroke, 24, 180)

local diffSelectedText = Instance.new("TextLabel")
diffSelectedText.Name = "SelectedText"
diffSelectedText.Position = UDim2.fromOffset(14, 0)
diffSelectedText.Size = UDim2.new(1, -38, 1, 0)
diffSelectedText.BackgroundTransparency = 1
diffSelectedText.Font = Enum.Font.GothamBold
diffSelectedText.Text = selectedDifficulty
diffSelectedText.TextSize = 12
diffSelectedText.TextColor3 = Color3.fromRGB(245, 249, 255)
diffSelectedText.TextXAlignment = Enum.TextXAlignment.Left
diffSelectedText.ZIndex = 53
diffSelectedText.Parent = diffTrigger

local diffChevron = Instance.new("TextLabel")
diffChevron.AnchorPoint = Vector2.new(1, 0.5)
diffChevron.Position = UDim2.new(1, -10, 0.5, 0)
diffChevron.Size = UDim2.fromOffset(16, 16)
diffChevron.BackgroundTransparency = 1
diffChevron.Font = Enum.Font.GothamBold
diffChevron.Text = "v"
diffChevron.TextSize = 10
diffChevron.TextColor3 = Color3.fromRGB(140, 150, 165)
diffChevron.ZIndex = 53
diffChevron.Parent = diffTrigger

local diffListContainer = Instance.new("Frame")
diffListContainer.Name = "DiffOptionsList"
diffListContainer.AnchorPoint = Vector2.new(1, 0)
diffListContainer.Position = UDim2.new(1, -16, 1, 6)
diffListContainer.Size = UDim2.fromOffset(200, 0)
diffListContainer.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
diffListContainer.BorderSizePixel = 0
diffListContainer.ClipsDescendants = true
diffListContainer.Visible = false
diffListContainer.ZIndex = 200
diffListContainer.Parent = diffCard

local dlcCorner = Instance.new("UICorner")
dlcCorner.CornerRadius = UDim.new(0, 8)
dlcCorner.Parent = diffListContainer

local dlcStroke = Instance.new("UIStroke")
dlcStroke.Color = Color3.fromRGB(255, 255, 255)
dlcStroke.Thickness = 1.4
dlcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dlcStroke.Parent = diffListContainer
attachRotatingOutline(dlcStroke, 24, 0)

local diffScroll = Instance.new("ScrollingFrame")
diffScroll.Size = UDim2.fromScale(1, 1)
diffScroll.BackgroundTransparency = 1
diffScroll.BorderSizePixel = 0
diffScroll.ScrollBarThickness = 3
diffScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
diffScroll.ScrollingDirection = Enum.ScrollingDirection.Y
diffScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
diffScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
diffScroll.ZIndex = 201
diffScroll.Parent = diffListContainer

local diffLayout = Instance.new("UIListLayout")
diffLayout.Padding = UDim.new(0, 4)
diffLayout.Parent = diffScroll

local diffPadding = Instance.new("UIPadding")
diffPadding.PaddingLeft = UDim.new(0, 4)
diffPadding.PaddingRight = UDim.new(0, 6)
diffPadding.PaddingTop = UDim.new(0, 4)
diffPadding.PaddingBottom = UDim.new(0, 4)
diffPadding.Parent = diffScroll

local diffOptionButtons = {}

for _, item in ipairs(difficultyOptions) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Name = "DiffOption_" .. item.name
    itemBtn.Size = UDim2.new(1, 0, 0, 32)
    itemBtn.BackgroundColor3 = item.name == selectedDifficulty and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
    itemBtn.BorderSizePixel = 0
    itemBtn.AutoButtonColor = false
    itemBtn.Text = ""
    itemBtn.ZIndex = 202
    itemBtn.Parent = diffScroll
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = itemBtn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Position = UDim2.fromOffset(10, 0)
    nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Text = item.name
    nameLabel.TextSize = 11
    nameLabel.TextColor3 = item.name == selectedDifficulty and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(174, 204, 236)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 203
    nameLabel.Parent = itemBtn
    
    local reqLabel = Instance.new("TextLabel")
    reqLabel.Position = UDim2.new(0.5, 0, 0, 0)
    reqLabel.Size = UDim2.new(0.5, -10, 1, 0)
    reqLabel.BackgroundTransparency = 1
    reqLabel.Font = Enum.Font.Gotham
    reqLabel.Text = item.req
    reqLabel.TextSize = 10
    reqLabel.TextColor3 = Color3.fromRGB(140, 150, 165)
    reqLabel.TextXAlignment = Enum.TextXAlignment.Right
    reqLabel.ZIndex = 203
    reqLabel.Parent = itemBtn
    
    itemBtn.MouseEnter:Connect(function()
        if item.name ~= selectedDifficulty then
            TweenService:Create(itemBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(22, 31, 46)
            }):Play()
            TweenService:Create(nameLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    itemBtn.MouseLeave:Connect(function()
        if item.name ~= selectedDifficulty then
            TweenService:Create(itemBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(14, 19, 29)
            }):Play()
            TweenService:Create(nameLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(174, 204, 236)
            }):Play()
        end
    end)
    
    table.insert(diffOptionButtons, { button = itemBtn, label = nameLabel, data = item })
end

local isDiffOpen = false

local function setDiffDropdownOpen(open)
    isDiffOpen = open
    diffListContainer.Visible = true
    
    local targetHeight = isDiffOpen and 180 or 0
    local targetRotation = isDiffOpen and 180 or 0
    
    TweenService:Create(diffListContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(200, targetHeight)
    }):Play()
    
    TweenService:Create(diffChevron, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = targetRotation
    }):Play()
    
    if not isDiffOpen then
        task.delay(0.25, function()
            if not isDiffOpen then
                diffListContainer.Visible = false
            end
        end)
    end
end

diffTrigger.MouseButton1Click:Connect(function()
    setDiffDropdownOpen(not isDiffOpen)
end)

for _, opt in ipairs(diffOptionButtons) do
    opt.button.MouseButton1Click:Connect(function()
        selectedDifficulty = opt.data.name
        diffSelectedText.Text = selectedDifficulty
        isPlayerQueuedState = false
        
        for _, other in ipairs(diffOptionButtons) do
            local isActive = other.data.name == selectedDifficulty
            other.button.BackgroundColor3 = isActive and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
            other.label.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(174, 204, 236)
        end
        
        setDiffDropdownOpen(false)
    end)
end

-- DROPDOWN 2: SQUAD SIZE SELECTION CARD
local squadCard = Instance.new("Frame")
squadCard.Name = "DropdownCard_SquadSize"
squadCard.Size = UDim2.new(1, 0, 0, 72)
squadCard.BackgroundColor3 = Color3.fromRGB(16, 23, 34)
squadCard.BorderSizePixel = 0
squadCard.ZIndex = 40
squadCard.LayoutOrder = 3
squadCard.Parent = amScroll

local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 12)
scCorner.Parent = squadCard

local scStroke = Instance.new("UIStroke")
scStroke.Color = Color3.fromRGB(255, 255, 255)
scStroke.Thickness = 1.4
scStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
scStroke.Parent = squadCard
attachRotatingOutline(scStroke, 22, 180)

local scTitle = Instance.new("TextLabel")
scTitle.Position = UDim2.fromOffset(16, 12)
scTitle.Size = UDim2.new(0.5, 0, 0, 20)
scTitle.BackgroundTransparency = 1
scTitle.Font = Enum.Font.GothamBold
scTitle.Text = "Squad Size"
scTitle.TextSize = 14
scTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
scTitle.TextXAlignment = Enum.TextXAlignment.Left
scTitle.ZIndex = 41
scTitle.Parent = squadCard

local scSub = Instance.new("TextLabel")
scSub.Position = UDim2.fromOffset(16, 34)
scSub.Size = UDim2.new(0.5, 0, 0, 24)
scSub.BackgroundTransparency = 1
scSub.Font = Enum.Font.GothamMedium
scSub.Text = "Select elevator squad player count."
scSub.TextSize = 11
scSub.TextColor3 = Color3.fromRGB(140, 150, 165)
scSub.TextXAlignment = Enum.TextXAlignment.Left
scSub.TextWrapped = true
scSub.ZIndex = 41
scSub.Parent = squadCard

local squadTrigger = Instance.new("TextButton")
squadTrigger.Name = "SquadSizeTrigger"
squadTrigger.AnchorPoint = Vector2.new(1, 0.5)
squadTrigger.Position = UDim2.new(1, -16, 0.5, 0)
squadTrigger.Size = UDim2.fromOffset(200, 38)
squadTrigger.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
squadTrigger.BorderSizePixel = 0
squadTrigger.AutoButtonColor = false
squadTrigger.Text = ""
squadTrigger.ZIndex = 42
squadTrigger.Parent = squadCard

local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 8)
stCorner.Parent = squadTrigger

local stStroke = Instance.new("UIStroke")
stStroke.Color = Color3.fromRGB(255, 255, 255)
stStroke.Thickness = 1.4
stStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stStroke.Parent = squadTrigger
attachRotatingOutline(stStroke, 24, 270)

local squadSelectedText = Instance.new("TextLabel")
squadSelectedText.Name = "SelectedText"
squadSelectedText.Position = UDim2.fromOffset(14, 0)
squadSelectedText.Size = UDim2.new(1, -38, 1, 0)
squadSelectedText.BackgroundTransparency = 1
squadSelectedText.Font = Enum.Font.GothamBold
squadSelectedText.Text = selectedSquadSize
squadSelectedText.TextSize = 12
squadSelectedText.TextColor3 = Color3.fromRGB(245, 249, 255)
squadSelectedText.TextXAlignment = Enum.TextXAlignment.Left
squadSelectedText.ZIndex = 43
squadSelectedText.Parent = squadTrigger

local squadChevron = Instance.new("TextLabel")
squadChevron.AnchorPoint = Vector2.new(1, 0.5)
squadChevron.Position = UDim2.new(1, -10, 0.5, 0)
squadChevron.Size = UDim2.fromOffset(16, 16)
squadChevron.BackgroundTransparency = 1
squadChevron.Font = Enum.Font.GothamBold
squadChevron.Text = "v"
squadChevron.TextSize = 10
squadChevron.TextColor3 = Color3.fromRGB(140, 150, 165)
squadChevron.ZIndex = 43
squadChevron.Parent = squadTrigger

local squadListContainer = Instance.new("Frame")
squadListContainer.Name = "SquadOptionsList"
squadListContainer.AnchorPoint = Vector2.new(1, 0)
squadListContainer.Position = UDim2.new(1, -16, 1, 6)
squadListContainer.Size = UDim2.fromOffset(200, 0)
squadListContainer.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
squadListContainer.BorderSizePixel = 0
squadListContainer.ClipsDescendants = true
squadListContainer.Visible = false
squadListContainer.ZIndex = 190
squadListContainer.Parent = squadCard

local slcCorner = Instance.new("UICorner")
slcCorner.CornerRadius = UDim.new(0, 8)
slcCorner.Parent = squadListContainer

local slcStroke = Instance.new("UIStroke")
slcStroke.Color = Color3.fromRGB(255, 255, 255)
slcStroke.Thickness = 1.4
slcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
slcStroke.Parent = squadListContainer
attachRotatingOutline(slcStroke, 24, 0)

local squadScroll = Instance.new("ScrollingFrame")
squadScroll.Size = UDim2.fromScale(1, 1)
squadScroll.BackgroundTransparency = 1
squadScroll.BorderSizePixel = 0
squadScroll.ScrollBarThickness = 3
squadScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
squadScroll.ScrollingDirection = Enum.ScrollingDirection.Y
squadScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
squadScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
squadScroll.ZIndex = 191
squadScroll.Parent = squadListContainer

local squadLayout = Instance.new("UIListLayout")
squadLayout.Padding = UDim.new(0, 4)
squadLayout.Parent = squadScroll

local squadPadding = Instance.new("UIPadding")
squadPadding.PaddingLeft = UDim.new(0, 4)
squadPadding.PaddingRight = UDim.new(0, 6)
squadPadding.PaddingTop = UDim.new(0, 4)
squadPadding.PaddingBottom = UDim.new(0, 4)
squadPadding.Parent = squadScroll

local squadOptionButtons = {}

for _, modeName in ipairs(squadSizeOptions) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Name = "SquadOption_" .. modeName
    itemBtn.Size = UDim2.new(1, 0, 0, 32)
    itemBtn.BackgroundColor3 = modeName == selectedSquadSize and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
    itemBtn.BorderSizePixel = 0
    itemBtn.AutoButtonColor = false
    itemBtn.Text = ""
    itemBtn.ZIndex = 192
    itemBtn.Parent = squadScroll
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = itemBtn
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Position = UDim2.fromOffset(10, 0)
    nameLabel.Size = UDim2.new(1, -20, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Text = modeName
    nameLabel.TextSize = 11
    nameLabel.TextColor3 = modeName == selectedSquadSize and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(174, 204, 236)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 193
    nameLabel.Parent = itemBtn
    
    itemBtn.MouseEnter:Connect(function()
        if modeName ~= selectedSquadSize then
            TweenService:Create(itemBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(22, 31, 46)
            }):Play()
            TweenService:Create(nameLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    itemBtn.MouseLeave:Connect(function()
        if modeName ~= selectedSquadSize then
            TweenService:Create(itemBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(14, 19, 29)
            }):Play()
            TweenService:Create(nameLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(174, 204, 236)
            }):Play()
        end
    end)
    
    table.insert(squadOptionButtons, { button = itemBtn, label = nameLabel, name = modeName })
end

local isSquadOpen = false

local function setSquadDropdownOpen(open)
    isSquadOpen = open
    squadListContainer.Visible = true
    
    local targetHeight = isSquadOpen and 150 or 0
    local targetRotation = isSquadOpen and 180 or 0
    
    TweenService:Create(squadListContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(200, targetHeight)
    }):Play()
    
    TweenService:Create(squadChevron, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = targetRotation
    }):Play()
    
    if not isSquadOpen then
        task.delay(0.25, function()
            if not isSquadOpen then
                squadListContainer.Visible = false
            end
        end)
    end
end

squadTrigger.MouseButton1Click:Connect(function()
    setSquadDropdownOpen(not isSquadOpen)
end)

for _, opt in ipairs(squadOptionButtons) do
    opt.button.MouseButton1Click:Connect(function()
        selectedSquadSize = opt.name
        squadSelectedText.Text = selectedSquadSize
        isPlayerQueuedState = false
        
        for _, other in ipairs(squadOptionButtons) do
            local isActive = other.name == selectedSquadSize
            other.button.BackgroundColor3 = isActive and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
            other.label.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(174, 204, 236)
        end
        
        setSquadDropdownOpen(false)
    end)
end

end -- Page 1 scope

do -- Click Engine scope
-- ==========================================================
-- REAL VISIBILITY & PRECISE CLICK ENGINE
-- ==========================================================

-- Check if a GUI element is TRULY visible to the user on screen
local function isGuiObjectTrulyVisible(gui)
    if not gui or not gui:IsA("GuiObject") then return false end
    if gui.AbsoluteSize.X <= 2 or gui.AbsoluteSize.Y <= 2 then return false end
    
    -- STRICT Viewport Screen Bounds Check
    local vp = Vector2.new(1920, 1080)
    pcall(function()
        if workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize then
            vp = workspace.CurrentCamera.ViewportSize
        end
    end)
    local absPos = gui.AbsolutePosition
    local absSize = gui.AbsoluteSize
    if absPos.X + absSize.X <= 0 or absPos.Y + absSize.Y <= 0 or absPos.X >= vp.X or absPos.Y >= vp.Y then
        return false
    end
    
    local current = gui
    while current do
        if current:IsA("ScreenGui") then
            if not current.Enabled then return false end
            break
        elseif current:IsA("GuiObject") then
            if not current.Visible then return false end
            if current:IsA("CanvasGroup") and current.GroupTransparency >= 0.95 then return false end
        end
        current = current.Parent
    end
    return true
end

local function sendHardwareClick(gui)
    if not gui or not isGuiObjectTrulyVisible(gui) then return false end
    local absPos = gui.AbsolutePosition
    local absSize = gui.AbsoluteSize
    if absSize.X <= 0 or absSize.Y <= 0 then return false end
    
    local centerX = math.floor(absPos.X + absSize.X / 2)
    local centerY = math.floor(absPos.Y + absSize.Y / 2)
    
    -- Temporarily hide custom TDS TEST menu if it overlaps the click point
    local menuWasVisible = root.Visible
    local isOverlappingMenu = false
    if menuWasVisible and root.AbsoluteSize.X > 0 then
        local rX, rY = root.AbsolutePosition.X, root.AbsolutePosition.Y
        local rW, rH = root.AbsoluteSize.X, root.AbsoluteSize.Y
        if centerX >= rX and centerX <= (rX + rW) and centerY >= rY and centerY <= (rY + rH) then
            isOverlappingMenu = true
        end
    end
    
    if isOverlappingMenu then
        root.Visible = false
        task.wait(0.02)
    end
    
    pcall(function()
        VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.04)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end)
    
    if isOverlappingMenu then
        task.wait(0.02)
        root.Visible = true
    end
    return true
end

local function triggerAllSignals(gui)
    if not gui or not isGuiObjectTrulyVisible(gui) then return false end
    local success = false
    
    -- 1. Execute direct signals via firesignal / getconnections / Activate
    if typeof(firesignal) == "function" then
        local current = gui
        for depth = 1, 4 do
            if not current or current:IsA("ScreenGui") then break end
            pcall(function()
                if current:IsA("GuiButton") then
                    firesignal(current.MouseButton1Click)
                    firesignal(current.MouseButton1Down)
                    firesignal(current.MouseButton1Up)
                    firesignal(current.Activated)
                end
                firesignal(current.InputBegan, {UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin})
                firesignal(current.InputEnded, {UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.End})
                success = true
            end)
            current = current.Parent
        end
    end
    
    if typeof(getconnections) == "function" then
        local current = gui
        for depth = 1, 4 do
            if not current or current:IsA("ScreenGui") then break end
            pcall(function()
                for _, conn in pairs(getconnections(current.InputBegan)) do
                    conn:Fire({UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin})
                    success = true
                end
                if current:IsA("GuiButton") then
                    for _, conn in pairs(getconnections(current.MouseButton1Click)) do
                        conn:Fire()
                        success = true
                    end
                    for _, conn in pairs(getconnections(current.Activated)) do
                        conn:Fire()
                        success = true
                    end
                end
            end)
            current = current.Parent
        end
    end
    
    if gui:IsA("GuiButton") and typeof(gui.Activate) == "function" then
        pcall(function()
            gui:Activate()
            success = true
        end)
    end
    
    -- 2. Hardware click simulation
    sendHardwareClick(gui)
    
    return success
end

-- Precise Target Element Finder (Strictly checks entire parent tree visibility)
local function findTargetButton(targetKeyword)
    local pg = getPlayerGui()
    if not pg then return nil end
    local lowerKw = string.lower(targetKeyword)
    
    for _, desc in ipairs(pg:GetDescendants()) do
        -- CRITICAL: Skip our own custom GUI menu!
        if not (screenGui and desc:IsDescendantOf(screenGui)) then
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and isGuiObjectTrulyVisible(desc) then
            local txt = string.lower(desc.Text or "")
            txt = string.gsub(txt, "^%s*(.-)%s*$", "%1")
            
            local isMatch = false
            if lowerKw == "play" then
                if txt == "play" then isMatch = true end
            elseif lowerKw == "survival" then
                if (txt == "survival" or string.find(txt, "classic tower defense", 1, true)) and not string.find(txt, "pvp", 1, true) and not string.find(txt, "hardcore", 1, true) then
                    isMatch = true
                end
            elseif lowerKw == "easy" then
                if txt == "easy" or string.find(txt, "for new users", 1, true) then isMatch = true end
            elseif lowerKw == "casual" then
                if txt == "casual" or string.find(txt, "for the casual user", 1, true) then isMatch = true end
            elseif lowerKw == "intermediate" then
                if txt == "intermediate" or string.find(txt, "a balanced experience", 1, true) then isMatch = true end
            elseif lowerKw == "molten" then
                if txt == "molten" or string.find(txt, "for a molten experience", 1, true) then isMatch = true end
            elseif lowerKw == "fallen" then
                if txt == "fallen" or string.find(txt, "for the experienced user", 1, true) then isMatch = true end
            elseif lowerKw == "solo" then
                if txt == "solo" then isMatch = true end
            elseif lowerKw == "duo" then
                if txt == "duo" then isMatch = true end
            elseif lowerKw == "trio" then
                if txt == "trio" then isMatch = true end
            elseif lowerKw == "quad" then
                if txt == "quad" then isMatch = true end
            elseif lowerKw == "cancel" then
                if txt == "cancel" or txt == "cancel queue" or txt == "leave queue" or string.find(txt, "cancel", 1, true) then
                    isMatch = true
                end
            end
            
            if isMatch then
                local current = desc
                for depth = 1, 4 do
                    if not current or current:IsA("ScreenGui") then break end
                    if current:IsA("GuiButton") or current:IsA("TextButton") or current:IsA("ImageButton") then
                        if isGuiObjectTrulyVisible(current) then
                            return current
                        end
                    end
                    current = current.Parent
                end
                return desc
            end
        end
    end
    end
    return nil
end

-- Intelligent Multi-State Auto Queue Logic
local isQueueRunning = false

local function executeAutoQueueStepByStep()
    if isQueueRunning or not autoQueueEnabled then return end
    isQueueRunning = true
    
    pcall(function()
        -- Validation Check 1: Difficulty or Squad Size not chosen
        if selectedDifficulty == "Not Chosen" and selectedSquadSize == "Not Chosen" then
            tStatus.Text = "Status: Difficulty & Squad Size Not Chosen"
            tStatus.TextColor3 = Color3.fromRGB(255, 120, 0)
            isQueueRunning = false
            return
        elseif selectedDifficulty == "Not Chosen" then
            tStatus.Text = "Status: Difficulty Not Chosen"
            tStatus.TextColor3 = Color3.fromRGB(255, 120, 0)
            isQueueRunning = false
            return
        elseif selectedSquadSize == "Not Chosen" then
            tStatus.Text = "Status: Squad Size Not Chosen"
            tStatus.TextColor3 = Color3.fromRGB(255, 120, 0)
            isQueueRunning = false
            return
        end
        
        -- Queue Check 2: Stop clicking if player is already queued or cancel queue button is visible
        local cancelBtn = findTargetButton("cancel")
        if cancelBtn or isPlayerQueuedState then
            tStatus.Text = "Status: Successfully Queued!"
            tStatus.TextColor3 = Color3.fromRGB(14, 255, 0)
            isQueueRunning = false
            return
        end
        
        -- Priority 1: Click lobby PLAY button (opens Gamemode menu)
        local playObj = findTargetButton("play")
        if playObj then
            tStatus.Text = "Status: Opening Play Menu..."
            tStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
            triggerAllSignals(playObj)
            task.wait(1.2)
            isQueueRunning = false
            return
        end
        
        -- Priority 2: Click Survival card (opens Difficulty menu)
        local survivalObj = findTargetButton("survival")
        if survivalObj then
            tStatus.Text = "Status: Selecting Survival..."
            tStatus.TextColor3 = Color3.fromRGB(0, 229, 255)
            triggerAllSignals(survivalObj)
            task.wait(1.2)
            isQueueRunning = false
            return
        end
        
        -- Priority 3: Click selected Difficulty (opens Squad Size menu)
        local diffObj = findTargetButton(selectedDifficulty)
        if diffObj then
            tStatus.Text = string.format("Status: Selecting %s...", selectedDifficulty)
            tStatus.TextColor3 = Color3.fromRGB(0, 229, 255)
            triggerAllSignals(diffObj)
            task.wait(1.2)
            isQueueRunning = false
            return
        end
        
        -- Priority 4: Click selected Squad Size (queues player)
        local squadObj = findTargetButton(selectedSquadSize)
        if squadObj then
            tStatus.Text = string.format("Status: Selecting %s...", selectedSquadSize)
            tStatus.TextColor3 = Color3.fromRGB(0, 229, 255)
            triggerAllSignals(squadObj)
            task.wait(1.2)
            
            isPlayerQueuedState = true
            tStatus.Text = "Status: Successfully Queued!"
            tStatus.TextColor3 = Color3.fromRGB(14, 255, 0)
            isQueueRunning = false
            return
        end
        
        tStatus.Text = "Status: Standing By"
        tStatus.TextColor3 = Color3.fromRGB(160, 170, 184)
    end)
    
    isQueueRunning = false
end

-- Auto Queue Main Polling Loop (Runs every 0.8 seconds)
task.spawn(function()
    while true do
        if autoQueueEnabled then
            executeAutoQueueStepByStep()
            task.wait(0.8)
        else
            task.wait(0.5)
        end
    end
end)

-- Toggle Switch Interaction
switchBtn.MouseButton1Click:Connect(function()
    autoQueueEnabled = not autoQueueEnabled
    isQueueRunning = false -- Force reset state lock on toggle
    isPlayerQueuedState = false -- Reset queue state on toggle
    
    local targetPos = autoQueueEnabled and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3)
    local targetColor = autoQueueEnabled and Color3.fromRGB(14, 255, 0) or Color3.fromRGB(140, 150, 165)
    local targetBg = autoQueueEnabled and Color3.fromRGB(22, 35, 25) or Color3.fromRGB(11, 15, 24)
    
    TweenService:Create(swKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = targetPos,
        BackgroundColor3 = targetColor
    }):Play()
    
    TweenService:Create(switchBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetBg
    }):Play()
    
    if autoQueueEnabled then
        if selectedDifficulty == "Not Chosen" and selectedSquadSize == "Not Chosen" then
            tStatus.Text = "Status: Difficulty & Squad Size Not Chosen"
            tStatus.TextColor3 = Color3.fromRGB(255, 120, 0)
        elseif selectedDifficulty == "Not Chosen" then
            tStatus.Text = "Status: Difficulty Not Chosen"
            tStatus.TextColor3 = Color3.fromRGB(255, 120, 0)
        elseif selectedSquadSize == "Not Chosen" then
            tStatus.Text = "Status: Squad Size Not Chosen"
            tStatus.TextColor3 = Color3.fromRGB(255, 120, 0)
        else
            tStatus.Text = "Status: Initializing Queue..."
            tStatus.TextColor3 = Color3.fromRGB(0, 229, 255)
            task.spawn(executeAutoQueueStepByStep)
        end
    else
        tStatus.Text = "Status: Disabled"
        tStatus.TextColor3 = Color3.fromRGB(160, 170, 184)
    end
end)

end -- Click Engine scope

do -- Page 2: Menu Settings scope
-- ==========================================================
-- PAGE 2: MENU SETTINGS TAB
-- ==========================================================

local menuSettingsPage = Instance.new("Frame")
menuSettingsPage.Name = "Page_MenuSettings"
menuSettingsPage.AnchorPoint = Vector2.new(1, 0)
menuSettingsPage.Position = UDim2.new(1, 0, 0, 0)
menuSettingsPage.Size = UDim2.new(1, -204, 1, 0)
menuSettingsPage.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
menuSettingsPage.BackgroundTransparency = 0.25
menuSettingsPage.BorderSizePixel = 0
menuSettingsPage.Visible = false
menuSettingsPage.Parent = contentArea

local msCorner = Instance.new("UICorner")
msCorner.CornerRadius = UDim.new(0, 14)
msCorner.Parent = menuSettingsPage

local msStroke = Instance.new("UIStroke")
msStroke.Color = Color3.fromRGB(255, 255, 255)
msStroke.Thickness = 1.4
msStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
msStroke.Parent = menuSettingsPage
attachRotatingOutline(msStroke, 20, 270)

local panelTitle = Instance.new("TextLabel")
panelTitle.Name = "PanelTitle"
panelTitle.BackgroundTransparency = 1
panelTitle.Position = UDim2.fromOffset(18, 14)
panelTitle.Size = UDim2.new(1, -36, 0, 24)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.Text = "Menu Settings"
panelTitle.TextSize = 20
panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Parent = menuSettingsPage

local panelDescription = Instance.new("TextLabel")
panelDescription.Name = "PanelDesc"
panelDescription.BackgroundTransparency = 1
panelDescription.Position = UDim2.fromOffset(18, 38)
panelDescription.Size = UDim2.new(1, -36, 0, 16)
panelDescription.Font = Enum.Font.GothamMedium
panelDescription.Text = "Customize interface visuals, themes & neon outlines."
panelDescription.TextSize = 11
panelDescription.TextColor3 = Color3.fromRGB(140, 150, 165)
panelDescription.TextXAlignment = Enum.TextXAlignment.Left
panelDescription.Parent = menuSettingsPage

local featureArea = Instance.new("ScrollingFrame")
featureArea.Name = "FeatureArea"
featureArea.BackgroundTransparency = 1
featureArea.Position = UDim2.fromOffset(18, 64)
featureArea.Size = UDim2.new(1, -36, 1, -74)
featureArea.CanvasSize = UDim2.new(0, 0, 0, 0)
featureArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
featureArea.ScrollBarThickness = 4
featureArea.ScrollBarImageColor3 = Color3.fromRGB(27, 36, 51)
featureArea.ScrollBarImageTransparency = 0.35
featureArea.ScrollingDirection = Enum.ScrollingDirection.Y
featureArea.BorderSizePixel = 0
featureArea.ClipsDescendants = false
featureArea.ScrollingEnabled = true
featureArea.Parent = menuSettingsPage

local featureLayout = Instance.new("UIListLayout")
featureLayout.Padding = UDim.new(0, 14)
featureLayout.SortOrder = Enum.SortOrder.LayoutOrder
featureLayout.Parent = featureArea

local featurePadding = Instance.new("UIPadding")
featurePadding.PaddingLeft = UDim.new(0, 2)
featurePadding.PaddingRight = UDim.new(0, 6)
featurePadding.PaddingTop = UDim.new(0, 4)
featurePadding.PaddingBottom = UDim.new(0, 14)
featurePadding.Parent = featureArea

tabPagesList["Menu Settings"] = menuSettingsPage

-- DROPDOWN CONTROL: "Menu Outline Color"
local dropdownCard = Instance.new("Frame")
dropdownCard.Name = "DropdownCard_MenuOutlineColor"
dropdownCard.Size = UDim2.new(1, 0, 0, 72)
dropdownCard.BackgroundColor3 = Color3.fromRGB(16, 23, 34)
dropdownCard.BorderSizePixel = 0
dropdownCard.ZIndex = 20
dropdownCard.Parent = featureArea

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = dropdownCard

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(255, 255, 255)
cardStroke.Thickness = 1.4
cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
cardStroke.Parent = dropdownCard
attachRotatingOutline(cardStroke, 22, 45)

local labelTitle = Instance.new("TextLabel")
labelTitle.Position = UDim2.fromOffset(16, 12)
labelTitle.Size = UDim2.new(0.5, 0, 0, 20)
labelTitle.BackgroundTransparency = 1
labelTitle.Font = Enum.Font.GothamBold
labelTitle.Text = "Menu Outline Color"
labelTitle.TextSize = 14
labelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
labelTitle.TextXAlignment = Enum.TextXAlignment.Left
labelTitle.ZIndex = 21
labelTitle.Parent = dropdownCard

local labelSub = Instance.new("TextLabel")
labelSub.Position = UDim2.fromOffset(16, 34)
labelSub.Size = UDim2.new(0.5, 0, 0, 24)
labelSub.BackgroundTransparency = 1
labelSub.Font = Enum.Font.GothamMedium
labelSub.Text = "Select theme color sequence for UI neon borders."
labelSub.TextSize = 11
labelSub.TextColor3 = Color3.fromRGB(140, 150, 165)
labelSub.TextXAlignment = Enum.TextXAlignment.Left
labelSub.TextWrapped = true
labelSub.ZIndex = 21
labelSub.Parent = dropdownCard

local dropBtn = Instance.new("TextButton")
dropBtn.Name = "DropdownTrigger"
dropBtn.AnchorPoint = Vector2.new(1, 0.5)
dropBtn.Position = UDim2.new(1, -16, 0.5, 0)
dropBtn.Size = UDim2.fromOffset(200, 38)
dropBtn.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
dropBtn.BorderSizePixel = 0
dropBtn.AutoButtonColor = false
dropBtn.Text = ""
dropBtn.ZIndex = 22
dropBtn.Parent = dropdownCard

local dropBtnCorner = Instance.new("UICorner")
dropBtnCorner.CornerRadius = UDim.new(0, 8)
dropBtnCorner.Parent = dropBtn

local dropBtnStroke = Instance.new("UIStroke")
dropBtnStroke.Color = Color3.fromRGB(255, 255, 255)
dropBtnStroke.Thickness = 1.4
dropBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
dropBtnStroke.Parent = dropBtn
attachRotatingOutline(dropBtnStroke, 24, 135)

local colorPreviewPill = Instance.new("Frame")
colorPreviewPill.Name = "ColorPreviewPill"
colorPreviewPill.Size = UDim2.fromOffset(24, 16)
colorPreviewPill.Position = UDim2.fromOffset(10, 11)
colorPreviewPill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
colorPreviewPill.BorderSizePixel = 0
colorPreviewPill.ZIndex = 23
colorPreviewPill.Parent = dropBtn

local pillCorner = Instance.new("UICorner")
pillCorner.CornerRadius = UDim.new(1, 0)
pillCorner.Parent = colorPreviewPill

local pillGrad = Instance.new("UIGradient")
pillGrad.Color = getThemeColorSequence(uiColorTheme)
pillGrad.Parent = colorPreviewPill

local selectedText = Instance.new("TextLabel")
selectedText.Name = "SelectedText"
selectedText.Position = UDim2.fromOffset(42, 0)
selectedText.Size = UDim2.new(1, -68, 1, 0)
selectedText.BackgroundTransparency = 1
selectedText.Font = Enum.Font.GothamBold
selectedText.Text = uiColorTheme
selectedText.TextSize = 12
selectedText.TextColor3 = Color3.fromRGB(245, 249, 255)
selectedText.TextXAlignment = Enum.TextXAlignment.Left
selectedText.ZIndex = 23
selectedText.Parent = dropBtn

local chevron = Instance.new("TextLabel")
chevron.Name = "Chevron"
chevron.AnchorPoint = Vector2.new(1, 0.5)
chevron.Position = UDim2.new(1, -10, 0.5, 0)
chevron.Size = UDim2.fromOffset(16, 16)
chevron.BackgroundTransparency = 1
chevron.Font = Enum.Font.GothamBold
chevron.Text = "v"
chevron.TextSize = 10
chevron.TextColor3 = Color3.fromRGB(140, 150, 165)
chevron.ZIndex = 23
chevron.Parent = dropBtn

local listContainer = Instance.new("Frame")
listContainer.Name = "OptionsList"
listContainer.AnchorPoint = Vector2.new(1, 0)
listContainer.Position = UDim2.new(1, -16, 1, 6)
listContainer.Size = UDim2.fromOffset(200, 0)
listContainer.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
listContainer.BorderSizePixel = 0
listContainer.ClipsDescendants = true
listContainer.Visible = false
listContainer.ZIndex = 100
listContainer.Parent = dropdownCard

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = listContainer

local listStroke = Instance.new("UIStroke")
listStroke.Color = Color3.fromRGB(255, 255, 255)
listStroke.Thickness = 1.4
listStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
listStroke.Parent = listContainer
attachRotatingOutline(listStroke, 24, 0)

local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.fromScale(1, 1)
listScroll.BackgroundTransparency = 1
listScroll.BorderSizePixel = 0
listScroll.ScrollBarThickness = 3
listScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
listScroll.ScrollingDirection = Enum.ScrollingDirection.Y
listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
listScroll.ZIndex = 101
listScroll.Parent = listContainer

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = listScroll

local listPadding = Instance.new("UIPadding")
listPadding.PaddingLeft = UDim.new(0, 4)
listPadding.PaddingRight = UDim.new(0, 6)
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingBottom = UDim.new(0, 4)
listPadding.Parent = listScroll

local optionButtons = {}

for _, themeName in ipairs(uiThemeOptions) do
    local itemBtn = Instance.new("TextButton")
    itemBtn.Name = "Option_" .. themeName
    itemBtn.Size = UDim2.new(1, 0, 0, 32)
    itemBtn.BackgroundColor3 = themeName == uiColorTheme and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
    itemBtn.BorderSizePixel = 0
    itemBtn.AutoButtonColor = false
    itemBtn.Text = ""
    itemBtn.ZIndex = 102
    itemBtn.Parent = listScroll
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = itemBtn
    
    local itemSwatch = Instance.new("Frame")
    itemSwatch.Size = UDim2.fromOffset(20, 12)
    itemSwatch.Position = UDim2.fromOffset(8, 10)
    itemSwatch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    itemSwatch.BorderSizePixel = 0
    itemSwatch.ZIndex = 103
    itemSwatch.Parent = itemBtn
    
    local isC = Instance.new("UICorner")
    isC.CornerRadius = UDim.new(1, 0)
    isC.Parent = itemSwatch
    
    local isGrad = Instance.new("UIGradient")
    isGrad.Color = getThemeColorSequence(themeName)
    isGrad.Parent = itemSwatch
    
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Position = UDim2.fromOffset(36, 0)
    itemLabel.Size = UDim2.new(1, -42, 1, 0)
    itemLabel.BackgroundTransparency = 1
    itemLabel.Font = Enum.Font.GothamMedium
    itemLabel.Text = themeName
    itemLabel.TextSize = 11
    itemLabel.TextColor3 = themeName == uiColorTheme and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(174, 204, 236)
    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemLabel.ZIndex = 103
    itemLabel.Parent = itemBtn
    
    itemBtn.MouseEnter:Connect(function()
        if themeName ~= uiColorTheme then
            TweenService:Create(itemBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(22, 31, 46)
            }):Play()
            TweenService:Create(itemLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    itemBtn.MouseLeave:Connect(function()
        if themeName ~= uiColorTheme then
            TweenService:Create(itemBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(14, 19, 29)
            }):Play()
            TweenService:Create(itemLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(174, 204, 236)
            }):Play()
        end
    end)
    
    table.insert(optionButtons, { button = itemBtn, label = itemLabel, name = themeName })
end

local isOpen = false

local function setDropdownOpen(open)
    isOpen = open
    listContainer.Visible = true
    
    local targetHeight = isOpen and 180 or 0
    local targetRotation = isOpen and 180 or 0
    
    TweenService:Create(listContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(200, targetHeight)
    }):Play()
    
    TweenService:Create(chevron, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = targetRotation
    }):Play()
    
    if not isOpen then
        task.delay(0.25, function()
            if not isOpen then
                listContainer.Visible = false
            end
        end)
    end
end

dropBtn.MouseButton1Click:Connect(function()
    setDropdownOpen(not isOpen)
end)

for _, item in ipairs(optionButtons) do
    item.button.MouseButton1Click:Connect(function()
        uiColorTheme = item.name
        selectedText.Text = item.name
        pillGrad.Color = getThemeColorSequence(item.name)
        
        for _, opt in ipairs(optionButtons) do
            local isActive = opt.name == uiColorTheme
            opt.button.BackgroundColor3 = isActive and Color3.fromRGB(22, 31, 46) or Color3.fromRGB(14, 19, 29)
            opt.label.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(174, 204, 236)
        end
        
        setDropdownOpen(false)
    end)
end

-- Initialize default tab view
switchTab("Auto Matchmaking")

-- Smooth Window Dragging Mechanics (Top Header Drag)
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    root.Position = UDim2.new(startPos.Width.Scale, startPos.Width.Offset + delta.X, startPos.Height.Scale, startPos.Height.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = root.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Register Singleton State Cleanup Handle
EXEC_ENV[MENU_STATE_KEY] = {
    gui = screenGui,
    cleanup = function()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end
}

end -- Page 2 scope

-- ==========================================
-- PREMIUM LOADER SCREEN & INTRO TRANSITION
-- ==========================================
do
    local menuRoot = root
    local origSize = UDim2.fromOffset(720, 470)
    
    menuRoot.Visible = false
    menuRoot.Size = UDim2.fromOffset(0, 0)
    
    -- 1. Get real Game Name & User Avatar Details
    local gameName = "TDS Test"
    local avatarUrl = nil
    
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name
        end
    end)
    if gameName == "Unknown Game" or gameName == "Game" or gameName == "Ugc" then
        pcall(function()
            gameName = game.Name
        end)
    end
    
    if LocalPlayer then
        pcall(function()
            avatarUrl = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
    end
    
    -- Create ScreenGui inside parentContainer
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "TDSTestLoaderGui"
    loaderGui.IgnoreGuiInset = true
    loaderGui.DisplayOrder = 2147483647
    loaderGui.Parent = parentContainer
    
    -- Screen Wrapper
    local screenWrapper = Instance.new("Frame")
    screenWrapper.Size = UDim2.fromScale(1, 1)
    screenWrapper.BackgroundTransparency = 1
    screenWrapper.Parent = loaderGui
    
    -- Background Shutter Blind Panels (Interlaced 6 vertical panels)
    local blindPanels = {}
    for i = 1, 6 do
        local blind = Instance.new("Frame")
        blind.Size = UDim2.new(1/6 + 0.002, 0, 1, 0)
        blind.Position = UDim2.new((i-1)/6, 0, 0, 0)
        blind.BackgroundColor3 = Color3.fromRGB(7, 9, 13)
        blind.BorderSizePixel = 0
        blind.ZIndex = 5
        blind.Parent = screenWrapper
        table.insert(blindPanels, blind)
    end
    
    -- Grid Pattern Overlay
    local gridOverlay = Instance.new("Frame")
    gridOverlay.Size = UDim2.fromScale(1, 1)
    gridOverlay.BackgroundTransparency = 0.95
    gridOverlay.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    gridOverlay.ZIndex = 6
    gridOverlay.Parent = screenWrapper
    
    -- Core Visualizer / Wormhole Tunnel Container
    local tunnelFrame = Instance.new("Frame")
    tunnelFrame.Size = UDim2.fromScale(1, 1)
    tunnelFrame.BackgroundTransparency = 1
    tunnelFrame.ZIndex = 7
    tunnelFrame.Parent = screenWrapper
    
    -- 4 Straight Inward Zooming Concentric Vector Rings
    local tunnelRings = {}
    for i = 1, 4 do
        local ring = Instance.new("Frame")
        ring.Size = UDim2.fromScale(0.3 * i, 0.3 * i)
        ring.Position = UDim2.fromScale(0.5, 0.5)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.BackgroundTransparency = 1
        ring.ZIndex = 7
        ring.Parent = tunnelFrame
        
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0.2, 0)
        rc.Parent = ring
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 255, 255)
        stroke.Thickness = 1.5
        stroke.Parent = ring
        attachRotatingOutline(stroke, 30, i * 45)
        
        table.insert(tunnelRings, { gui = ring, stroke = stroke, scale = 0.3 * i, speed = 0.6, idx = i })
    end
    
    -- Inward Starfield Glide System (90 stars)
    local starfield = {}
    local function createStar(parent, x, y, size)
        local star = Instance.new("Frame")
        star.Size = UDim2.fromOffset(size or 2, size or 2)
        star.Position = UDim2.fromScale(x, y)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BorderSizePixel = 0
        star.ZIndex = 8
        star.Parent = parent
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = star
        return star
    end
    
    for i = 1, 90 do
        local angle = math.random() * math.pi * 2
        local radius = math.random() * 0.9
        local size = math.random(1, 3)
        local starGui = createStar(tunnelFrame, 0.5 + math.cos(angle) * radius, 0.5 + math.sin(angle) * radius, size)
        table.insert(starfield, { gui = starGui, angle = angle, radius = radius, speed = 0.4 + math.random() * 0.5, baseOpacity = math.random(60, 100)/100 })
    end
    
    -- Pulsing Vector Cyber Core Ring in Center
    local coreFrame = Instance.new("Frame")
    coreFrame.Size = UDim2.fromOffset(130, 130)
    coreFrame.Position = UDim2.fromScale(0.5, 0.5)
    coreFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    coreFrame.BackgroundTransparency = 1
    coreFrame.ZIndex = 9
    coreFrame.Parent = screenWrapper
    
    local coreGlow = Instance.new("Frame")
    coreGlow.Size = UDim2.fromScale(1.4, 1.4)
    coreGlow.Position = UDim2.fromScale(0.5, 0.5)
    coreGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    coreGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    coreGlow.BackgroundTransparency = 0.88
    coreGlow.ZIndex = 8
    coreGlow.Parent = coreFrame
    local cgC = Instance.new("UICorner")
    cgC.CornerRadius = UDim.new(1, 0)
    cgC.Parent = coreGlow
    
    -- Radial Dynamic Audio Equalizer Bars
    local radialBars = {}
    for i = 1, 32 do
        local angle = (i / 32) * math.pi * 2
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(4, 18)
        bar.AnchorPoint = Vector2.new(0.5, 1)
        
        local radius = 80
        local cx = 0.5 + (math.cos(angle) * radius / 130)
        local cy = 0.5 + (math.sin(angle) * radius / 130)
        
        bar.Position = UDim2.fromScale(cx, cy)
        bar.Rotation = math.deg(angle) + 90
        bar.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        bar.BorderSizePixel = 0
        bar.ZIndex = 10
        bar.Parent = coreFrame
        
        local bC = Instance.new("UICorner")
        bC.CornerRadius = UDim.new(1, 0)
        bC.Parent = bar
        
        local bGrad = Instance.new("UIGradient")
        bGrad.Color = getThemeColorSequence(uiColorTheme)
        bGrad.Parent = bar
        
        table.insert(radialBars, { bar = bar, angle = angle })
    end
    
    -- Scanning laser line
    local scanLine = Instance.new("Frame")
    scanLine.Size = UDim2.new(1, 0, 0, 2)
    scanLine.Position = UDim2.fromScale(0, 0.5)
    scanLine.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    scanLine.BackgroundTransparency = 0.3
    scanLine.BorderSizePixel = 0
    scanLine.ZIndex = 9
    scanLine.Parent = screenWrapper
    
    local innerCore = Instance.new("Frame")
    innerCore.Size = UDim2.fromOffset(75, 75)
    innerCore.Position = UDim2.fromScale(0.5, 0.5)
    innerCore.AnchorPoint = Vector2.new(0.5, 0.5)
    innerCore.BackgroundColor3 = Color3.fromRGB(7, 9, 13)
    innerCore.ZIndex = 11
    innerCore.Parent = coreFrame
    local icC = Instance.new("UICorner")
    icC.CornerRadius = UDim.new(1, 0)
    icC.Parent = innerCore
    local icStroke = Instance.new("UIStroke")
    icStroke.Color = Color3.fromRGB(0, 255, 255)
    icStroke.Thickness = 1.5
    icStroke.Parent = innerCore
    attachRotatingOutline(icStroke, -30, 180)
    
    local loaderPercent = Instance.new("TextLabel")
    loaderPercent.BackgroundTransparency = 1
    loaderPercent.Size = UDim2.fromScale(1, 1)
    loaderPercent.Font = Enum.Font.Code
    loaderPercent.Text = "0.00%"
    loaderPercent.TextSize = 20
    loaderPercent.TextColor3 = Color3.fromRGB(0, 255, 255)
    loaderPercent.TextXAlignment = Enum.TextXAlignment.Center
    loaderPercent.TextYAlignment = Enum.TextYAlignment.Center
    loaderPercent.ZIndex = 12
    loaderPercent.Parent = innerCore
    
    -- Integrated Authorization Dashboard Card
    local authCard = Instance.new("Frame")
    authCard.Size = UDim2.fromOffset(360, 85)
    authCard.Position = UDim2.new(0.5, 0, 0, -120)
    authCard.AnchorPoint = Vector2.new(0.5, 0)
    authCard.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    authCard.BackgroundTransparency = 0.25
    authCard.ZIndex = 12
    authCard.Parent = screenWrapper
    
    local acCorner = Instance.new("UICorner")
    acCorner.CornerRadius = UDim.new(0, 16)
    acCorner.Parent = authCard
    
    local acStroke = Instance.new("UIStroke")
    acStroke.Color = Color3.fromRGB(0, 255, 255)
    acStroke.Thickness = 1.5
    acStroke.Parent = authCard
    attachRotatingOutline(acStroke, 25, 0)
    
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.fromOffset(55, 55)
    avatarFrame.Position = UDim2.fromOffset(15, 15)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    avatarFrame.ZIndex = 13
    avatarFrame.Parent = authCard
    local avC = Instance.new("UICorner")
    avC.CornerRadius = UDim.new(0.3, 0)
    avC.Parent = avatarFrame
    local avS = Instance.new("UIStroke")
    avS.Color = Color3.fromRGB(0, 255, 255)
    avS.Thickness = 1.2
    avS.Parent = avatarFrame
    
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.fromScale(0.9, 0.9)
    avatarImg.Position = UDim2.fromScale(0.05, 0.05)
    avatarImg.BackgroundTransparency = 1
    avatarImg.ZIndex = 14
    avatarImg.Parent = avatarFrame
    local avImgCorner = Instance.new("UICorner")
    avImgCorner.CornerRadius = UDim.new(0.3, 0)
    avImgCorner.Parent = avatarImg
    if avatarUrl then
        avatarImg.Image = avatarUrl
    end
    
    local userNameStr = LocalPlayer and LocalPlayer.Name or "User"
    local authTitle = Instance.new("TextLabel")
    authTitle.Position = UDim2.fromOffset(85, 12)
    authTitle.Size = UDim2.new(1, -100, 0, 18)
    authTitle.Font = Enum.Font.Code
    authTitle.Text = "ACCESS AUTHORIZED // CLIENT SECURE"
    authTitle.TextSize = 11
    authTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
    authTitle.TextXAlignment = Enum.TextXAlignment.Left
    authTitle.BackgroundTransparency = 1
    authTitle.ZIndex = 13
    authTitle.Parent = authCard
    
    local authBody = Instance.new("TextLabel")
    authBody.Position = UDim2.fromOffset(85, 30)
    authBody.Size = UDim2.new(1, -100, 0, 42)
    authBody.Font = Enum.Font.Code
    authBody.Text = string.format("USER: %s\nGAME: %s\nLOAD: INITIALIZED", userNameStr, string.upper(gameName))
    authBody.TextSize = 10
    authBody.TextColor3 = Color3.fromRGB(240, 245, 255)
    authBody.TextXAlignment = Enum.TextXAlignment.Left
    authBody.TextYAlignment = Enum.TextYAlignment.Top
    authBody.BackgroundTransparency = 1
    authBody.ZIndex = 13
    authBody.Parent = authCard
    
    -- Status message center bottom
    local loaderStatus = Instance.new("TextLabel")
    loaderStatus.BackgroundTransparency = 1
    loaderStatus.AnchorPoint = Vector2.new(0.5, 1)
    loaderStatus.Position = UDim2.new(0.5, 0, 1, -45)
    loaderStatus.Size = UDim2.fromOffset(600, 20)
    loaderStatus.Font = Enum.Font.Code
    loaderStatus.Text = "> INIT DIAL LINK..."
    loaderStatus.TextSize = 11
    loaderStatus.TextColor3 = Color3.fromRGB(255, 60, 60)
    loaderStatus.TextXAlignment = Enum.TextXAlignment.Center
    loaderStatus.ZIndex = 10
    loaderStatus.Parent = screenWrapper
    
    -- Title Header
    local loaderTitle = Instance.new("TextLabel")
    loaderTitle.BackgroundTransparency = 1
    loaderTitle.AnchorPoint = Vector2.new(0.5, 0)
    loaderTitle.Position = UDim2.new(0.5, 0, 0, 36)
    loaderTitle.Size = UDim2.fromOffset(500, 45)
    loaderTitle.Font = Enum.Font.GothamBold
    loaderTitle.Text = "TDS TEST"
    loaderTitle.TextSize = 28
    loaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    loaderTitle.TextXAlignment = Enum.TextXAlignment.Center
    loaderTitle.ZIndex = 10
    loaderTitle.Parent = screenWrapper
    
    -- White Blinding Camera Flash Overlay
    local cameraFlash = Instance.new("Frame")
    cameraFlash.Size = UDim2.fromScale(1, 1)
    cameraFlash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cameraFlash.BackgroundTransparency = 1
    cameraFlash.BorderSizePixel = 0
    cameraFlash.ZIndex = 999999
    cameraFlash.Parent = screenWrapper
    
    -- ========= RUN TRANSITION =========
    task.spawn(function()
        local success, err = pcall(function()
        local function typeText(lbl, text, speed)
            local sc = {"#", "%", "X", "0", "1"}
            for i = 1, #text do
                local cur = string.sub(text, 1, i)
                if i < #text then
                    cur = cur .. sc[math.random(1, #sc)]
                end
                lbl.Text = "> " .. cur .. " _"
                task.wait(speed or 0.012)
            end
        end
        
        -- Slide down Auth HUD card
        TweenService:Create(authCard, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 100)
        }):Play()
        
        local lastTime = os.clock()
        
        local function runStage(targetPct, statusText, duration)
            task.spawn(function() typeText(loaderStatus, statusText, 0.007) end)
            local startTime = os.clock()
            local startPct = tonumber(string.match(loaderPercent.Text, "%d+%.?%d*")) or 0
            
            while os.clock() - startTime < duration do
                local el = os.clock() - startTime
                local prog = math.clamp(el / duration, 0, 1)
                local curPct = startPct + (targetPct * 100 - startPct) * prog
                loaderPercent.Text = string.format("%.2f%%", curPct)
                local t = curPct / 100
                
                -- Laser line sweep
                scanLine.Position = UDim2.new(0, 0, (math.sin(os.clock() * 5.2) + 1)/2, 0)
                
                -- Decelerate core rotation near 90%
                local rotationSpeed = 32
                local waveIntensity = 8
                local noiseIntensity = 12
                if t > 0.85 then
                    local scaleBack = (1 - t) / 0.15
                    rotationSpeed = 4 + (28 * scaleBack)
                    waveIntensity = 2 + (6 * scaleBack)
                    noiseIntensity = 3 + (9 * scaleBack)
                end
                
                -- Dynamic visualizer waves
                for _, data in ipairs(radialBars) do
                    local phase = (data.angle) * 2
                    local wave = math.sin(os.clock() * 15 + phase) * waveIntensity
                    local noiseVal = math.noise(data.angle, os.clock() * 8) * noiseIntensity
                    local length = math.clamp(14 + wave + noiseVal, 6, 44)
                    data.bar.Size = UDim2.fromOffset(4, length)
                end
                
                -- Inward Starfield Glide (90 stars)
                local dt = os.clock() - lastTime
                lastTime = os.clock()
                if dt > 0.1 then dt = 0.016 end
                
                for _, star in ipairs(starfield) do
                    star.radius = star.radius - star.speed * dt
                    if star.radius < 0.05 then
                        star.radius = 1.0 + math.random() * 0.15
                        star.angle = math.random() * math.pi * 2
                    end
                    
                    local x = 0.5 + math.cos(star.angle) * star.radius
                    local y = 0.5 + math.sin(star.angle) * star.radius
                    star.gui.Position = UDim2.fromScale(x, y)
                    
                    local opacity = 1
                    if star.radius < 0.15 then
                        opacity = (star.radius - 0.05) / 0.10
                    elseif star.radius > 0.9 then
                        opacity = (1.15 - star.radius) / 0.25
                    end
                    star.gui.BackgroundTransparency = 1 - (opacity * star.baseOpacity)
                end
                
                coreFrame.Rotation = (coreFrame.Rotation + (rotationSpeed * task.wait())) % 360
            end
            loaderPercent.Text = string.format("%.2f%%", targetPct * 100)
        end
        
        -- Run Stages (0.4 seconds each, total 1.6 seconds intro)
        runStage(0.25, "PERFORMING SYSTEM SECURITY AUDIT...", 0.4)
        runStage(0.60, "HOOKING CLIENT APIS & CONTEXTS...", 0.4)
        runStage(0.90, "SYNCHRONIZING DESKTOP WRAPPERS...", 0.4)
        runStage(1.00, "CONSOLE INTERFACE CONNECTED...", 0.4)
        task.wait(0.08)
        
        -- Hide percentage text
        loaderPercent.Visible = false
        
        -- Retract HUD elements
        TweenService:Create(authCard, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, -150)
        }):Play()
        TweenService:Create(loaderTitle, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, -100)
        }):Play()
        TweenService:Create(loaderStatus, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 1, 100)
        }):Play()
        TweenService:Create(scanLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
        
        -- Implode inner core
        TweenService:Create(innerCore, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        TweenService:Create(coreGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromScale(0, 0)
        }):Play()
        
        task.wait(0.2)
        
        -- Interlaced Blind Slide
        local slideTime = 0.45
        for index, blind in ipairs(blindPanels) do
            local targetX = (index % 2 == 0) and -1.2 or 1.2
            TweenService:Create(blind, TweenInfo.new(slideTime, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(targetX, 0, blind.Position.Y.Scale, 0)
            }):Play()
        end
        
        task.wait(slideTime - 0.1)
        
        -- Reveal Root Menu Window with smooth bounce scale
        menuRoot.Size = UDim2.fromOffset(0, 0)
        menuRoot.Visible = true
        local bounceTween = TweenService:Create(menuRoot, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = origSize
        })
        bounceTween:Play()
        
        task.wait(0.1)
        end) -- end pcall
        
        -- Fail-safe guarantee: reveal root menu & cleanup loader
        menuRoot.Visible = true
        menuRoot.Size = origSize
        pcall(function()
            if loaderGui and loaderGui.Parent then
                loaderGui:Destroy()
            end
        end)
    end)
end
