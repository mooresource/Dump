--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Configuration
local Config = {
    Enabled = true,
    FollowMouse = true,
    TeamCheck = false,
    WallCheck = false,
    ShowFOV = true,
    FOVRadius = 150,
    MaxDistance = 1000,
    MissChance = 0,
}

--// Minimalist Theme
local Theme = {
    Bg = Color3.fromRGB(18, 18, 18),
    BgLight = Color3.fromRGB(28, 28, 28),
    Border = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(220, 220, 220),
    TextDim = Color3.fromRGB(130, 130, 130),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentDim = Color3.fromRGB(100, 100, 100),
}

--// State
local State = {
    CurrentTarget = nil,
    CurrentHighlight = nil,
    FOVRing = nil,
    GUI = nil,
    Connections = {},
}

--// Utilities
local function Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function IsVisible(targetPart)
    if not Config.WallCheck then return true end
    local ignoreList = {LocalPlayer.Character, targetPart.Parent}
    local parts = Camera:GetPartsObscuringTarget({targetPart.Position}, ignoreList)
    return #parts == 0
end

local function GetFOVPosition()
    if Config.FollowMouse then
        local mousePos = UserInputService:GetMouseLocation()
        return Vector2.new(mousePos.X, mousePos.Y)
    else
        return Camera.ViewportSize / 2
    end
end

--// Target System
local function GetClosestTarget()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local closestPlayer, shortestDist = nil, Config.FOVRadius
    local fovPos = GetFOVPosition()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                local char = player.Character
                if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") then
                    if char.Humanoid.Health > 0 then
                        local head = char.Head
                        local root = char.HumanoidRootPart
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        
                        if distance <= Config.MaxDistance and IsVisible(head) then
                            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                            if onScreen then
                                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - fovPos).Magnitude
                                if screenDist < shortestDist then
                                    closestPlayer = player
                                    shortestDist = screenDist
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

--// Highlight System
local function CreateHighlight(player)
    if not player or not player.Character then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    
    if player.Team and player.Team.TeamColor then
        local teamColor = player.Team.TeamColor.Color
        highlight.FillColor = teamColor
        highlight.OutlineColor = teamColor
    else
        highlight.FillColor = Theme.Accent
        highlight.OutlineColor = Theme.Accent
    end
    
    highlight.Parent = PlayerGui
    return highlight
end

local function UpdateHighlight(newTarget)
    if newTarget ~= State.CurrentTarget then
        if State.CurrentHighlight then
            State.CurrentHighlight:Destroy()
            State.CurrentHighlight = nil
        end
        
        if newTarget then
            State.CurrentHighlight = CreateHighlight(newTarget)
        end
        
        State.CurrentTarget = newTarget
    end
end

--// Minimalist GUI
local GUI = {}

function GUI.New(class, props)
    local element = Instance.new(class)
    for prop, value in pairs(props) do
        element[prop] = value
    end
    return element
end

function GUI.CreateMain()
    local screenGui = GUI.New("ScreenGui", {
        Name = "SilentAim",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = PlayerGui
    })
    State.GUI = screenGui
    
    local main = GUI.New("Frame", {
        Size = UDim2.new(0, 240, 0, 320),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Theme.Bg,
        BorderColor3 = Theme.Border,
        BorderSizePixel = 1,
        Parent = screenGui
    })
    
    local content = GUI.New("Frame", {
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Parent = main
    })
    
    GUI.New("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = content
    })
    
    local title = GUI.New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = "SILENT AIM",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = main
    })
    
    GUI.MakeDraggable(main)
    return content
end

function GUI.Toggle(parent, name, default, callback)
    local container = GUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = GUI.New("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local box = GUI.New("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -12, 0, 4),
        BackgroundColor3 = default and Theme.Accent or Theme.BgLight,
        BorderColor3 = Theme.Border,
        BorderSizePixel = 1,
        Parent = container
    })
    
    local button = GUI.New("TextButton", {
        Size = UDim2.new(1, 20, 1, 0),
        Position = UDim2.new(0, -10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    button.MouseButton1Click:Connect(function()
        default = not default
        callback(default)
        box.BackgroundColor3 = default and Theme.Accent or Theme.BgLight
    end)
end

function GUI.Slider(parent, name, min, max, default, callback)
    local container = GUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local labelFrame = GUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Parent = container
    })
    
    local label = GUI.New("TextLabel", {
        Size = UDim2.new(0.65, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = labelFrame
    })
    
    local value = GUI.New("TextLabel", {
        Size = UDim2.new(0.35, 0, 1, 0),
        Position = UDim2.new(0.65, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = labelFrame
    })
    
    local track = GUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Theme.BgLight,
        BorderSizePixel = 0,
        Parent = container
    })
    
    local fill = GUI.New("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track
    })
    
    local dragging = false
    
    local function update(input)
        local pos = Clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        value.Text = tostring(val)
        callback(val)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

function GUI.Divider(parent)
    GUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = parent
    })
end

function GUI.MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// FOV Ring
local function CreateFOVRing(parent)
    local fov = GUI.New("Frame", {
        Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent
    })
    
    GUI.New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = fov
    })
    
    GUI.New("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1,
        Transparency = 0,
        Parent = fov
    })
    
    State.FOVRing = fov
    return fov
end

--// Hooks
local function SetupHooks()
    if not hookmetamethod then return end
    
    local old_namecall
    old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if Config.Enabled and State.CurrentTarget and method == "Raycast" and not checkcaller() then
            if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                local origin = args[1]
                local direction = args[2]
                local rayLength = direction.Magnitude
                local distanceFromCamera = (origin - Camera.CFrame.Position).Magnitude
                
                if rayLength > 10 or distanceFromCamera < 3 then
                    if Config.MissChance > 0 and math.random(1, 100) <= Config.MissChance then
                        return old_namecall(self, unpack(args))
                    end
                    
                    local targetPart = State.CurrentTarget.Character.Head
                    args[2] = (targetPart.Position - origin).Unit * rayLength
                    return old_namecall(self, unpack(args))
                end
            end
        end
        
        return old_namecall(self, ...)
    end)
end

--// Cleanup
local function Cleanup()
    if State.GUI then State.GUI:Destroy() end
    if State.CurrentHighlight then State.CurrentHighlight:Destroy() end
    for _, conn in pairs(State.Connections) do
        if conn then conn:Disconnect() end
    end
    State.Connections = {}
end

--// Initialize
local function Initialize()
    Cleanup()
    
    -- Create GUI
    local screenGui = GUI.New("ScreenGui", {
        Name = "SilentAim",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = PlayerGui
    })
    State.GUI = screenGui
    
    -- FOV Ring
    CreateFOVRing(screenGui)
    
    -- Main GUI
    local content = GUI.CreateMain()
    
    -- Controls
    GUI.Toggle(content, "Enabled", Config.Enabled, function(v) Config.Enabled = v end)
    GUI.Toggle(content, "Show FOV", Config.ShowFOV, function(v) Config.ShowFOV = v end)
    GUI.Toggle(content, "Follow Mouse", Config.FollowMouse, function(v) Config.FollowMouse = v end)
    GUI.Toggle(content, "Team Check", Config.TeamCheck, function(v) Config.TeamCheck = v end)
    GUI.Toggle(content, "Wall Check", Config.WallCheck, function(v) Config.WallCheck = v end)
    
    GUI.Divider(content)
    
    GUI.Slider(content, "FOV Radius", 10, 800, Config.FOVRadius, function(v) Config.FOVRadius = v end)
    GUI.Slider(content, "Max Distance", 100, 10000, Config.MaxDistance, function(v) Config.MaxDistance = v end)
    GUI.Slider(content, "Miss Chance", 0, 100, Config.MissChance, function(v) Config.MissChance = v end)
    
    -- Main Loop
    local conn = RunService.RenderStepped:Connect(function()
        local fovPos = GetFOVPosition()
        
        if State.FOVRing then
            State.FOVRing.Visible = Config.ShowFOV
            State.FOVRing.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
            State.FOVRing.Position = UDim2.new(0, fovPos.X, 0, fovPos.Y)
        end
        
        if Config.Enabled then
            UpdateHighlight(GetClosestTarget())
        else
            UpdateHighlight(nil)
        end
    end)
    State.Connections.MainLoop = conn
    
    -- Setup Hooks
    SetupHooks()
end

-- Run
Initialize()
