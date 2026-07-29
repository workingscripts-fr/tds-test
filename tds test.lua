-- ==========================================
-- TDS TEST - AAA COSMIC UNIVERSE UI
-- ==========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Dynamic fail-proof LocalPlayer & PlayerGui Resolution
local function getLocalPlayer()
    local lp = Players.LocalPlayer or Players:FindFirstChildOfClass("Player")
    if not lp then
        pcall(function()
            lp = Players:FindFirstChildOfClass("Player")
        end)
    end
    return lp
end

local LocalPlayer = getLocalPlayer()

local function getPlayerGui()
    local lp = getLocalPlayer()
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
        if pg then return pg end
    end
    return nil
end

local PlayerGui = getPlayerGui()

-- Fail-proof parent container resolution
local parentContainer = nil
pcall(function()
    if type(gethui) == "function" then parentContainer = gethui() end
end)
if not parentContainer then
    pcall(function() parentContainer = game:GetService("CoreGui") end)
end
if not parentContainer then parentContainer = getPlayerGui() end

-- Singleton cleanup to prevent duplicate GUI instances
local EXEC_ENV = (type(getgenv) == "function" and getgenv()) or _G
local MENU_STATE_KEY = "__TDSTestSingletonState"
do
    local prev = EXEC_ENV[MENU_STATE_KEY]
    if prev then
        if prev.cleanup then pcall(prev.cleanup) end
        if prev.gui and prev.gui.Parent then pcall(function() prev.gui:Destroy() end) end
        EXEC_ENV[MENU_STATE_KEY] = nil
    end
end

-- Shared State Table
local S = {}
S.uiColorTheme = "Rainbow"
S.uiThemeOptions = {
    "Green/Purple","Rainbow","Green/White","Orange/Yellow","Violet/Indigo",
    "Blue/Pink","Blue/Green","Blue/White","Red/Blue","America","Green/Cyan"
}
S.rotatingGradients = {}
S.autoQueueEnabled = false
S.isPlayerQueuedState = false
S.selectedDifficulty = "Not Chosen"
S.selectedSquadSize = "Not Chosen"
S.isQueueRunning = false

-- ============================================
-- THEME COLOR ENGINE (scoped)
-- ============================================
local getThemeColorAt, getThemeColorSequence, getShiftedThemeColorSequence, attachRotatingOutline

do
    function getThemeColorAt(theme, t)
        t = t % 1
        if theme == "Rainbow" then
            local base = {
                Color3.fromRGB(255,0,51), Color3.fromRGB(255,94,0), Color3.fromRGB(255,255,0),
                Color3.fromRGB(0,255,102), Color3.fromRGB(0,207,255), Color3.fromRGB(61,0,255),
                Color3.fromRGB(204,0,255), Color3.fromRGB(255,0,51)
            }
            local n = #base
            local idx = t * (n - 1) + 1
            local low = math.floor(idx)
            local high = math.ceil(idx)
            if low == high then return base[low] end
            return base[low]:Lerp(base[high], idx - low)
        end
        local pairs = {
            ["Green/Purple"] = {Color3.fromRGB(14,255,0), Color3.fromRGB(214,0,255)},
            ["Green/White"] = {Color3.fromRGB(14,255,0), Color3.fromRGB(245,249,255)},
            ["Orange/Yellow"] = {Color3.fromRGB(255,120,0), Color3.fromRGB(255,220,0)},
            ["Violet/Indigo"] = {Color3.fromRGB(140,0,255), Color3.fromRGB(40,0,255)},
            ["Blue/Pink"] = {Color3.fromRGB(0,180,255), Color3.fromRGB(255,100,200)},
            ["Blue/Green"] = {Color3.fromRGB(0,100,255), Color3.fromRGB(0,255,150)},
            ["Blue/White"] = {Color3.fromRGB(0,150,255), Color3.fromRGB(245,249,255)},
            ["Red/Blue"] = {Color3.fromRGB(255,40,40), Color3.fromRGB(40,40,255)},
            ["Green/Cyan"] = {Color3.fromRGB(0,255,100), Color3.fromRGB(0,200,255)}
        }
        if theme == "America" then
            if t < 0.33 then
                return Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(255,255,255), t / 0.33)
            elseif t < 0.66 then
                return Color3.fromRGB(255,255,255):Lerp(Color3.fromRGB(0,0,255), (t-0.33)/0.33)
            else
                return Color3.fromRGB(0,0,255):Lerp(Color3.fromRGB(255,0,0), (t-0.66)/0.34)
            end
        end
        local p = pairs[theme]
        if p then return p[1]:Lerp(p[2], (math.sin(t * math.pi * 2) + 1) / 2) end
        return Color3.fromRGB(0,255,255):Lerp(Color3.fromRGB(214,0,255), (math.sin(t * math.pi * 2) + 1) / 2)
    end

    function getThemeColorSequence(theme)
        local kp = {}
        for i = 0, 7 do
            local p = i / 7
            table.insert(kp, ColorSequenceKeypoint.new(p, getThemeColorAt(theme, p)))
        end
        return ColorSequence.new(kp)
    end

    function getShiftedThemeColorSequence(theme, shift)
        local kp = {}
        for i = 0, 7 do
            local p = i / 7
            table.insert(kp, ColorSequenceKeypoint.new(p, getThemeColorAt(theme, p - shift)))
        end
        return ColorSequence.new(kp)
    end

    function attachRotatingOutline(strokeOrGrad, speed, initRot)
        local grad
        if strokeOrGrad:IsA("UIStroke") then
            grad = Instance.new("UIGradient")
            grad.Color = getThemeColorSequence(S.uiColorTheme)
            grad.Rotation = initRot or 0
            grad.Parent = strokeOrGrad
        elseif strokeOrGrad:IsA("UIGradient") then
            grad = strokeOrGrad
        end
        if grad then
            table.insert(S.rotatingGradients, { gradient = grad, speed = speed or 20 })
        end
        return grad
    end
end

-- Gradient rotation loop
task.spawn(function()
    local lastT = os.clock()
    while true do
        local now = os.clock()
        local dt = now - lastT
        lastT = now
        for _, item in ipairs(S.rotatingGradients) do
            if item.gradient and item.gradient.Parent then
                item.gradient.Rotation = (item.gradient.Rotation + (item.speed * dt)) % 360
                item.gradient.Color = getShiftedThemeColorSequence(S.uiColorTheme, now * 0.35)
            end
        end
        task.wait(0.03)
    end
end)

-- ============================================
-- MAIN GUI SHELL
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TDSTestUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 2147483647
pcall(function() screenGui.OnTopOfCoreBlur = true end)
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

local function addStroke(parent, thickness, speed, rot)
    local st = Instance.new("UIStroke")
    st.Thickness = thickness or 1.4
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = parent
    attachRotatingOutline(st, speed or 22, rot or 0)
    return st
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

addCorner(root, 16)
addStroke(root, 2.0, 22, 0)
S.root = root

-- ============================================
-- COSMIC BACKGROUND (scoped)
-- ============================================
do
    local bg = Instance.new("Frame")
    bg.Name = "UniverseBackground"
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(7, 9, 13)
    bg.BackgroundTransparency = 0.05
    bg.BorderSizePixel = 0
    bg.ZIndex = -10
    bg.Parent = root
    addCorner(bg, 16)

    for i, data in ipairs({
        {s=1.4, p=-0.2, t=0.78, c1={15,5,40}, c2={5,25,65}, c3={30,5,50}, spd=5, z=-9},
        {s=1.3, p=-0.15, t=0.82, c1={40,5,70}, c2={5,40,50}, c3={10,5,30}, spd=-8, z=-8}
    }) do
        local neb = Instance.new("Frame")
        neb.Size = UDim2.fromScale(data.s, data.s)
        neb.Position = UDim2.fromScale(data.p, data.p)
        neb.BackgroundTransparency = data.t
        neb.BorderSizePixel = 0
        neb.ZIndex = data.z
        neb.Parent = bg
        addCorner(neb, 16)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(unpack(data.c1))),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(unpack(data.c2))),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(unpack(data.c3)))
        })
        g.Parent = neb
        table.insert(S.rotatingGradients, { gradient = g, speed = data.spd })
    end

    for i = 1, 20 do
        local star = Instance.new("Frame")
        star.Size = UDim2.fromOffset(math.random(10,20)/10, math.random(10,20)/10)
        star.Position = UDim2.fromScale(math.random(), math.random())
        star.BackgroundColor3 = Color3.fromRGB(255,255,255)
        star.BackgroundTransparency = 0.4 + math.random() * 0.4
        star.BorderSizePixel = 0
        star.ZIndex = -7
        star.Parent = bg
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
        task.spawn(function()
            while star and star.Parent do
                local tw = 1.5 + math.random() * 2.5
                TweenService:Create(star, TweenInfo.new(tw, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.15 + math.random() * 0.75
                }):Play()
                task.wait(tw)
            end
        end)
    end

    for i = 1, 12 do
        local p = Instance.new("Frame")
        p.Size = UDim2.fromOffset(2, 2)
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BackgroundColor3 = Color3.fromRGB(174,204,236)
        p.BackgroundTransparency = 0.6 + math.random() * 0.3
        p.BorderSizePixel = 0
        p.ZIndex = -6
        p.Parent = bg
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        task.spawn(function()
            local sx = (math.random() - 0.5) * 0.012
            local sy = (math.random() - 0.5) * 0.012
            while p and p.Parent do
                p.Position = UDim2.fromScale((p.Position.X.Scale + sx) % 1, (p.Position.Y.Scale + sy) % 1)
                task.wait(0.06)
            end
        end)
    end

    task.spawn(function()
        while bg and bg.Parent do
            task.wait(math.random(8, 16))
            if not bg or not bg.Parent then break end
            local ss = Instance.new("Frame")
            ss.Size = UDim2.fromOffset(50, 1)
            ss.Position = UDim2.fromScale(-0.1, math.random(10, 60) / 100)
            ss.Rotation = 12
            ss.BorderSizePixel = 0
            ss.ZIndex = -5
            ss.Parent = bg
            local sG = Instance.new("UIGradient")
            sG.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(7,9,13))
            })
            sG.Parent = ss
            local startY = ss.Position.Y.Scale
            local tw = TweenService:Create(ss, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.fromScale(1.2, startY + 0.3),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function() ss:Destroy() end)
        end
    end)
end

-- ============================================
-- HEADER BAR (scoped)
-- ============================================
local topBar = Instance.new("Frame")
topBar.Name = "Header"
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.new(1, -32, 0, 68)
topBar.Position = UDim2.fromOffset(16, 12)
topBar.Parent = root

do
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0.35, 0, 0, 26)
    title.Position = UDim2.fromOffset(0, 4)
    title.Font = Enum.Font.GothamBold
    title.Text = "TDS TEST"
    title.TextSize = 25
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    local tg = Instance.new("UIGradient")
    tg.Color = getThemeColorSequence(S.uiColorTheme)
    tg.Parent = title
    attachRotatingOutline(tg, 35, 0)

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(0.35, 0, 0, 16)
    sub.Position = UDim2.fromOffset(0, 32)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "Universal Cosmic Interface v1.0"
    sub.TextSize = 11
    sub.TextColor3 = Color3.fromRGB(140,150,165)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = topBar
end

local headerRight = Instance.new("Frame")
headerRight.AnchorPoint = Vector2.new(1, 0.5)
headerRight.Position = UDim2.new(1, 0, 0.5, 0)
headerRight.Size = UDim2.new(0.6, 0, 1, 0)
headerRight.BackgroundTransparency = 1
headerRight.Parent = topBar
Instance.new("UIListLayout", headerRight).FillDirection = Enum.FillDirection.Horizontal
headerRight:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Right
headerRight:FindFirstChildOfClass("UIListLayout").VerticalAlignment = Enum.VerticalAlignment.Center
headerRight:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, 14)

do
    local isMinimized = false

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.BackgroundColor3 = Color3.fromRGB(11,15,24)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = Color3.fromRGB(255,90,90)
    closeBtn.AutoButtonColor = false
    closeBtn.LayoutOrder = 10
    closeBtn.Parent = headerRight
    addCorner(closeBtn, 8)
    addStroke(closeBtn, 1.4, 26, math.random(0,359))
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(30, 30)
    minBtn.BackgroundColor3 = Color3.fromRGB(11,15,24)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Text = "_"
    minBtn.TextSize = 16
    minBtn.TextColor3 = Color3.fromRGB(245,249,255)
    minBtn.AutoButtonColor = false
    minBtn.LayoutOrder = 9
    minBtn.Parent = headerRight
    addCorner(minBtn, 8)
    addStroke(minBtn, 1.4, 26, math.random(0,359))
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        root.Visible = not isMinimized
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            isMinimized = not isMinimized
            root.Visible = not isMinimized
        end
    end)

    local sc = Instance.new("Frame")
    sc.Size = UDim2.fromOffset(190, 30)
    sc.BackgroundColor3 = Color3.fromRGB(11,15,24)
    sc.BorderSizePixel = 0
    sc.LayoutOrder = 8
    sc.Parent = headerRight
    addCorner(sc, 8)
    addStroke(sc, 1.4, 24, 90)
    local sl = Instance.new("UIListLayout")
    sl.FillDirection = Enum.FillDirection.Horizontal
    sl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sl.VerticalAlignment = Enum.VerticalAlignment.Center
    sl.Padding = UDim.new(0, 10)
    sl.Parent = sc

    local fpsL = Instance.new("TextLabel")
    fpsL.BackgroundTransparency = 1
    fpsL.Size = UDim2.new(0, 50, 1, 0)
    fpsL.Font = Enum.Font.GothamBold
    fpsL.Text = "60 FPS"
    fpsL.TextSize = 11
    fpsL.TextColor3 = Color3.fromRGB(255,255,255)
    fpsL.Parent = sc

    local pingL = Instance.new("TextLabel")
    pingL.BackgroundTransparency = 1
    pingL.Size = UDim2.new(0, 50, 1, 0)
    pingL.Font = Enum.Font.GothamBold
    pingL.Text = "0 MS"
    pingL.TextSize = 11
    pingL.TextColor3 = Color3.fromRGB(174,204,236)
    pingL.Parent = sc

    local clockL = Instance.new("TextLabel")
    clockL.BackgroundTransparency = 1
    clockL.Size = UDim2.new(0, 50, 1, 0)
    clockL.Font = Enum.Font.GothamBold
    clockL.Text = "00:00"
    clockL.TextSize = 11
    clockL.TextColor3 = Color3.fromRGB(140,150,165)
    clockL.Parent = sc

    task.spawn(function()
        local fc = 0
        local lt = os.clock()
        RunService.RenderStepped:Connect(function()
            fc = fc + 1
            local now = os.clock()
            if now - lt >= 1 then
                fpsL.Text = math.floor(fc / (now - lt)) .. " FPS"
                fc = 0
                lt = now
                pcall(function()
                    pingL.Text = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " MS"
                end)
                clockL.Text = os.date("%H:%M")
            end
        end)
    end)

    local pf = Instance.new("Frame")
    pf.Size = UDim2.fromOffset(30, 30)
    pf.BackgroundColor3 = Color3.fromRGB(11,15,24)
    pf.BorderSizePixel = 0
    pf.LayoutOrder = 7
    pf.Parent = headerRight
    addCorner(pf, 15)
    addStroke(pf, 1.4, 24, 180)
    local pfImg = Instance.new("ImageLabel")
    pfImg.Size = UDim2.fromScale(1, 1)
    pfImg.BackgroundTransparency = 1
    pfImg.Parent = pf
    Instance.new("UICorner", pfImg).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        local lp = getLocalPlayer()
        if lp then
            pcall(function()
                pfImg.Image = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
        end
    end)
end

-- ============================================
-- CONTENT AREA + SIDEBAR + TABS
-- ============================================
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.BackgroundTransparency = 1
contentArea.Position = UDim2.fromOffset(16, 84)
contentArea.Size = UDim2.new(1, -32, 1, -100)
contentArea.Parent = root

local tabButtonsList = {}
local tabPagesList = {}
local activeTabName = "Auto Matchmaking"

local function switchTab(tabName)
    activeTabName = tabName
    for name, data in pairs(tabButtonsList) do
        local isActive = (name == tabName)
        data.button.BackgroundColor3 = isActive and Color3.fromRGB(22,31,46) or Color3.fromRGB(14,19,29)
        data.stroke.Transparency = isActive and 0 or 0.7
    end
    for name, page in pairs(tabPagesList) do
        page.Visible = (name == tabName)
    end
end

do
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Color3.fromRGB(11,15,24)
    sidebar.Size = UDim2.new(0, 190, 1, 0)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = contentArea
    addCorner(sidebar, 14)
    addStroke(sidebar, 1.4, 20, 90)

    local sp = Instance.new("UIPadding")
    sp.PaddingLeft = UDim.new(0, 8)
    sp.PaddingRight = UDim.new(0, 8)
    sp.PaddingTop = UDim.new(0, 10)
    sp.PaddingBottom = UDim.new(0, 10)
    sp.Parent = sidebar
    Instance.new("UIListLayout", sidebar).Padding = UDim.new(0, 8)

    for _, name in ipairs({"Auto Matchmaking", "Menu Settings"}) do
        local btn = Instance.new("TextButton")
        btn.Name = "TabBtn_" .. name
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(14,19,29)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Parent = sidebar
        addCorner(btn, 10)
        local st = addStroke(btn, 1.4, 24, 0)

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.fromScale(1, 1)
        tl.BackgroundTransparency = 1
        tl.Font = Enum.Font.GothamBold
        tl.Text = name
        tl.TextSize = 13
        tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Parent = btn

        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabButtonsList[name] = { button = btn, stroke = st }
    end
end

-- ============================================
-- CLICK ENGINE & AUTO QUEUE LOGIC (scoped)
-- ============================================
local isGuiObjectTrulyVisible, sendHardwareClick, triggerAllSignals, findTargetButton

do
    function isGuiObjectTrulyVisible(gui)
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
        
        -- Filter out elements hidden off-screen by TDS UI animation systems!
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

    function sendHardwareClick(gui)
        if not gui or not isGuiObjectTrulyVisible(gui) then return false end
        local absPos = gui.AbsolutePosition
        local absSize = gui.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then return false end
        local cx = math.floor(absPos.X + absSize.X / 2)
        local cy = math.floor(absPos.Y + absSize.Y / 2)
        local menuWasVis = S.root.Visible
        local overlap = false
        if menuWasVis and S.root.AbsoluteSize.X > 0 then
            local rX, rY = S.root.AbsolutePosition.X, S.root.AbsolutePosition.Y
            local rW, rH = S.root.AbsoluteSize.X, S.root.AbsoluteSize.Y
            if cx >= rX and cx <= (rX + rW) and cy >= rY and cy <= (rY + rH) then overlap = true end
        end
        if overlap then S.root.Visible = false; task.wait(0.02) end
        pcall(function()
            VirtualInputManager:SendMouseMoveEvent(cx, cy, game)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
            task.wait(0.04)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
        end)
        if overlap then task.wait(0.02); S.root.Visible = true end
        return true
    end

    function triggerAllSignals(gui)
        if not gui or not isGuiObjectTrulyVisible(gui) then return false end
        local success = false

        local targetList = { gui }
        if gui.Parent and not gui.Parent:IsA("ScreenGui") then
            table.insert(targetList, gui.Parent)
        end
        for _, child in ipairs(gui:GetChildren()) do
            if child:IsA("GuiObject") then
                table.insert(targetList, child)
            end
        end

        for _, target in ipairs(targetList) do
            if type(firesignal) == "function" then
                pcall(function()
                    if target:IsA("GuiButton") then
                        firesignal(target.MouseButton1Click)
                        firesignal(target.MouseButton1Down)
                        firesignal(target.MouseButton1Up)
                        firesignal(target.Activated)
                    end
                    firesignal(target.InputBegan, {UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin})
                    firesignal(target.InputEnded, {UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.End})
                    success = true
                end)
            end

            if type(getconnections) == "function" then
                pcall(function()
                    for _, conn in pairs(getconnections(target.InputBegan)) do
                        conn:Fire({UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin})
                        success = true
                    end
                    if target:IsA("GuiButton") then
                        for _, conn in pairs(getconnections(target.MouseButton1Click)) do conn:Fire(); success = true end
                        for _, conn in pairs(getconnections(target.Activated)) do conn:Fire(); success = true end
                    end
                end)
            end

            if target:IsA("GuiButton") then
                pcall(function() target:Activate(); success = true end)
            end
        end

        sendHardwareClick(gui)
        return success
    end

    function findTargetButton(keyword)
        local pg = getPlayerGui()
        if not pg then return nil end
        local kw = string.lower(keyword or "")
        if kw == "not chosen" or kw == "" then return nil end

        local candidates = {}
        local viewportY = 1000
        pcall(function()
            if workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize then
                viewportY = workspace.CurrentCamera.ViewportSize.Y
            end
        end)

        for _, desc in ipairs(pg:GetDescendants()) do
            -- CRITICAL: Skip any elements inside our own custom GUI menu!
            if not (screenGui and desc:IsDescendantOf(screenGui)) then
                if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("ImageLabel") or desc:IsA("ImageButton")) and isGuiObjectTrulyVisible(desc) then
                    local txt = ""
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                        txt = string.lower(string.gsub(desc.Text or "", "^%s*(.-)%s*$", "%1"))
                    end
                    local descName = string.lower(desc.Name or "")

                    local isQuestOrInfo = (string.find(txt, "win", 1, true) or string.find(txt, "quest", 1, true) or string.find(txt, "badge", 1, true) or string.find(txt, "triumph", 1, true))

                    local match = false
                    local score = 0

                    if kw == "play" then
                        if not isQuestOrInfo then
                            if txt == "play" then
                                match = true
                                score = 100
                            elseif descName == "play" or descName == "playbutton" or descName == "play_button" then
                                match = true
                                score = 90
                            elseif string.find(txt, "play", 1, true) and not string.find(txt, "replay", 1, true) and not string.find(txt, "display", 1, true) and not string.find(txt, "player", 1, true) and not string.find(txt, "how to", 1, true) then
                                match = true
                                score = 70
                            end
                            if match and desc.AbsolutePosition.Y > (viewportY * 0.5) then
                                score = score + 50
                            end
                        end
                    elseif kw == "survival" then
                        if not isQuestOrInfo then
                            if txt == "survival" or descName == "survival" then
                                match = true
                                score = 100
                            elseif string.find(txt, "classic tower defense", 1, true) or string.find(txt, "survival", 1, true) or string.find(descName, "survival", 1, true) then
                                match = true
                                score = 80
                            end
                            if string.find(txt, "pvp", 1, true) or string.find(txt, "hardcore", 1, true) or string.find(txt, "sandbox", 1, true) or string.find(txt, "special modes", 1, true) then
                                match = false
                                score = 0
                            end
                        end
                    elseif kw == "easy" then
                        if not isQuestOrInfo and (txt == "easy" or descName == "easy" or string.find(txt, "for new users", 1, true)) then
                            match = true
                            score = 100
                        end
                    elseif kw == "casual" then
                        if not isQuestOrInfo and (txt == "casual" or descName == "casual" or string.find(txt, "for the casual user", 1, true)) then
                            match = true
                            score = 100
                        end
                    elseif kw == "intermediate" then
                        if not isQuestOrInfo and (txt == "intermediate" or descName == "intermediate" or string.find(txt, "a balanced experience", 1, true)) then
                            match = true
                            score = 100
                        end
                    elseif kw == "molten" then
                        if not isQuestOrInfo and (txt == "molten" or descName == "molten" or string.find(txt, "for a molten experience", 1, true)) then
                            match = true
                            score = 100
                        end
                    elseif kw == "fallen" then
                        if not isQuestOrInfo and (txt == "fallen" or descName == "fallen" or string.find(txt, "for the experienced user", 1, true)) then
                            match = true
                            score = 100
                        end
                    elseif kw == "solo" then
                        if not isQuestOrInfo and (txt == "solo" or descName == "solo") then
                            match = true
                            score = 100
                        end
                    elseif kw == "duo" then
                        if not isQuestOrInfo and (txt == "duo" or descName == "duo") then
                            match = true
                            score = 100
                        end
                    elseif kw == "trio" then
                        if not isQuestOrInfo and (txt == "trio" or descName == "trio") then
                            match = true
                            score = 100
                        end
                    elseif kw == "quad" then
                        if not isQuestOrInfo and (txt == "quad" or descName == "quad") then
                            match = true
                            score = 100
                        end
                    elseif kw == "cancel" then
                        if txt == "cancel" or descName == "cancel" or string.find(txt, "cancel queue", 1, true) or string.find(txt, "leave queue", 1, true) then
                            match = true
                            score = 100
                        end
                    end

                    if match then
                        local btnObj = desc
                        local cur = desc
                        for depth = 1, 5 do
                            if not cur or cur:IsA("ScreenGui") then break end
                            if (cur:IsA("GuiButton") or cur:IsA("TextButton") or cur:IsA("ImageButton")) and isGuiObjectTrulyVisible(cur) then
                                btnObj = cur
                                break
                            end
                            cur = cur.Parent
                        end
                        table.insert(candidates, { element = btnObj, score = score, y = btnObj.AbsolutePosition.Y })
                    end
                end
            end
        end

        if #candidates > 0 then
            table.sort(candidates, function(a, b)
                return a.score > b.score
            end)
            return candidates[1].element
        end

        return nil
    end
end

-- ============================================
-- PAGE 1: AUTO MATCHMAKING (scoped)
-- ============================================
local tStatus

do
    local page = Instance.new("Frame")
    page.Name = "Page_AutoMatchmaking"
    page.AnchorPoint = Vector2.new(1, 0)
    page.Position = UDim2.new(1, 0, 0, 0)
    page.Size = UDim2.new(1, -204, 1, 0)
    page.BackgroundColor3 = Color3.fromRGB(11,15,24)
    page.BackgroundTransparency = 0.25
    page.BorderSizePixel = 0
    page.Visible = true
    page.Parent = contentArea
    addCorner(page, 14)
    addStroke(page, 1.4, 20, 270)

    local pt = Instance.new("TextLabel")
    pt.BackgroundTransparency = 1
    pt.Position = UDim2.fromOffset(18, 14)
    pt.Size = UDim2.new(1, -36, 0, 24)
    pt.Font = Enum.Font.GothamBold
    pt.Text = "Auto Matchmaking"
    pt.TextSize = 20
    pt.TextColor3 = Color3.fromRGB(255,255,255)
    pt.TextXAlignment = Enum.TextXAlignment.Left
    pt.Parent = page

    local pd = Instance.new("TextLabel")
    pd.BackgroundTransparency = 1
    pd.Position = UDim2.fromOffset(18, 38)
    pd.Size = UDim2.new(1, -36, 0, 16)
    pd.Font = Enum.Font.GothamMedium
    pd.Text = "Automated queue and mode selection system."
    pd.TextSize = 11
    pd.TextColor3 = Color3.fromRGB(140,150,165)
    pd.TextXAlignment = Enum.TextXAlignment.Left
    pd.Parent = page

    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.Position = UDim2.fromOffset(18, 64)
    scroll.Size = UDim2.new(1, -36, 1, -74)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(27,36,51)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.BorderSizePixel = 0
    scroll.ClipsDescendants = false
    scroll.Parent = page
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 14)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = scroll
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.Parent = scroll

    tabPagesList["Auto Matchmaking"] = page

    -- TOGGLE CARD
    do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 84)
        card.BackgroundColor3 = Color3.fromRGB(16,23,34)
        card.BorderSizePixel = 0
        card.LayoutOrder = 1
        card.Parent = scroll
        addCorner(card, 12)
        addStroke(card, 1.4, 22, 45)

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.fromOffset(16, 10)
        lbl.Size = UDim2.new(0.65, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = "Auto Queue"
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = card

        local sub = Instance.new("TextLabel")
        sub.Position = UDim2.fromOffset(16, 30)
        sub.Size = UDim2.new(0.65, 0, 0, 20)
        sub.BackgroundTransparency = 1
        sub.Font = Enum.Font.GothamMedium
        sub.Text = "Auto queue into selected mode and squad size."
        sub.TextSize = 11
        sub.TextColor3 = Color3.fromRGB(140,150,165)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent = card

        tStatus = Instance.new("TextLabel")
        tStatus.Name = "LiveStatus"
        tStatus.Position = UDim2.fromOffset(16, 52)
        tStatus.Size = UDim2.new(0.9, 0, 0, 20)
        tStatus.BackgroundTransparency = 1
        tStatus.Font = Enum.Font.GothamMedium
        tStatus.Text = "Status: Disabled"
        tStatus.TextSize = 12
        tStatus.TextColor3 = Color3.fromRGB(160,170,184)
        tStatus.TextXAlignment = Enum.TextXAlignment.Left
        tStatus.Parent = card

        local sw = Instance.new("TextButton")
        sw.AnchorPoint = Vector2.new(1, 0.5)
        sw.Position = UDim2.new(1, -16, 0.4, 0)
        sw.Size = UDim2.fromOffset(50, 26)
        sw.BackgroundColor3 = Color3.fromRGB(11,15,24)
        sw.BorderSizePixel = 0
        sw.AutoButtonColor = false
        sw.Text = ""
        sw.Parent = card
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
        addStroke(sw, 1.4, 24, 135)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(20, 20)
        knob.Position = UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = Color3.fromRGB(140,150,165)
        knob.BorderSizePixel = 0
        knob.Parent = sw
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        sw.MouseButton1Click:Connect(function()
            S.autoQueueEnabled = not S.autoQueueEnabled
            S.isQueueRunning = false
            S.isPlayerQueuedState = false
            local on = S.autoQueueEnabled
            TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = on and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = on and Color3.fromRGB(14,255,0) or Color3.fromRGB(140,150,165)
            }):Play()
            TweenService:Create(sw, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = on and Color3.fromRGB(22,35,25) or Color3.fromRGB(11,15,24)
            }):Play()
            if on then
                if S.selectedDifficulty == "Not Chosen" then
                    tStatus.Text = "Status: Difficulty Not Chosen"
                    tStatus.TextColor3 = Color3.fromRGB(255,170,0)
                elseif S.selectedSquadSize == "Not Chosen" then
                    tStatus.Text = "Status: Squad Size Not Chosen"
                    tStatus.TextColor3 = Color3.fromRGB(255,170,0)
                else
                    tStatus.Text = "Status: Initializing Queue..."
                    tStatus.TextColor3 = Color3.fromRGB(0,229,255)
                end
            else
                tStatus.Text = "Status: Disabled"
                tStatus.TextColor3 = Color3.fromRGB(160,170,184)
            end
        end)
    end

    local function createDropdownCard(parentScroll, config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 72)
        card.BackgroundColor3 = Color3.fromRGB(16,23,34)
        card.BorderSizePixel = 0
        card.ZIndex = config.zIndex or 20
        card.LayoutOrder = config.layoutOrder or 2
        card.Parent = parentScroll
        addCorner(card, 12)
        addStroke(card, 1.4, 22, config.strokeRot or 0)

        local t1 = Instance.new("TextLabel")
        t1.Position = UDim2.fromOffset(16, 12)
        t1.Size = UDim2.new(0.5, 0, 0, 20)
        t1.BackgroundTransparency = 1
        t1.Font = Enum.Font.GothamBold
        t1.Text = config.title
        t1.TextSize = 14
        t1.TextColor3 = Color3.fromRGB(255,255,255)
        t1.TextXAlignment = Enum.TextXAlignment.Left
        t1.ZIndex = config.zIndex + 1
        t1.Parent = card

        local t2 = Instance.new("TextLabel")
        t2.Position = UDim2.fromOffset(16, 34)
        t2.Size = UDim2.new(0.5, 0, 0, 24)
        t2.BackgroundTransparency = 1
        t2.Font = Enum.Font.GothamMedium
        t2.Text = config.subtitle
        t2.TextSize = 11
        t2.TextColor3 = Color3.fromRGB(140,150,165)
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.ZIndex = config.zIndex + 1
        t2.Parent = card

        local trigger = Instance.new("TextButton")
        trigger.AnchorPoint = Vector2.new(1, 0.5)
        trigger.Position = UDim2.new(1, -16, 0.5, 0)
        trigger.Size = UDim2.fromOffset(200, 38)
        trigger.BackgroundColor3 = Color3.fromRGB(11,15,24)
        trigger.BorderSizePixel = 0
        trigger.AutoButtonColor = false
        trigger.Text = ""
        trigger.ZIndex = config.zIndex + 2
        trigger.Parent = card
        addCorner(trigger, 8)
        addStroke(trigger, 1.4, 24, 0)

        local selLabel = Instance.new("TextLabel")
        selLabel.Position = UDim2.fromOffset(12, 0)
        selLabel.Size = UDim2.new(1, -38, 1, 0)
        selLabel.BackgroundTransparency = 1
        selLabel.Font = Enum.Font.GothamBold
        selLabel.Text = config.default
        selLabel.TextSize = 12
        selLabel.TextColor3 = Color3.fromRGB(245,249,255)
        selLabel.TextXAlignment = Enum.TextXAlignment.Left
        selLabel.ZIndex = config.zIndex + 3
        selLabel.Parent = trigger

        local chev = Instance.new("TextLabel")
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.new(1, -10, 0.5, 0)
        chev.Size = UDim2.fromOffset(16, 16)
        chev.BackgroundTransparency = 1
        chev.Font = Enum.Font.GothamBold
        chev.Text = "v"
        chev.TextSize = 10
        chev.TextColor3 = Color3.fromRGB(140,150,165)
        chev.ZIndex = config.zIndex + 3
        chev.Parent = trigger

        local listC = Instance.new("Frame")
        listC.AnchorPoint = Vector2.new(1, 0)
        listC.Position = UDim2.new(1, -16, 1, 6)
        listC.Size = UDim2.fromOffset(200, 0)
        listC.BackgroundColor3 = Color3.fromRGB(11,15,24)
        listC.BorderSizePixel = 0
        listC.ClipsDescendants = true
        listC.Visible = false
        listC.ZIndex = 100
        listC.Parent = card
        addCorner(listC, 8)
        addStroke(listC, 1.4, 24, 0)

        local lScroll = Instance.new("ScrollingFrame")
        lScroll.Size = UDim2.fromScale(1, 1)
        lScroll.BackgroundTransparency = 1
        lScroll.BorderSizePixel = 0
        lScroll.ScrollBarThickness = 3
        lScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        lScroll.CanvasSize = UDim2.new(0,0,0,0)
        lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        lScroll.ZIndex = 101
        lScroll.Parent = listC
        Instance.new("UIListLayout", lScroll).Padding = UDim.new(0, 4)
        local lPad = Instance.new("UIPadding")
        lPad.PaddingLeft = UDim.new(0, 4)
        lPad.PaddingRight = UDim.new(0, 6)
        lPad.PaddingTop = UDim.new(0, 4)
        lPad.PaddingBottom = UDim.new(0, 4)
        lPad.Parent = lScroll

        local isOpen = false
        local optBtns = {}

        for _, opt in ipairs(config.options) do
            local iBtn = Instance.new("TextButton")
            iBtn.Size = UDim2.new(1, 0, 0, 32)
            iBtn.BackgroundColor3 = Color3.fromRGB(14,19,29)
            iBtn.BorderSizePixel = 0
            iBtn.AutoButtonColor = false
            iBtn.Text = ""
            iBtn.ZIndex = 102
            iBtn.Parent = lScroll
            Instance.new("UICorner", iBtn).CornerRadius = UDim.new(0, 6)

            local mL = Instance.new("TextLabel")
            mL.Position = UDim2.fromOffset(10, 0)
            mL.Size = UDim2.new(0.5, 0, 1, 0)
            mL.BackgroundTransparency = 1
            mL.Font = Enum.Font.GothamMedium
            mL.Text = opt.label or opt.name
            mL.TextSize = 11
            mL.TextColor3 = Color3.fromRGB(174,204,236)
            mL.TextXAlignment = Enum.TextXAlignment.Left
            mL.ZIndex = 103
            mL.Parent = iBtn

            if opt.req then
                local rL = Instance.new("TextLabel")
                rL.Position = UDim2.new(0.5, 0, 0, 0)
                rL.Size = UDim2.new(0.5, -10, 1, 0)
                rL.BackgroundTransparency = 1
                rL.Font = Enum.Font.GothamMedium
                rL.Text = opt.req
                rL.TextSize = 10
                rL.TextColor3 = Color3.fromRGB(140,150,165)
                rL.TextXAlignment = Enum.TextXAlignment.Right
                rL.ZIndex = 103
                rL.Parent = iBtn
            end

            table.insert(optBtns, { button = iBtn, label = mL, name = opt.name })
        end

        local function setOpen(open)
            isOpen = open
            listC.Visible = true
            TweenService:Create(listC, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(200, isOpen and config.listHeight or 0)
            }):Play()
            TweenService:Create(chev, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Rotation = isOpen and 180 or 0
            }):Play()
            if not isOpen then
                task.delay(0.25, function() if not isOpen then listC.Visible = false end end)
            end
        end

        trigger.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

        for _, o in ipairs(optBtns) do
            o.button.MouseButton1Click:Connect(function()
                config.onSelect(o.name)
                selLabel.Text = o.name
                S.isPlayerQueuedState = false
                for _, b in ipairs(optBtns) do
                    local active = b.name == o.name
                    b.button.BackgroundColor3 = active and Color3.fromRGB(22,31,46) or Color3.fromRGB(14,19,29)
                    b.label.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(174,204,236)
                end
                setOpen(false)
            end)
        end

        return card
    end

    createDropdownCard(scroll, {
        title = "Difficulty Mode",
        subtitle = "Select difficulty (Easy to Fallen).",
        default = "Not Chosen",
        zIndex = 40,
        layoutOrder = 2,
        strokeRot = 90,
        listHeight = 190,
        options = {
            {name="Easy", req="No req (Lvl 0)"},
            {name="Casual", req="No req (Lvl 0)"},
            {name="Intermediate", req="Level 5"},
            {name="Molten", req="Level 15"},
            {name="Fallen", req="Level 30"}
        },
        onSelect = function(val) S.selectedDifficulty = val end
    })

    createDropdownCard(scroll, {
        title = "Squad Size",
        subtitle = "Select squad size (Solo to Quad).",
        default = "Not Chosen",
        zIndex = 20,
        layoutOrder = 3,
        strokeRot = 180,
        listHeight = 150,
        options = {
            {name="Solo"},
            {name="Duo"},
            {name="Trio"},
            {name="Quad"}
        },
        onSelect = function(val) S.selectedSquadSize = val end
    })
end

-- Auto Queue Engine Loop
do
    local function executeStep()
        if S.isQueueRunning or not S.autoQueueEnabled then return end
        S.isQueueRunning = true
        pcall(function()
            if S.selectedDifficulty == "Not Chosen" then
                tStatus.Text = "Status: Difficulty Not Chosen"
                tStatus.TextColor3 = Color3.fromRGB(255,170,0)
                S.isQueueRunning = false
                return
            end
            if S.selectedSquadSize == "Not Chosen" then
                tStatus.Text = "Status: Squad Size Not Chosen"
                tStatus.TextColor3 = Color3.fromRGB(255,170,0)
                S.isQueueRunning = false
                return
            end
            
            -- Stop clicking if already queued
            local cancelBtn = findTargetButton("cancel")
            if cancelBtn or S.isPlayerQueuedState then
                tStatus.Text = "Status: Successfully Queued!"
                tStatus.TextColor3 = Color3.fromRGB(14,255,0)
                S.isQueueRunning = false
                return
            end

            -- Check Priority 1: Squad Size card visible on screen?
            local squadObj = findTargetButton(S.selectedSquadSize)
            if squadObj then
                tStatus.Text = "Status: Selecting " .. S.selectedSquadSize .. "..."
                tStatus.TextColor3 = Color3.fromRGB(0,229,255)
                triggerAllSignals(squadObj)
                task.wait(1.2)
                S.isPlayerQueuedState = true
                tStatus.Text = "Status: Successfully Queued!"
                tStatus.TextColor3 = Color3.fromRGB(14,255,0)
                S.isQueueRunning = false
                return
            end

            -- Check Priority 2: Difficulty card visible on screen?
            local diffObj = findTargetButton(S.selectedDifficulty)
            if diffObj then
                tStatus.Text = "Status: Selecting " .. S.selectedDifficulty .. "..."
                tStatus.TextColor3 = Color3.fromRGB(0,229,255)
                triggerAllSignals(diffObj)
                task.wait(1.2)
                S.isQueueRunning = false
                return
            end

            -- Check Priority 3: Gamemode "Survival" card visible on screen?
            local survObj = findTargetButton("survival")
            if survObj then
                tStatus.Text = "Status: Selecting Survival..."
                tStatus.TextColor3 = Color3.fromRGB(0,229,255)
                triggerAllSignals(survObj)
                task.wait(1.2)
                S.isQueueRunning = false
                return
            end

            -- Check Priority 4: Main green PLAY button in lobby (only if no submenus are open!)
            local playObj = findTargetButton("play")
            if playObj then
                tStatus.Text = "Status: Opening Play Menu..."
                tStatus.TextColor3 = Color3.fromRGB(255,200,0)
                triggerAllSignals(playObj)
                task.wait(1.2)
                S.isQueueRunning = false
                return
            end

            tStatus.Text = "Status: Standing By"
            tStatus.TextColor3 = Color3.fromRGB(160,170,184)
        end)
        S.isQueueRunning = false
    end

    task.spawn(function()
        while true do
            if S.autoQueueEnabled then
                executeStep()
                task.wait(0.8)
            else
                task.wait(0.5)
            end
        end
    end)
end

-- ============================================
-- PAGE 2: MENU SETTINGS (scoped)
-- ============================================
do
    local page = Instance.new("Frame")
    page.Name = "Page_MenuSettings"
    page.AnchorPoint = Vector2.new(1, 0)
    page.Position = UDim2.new(1, 0, 0, 0)
    page.Size = UDim2.new(1, -204, 1, 0)
    page.BackgroundColor3 = Color3.fromRGB(11,15,24)
    page.BackgroundTransparency = 0.25
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = contentArea
    addCorner(page, 14)
    addStroke(page, 1.4, 20, 270)

    local pt = Instance.new("TextLabel")
    pt.BackgroundTransparency = 1
    pt.Position = UDim2.fromOffset(18, 14)
    pt.Size = UDim2.new(1, -36, 0, 24)
    pt.Font = Enum.Font.GothamBold
    pt.Text = "Menu Settings"
    pt.TextSize = 20
    pt.TextColor3 = Color3.fromRGB(255,255,255)
    pt.TextXAlignment = Enum.TextXAlignment.Left
    pt.Parent = page

    local pd = Instance.new("TextLabel")
    pd.BackgroundTransparency = 1
    pd.Position = UDim2.fromOffset(18, 38)
    pd.Size = UDim2.new(1, -36, 0, 16)
    pd.Font = Enum.Font.GothamMedium
    pd.Text = "Customize interface visuals, themes and neon outlines."
    pd.TextSize = 11
    pd.TextColor3 = Color3.fromRGB(140,150,165)
    pd.TextXAlignment = Enum.TextXAlignment.Left
    pd.Parent = page

    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.Position = UDim2.fromOffset(18, 64)
    scroll.Size = UDim2.new(1, -36, 1, -74)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(27,36,51)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.BorderSizePixel = 0
    scroll.ClipsDescendants = false
    scroll.Parent = page
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 14)
    scroll:FindFirstChildOfClass("UIListLayout").SortOrder = Enum.SortOrder.LayoutOrder
    local sPad = Instance.new("UIPadding")
    sPad.PaddingLeft = UDim.new(0, 2)
    sPad.PaddingRight = UDim.new(0, 6)
    sPad.PaddingTop = UDim.new(0, 4)
    sPad.PaddingBottom = UDim.new(0, 14)
    sPad.Parent = scroll

    tabPagesList["Menu Settings"] = page

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 72)
    card.BackgroundColor3 = Color3.fromRGB(16,23,34)
    card.BorderSizePixel = 0
    card.ZIndex = 20
    card.Parent = scroll
    addCorner(card, 12)
    addStroke(card, 1.4, 22, 45)

    local lt = Instance.new("TextLabel")
    lt.Position = UDim2.fromOffset(16, 12)
    lt.Size = UDim2.new(0.5, 0, 0, 20)
    lt.BackgroundTransparency = 1
    lt.Font = Enum.Font.GothamBold
    lt.Text = "Menu Outline Color"
    lt.TextSize = 14
    lt.TextColor3 = Color3.fromRGB(255,255,255)
    lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.ZIndex = 21
    lt.Parent = card

    local ls = Instance.new("TextLabel")
    ls.Position = UDim2.fromOffset(16, 34)
    ls.Size = UDim2.new(0.5, 0, 0, 24)
    ls.BackgroundTransparency = 1
    ls.Font = Enum.Font.GothamMedium
    ls.Text = "Select theme color for neon borders."
    ls.TextSize = 11
    ls.TextColor3 = Color3.fromRGB(140,150,165)
    ls.TextXAlignment = Enum.TextXAlignment.Left
    ls.ZIndex = 21
    ls.Parent = card

    local trigger = Instance.new("TextButton")
    trigger.AnchorPoint = Vector2.new(1, 0.5)
    trigger.Position = UDim2.new(1, -16, 0.5, 0)
    trigger.Size = UDim2.fromOffset(200, 38)
    trigger.BackgroundColor3 = Color3.fromRGB(11,15,24)
    trigger.BorderSizePixel = 0
    trigger.AutoButtonColor = false
    trigger.Text = ""
    trigger.ZIndex = 22
    trigger.Parent = card
    addCorner(trigger, 8)
    addStroke(trigger, 1.4, 24, 135)

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(24, 16)
    pill.Position = UDim2.fromOffset(10, 11)
    pill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    pill.BorderSizePixel = 0
    pill.ZIndex = 23
    pill.Parent = trigger
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    local pillGrad = Instance.new("UIGradient")
    pillGrad.Color = getThemeColorSequence(S.uiColorTheme)
    pillGrad.Parent = pill

    local selText = Instance.new("TextLabel")
    selText.Position = UDim2.fromOffset(42, 0)
    selText.Size = UDim2.new(1, -68, 1, 0)
    selText.BackgroundTransparency = 1
    selText.Font = Enum.Font.GothamBold
    selText.Text = S.uiColorTheme
    selText.TextSize = 12
    selText.TextColor3 = Color3.fromRGB(245,249,255)
    selText.TextXAlignment = Enum.TextXAlignment.Left
    selText.ZIndex = 23
    selText.Parent = trigger

    local chev = Instance.new("TextLabel")
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, -10, 0.5, 0)
    chev.Size = UDim2.fromOffset(16, 16)
    chev.BackgroundTransparency = 1
    chev.Font = Enum.Font.GothamBold
    chev.Text = "v"
    chev.TextSize = 10
    chev.TextColor3 = Color3.fromRGB(140,150,165)
    chev.ZIndex = 23
    chev.Parent = trigger

    local listC = Instance.new("Frame")
    listC.AnchorPoint = Vector2.new(1, 0)
    listC.Position = UDim2.new(1, -16, 1, 6)
    listC.Size = UDim2.fromOffset(200, 0)
    listC.BackgroundColor3 = Color3.fromRGB(11,15,24)
    listC.BorderSizePixel = 0
    listC.ClipsDescendants = true
    listC.Visible = false
    listC.ZIndex = 100
    listC.Parent = card
    addCorner(listC, 8)
    addStroke(listC, 1.4, 24, 0)

    local lScroll = Instance.new("ScrollingFrame")
    lScroll.Size = UDim2.fromScale(1, 1)
    lScroll.BackgroundTransparency = 1
    lScroll.BorderSizePixel = 0
    lScroll.ScrollBarThickness = 3
    lScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    lScroll.CanvasSize = UDim2.new(0,0,0,0)
    lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lScroll.ZIndex = 101
    lScroll.Parent = listC
    Instance.new("UIListLayout", lScroll).Padding = UDim.new(0, 4)
    local lPad = Instance.new("UIPadding")
    lPad.PaddingLeft = UDim.new(0, 4)
    lPad.PaddingRight = UDim.new(0, 6)
    lPad.PaddingTop = UDim.new(0, 4)
    lPad.PaddingBottom = UDim.new(0, 14)
    lPad.Parent = listC

    local optBtns = {}
    local isOpen = false

    for _, name in ipairs(S.uiThemeOptions) do
        local iBtn = Instance.new("TextButton")
        iBtn.Size = UDim2.new(1, 0, 0, 32)
        iBtn.BackgroundColor3 = Color3.fromRGB(14,19,29)
        iBtn.BorderSizePixel = 0
        iBtn.AutoButtonColor = false
        iBtn.Text = ""
        iBtn.ZIndex = 102
        iBtn.Parent = lScroll
        Instance.new("UICorner", iBtn).CornerRadius = UDim.new(0, 6)

        local sw = Instance.new("Frame")
        sw.Size = UDim2.fromOffset(20, 12)
        sw.Position = UDim2.fromOffset(8, 10)
        sw.BackgroundColor3 = Color3.fromRGB(255,255,255)
        sw.BorderSizePixel = 0
        sw.ZIndex = 103
        sw.Parent = iBtn
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
        local swG = Instance.new("UIGradient")
        swG.Color = getThemeColorSequence(name)
        swG.Parent = sw

        local iL = Instance.new("TextLabel")
        iL.Position = UDim2.fromOffset(36, 0)
        iL.Size = UDim2.new(1, -42, 1, 0)
        iL.BackgroundTransparency = 1
        iL.Font = Enum.Font.GothamMedium
        iL.Text = name
        iL.TextSize = 11
        iL.TextColor3 = Color3.fromRGB(174,204,236)
        iL.TextXAlignment = Enum.TextXAlignment.Left
        iL.ZIndex = 103
        iL.Parent = iBtn

        table.insert(optBtns, { button = iBtn, label = iL, name = name })
    end

    local function setOpen(open)
        isOpen = open
        listC.Visible = true
        TweenService:Create(listC, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(200, isOpen and 180 or 0)
        }):Play()
        TweenService:Create(chev, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Rotation = isOpen and 180 or 0
        }):Play()
        if not isOpen then
            task.delay(0.25, function() if not isOpen then listC.Visible = false end end)
        end
    end

    trigger.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

    for _, o in ipairs(optBtns) do
        o.button.MouseButton1Click:Connect(function()
            S.uiColorTheme = o.name
            selText.Text = o.name
            pillGrad.Color = getThemeColorSequence(o.name)
            for _, b in ipairs(optBtns) do
                local active = b.name == o.name
                b.button.BackgroundColor3 = active and Color3.fromRGB(22,31,46) or Color3.fromRGB(14,19,29)
                b.label.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(174,204,236)
            end
            setOpen(false)
        end)
    end
end

-- Initialize tab view
switchTab("Auto Matchmaking")

-- ============================================
-- WINDOW DRAGGING (scoped)
-- ============================================
do
    local dragging = false
    local dragInput, dragStart, startPos

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.Width.Scale, startPos.Width.Offset + delta.X, startPos.Height.Scale, startPos.Height.Offset + delta.Y)
        end
    end)
end

-- Singleton registration
EXEC_ENV[MENU_STATE_KEY] = {
    gui = screenGui,
    cleanup = function()
        if screenGui and screenGui.Parent then screenGui:Destroy() end
    end
}

-- ============================================
-- PREMIUM LOADER INTRO (scoped)
-- ============================================
do
    local origSize = UDim2.fromOffset(720, 470)
    root.Visible = false
    root.Size = UDim2.fromOffset(0, 0)

    local gameName = "TDS Test"
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if info and info.Name then gameName = info.Name end
    end)

    local avatarUrl = nil
    local lp = getLocalPlayer()
    if lp then
        pcall(function()
            avatarUrl = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
    end

    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "TDSTestLoader"
    loaderGui.IgnoreGuiInset = true
    loaderGui.DisplayOrder = 2147483647
    loaderGui.Parent = parentContainer

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.fromScale(1, 1)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = loaderGui

    local blinds = {}
    for i = 1, 6 do
        local b = Instance.new("Frame")
        b.Size = UDim2.new(1/6 + 0.002, 0, 1, 0)
        b.Position = UDim2.new((i-1)/6, 0, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(7,9,13)
        b.BorderSizePixel = 0
        b.ZIndex = 5
        b.Parent = wrapper
        table.insert(blinds, b)
    end

    for i = 1, 4 do
        local ring = Instance.new("Frame")
        ring.Size = UDim2.fromScale(0.3*i, 0.3*i)
        ring.Position = UDim2.fromScale(0.5, 0.5)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.BackgroundTransparency = 1
        ring.ZIndex = 7
        ring.Parent = wrapper
        Instance.new("UICorner", ring).CornerRadius = UDim.new(0.2, 0)
        addStroke(ring, 1.5, 30, i * 45)
    end

    local starfield = {}
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2
        local radius = math.random() * 0.9
        local star = Instance.new("Frame")
        star.Size = UDim2.fromOffset(math.random(1,3), math.random(1,3))
        star.Position = UDim2.fromScale(0.5 + math.cos(angle)*radius, 0.5 + math.sin(angle)*radius)
        star.BackgroundColor3 = Color3.fromRGB(255,255,255)
        star.BorderSizePixel = 0
        star.ZIndex = 8
        star.Parent = wrapper
        Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
        table.insert(starfield, {gui=star, angle=angle, radius=radius, speed=0.4+math.random()*0.5, opacity=math.random(60,100)/100})
    end

    local coreFrame = Instance.new("Frame")
    coreFrame.Size = UDim2.fromOffset(130, 130)
    coreFrame.Position = UDim2.fromScale(0.5, 0.5)
    coreFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    coreFrame.BackgroundTransparency = 1
    coreFrame.ZIndex = 9
    coreFrame.Parent = wrapper

    local coreGlow = Instance.new("Frame")
    coreGlow.Size = UDim2.fromScale(1.4, 1.4)
    coreGlow.Position = UDim2.fromScale(0.5, 0.5)
    coreGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    coreGlow.BackgroundColor3 = Color3.fromRGB(0,255,255)
    coreGlow.BackgroundTransparency = 0.88
    coreGlow.ZIndex = 8
    coreGlow.Parent = coreFrame
    Instance.new("UICorner", coreGlow).CornerRadius = UDim.new(1, 0)

    local radialBars = {}
    for i = 1, 32 do
        local angle = (i / 32) * math.pi * 2
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(4, 18)
        bar.AnchorPoint = Vector2.new(0.5, 1)
        local rad = 80
        bar.Position = UDim2.fromScale(0.5 + (math.cos(angle)*rad/130), 0.5 + (math.sin(angle)*rad/130))
        bar.Rotation = math.deg(angle) + 90
        bar.BackgroundColor3 = Color3.fromRGB(0,255,255)
        bar.BorderSizePixel = 0
        bar.ZIndex = 10
        bar.Parent = coreFrame
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local bG = Instance.new("UIGradient")
        bG.Color = getThemeColorSequence(S.uiColorTheme)
        bG.Parent = bar
        table.insert(radialBars, {bar=bar, angle=angle})
    end

    local scanLine = Instance.new("Frame")
    scanLine.Size = UDim2.new(1, 0, 0, 2)
    scanLine.Position = UDim2.fromScale(0, 0.5)
    scanLine.BackgroundColor3 = Color3.fromRGB(0,255,255)
    scanLine.BackgroundTransparency = 0.3
    scanLine.BorderSizePixel = 0
    scanLine.ZIndex = 9
    scanLine.Parent = wrapper

    local innerCore = Instance.new("Frame")
    innerCore.Size = UDim2.fromOffset(75, 75)
    innerCore.Position = UDim2.fromScale(0.5, 0.5)
    innerCore.AnchorPoint = Vector2.new(0.5, 0.5)
    innerCore.BackgroundColor3 = Color3.fromRGB(7,9,13)
    innerCore.ZIndex = 11
    innerCore.Parent = coreFrame
    Instance.new("UICorner", innerCore).CornerRadius = UDim.new(1, 0)
    addStroke(innerCore, 1.5, -30, 180)

    local pctLabel = Instance.new("TextLabel")
    pctLabel.BackgroundTransparency = 1
    pctLabel.Size = UDim2.fromScale(1, 1)
    pctLabel.Font = Enum.Font.Code
    pctLabel.Text = "0.00%"
    pctLabel.TextSize = 20
    pctLabel.TextColor3 = Color3.fromRGB(0,255,255)
    pctLabel.ZIndex = 12
    pctLabel.Parent = innerCore

    local authCard = Instance.new("Frame")
    authCard.Size = UDim2.fromOffset(360, 85)
    authCard.Position = UDim2.new(0.5, 0, 0, -120)
    authCard.AnchorPoint = Vector2.new(0.5, 0)
    authCard.BackgroundColor3 = Color3.fromRGB(0,0,0)
    authCard.BackgroundTransparency = 0.25
    authCard.ZIndex = 12
    authCard.Parent = wrapper
    addCorner(authCard, 16)
    addStroke(authCard, 1.5, 25, 0)

    local avFrame = Instance.new("Frame")
    avFrame.Size = UDim2.fromOffset(55, 55)
    avFrame.Position = UDim2.fromOffset(15, 15)
    avFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
    avFrame.ZIndex = 13
    avFrame.Parent = authCard
    Instance.new("UICorner", avFrame).CornerRadius = UDim.new(0.3, 0)
    local avImg = Instance.new("ImageLabel")
    avImg.Size = UDim2.fromScale(0.9, 0.9)
    avImg.Position = UDim2.fromScale(0.05, 0.05)
    avImg.BackgroundTransparency = 1
    avImg.ZIndex = 14
    avImg.Parent = avFrame
    Instance.new("UICorner", avImg).CornerRadius = UDim.new(0.3, 0)
    if avatarUrl then avImg.Image = avatarUrl end

    local userName = lp and lp.Name or "User"
    local authT = Instance.new("TextLabel")
    authT.Position = UDim2.fromOffset(85, 12)
    authT.Size = UDim2.new(1, -100, 0, 18)
    authT.Font = Enum.Font.Code
    authT.Text = "ACCESS AUTHORIZED // CLIENT SECURE"
    authT.TextSize = 11
    authT.TextColor3 = Color3.fromRGB(0,255,255)
    authT.TextXAlignment = Enum.TextXAlignment.Left
    authT.BackgroundTransparency = 1
    authT.ZIndex = 13
    authT.Parent = authCard

    local authB = Instance.new("TextLabel")
    authB.Position = UDim2.fromOffset(85, 30)
    authB.Size = UDim2.new(1, -100, 0, 42)
    authB.Font = Enum.Font.Code
    authB.Text = string.format("USER: %s\nGAME: %s\nLOAD: INITIALIZED", userName, string.upper(gameName))
    authB.TextSize = 10
    authB.TextColor3 = Color3.fromRGB(240,245,255)
    authB.TextXAlignment = Enum.TextXAlignment.Left
    authB.TextYAlignment = Enum.TextYAlignment.Top
    authB.BackgroundTransparency = 1
    authB.ZIndex = 13
    authB.Parent = authCard

    local statusLbl = Instance.new("TextLabel")
    statusLbl.BackgroundTransparency = 1
    statusLbl.AnchorPoint = Vector2.new(0.5, 1)
    statusLbl.Position = UDim2.new(0.5, 0, 1, -45)
    statusLbl.Size = UDim2.fromOffset(600, 20)
    statusLbl.Font = Enum.Font.Code
    statusLbl.Text = "> INIT..."
    statusLbl.TextSize = 11
    statusLbl.TextColor3 = Color3.fromRGB(255,60,60)
    statusLbl.ZIndex = 10
    statusLbl.Parent = wrapper

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.AnchorPoint = Vector2.new(0.5, 0)
    titleLbl.Position = UDim2.new(0.5, 0, 0, 36)
    titleLbl.Size = UDim2.fromOffset(500, 45)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = "TDS TEST"
    titleLbl.TextSize = 28
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.ZIndex = 10
    titleLbl.Parent = wrapper

    task.spawn(function()
        TweenService:Create(authCard, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 100)
        }):Play()

        local function runStage(targetPct, text, dur)
            statusLbl.Text = "> " .. text
            local startTime = os.clock()
            local startPct = tonumber(string.match(pctLabel.Text, "%d+%.?%d*")) or 0
            while os.clock() - startTime < dur do
                local prog = math.clamp((os.clock() - startTime) / dur, 0, 1)
                local curPct = startPct + (targetPct * 100 - startPct) * prog
                pctLabel.Text = string.format("%.2f%%", curPct)
                scanLine.Position = UDim2.new(0, 0, (math.sin(os.clock() * 5.2) + 1)/2, 0)
                for _, d in ipairs(radialBars) do
                    local wave = math.sin(os.clock() * 15 + d.angle * 2) * 8
                    local noise = math.noise(d.angle, os.clock() * 8) * 12
                    d.bar.Size = UDim2.fromOffset(4, math.clamp(14 + wave + noise, 6, 44))
                end
                for _, star in ipairs(starfield) do
                    star.radius = star.radius - star.speed * 0.016
                    if star.radius < 0.05 then star.radius = 1.0; star.angle = math.random() * math.pi * 2 end
                    star.gui.Position = UDim2.fromScale(0.5 + math.cos(star.angle) * star.radius, 0.5 + math.sin(star.angle) * star.radius)
                end
                coreFrame.Rotation = (coreFrame.Rotation + 1) % 360
                task.wait()
            end
            pctLabel.Text = string.format("%.2f%%", targetPct * 100)
        end

        runStage(0.25, "SECURITY AUDIT...", 0.4)
        runStage(0.60, "HOOKING CLIENT APIS...", 0.4)
        runStage(0.90, "SYNCING WRAPPERS...", 0.4)
        runStage(1.00, "CONNECTED.", 0.4)
        task.wait(0.08)

        pctLabel.Visible = false
        TweenService:Create(authCard, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5,0,0,-150)}):Play()
        TweenService:Create(titleLbl, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5,0,0,-100)}):Play()
        TweenService:Create(statusLbl, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5,0,1,100)}):Play()
        TweenService:Create(scanLine, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(innerCore, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0,0)}):Play()
        TweenService:Create(coreGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(0,0)}):Play()
        task.wait(0.2)

        for idx, blind in ipairs(blinds) do
            local tx = (idx % 2 == 0) and -1.2 or 1.2
            TweenService:Create(blind, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(tx, 0, blind.Position.Y.Scale, 0)
            }):Play()
        end
        task.wait(0.35)

        root.Size = UDim2.fromOffset(0, 0)
        root.Visible = true
        TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = origSize
        }):Play()
        task.wait(0.1)
        loaderGui:Destroy()
    end)
end