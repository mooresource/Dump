-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    MinMultiplier = 0.5,
    MaxMultiplier = 20,
    DefaultMultiplier = 5,
    StepSize = 0.5,
    OuterTransparency = 0.85,
    CoreTransparency = 0
}

-- State
local BallMultiplier = CONFIG.DefaultMultiplier
local EnhancedBalls = {}
local IsMinimized = false

local COLORS = {
    Window = Color3.fromRGB(212, 208, 200),
    TitleBarActive = Color3.fromRGB(10, 36, 106),
    TitleBarText = Color3.fromRGB(255, 255, 255),
    ButtonFace = Color3.fromRGB(212, 208, 200),
    ButtonHighlight = Color3.fromRGB(255, 255, 255),
    ButtonShadow = Color3.fromRGB(128, 128, 128),
    ButtonDarkShadow = Color3.fromRGB(64, 64, 64),
    ButtonText = Color3.fromRGB(0, 0, 0),
    InputBg = Color3.fromRGB(255, 255, 255),
    SliderTrack = Color3.fromRGB(169, 169, 169),
    SliderFill = Color3.fromRGB(49, 106, 197),
    Highlight = Color3.fromRGB(49, 106, 197),
    HighlightText = Color3.fromRGB(255, 255, 255),
    DividerLight = Color3.fromRGB(255, 255, 255),
    DividerDark = Color3.fromRGB(128, 128, 128),
}

local UI = {}

function UI.CreateBevel(parent, x1, y1, x2, y2, lightColor, darkColor)
    lightColor = lightColor or COLORS.ButtonHighlight
    darkColor = darkColor or COLORS.DividerDark
    
    local bevels = {}
    local positions = {
        {UDim2.new(x1, 0, y1, 0), UDim2.new(x2 - x1, 0, 0, 1)},
        {UDim2.new(x1, 0, y1, 0), UDim2.new(0, 1, y2 - y1, 0)},
        {UDim2.new(x1, 0, y2, -1), UDim2.new(x2 - x1, 0, 0, 1)},
        {UDim2.new(x2, -1, y1, 0), UDim2.new(0, 1, y2 - y1, 0)}
    }
    
    for i, pos in ipairs(positions) do
        local bevel = Instance.new("Frame")
        bevel.Position = pos[1]
        bevel.Size = pos[2]
        bevel.BackgroundColor3 = i <= 2 and lightColor or darkColor
        bevel.BorderSizePixel = 0
        bevel.ZIndex = 1
        bevel.Parent = parent
    end
end

function UI.CreateSunkenBorder(parent)
    local borders = {
        {UDim2.new(0, 1, 0, 1), UDim2.new(1, -2, 0, 1), COLORS.DividerDark},
        {UDim2.new(0, 1, 0, 1), UDim2.new(0, 1, 1, -2), COLORS.DividerDark},
        {UDim2.new(0, 1, 1, -2), UDim2.new(1, -2, 0, 1), COLORS.ButtonHighlight},
        {UDim2.new(1, -2, 0, 1), UDim2.new(0, 1, 1, -2), COLORS.ButtonHighlight}
    }
    
    for _, border in ipairs(borders) do
        local frame = Instance.new("Frame")
        frame.Position = border[1]
        frame.Size = border[2]
        frame.BackgroundColor3 = border[3]
        frame.BorderSizePixel = 0
        frame.ZIndex = 2
        frame.Parent = parent
    end
end

function UI.CreateMainFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ThegxxHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local windowOuter = Instance.new("Frame")
    windowOuter.Name = "WindowOuter"
    windowOuter.Size = UDim2.new(0, 210, 0, 200)
    windowOuter.Position = UDim2.new(0, 10, 0.5, -100)
    windowOuter.BackgroundColor3 = COLORS.DividerDark
    windowOuter.BorderSizePixel = 0
    windowOuter.Active = true
    windowOuter.Draggable = true
    windowOuter.Parent = screenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, -4, 1, -4)
    mainFrame.Position = UDim2.new(0, 2, 0, 2)
    mainFrame.BackgroundColor3 = COLORS.Window
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = windowOuter
    
    UI.CreateBevel(mainFrame, 0, 0, 1, 1, COLORS.ButtonHighlight, COLORS.ButtonShadow)
    
    return screenGui, mainFrame, windowOuter
end

function UI.CreateTitleBar(parent)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -4, 0, 22)
    titleBar.Position = UDim2.new(0, 2, 0, 2)
    titleBar.BackgroundColor3 = COLORS.TitleBarActive
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    titleBar.Parent = parent
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 72, 168)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 36, 106)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 72, 168))
    })
    titleGradient.Parent = titleBar
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 16, 0, 16)
    iconLabel.Position = UDim2.new(0, 3, 0, 3)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "⚽"
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.Font = Enum.Font.SourceSans
    iconLabel.TextSize = 11
    iconLabel.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 22, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Ball Enhancer"
    titleText.TextColor3 = COLORS.TitleBarText
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 11
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Size = UDim2.new(0, 16, 0, 14)
    closeButton.Position = UDim2.new(1, -19, 0, 4)
    closeButton.BackgroundColor3 = COLORS.ButtonFace
    closeButton.BorderSizePixel = 0
    closeButton.Text = ""
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    
    UI.CreateBevel(closeButton, 0, 0, 1, 1)
    
    local closeIcon = Instance.new("TextLabel")
    closeIcon.Size = UDim2.new(1, 0, 1, 0)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Text = "×"
    closeIcon.TextColor3 = COLORS.ButtonText
    closeIcon.Font = Enum.Font.SourceSansBold
    closeIcon.TextSize = 12
    closeIcon.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local windowOuter = parent.Parent
        if not windowOuter then return end
        
        windowOuter.Size = IsMinimized 
            and UDim2.new(0, 210, 0, 26) 
            or UDim2.new(0, 210, 0, 200)
        closeIcon.Text = IsMinimized and "□" or "×"
    end)
    
    return titleBar
end

function UI.CreateLabel(parent, text, yPosition)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 14)
    label.Position = UDim2.new(0, 6, 0, yPosition)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.ButtonText
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

function UI.CreateSliderControl(parent, yPosition, callback)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -12, 0, 70)
    sliderContainer.Position = UDim2.new(0, 6, 0, yPosition)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent
    
    local groupBox = Instance.new("Frame")
    groupBox.Size = UDim2.new(1, -2, 1, -2)
    groupBox.Position = UDim2.new(0, 1, 0, 1)
    groupBox.BackgroundColor3 = COLORS.Window
    groupBox.BorderSizePixel = 0
    groupBox.Parent = sliderContainer
    UI.CreateSunkenBorder(groupBox)
    
    local valueDisplay = Instance.new("Frame")
    valueDisplay.Name = "ValueDisplay"
    valueDisplay.Size = UDim2.new(1, -12, 0, 20)
    valueDisplay.Position = UDim2.new(0, 6, 0, 8)
    valueDisplay.BackgroundColor3 = COLORS.InputBg
    valueDisplay.BorderSizePixel = 0
    valueDisplay.Parent = groupBox
    UI.CreateSunkenBorder(valueDisplay)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(1, -4, 1, -4)
    valueLabel.Position = UDim2.new(0, 2, 0, 2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("Size: %.1fx", BallMultiplier)
    valueLabel.TextColor3 = COLORS.ButtonText
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 11
    valueLabel.ZIndex = 3
    valueLabel.Parent = valueDisplay
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, -12, 0, 6)
    sliderTrack.Position = UDim2.new(0, 6, 0, 36)
    sliderTrack.BackgroundColor3 = COLORS.Window
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = groupBox
    UI.CreateSunkenBorder(sliderTrack)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0, 0, 1, -2)
    sliderFill.Position = UDim2.new(0, 1, 0, 1)
    sliderFill.BackgroundColor3 = COLORS.Highlight
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 3
    sliderFill.Parent = sliderTrack
    
    local sliderThumb = Instance.new("TextButton")
    sliderThumb.Name = "SliderThumb"
    sliderThumb.Size = UDim2.new(0, 24, 0, 20)
    sliderThumb.Position = UDim2.new(0.5, -12, 0, -7)
    sliderThumb.BackgroundColor3 = COLORS.ButtonFace
    sliderThumb.BorderSizePixel = 0
    sliderThumb.Text = ""
    sliderThumb.AutoButtonColor = false
    sliderThumb.ZIndex = 4
    sliderThumb.Parent = sliderTrack
    UI.CreateBevel(sliderThumb, 0, 0, 1, 1)
    
    for i = 0, 2 do
        local gripLine = Instance.new("Frame")
        gripLine.Size = UDim2.new(0, 1, 0, 10)
        gripLine.Position = UDim2.new(0, 9 + (i * 3), 0.5, -5)
        gripLine.BackgroundColor3 = COLORS.ButtonShadow
        gripLine.BorderSizePixel = 0
        gripLine.ZIndex = 5
        gripLine.Parent = sliderThumb
    end
    
    local function createEndpointLabel(text, xAlignment)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 40, 0, 14)
        label.Position = UDim2.new(xAlignment == Enum.TextXAlignment.Left and 0 or 1, xAlignment == Enum.TextXAlignment.Left and 4 or -44, 0, 52)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = COLORS.ButtonShadow
        label.Font = Enum.Font.SourceSans
        label.TextSize = 9
        label.TextXAlignment = xAlignment
        label.Parent = groupBox
    end
    
    createEndpointLabel(string.format("%.1f", CONFIG.MinMultiplier), Enum.TextXAlignment.Left)
    createEndpointLabel(string.format("%.1f", CONFIG.MaxMultiplier), Enum.TextXAlignment.Right)
    
    local function updateSlider(value)
        local percent = (value - CONFIG.MinMultiplier) / (CONFIG.MaxMultiplier - CONFIG.MinMultiplier)
        sliderThumb.Position = UDim2.new(percent, -12, 0, -7)
        sliderFill.Size = UDim2.new(percent, 1, 1, -2)
        valueLabel.Text = string.format("Size: %.1fx", value)
    end
    
    updateSlider(BallMultiplier)
    
    local dragging = false
    
    local function updateFromPosition(inputX)
        local trackWidth = sliderTrack.AbsoluteSize.X
        local relativeX = math.clamp(inputX - sliderTrack.AbsolutePosition.X, 0, trackWidth)
        local percent = relativeX / trackWidth
        
        local rawValue = CONFIG.MinMultiplier + (percent * (CONFIG.MaxMultiplier - CONFIG.MinMultiplier))
        local snappedValue = math.clamp(
            math.floor(rawValue / CONFIG.StepSize + 0.5) * CONFIG.StepSize,
            CONFIG.MinMultiplier,
            CONFIG.MaxMultiplier
        )
        
        BallMultiplier = snappedValue
        updateSlider(BallMultiplier)
        callback(BallMultiplier)
    end
    
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateFromPosition(input.Position.X)
            end
        end
    end
    
    sliderThumb.InputBegan:Connect(onInputBegan)
    sliderTrack.InputBegan:Connect(onInputBegan)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPosition(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return sliderContainer
end

function UI.CreateButton(parent, text, yPosition, callback)
    local buttonBorder = Instance.new("Frame")
    buttonBorder.Size = UDim2.new(1, -12, 0, 24)
    buttonBorder.Position = UDim2.new(0, 6, 0, yPosition)
    buttonBorder.BackgroundColor3 = COLORS.DividerDark
    buttonBorder.BorderSizePixel = 0
    buttonBorder.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -2, 1, -2)
    button.Position = UDim2.new(0, 1, 0, 1)
    button.BackgroundColor3 = COLORS.ButtonFace
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = buttonBorder
    
    UI.CreateBevel(button, 0, 0, 1, 1)
    
    local buttonText = Instance.new("TextLabel")
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = text
    buttonText.TextColor3 = COLORS.ButtonText
    buttonText.Font = Enum.Font.SourceSans
    buttonText.TextSize = 11
    buttonText.ZIndex = 3
    buttonText.Parent = button
    
    local function setButtonState(pressed)
        button.BackgroundColor3 = pressed and COLORS.ButtonShadow or COLORS.ButtonFace
        UI.CreateBevel(button, 0, 0, 1, 1, pressed and COLORS.DividerDark or COLORS.ButtonHighlight, pressed and COLORS.ButtonHighlight or COLORS.ButtonShadow)
        buttonText.Position = pressed and UDim2.new(0, 1, 0, 1) or UDim2.new(0, 0, 0, 0)
    end
    
    button.MouseButton1Down:Connect(function() setButtonState(true) end)
    button.MouseButton1Up:Connect(function() setButtonState(false) end)
    button.MouseButton1Click:Connect(function()
        setButtonState(false)
        callback()
    end)
    
    return button
end

function UI.CreateStatusBar(parent)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -4, 0, 18)
    statusBar.Position = UDim2.new(0, 2, 1, -20)
    statusBar.BackgroundColor3 = COLORS.Window
    statusBar.BorderSizePixel = 0
    statusBar.Parent = parent
    
    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.BackgroundColor3 = COLORS.DividerDark
    topLine.BorderSizePixel = 0
    topLine.Parent = statusBar
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -8, 1, -2)
    statusText.Position = UDim2.new(0, 4, 0, 1)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Ready"
    statusText.TextColor3 = COLORS.ButtonText
    statusText.Font = Enum.Font.SourceSans
    statusText.TextSize = 10
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Name = "StatusText"
    statusText.Parent = statusBar
    
    return statusText
end

local BallEnhancer = {}

function BallEnhancer.Enhance(ballModel, multiplier)
    if not ballModel or not ballModel:IsA('Model') then return end
    if not ballModel.Name:match('^CLIENT_BALL_%d+$') then return end
    
    local ballPart = ballModel:FindFirstChild('Ball.001') or ballModel:FindFirstChildWhichIsA('BasePart')
    if not ballPart then return end
    
    local data = EnhancedBalls[ballModel]
    if not data then
        EnhancedBalls[ballModel] = { Part = ballPart }
        data = EnhancedBalls[ballModel]
    end
    
    if data.CoreSphere and data.CoreSphere.Parent then
        data.CoreSphere:Destroy()
    end
    
    ballPart.Size = Vector3.new(2, 2, 2) * multiplier
    ballPart.Transparency = CONFIG.OuterTransparency
    ballPart.Material = Enum.Material.Glass
    ballPart.BrickColor = BrickColor.new("Bright blue")
    
    local coreSphere = Instance.new("Part")
    coreSphere.Name = "CoreSphere"
    coreSphere.Shape = Enum.PartType.Ball
    coreSphere.Size = Vector3.new(2, 2, 2)
    coreSphere.Position = ballPart.Position
    coreSphere.Anchored = true
    coreSphere.CanCollide = false
    coreSphere.Material = Enum.Material.Neon
    coreSphere.BrickColor = BrickColor.new("Bright red")
    coreSphere.Transparency = CONFIG.CoreTransparency
    coreSphere.Parent = ballPart
    
    data.CoreSphere = coreSphere
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ballPart
    weld.Part1 = coreSphere
    weld.Parent = coreSphere
end

function BallEnhancer.UpdateAll(multiplier)
    for ballModel, _ in pairs(EnhancedBalls) do
        if ballModel and ballModel.Parent then
            BallEnhancer.Enhance(ballModel, multiplier)
        else
            EnhancedBalls[ballModel] = nil
        end
    end
end

function BallEnhancer.Refresh(multiplier)
    EnhancedBalls = {}
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA('Model') and model.Name:match('^CLIENT_BALL_%d+$') then
            BallEnhancer.Enhance(model, multiplier)
        end
    end
end

function BallEnhancer.Clear()
    for _, data in pairs(EnhancedBalls) do
        local ballPart = data.Part
        if ballPart and ballPart.Parent then
            ballPart.Size = Vector3.new(2, 2, 2)
            ballPart.Transparency = 0
            ballPart.Material = Enum.Material.Plastic
            
            if data.CoreSphere and data.CoreSphere.Parent then
                data.CoreSphere:Destroy()
            end
        end
    end
    EnhancedBalls = {}
end

local function Initialize()
    local oldGui = LocalPlayer.PlayerGui:FindFirstChild("ThegxxHub")
    if oldGui then oldGui:Destroy() end
    
    local _, mainFrame = UI.CreateMainFrame()
    UI.CreateTitleBar(mainFrame)
    
    UI.CreateSliderControl(mainFrame, 26, function(value)
        BallEnhancer.UpdateAll(value)
    end)
    
    UI.CreateButton(mainFrame, "Refresh Balls", 104, function()
        local statusText = mainFrame:FindFirstChild("StatusText", true)
        if statusText then statusText.Text = "Refreshing balls..." end
        BallEnhancer.Refresh(BallMultiplier)
        if statusText then statusText.Text = "Ready" end
    end)
    
    UI.CreateButton(mainFrame, "Reset Balls", 136, function()
        local statusText = mainFrame:FindFirstChild("StatusText", true)
        if statusText then statusText.Text = "Resetting balls..." end
        BallEnhancer.Clear()
        if statusText then statusText.Text = "Ready" end
    end)
    
    UI.CreateStatusBar(mainFrame)
    
    Workspace.ChildAdded:Connect(function(child)
        if child:IsA('Model') and child.Name:match('^CLIENT_BALL_%d+$') then
            task.wait(0.2)
            BallEnhancer.Enhance(child, BallMultiplier)
        end
    end)
    
    BallEnhancer.Refresh(BallMultiplier)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Initialize()
end)

Initialize()
