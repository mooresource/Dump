-- Section 1: Services
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui"),
    TeleportService = game:GetService("TeleportService"),
    UserInputService = game:GetService("UserInputService"),
    StarterGui = game:GetService("StarterGui"),
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

local CONFIG = {
    SaveFile = "MirageLib_config",
    UIKey = Enum.KeyCode.K,
    Theme = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(240, 240, 240),
        Border = Color3.fromRGB(60, 60, 70)
    }
}

-- Section 2: UI Library
local SimpleUI = {
    Enabled = true,
    MainFrame = nil,
    Tabs = {},
    CurrentTab = nil,
    Config = {}
}

function SimpleUI:LoadConfig()
    local success, data = pcall(function()
        return Services.HttpService:JSONDecode(readfile(CONFIG.SaveFile .. ".json"))
    end)
    if success then
        self.Config = data
    end
end

function SimpleUI:SaveConfig()
    pcall(function()
        writefile(CONFIG.SaveFile .. ".json", Services.HttpService:JSONEncode(self.Config))
    end)
end

function SimpleUI:CreateWindow()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MirageLib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = Services.CoreGui

    -- Main container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = CONFIG.Theme.Background
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Size = UDim2.new(1, 0, 1, 0)
    DropShadow.Position = UDim2.new(0, 0, 0, 0)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://6014261993"
    DropShadow.ImageColor3 = Color3.new(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.Parent = MainFrame

    -- Title bar with improved design
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = CONFIG.Theme.Secondary
    TitleBar.BorderSizePixel = 0
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MirageLib"
    Title.TextColor3 = CONFIG.Theme.Accent
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
    CloseButton.BackgroundColor3 = CONFIG.Theme.Secondary
    CloseButton.Text = "×"
    CloseButton.TextColor3 = CONFIG.Theme.Text
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        CloseButton.BackgroundColor3 = CONFIG.Theme.Secondary
    end)
    
    CloseButton.Parent = TitleBar

    -- Tab container with better layout
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 0, 36)
    TabContainer.Position = UDim2.new(0, 10, 0, 44)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    -- Content container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, -20, 1, -100)
    ContentContainer.Position = UDim2.new(0, 10, 0, 88)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = CONFIG.Theme.Accent
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentContainer.Parent = MainFrame

    -- Assemble
    TitleBar.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    self.MainFrame = MainFrame
    self.TabContainer = TabContainer
    self.ContentContainer = ContentContainer
    self.ScreenGui = ScreenGui
    
    -- Load config
    self:LoadConfig()
    
    -- Toggle hotkey
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == CONFIG.UIKey then
            self:Toggle()
        end
    end)
    
    return self
end

function SimpleUI:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Size = UDim2.new(0.33, -5, 1, 0)
    TabButton.BackgroundColor3 = CONFIG.Theme.Secondary
    TabButton.BackgroundTransparency = 0.8
    TabButton.Text = name
    TabButton.TextColor3 = CONFIG.Theme.Text
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.AutoButtonColor = false
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = TabButton
    
    -- Position button
    local tabCount = #self.Tabs + 1
    TabButton.Position = UDim2.new((tabCount - 1) * 0.33, (tabCount - 1) * 5, 0, 0)
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = TabContent
    
    local tab = {
        Button = TabButton,
        Content = TabContent,
        Elements = {},
        Layout = UIListLayout
    }
    
    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    TabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            Services.TweenService:Create(TabButton, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.6,
                TextColor3 = CONFIG.Theme.Accent
            }):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            Services.TweenService:Create(TabButton, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.8,
                TextColor3 = CONFIG.Theme.Text
            }):Play()
        end
    end)
    
    TabButton.Parent = self.TabContainer
    table.insert(self.Tabs, tab)
    
    -- Set as first tab if none selected
    if not self.CurrentTab then
        self:SwitchTab(name)
    end
    
    return tab
end

function SimpleUI:SwitchTab(name)
    for _, tab in ipairs(self.Tabs) do
        local isActive = tab.Button.Name == name
        
        if isActive then
            tab.Content.Visible = true
            Services.TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                TextColor3 = CONFIG.Theme.Accent
            }):Play()
        else
            tab.Content.Visible = false
            Services.TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.8,
                TextColor3 = CONFIG.Theme.Text
            }):Play()
        end
    end
    
    self.CurrentTab = name
end

function SimpleUI:Toggle()
    self.Enabled = not self.Enabled
    self.MainFrame.Visible = self.Enabled
    
    if self.Enabled then
        Services.UserInputService.MouseIconEnabled = true
    end
end

function SimpleUI:CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 36)
    Section.BackgroundColor3 = CONFIG.Theme.Secondary
    Section.BackgroundTransparency = 0.95
    Section.LayoutOrder = #parent:GetChildren()
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = Section
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = CONFIG.Theme.Accent
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamSemibold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Section
    
    Section.Parent = parent
    
    return Section
end

function SimpleUI:CreateToggle(parent, config)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 28)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = #parent:GetChildren()
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 46, 0, 22)
    ToggleButton.Position = UDim2.new(1, -46, 0.5, -11)
    ToggleButton.BackgroundColor3 = config.CurrentValue and CONFIG.Theme.Accent or CONFIG.Theme.Secondary
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Name = "Dot"
    ToggleDot.Size = UDim2.new(0, 14, 0, 14)
    ToggleDot.Position = UDim2.new(config.CurrentValue and 0.5 or 0, config.CurrentValue and 5 or 3, 0.5, -7)
    ToggleDot.BackgroundColor3 = CONFIG.Theme.Text
    ToggleDot.BorderSizePixel = 0
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = ToggleDot
    
    ToggleDot.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        config.CurrentValue = not config.CurrentValue
        config.Callback(config.CurrentValue)
        
        Services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = config.CurrentValue and CONFIG.Theme.Accent or CONFIG.Theme.Secondary
        }):Play()
        
        Services.TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
            Position = UDim2.new(config.CurrentValue and 0.5 or 0, config.CurrentValue and 5 or 3, 0.5, -7)
        }):Play()
        
        if config.Flag then
            self.Config[config.Flag] = config.CurrentValue
            self:SaveConfig()
        end
    end)
    
    if config.Flag and self.Config[config.Flag] ~= nil then
        config.CurrentValue = self.Config[config.Flag]
        ToggleButton.BackgroundColor3 = config.CurrentValue and CONFIG.Theme.Accent or CONFIG.Theme.Secondary
        ToggleDot.Position = UDim2.new(config.CurrentValue and 0.5 or 0, config.CurrentValue and 5 or 3, 0.5, -7)
    end
    
    ToggleButton.Parent = ToggleFrame
    ToggleFrame.Parent = parent
    
    return ToggleFrame
end

function SimpleUI:CreateSlider(parent, config)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 46)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = #parent:GetChildren()
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name .. ": " .. config.CurrentValue .. config.Suffix
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, 0, 0, 4)
    Track.Position = UDim2.new(0, 0, 0, 26)
    Track.BackgroundColor3 = CONFIG.Theme.Secondary
    Track.BorderSizePixel = 0
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new((config.CurrentValue - config.Range[1]) / (config.Range[2] - config.Range[1]), 0, 1, 0)
    Fill.Position = UDim2.new(0, 0, 0, 0)
    Fill.BackgroundColor3 = CONFIG.Theme.Accent
    Fill.BorderSizePixel = 0
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    Fill.Parent = Track
    
    local Handle = Instance.new("TextButton")
    Handle.Name = "Handle"
    Handle.Size = UDim2.new(0, 14, 0, 14)
    Handle.Position = UDim2.new(Fill.Size.X.Scale, -7, 0.5, -7)
    Handle.BackgroundColor3 = CONFIG.Theme.Text
    Handle.Text = ""
    Handle.AutoButtonColor = false
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(1, 0)
    HandleCorner.Parent = Handle
    
    local dragging = false
    
    Handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = Services.UserInputService:GetMouseLocation()
            local trackPos = Track.AbsolutePosition
            local trackSize = Track.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
            local value = config.Range[1] + (relativeX * (config.Range[2] - config.Range[1]))
            value = math.floor(value / config.Increment) * config.Increment
            
            config.CurrentValue = value
            Label.Text = config.Name .. ": " .. string.format("%.1f", value) .. config.Suffix
            Fill.Size = UDim2.new(relativeX, 0, 1, 0)
            Handle.Position = UDim2.new(relativeX, -7, 0.5, -7)
            
            config.Callback(value)
            
            if config.Flag then
                self.Config[config.Flag] = value
                self:SaveConfig()
            end
        end
    end)
    
    if config.Flag and self.Config[config.Flag] ~= nil then
        config.CurrentValue = self.Config[config.Flag]
        local relativeX = (config.CurrentValue - config.Range[1]) / (config.Range[2] - config.Range[1])
        Label.Text = config.Name .. ": " .. string.format("%.1f", config.CurrentValue) .. config.Suffix
        Fill.Size = UDim2.new(relativeX, 0, 1, 0)
        Handle.Position = UDim2.new(relativeX, -7, 0.5, -7)
    end
    
    Track.Parent = SliderFrame
    Handle.Parent = SliderFrame
    SliderFrame.Parent = parent
    
    return SliderFrame
end

function SimpleUI:CreateButton(parent, config)
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Name = "Button"
    ButtonFrame.Size = UDim2.new(1, 0, 0, 32)
    ButtonFrame.BackgroundColor3 = CONFIG.Theme.Accent
    ButtonFrame.BackgroundTransparency = 0.8
    ButtonFrame.Text = config.Name
    ButtonFrame.TextColor3 = CONFIG.Theme.Text
    ButtonFrame.TextSize = 13
    ButtonFrame.Font = Enum.Font.GothamSemibold
    ButtonFrame.AutoButtonColor = false
    ButtonFrame.LayoutOrder = #parent:GetChildren()
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ButtonFrame
    
    ButtonFrame.MouseButton1Click:Connect(function()
        config.Callback()
    end)
    
    ButtonFrame.MouseEnter:Connect(function()
        Services.TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        Services.TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)
    
    ButtonFrame.Parent = parent
    
    return ButtonFrame
end

function SimpleUI:Notify(title, content)
    warn("MirageLib: " .. title .. " - " .. content)
end

-- Section 3: Visual Module (Contains Clone ESP)
local VisualModule = {
    -- Clone ESP settings
    CloneESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Folder = nil,
        Clones = {},
        RenderConnection = nil
    },
    
    -- ESP Settings
    LinesEnabled = true,
    LineDistance = 50,
    MaxLines = 6,
    Beams = {},
    
    -- Jump ESP
    JumpESPEnabled = true,
    JumpHighlights = {}
}

local VALID_BODY_PARTS = {
    Head = true, Torso = true, UpperTorso = true, LowerTorso = true,
    LeftArm = true, RightArm = true, LeftUpperArm = true, RightUpperArm = true,
    LeftLowerArm = true, RightLowerArm = true, LeftHand = true, RightHand = true,
    LeftLeg = true, RightLeg = true, LeftUpperLeg = true, RightUpperLeg = true,
    LeftLowerLeg = true, RightLowerLeg = true, LeftFoot = true, RightFoot = true,
    HumanoidRootPart = true
}

function VisualModule:CloneESPCleanup()
    if self.CloneESP.RenderConnection then
        self.CloneESP.RenderConnection:Disconnect()
        self.CloneESP.RenderConnection = nil
    end
    
    if self.CloneESP.Folder then
        self.CloneESP.Folder:Destroy()
        self.CloneESP.Folder = nil
    end
    
    self.CloneESP.Clones = {}
end

function VisualModule:CreateCloneESP(character)
    if not character or not self.CloneESP.Enabled then return end
    
    self:CloneESPCleanup()
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    self.CloneESP.Folder = Instance.new("Folder")
    self.CloneESP.Folder.Name = "ESP_Clones"
    self.CloneESP.Folder.Parent = Camera
    
    for _, part in ipairs(character:GetChildren()) do
        if (part:IsA("Part") or part:IsA("MeshPart")) and VALID_BODY_PARTS[part.Name] then
            local clone = part:Clone()
            clone.Anchored = true
            clone.CanCollide = false
            clone.CanTouch = false
            clone.CanQuery = false
            clone.Parent = self.CloneESP.Folder
            
            clone.Material = part.Material
            clone.Transparency = part.Transparency + 0.3
            clone.Color = self.CloneESP.Color
            
            for _, child in ipairs(clone:GetChildren()) do
                if child:IsA("Script") or child:IsA("Motor6D") then child:Destroy() end
            end
            
            self.CloneESP.Clones[part] = clone
        end
    end
    
    self.CloneESP.RenderConnection = Services.RunService.RenderStepped:Connect(function()
        if not character or not character.Parent or not hrp then
            self:CloneESPCleanup()
            return
        end
        
        local camLook = Camera.CFrame.LookVector
        local horizontalLook = Vector3.new(camLook.X, 0, camLook.Z)
        if horizontalLook.Magnitude > 0 then
            horizontalLook = horizontalLook.Unit
        else
            horizontalLook = Vector3.new(0, 0, 1)
        end
        
        local espPos = hrp.Position - horizontalLook * 5
        local espCFrame = CFrame.new(espPos, espPos + horizontalLook)
        
        for originalPart, clone in pairs(self.CloneESP.Clones) do
            if originalPart and originalPart:IsDescendantOf(character) and clone and clone.Parent then
                local success, relativeCFrame = pcall(function()
                    return hrp.CFrame:ToObjectSpace(originalPart.CFrame)
                end)
                
                if success then
                    clone.CFrame = espCFrame * relativeCFrame
                    clone.Color = self.CloneESP.Color
                    clone.Material = originalPart.Material
                    clone.Transparency = originalPart.Transparency + 0.3
                end
            end
        end
    end)
end

function VisualModule:CreateBeamForPlayer(player, index)
    if self.Beams[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    local colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(128, 0, 128), Color3.fromRGB(255, 255, 0)
    }
    
    local startAtt = Instance.new("Attachment", head)
    local targetPart = Instance.new("Part")
    targetPart.Anchored = true
    targetPart.CanCollide = false
    targetPart.Transparency = 1
    targetPart.Size = Vector3.new(0.1, 0.1, 0.1)
    targetPart.Parent = Services.Workspace
    local endAtt = Instance.new("Attachment", targetPart)
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = startAtt
    beam.Attachment1 = endAtt
    beam.Width0 = 0.25
    beam.Width1 = 0.25
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(0.3)
    beam.Color = ColorSequence.new(colors[(index - 1) % #colors + 1])
    beam.Parent = head
    
    self.Beams[player] = { beam = beam, target = targetPart, attachment = startAtt }
end

function VisualModule:UpdateLinePosition(player)
    local data = self.Beams[player]
    if not data then return end
    
    local character = player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if head and hrp and data.target then
        data.target.Position = head.Position + hrp.CFrame.LookVector * self.LineDistance
    end
end

function VisualModule:ClearLine(player)
    local data = self.Beams[player]
    if not data then return end
    
    if data.beam then data.beam:Destroy() end
    if data.target then data.target:Destroy() end
    if data.attachment then data.attachment:Destroy() end
    
    self.Beams[player] = nil
end

function VisualModule:IsEnemy(player)
    return player ~= LocalPlayer and 
           player.Team and LocalPlayer.Team and 
           player.Team ~= LocalPlayer.Team
end

function VisualModule:CreateJumpESP(player)
    if not player.Character or self.JumpHighlights[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "JumpESP"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    
    self.JumpHighlights[player] = highlight
end

function VisualModule:RemoveJumpESP(player)
    if self.JumpHighlights[player] then
        self.JumpHighlights[player]:Destroy()
        self.JumpHighlights[player] = nil
    end
end

function VisualModule:SetupPlayerJumpESP(player)
    if player == LocalPlayer then return end
    
    local function MonitorCharacter(character)
        local humanoid = character:WaitForChild("Humanoid", 3)
        if not humanoid then return end
        
        humanoid.StateChanged:Connect(function(_, newState)
            if not self.JumpESPEnabled then return end
            
            if self:IsEnemy(player) then
                if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
                    self:CreateJumpESP(player)
                elseif newState == Enum.HumanoidStateType.Landed then
                    self:RemoveJumpESP(player)
                end
            end
        end)
    end
    
    if player.Character then MonitorCharacter(player.Character) end
    player.CharacterAdded:Connect(MonitorCharacter)
end

function VisualModule:SetupListeners()
    Services.RunService.RenderStepped:Connect(function()
        if self.LinesEnabled then
            local enemies = {}
            for _, player in ipairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                    table.insert(enemies, player)
                end
            end
            
            for i = 1, math.min(#enemies, self.MaxLines) do
                local player = enemies[i]
                if not self.Beams[player] then self:CreateBeamForPlayer(player, i) end
                self:UpdateLinePosition(player)
            end
            
            for player in pairs(self.Beams) do
                if not table.find(enemies, player) then self:ClearLine(player) end
            end
        end
    end)
    
    Services.Players.PlayerRemoving:Connect(function(player)
        self:ClearLine(player)
        self:RemoveJumpESP(player)
    end)
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        self:SetupPlayerJumpESP(player)
    end
    
    Services.Players.PlayerAdded:Connect(function(player)
        self:SetupPlayerJumpESP(player)
    end)
end

function VisualModule:Initialize(tab)
    local parent = tab.Content
    
    SimpleUI:CreateSection(parent, "Clone ESP")
    
    SimpleUI:CreateToggle(parent, {
        Name = "Enable Clone ESP",
        CurrentValue = self.CloneESP.Enabled,
        Flag = "CloneESP_Toggle",
        Callback = function(val)
            self.CloneESP.Enabled = val
            if val then
                if LocalPlayer.Character then self:CreateCloneESP(LocalPlayer.Character) end
            else
                self:CloneESPCleanup()
            end
        end
    })
    
    SimpleUI:CreateButton(parent, {
        Name = "Color: White",
        Callback = function()
            self.CloneESP.Color = Color3.fromRGB(255, 255, 255)
            for _, clone in pairs(self.CloneESP.Clones) do
                if clone and clone:IsA("BasePart") then clone.Color = self.CloneESP.Color end
            end
        end
    })
    
    SimpleUI:CreateSection(parent, "Direction Lines")
    
    SimpleUI:CreateToggle(parent, {
        Name = "Show Direction Lines",
        CurrentValue = self.LinesEnabled,
        Flag = "LinesEnabled",
        Callback = function(val)
            self.LinesEnabled = val
            if not val then
                for player, data in pairs(self.Beams) do self:ClearLine(player) end
            end
        end
    })
    
    SimpleUI:CreateSlider(parent, {
        Name = "Line Distance",
        Range = {10, 100},
        Increment = 10,
        CurrentValue = self.LineDistance,
        Suffix = " studs",
        Flag = "LineDistance",
        Callback = function(val) self.LineDistance = val end
    })
    
    SimpleUI:CreateSection(parent, "Enemy Detection")
    
    SimpleUI:CreateToggle(parent, {
        Name = "Jump ESP Highlight",
        CurrentValue = self.JumpESPEnabled,
        Flag = "JumpESPEnabled",
        Callback = function(val)
            self.JumpESPEnabled = val
            if not val then
                for player in pairs(self.JumpHighlights) do self:RemoveJumpESP(player) end
            end
        end
    })
    
    self:SetupListeners()
end

-- Section 4: Character Module (Movement only)
local CharacterModule = {
    DirectionalJump = true,
    AutoSteer = true,
    AirMovement = false,
    AirMoveSpeed = 50,
    IsJumping = false,
    
    Humanoid = nil,
    HRP = nil
}

function CharacterModule:SetupCharacter(character)
    self.Humanoid = character:WaitForChild("Humanoid")
    self.HRP = character:WaitForChild("HumanoidRootPart")
    
    self.Humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Landed then 
            self.Humanoid.AutoRotate = true 
        end
    end)
end

function CharacterModule:SetupCharacterListeners()
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        self:SetupCharacter(char)
    end)
    
    Services.UserInputService.JumpRequest:Connect(function()
        if self.DirectionalJump and self.Humanoid and self.HRP then
            task.defer(function()
                task.wait(0.03)
                local dir = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                if dir.Magnitude > 0 then
                    self.HRP.CFrame = CFrame.lookAt(self.HRP.Position, self.HRP.Position + dir.Unit)
                    self.Humanoid.AutoRotate = false
                end
            end)
        elseif self.Humanoid then
            self.Humanoid.AutoRotate = true
        end
    end)
    
    Services.RunService.Stepped:Connect(function()
        if self.Humanoid then
            local state = self.Humanoid:GetState()
            self.IsJumping = (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall)
            
            -- Auto steer when moving
            if self.AutoSteer and not self.IsJumping and self.Humanoid.MoveDirection.Magnitude > 0 then
                local moveDir = Vector3.new(self.Humanoid.MoveDirection.X, 0, self.Humanoid.MoveDirection.Z)
                if moveDir.Magnitude > 0 then
                    self.Humanoid.AutoRotate = true
                end
            end
        end
    end)
    
    Services.RunService.RenderStepped:Connect(function()
        if self.AirMovement and self.IsJumping and self.Humanoid and self.HRP then
            local moveDir = self.Humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                self.HRP.Velocity = Vector3.new(
                    moveDir.X * self.AirMoveSpeed,
                    self.HRP.Velocity.Y,
                    moveDir.Z * self.AirMoveSpeed
                )
            end
        end
    end)
end

function CharacterModule:Initialize(tab)
    self.Humanoid = nil
    self.HRP = nil
    
    local parent = tab.Content
    SimpleUI:CreateSection(parent, "Movement")
    
    SimpleUI:CreateToggle(parent, {
        Name = "Directional Jump",
        CurrentValue = self.DirectionalJump,
        Flag = "DirectionalJump",
        Callback = function(val)
            self.DirectionalJump = val
            if not val and self.Humanoid then self.Humanoid.AutoRotate = true end
        end
    })
    
    SimpleUI:CreateToggle(parent, {
        Name = "Auto Steer",
        CurrentValue = self.AutoSteer,
        Flag = "AutoSteer",
        Callback = function(val)
            self.AutoSteer = val
            if val and self.Humanoid then self.Humanoid.AutoRotate = true end
        end
    })
    
    SimpleUI:CreateToggle(parent, {
        Name = "Air Movement",
        CurrentValue = self.AirMovement,
        Flag = "AirMoveToggle",
        Callback = function(val) self.AirMovement = val end
    })
    
    SimpleUI:CreateSlider(parent, {
        Name = "Air Move Speed",
        Range = {10, 150},
        Increment = 5,
        Suffix = "studs/s",
        CurrentValue = self.AirMoveSpeed,
        Flag = "AirMoveSpeed",
        Callback = function(val) self.AirMoveSpeed = val end
    })
    
    SimpleUI:CreateSection(parent, "Info")
    
    SimpleUI:CreateButton(parent, {
        Name = "How to use: Turn off shift-lock",
        Callback = function()
            SimpleUI:Notify("Tip", "Disable shift-lock in settings for best results")
        end
    })
    
    self:SetupCharacterListeners()
    if LocalPlayer.Character then self:SetupCharacter(LocalPlayer.Character) end
end

-- Section 5: Game Module (Ball Hitboxes)
local GameModule = {
    BallHitboxes = {
        Enabled = true,
        CurrentScale = 5.0,
        TrackedBalls = {}
    },
    
    AutoTilt = {
        Enabled = false,
        Hotkey = Enum.KeyCode.Z
    }
}

function GameModule:BallHitbox_FindAnyPart(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then return part end
    end
    return nil
end

function GameModule:BallHitbox_Create(model, scale)
    local existing = model:FindFirstChild("Ball.001")
    if existing then existing:Destroy() end
    
    local ref = self:BallHitbox_FindAnyPart(model)
    if not ref then return end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "Ball.001"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Size = Vector3.new(2, 2, 2) * scale
    hitbox.CFrame = ref.CFrame
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Transparency = 0.7
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(0, 255, 0)
    hitbox.Parent = model
    
    self.BallHitboxes.TrackedBalls[model] = hitbox
end

function GameModule:BallHitbox_UpdateAll(scale)
    for model, hitbox in pairs(self.BallHitboxes.TrackedBalls) do
        if model.Parent and hitbox.Parent then
            hitbox.Size = Vector3.new(2, 2, 2) * scale
        else
            self.BallHitboxes.TrackedBalls[model] = nil
        end
    end
end

function GameModule:BallHitbox_ClearAll()
    for _, hitbox in pairs(self.BallHitboxes.TrackedBalls) do
        if hitbox and hitbox.Parent then hitbox:Destroy() end
    end
    self.BallHitboxes.TrackedBalls = {}
end

function GameModule:BallHitbox_ProcessNew(model)
    if not self.BallHitboxes.Enabled then return end
    task.wait(0.1)
    
    if model.Parent and model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
        self:BallHitbox_Create(model, self.BallHitboxes.CurrentScale)
    end
end

function GameModule:BallHitbox_RebuildAll()
    self:BallHitbox_ClearAll()
    for _, model in ipairs(Services.Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            self:BallHitbox_ProcessNew(model)
        end
    end
end

function GameModule:BallHitbox_SetupListeners()
    Services.Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name:match("^CLIENT_BALL_%d+$") then
            self:BallHitbox_ProcessNew(child)
        end
    end)
    
    task.spawn(function()
        for _, model in ipairs(Services.Workspace:GetChildren()) do
            if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
                self:BallHitbox_ProcessNew(model)
            end
        end
    end)
end

function GameModule:ApplyAutoTilt()
    if not self.AutoTilt.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        local dir = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
        if dir.Magnitude > 0 then humanoid:Move(dir.Unit, false) end
    end
end

function GameModule:Initialize(tab)
    local parent = tab.Content
    SimpleUI:CreateSection(parent, "Ball Hitboxes")
    
    SimpleUI:CreateSlider(parent, {
        Name = "Hitbox Size",
        Range = {0, 20},
        Increment = 0.1,
        Suffix = "x",
        CurrentValue = self.BallHitboxes.CurrentScale,
        Flag = "HitboxSize",
        Callback = function(val)
            self.BallHitboxes.CurrentScale = val
            if self.BallHitboxes.Enabled then self:BallHitbox_UpdateAll(val) end
        end
    })
    
    SimpleUI:CreateToggle(parent, {
        Name = "Enable Ball Hitboxes",
        CurrentValue = self.BallHitboxes.Enabled,
        Flag = "HitboxToggle",
        Callback = function(val)
            self.BallHitboxes.Enabled = val
            if val then
                self:BallHitbox_RebuildAll()
                SimpleUI:Notify("Hitboxes", "Ball hitboxes created")
            else
                self:BallHitbox_ClearAll()
                SimpleUI:Notify("Hitboxes", "Ball hitboxes removed")
            end
        end
    })
    
    SimpleUI:CreateSection(parent, "Auto Tilt")
    
    SimpleUI:CreateToggle(parent, {
        Name = "Auto Tilt",
        CurrentValue = self.AutoTilt.Enabled,
        Flag = "AutoTilt",
        Callback = function(val) self.AutoTilt.Enabled = val end
    })
    
    SimpleUI:CreateButton(parent, {
        Name = "Hotkey: Z (Toggle in-game)",
        Callback = function()
            SimpleUI:Notify("Auto Tilt", "Press Z to toggle in-game")
        end
    })
    
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.AutoTilt.Hotkey then 
            self.AutoTilt.Enabled = not self.AutoTilt.Enabled
            SimpleUI:Notify("Auto Tilt", self.AutoTilt.Enabled and "Enabled" or "Disabled")
        end
    end)
    
    Services.RunService.RenderStepped:Connect(function()
        self:ApplyAutoTilt()
    end)
    
    self:BallHitbox_SetupListeners()
end

-- Section 6: Initialize UI and Modules
SimpleUI:CreateWindow()

-- Create tabs with proper organization
local VisualTab = SimpleUI:CreateTab("Visual")     -- Clone ESP, Direction Lines, Enemy ESP
local CharacterTab = SimpleUI:CreateTab("Character") -- Movement features
local GameTab = SimpleUI:CreateTab("Game")         -- Ball hitboxes, Auto Tilt

-- Initialize modules in correct tabs
VisualModule:Initialize(VisualTab)      -- Clone ESP goes here
CharacterModule:Initialize(CharacterTab) -- Movement features
GameModule:Initialize(GameTab)          -- Ball hitboxes and Auto Tilt

-- Auto reconnect
Services.CoreGui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") and child.Name == "ErrorPrompt" then
        task.wait(2)
        Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

SimpleUI:Notify(
    "MirageLib Loaded",
    "Press " .. tostring(CONFIG.UIKey) .. " to toggle interface\nP = Panic Mode (not implemented)"
)

-- Section 7: Cleanup
local function CleanupAll()
    -- Clean all modules
    VisualModule:CloneESPCleanup()
    
    for player in pairs(VisualModule.Beams) do VisualModule:ClearLine(player) end
    for player in pairs(VisualModule.JumpHighlights) do VisualModule:RemoveJumpESP(player) end
    
    GameModule:BallHitbox_ClearAll()
    
    -- Destroy UI
    if SimpleUI.ScreenGui then
        SimpleUI.ScreenGui:Destroy()
    end
    
    warn("MirageLib: Cleanup complete")
end

game:BindToClose(function() CleanupAll() end)
