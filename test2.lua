local UIManager = {}
UIManager.__index = UIManager

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LUCIDE_ICONS = {
    Check = "✓", Heart = "❤", Alert = "⚠", Lock = "🔒", Key = "🔑", 
    Settings = "⚙", Star = "★", Trash = "🗑", Plus = "+", Minus = "-"
}

local THEMES = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 40),
        Primary = Color3.fromRGB(70, 130, 200),
        Secondary = Color3.fromRGB(50, 50, 60),
        Text = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(255, 170, 0)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Primary = Color3.fromRGB(50, 120, 220),
        Secondary = Color3.fromRGB(220, 220, 230),
        Text = Color3.fromRGB(30, 30, 40),
        Accent = Color3.fromRGB(220, 90, 50)
    }
}

function UIManager.new()
    local self = setmetatable({}, UIManager)
    self.CurrentTheme = "Dark"
    self.Windows = {}
    self.Notifications = {}
    self.Keybinds = {}
    self.ActiveAnimations = {}

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UIManager_" .. HttpService:GenerateGUID(false)
    self.ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui.ResetOnSpawn = false

    self.NotificationFrame = Instance.new("Frame")
    self.NotificationFrame.Size = UDim2.new(0.3, 0, 0, 0)
    self.NotificationFrame.Position = UDim2.new(0.7, 0, 0.05, 0)
    self.NotificationFrame.BackgroundTransparency = 1
    self.NotificationFrame.Parent = self.ScreenGui

    self:SetTheme("Dark")

    return self
end

function UIManager:UpdateTheme(element)
    local theme = THEMES[self.CurrentTheme]
    if element:IsA("GuiObject") then
        if element:IsA("TextLabel") or element:IsA("TextButton") then
            element.TextColor3 = theme.Text
        else
            if element.Name == "PrimaryElement" then
                element.BackgroundColor3 = theme.Primary
            elseif element.Name == "SecondaryElement" then
                element.BackgroundColor3 = theme.Secondary
            else
                element.BackgroundColor3 = theme.Background
            end
        end
    end
end

function UIManager:SetTheme(themeName)
    if not THEMES[themeName] then return end
    self.CurrentTheme = themeName
    for _, window in pairs(self.Windows) do
        for _, descendant in pairs(window:GetDescendants()) do
            self:UpdateTheme(descendant)
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
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, -20, 0, 80)
    notification.Position = UDim2.new(0, 10, 0, #self.Notifications * 85)
    notification.BackgroundColor3 = THEMES[self.CurrentTheme].Secondary
    notification.BorderSizePixel = 0
    notification.Parent = self.NotificationFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = icon .. "  " .. title
    titleLabel.Font = Enum.Font.SemiBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = THEMES[self.CurrentTheme].Text
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.Regular
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.Size = UDim2.new(1, -30, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = THEMES[self.CurrentTheme].Text
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification

    self:Tween(notification, {Position = UDim2.new(0, 10, 0, #self.Notifications * 85)}, 0.3)
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

function UIManager:CreateWindow(title)
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 400, 0, 500)
    window.Position = UDim2.new(0.5, -200, 0.5, -250)
    window.BackgroundColor3 = THEMES[self.CurrentTheme].Background
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Parent = self.ScreenGui

    local titleBar = Instance.new("Frame")
    titleBar.Name = "PrimaryElement"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = THEMES[self.CurrentTheme].Primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.SemiBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = THEMES[self.CurrentTheme].Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    table.insert(self.Windows, window)
    return window
end

function UIManager:Destroy()
    for _, tween in pairs(self.ActiveAnimations) do
        tween:Cancel()
    end
    for _, connection in pairs(self.Keybinds) do
        connection:Disconnect()
    end
    self.ScreenGui:Destroy()
end

return UIManager
