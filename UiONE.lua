local UIManager = {}
UIManager.__index = UIManager

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LUCIDE_ICONS = {
    Check = "✓", Heart = "❤", Alert = "⚠", Lock = "🔒", Key = "🔑", Settings = "⚙", Star = "★", Trash = "🗑", Plus = "＋", Minus = "－", 
    ArrowRight = "→", ArrowLeft = "←", X = "✕", Search = "🔍", Moon = "🌙", Sun = "☀", Bell = "🔔", Zap = "⚡", User = "👤", 
    Info = "ℹ", Flag = "🏁", Clock = "⏱", Gift = "🎁", Pin = "📌", Eye = "👁", Edit = "✏", Download = "⤓", Upload = "⤒"
}

local THEMES = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Primary = Color3.fromRGB(50, 110, 190),
        Secondary = Color3.fromRGB(35, 35, 45),
        Text = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(255, 170, 0),
        Success = Color3.fromRGB(40, 190, 90),
        Error = Color3.fromRGB(210, 60, 60),
        Warning = Color3.fromRGB(220, 150, 50)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Primary = Color3.fromRGB(45, 115, 210),
        Secondary = Color3.fromRGB(210, 210, 220),
        Text = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(210, 80, 40),
        Success = Color3.fromRGB(35, 170, 75),
        Error = Color3.fromRGB(190, 50, 50),
        Warning = Color3.fromRGB(200, 130, 40)
    }
}

local function CreateDraggable(gui, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function UIManager.new()
    local self = setmetatable({}, UIManager)
    self.CurrentTheme = "Dark"
    self.Windows = {}
    self.Notifications = {}
    self.Keybinds = {}
    self.ActiveAnimations = {}
    self.Elements = {}
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UIManager_" .. HttpService:GenerateGUID(false)
    self.ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.DisplayOrder = 999

    self.NotificationFrame = Instance.new("Frame")
    self.NotificationFrame.Size = UDim2.new(0.25, 0, 0.8, 0)
    self.NotificationFrame.Position = UDim2.new(0.725, 0, 0.1, 0)
    self.NotificationFrame.BackgroundTransparency = 1
    self.NotificationFrame.Parent = self.ScreenGui

    self:SetTheme("Dark")

    return self
end

function UIManager:SetTheme(themeName)
    if not THEMES[themeName] then return end
    self.CurrentTheme = themeName
    for _, element in pairs(self.Elements) do
        if element.ThemeTag then
            local tag = element.ThemeTag
            if tag.Background then element.BackgroundColor3 = THEMES[themeName][tag.Background] end
            if tag.Text then element.TextColor3 = THEMES[themeName][tag.Text] end
            if tag.Image then element.ImageColor3 = THEMES[themeName][tag.Image] end
            if tag.Border then element.BorderColor3 = THEMES[themeName][tag.Border] end
        end
    end
end

function UIManager:Tween(element, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(element, TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out), properties)
    tween:Play()
    table.insert(self.ActiveAnimations, tween)
    return tween
end

function UIManager:Notify(title, message, icon, duration)
    duration = duration or 5
    icon = LUCIDE_ICONS[icon] or ""

    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, -20, 0, 0)
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.BackgroundColor3 = THEMES[self.CurrentTheme].Secondary
    notification.BorderSizePixel = 0
    notification.Position = UDim2.new(0, 10, 0, #self.Notifications * 85)
    notification.Parent = self.NotificationFrame
    notification.ThemeTag = { Background = "Secondary" }

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = icon .. "  " .. title
    titleLabel.Font = Enum.Font.SemiBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = THEMES[self.CurrentTheme].Text
    titleLabel.Parent = notification
    titleLabel.ThemeTag = { Text = "Text" }

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.Regular
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.Size = UDim2.new(1, -30, 0, 0)
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = THEMES[self.CurrentTheme].Text
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    messageLabel.ThemeTag = { Text = "Text" }

    table.insert(self.Elements, notification)
    table.insert(self.Elements, titleLabel)
    table.insert(self.Elements, messageLabel)

    self:Tween(notification, {Size = UDim2.new(1, -20, 0, 60 + messageLabel.TextBounds.Y)}, 0.3)
    table.insert(self.Notifications, notification)

    task.delay(duration, function()
        self:Tween(notification, {Position = UDim2.new(0, 10, 0, -100)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
        table.remove(self.Notifications, table.find(self.Notifications, notification))
    end)
end

function UIManager:BindKey(key, callback)
    if self.Keybinds[key] then self.Keybinds[key]:Disconnect() end
    self.Keybinds[key] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == key then callback() end
    end)
end

function UIManager:UnbindKey(key)
    if self.Keybinds[key] then self.Keybinds[key]:Disconnect() end
    self.Keybinds[key] = nil
end

function UIManager:CreateWindow(title)
    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, 450, 0, 550)
    window.Position = UDim2.new(0.5, -225, 0.5, -275)
    window.BackgroundColor3 = THEMES[self.CurrentTheme].Background
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Parent = self.ScreenGui
    window.ThemeTag = { Background = "Background" }

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = window

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = THEMES[self.CurrentTheme].Primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window
    titleBar.ThemeTag = { Background = "Primary" }

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.SemiBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = THEMES[self.CurrentTheme].Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    titleLabel.ThemeTag = { Text = "Text" }

    local closeButton = Instance.new("TextButton")
    closeButton.Text = LUCIDE_ICONS.X
    closeButton.Font = Enum.Font.SemiBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = THEMES[self.CurrentTheme].Text
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.Parent = titleBar
    closeButton.ThemeTag = { Text = "Text" }
    closeButton.MouseButton1Click:Connect(function()
        self:Tween(window, {Size = UDim2.new(0, 450, 0, 0)}, 0.3)
        task.wait(0.3)
        window:Destroy()
    end)

    CreateDraggable(window, titleBar)

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -20, 0, 40)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = window

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -20, 1, -90)
    contentContainer.Position = UDim2.new(0, 10, 0, 90)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = window

    table.insert(self.Windows, window)
    table.insert(self.Elements, window)
    table.insert(self.Elements, titleBar)
    table.insert(self.Elements, titleLabel)
    table.insert(self.Elements, closeButton)

    local windowAPI = {}
    windowAPI.Window = window
    windowAPI.Tabs = {}

    function windowAPI:CreateTab(name, icon)
        icon = LUCIDE_ICONS[icon] or ""
        local tabButton = Instance.new("TextButton")
        tabButton.Text = icon .. " " .. name
        tabButton.Font = Enum.Font.SemiBold
        tabButton.TextSize = 14
        tabButton.TextColor3 = THEMES[self.CurrentTheme].Text
        tabButton.BackgroundColor3 = THEMES[self.CurrentTheme].Secondary
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Position = UDim2.new(0, (#windowAPI.Tabs * 105), 0, 0)
        tabButton.Parent = tabContainer
        tabButton.ThemeTag = { Background = "Secondary", Text = "Text" }

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        tabContent.ScrollBarThickness = 3
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Parent = contentContainer

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.Parent = tabContent

        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(windowAPI.Tabs) do
                tab.Content.Visible = false
                self:Tween(tab.Button, {BackgroundColor3 = THEMES[self.CurrentTheme].Secondary}, 0.2)
            end
            tabContent.Visible = true
            self:Tween(tabButton, {BackgroundColor3 = THEMES[self.CurrentTheme].Primary}, 0.2)
        end)

        if #windowAPI.Tabs == 0 then
            tabContent.Visible = true
            self:Tween(tabButton, {BackgroundColor3 = THEMES[self.CurrentTheme].Primary}, 0.2)
        end

        local tabAPI = {}
        tabAPI.Button = tabButton
        tabAPI.Content = tabContent

        function tabAPI:AddButton(text, callback)
            local button = Instance.new("TextButton")
            button.Text = text
            button.Font = Enum.Font.SemiBold
            button.TextSize = 14
            button.TextColor3 = THEMES[self.CurrentTheme].Text
            button.BackgroundColor3 = THEMES[self.CurrentTheme].Secondary
            button.Size = UDim2.new(1, 0, 0, 35)
            button.Parent = tabContent
            button.ThemeTag = { Background = "Secondary", Text = "Text" }

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = button

            button.MouseButton1Click:Connect(function()
                self:Tween(button, {BackgroundColor3 = THEMES[self.CurrentTheme].Primary}, 0.2)
                task.wait(0.2)
                self:Tween(button, {BackgroundColor3 = THEMES[self.CurrentTheme].Secondary}, 0.2)
                callback()
            end)

            table.insert(self.Elements, button)
            return button
        end

        function tabAPI:AddToggle(text, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 35)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = tabContent

            local toggleButton = Instance.new("TextButton")
            toggleButton.Text = ""
            toggleButton.BackgroundColor3 = THEMES[self.CurrentTheme].Secondary
            toggleButton.Size = UDim2.new(0, 50, 0, 25)
            toggleButton.Position = UDim2.new(1, -55, 0.5, -12.5)
            toggleButton.Parent = toggleFrame
            toggleButton.ThemeTag = { Background = "Secondary" }

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 12)
            UICorner.Parent = toggleButton

            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Size = UDim2.new(0, 21, 0, 21)
            toggleIndicator.Position = UDim2.new(0, 2, 0.5, -10.5)
            toggleIndicator.BackgroundColor3 = THEMES[self.CurrentTheme].Text
            toggleIndicator.Parent = toggleButton
            toggleIndicator.ThemeTag = { Background = "Text" }

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Text = text
            toggleLabel.Font = Enum.Font.SemiBold
            toggleLabel.TextSize = 14
            toggleLabel.TextColor3 = THEMES[self.CurrentTheme].Text
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Size = UDim2.new(1, -60, 1, 0)
            toggleLabel.Position = UDim2.new(0, 0, 0, 0)
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            toggleLabel.ThemeTag = { Text = "Text" }

            local state = default or false
            local function updateToggle()
                if state then
                    self:Tween(toggleIndicator, {Position = UDim2.new(1, -23, 0.5, -10.5)}, 0.2)
                    self:Tween(toggleButton, {BackgroundColor3 = THEMES[self.CurrentTheme].Primary}, 0.2)
                else
                    self:Tween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, -10.5)}, 0.2)
                    self:Tween(toggleButton, {BackgroundColor3 = THEMES[self.CurrentTheme].Secondary}, 0.2)
                end
            end

            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                callback(state)
            end)

            updateToggle()

            table.insert(self.Elements, toggleButton)
            table.insert(self.Elements, toggleIndicator)
            table.insert(self.Elements, toggleLabel)
            return toggleButton
        end

        windowAPI.Tabs[#windowAPI.Tabs + 1] = tabAPI
        return tabAPI
    end

    return windowAPI
end

function UIManager:Destroy()
    for _, tween in pairs(self.ActiveAnimations) do tween:Cancel() end
    for _, connection in pairs(self.Keybinds) do connection:Disconnect() end
    self.ScreenGui:Destroy()
end

return UIManager
