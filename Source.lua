-- Volleyball legends
-- Section 1: Services
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui"),
    TeleportService = game:GetService("TeleportService"),
    UserInputService = game:GetService("UserInputService"),
    StarterGui = game:GetService("StarterGui"),
    HttpService = game:GetService("HttpService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

local CONFIG = {
    SaveFile = "zeckhub_config",
    UIKey = Enum.KeyCode.K,
    Theme = "Dark"
}

-- Section 2: UI Manager
local UIManager = {
    Rayfield = nil,
    Window = nil
}

function UIManager:LoadRayfield()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    
    if not success then
        warn("ZeckHub: Failed to load Rayfield")
        return false
    end
    
    self.Rayfield = result
    return true
end

function UIManager:CreateWindow()
    self.Window = self.Rayfield:CreateWindow({
        Name = "ZeckHub",
        LoadingTitle = "Loading ZeckHub...",
        LoadingSubtitle = "by Robertzeck",
        ConfigurationSaving = {
            Enabled = true,
            FileName = CONFIG.SaveFile
        },
        KeySystem = false,
        Theme = CONFIG.Theme,
        ToggleUIKeybind = CONFIG.UIKey
    })
end

function UIManager:Notify(title, content, icon)
    if self.Rayfield then
        self.Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = 3,
            Image = icon or "info"
        })
    end
end

-- Section 3: Hitbox Module
local HitboxModule = {
    Enabled = true,
    CurrentScale = 5.0,
    TrackedBalls = {}
}

function HitboxModule:FindAnyPart(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

function HitboxModule:CreateBallHitbox(model, scale)
    local existing = model:FindFirstChild("Ball.001")
    if existing then existing:Destroy() end
    
    local ref = self:FindAnyPart(model)
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
    
    self.TrackedBalls[model] = hitbox
end

function HitboxModule:UpdateAllHitboxes(scale)
    for model, hitbox in pairs(self.TrackedBalls) do
        if model.Parent and hitbox.Parent then
            hitbox.Size = Vector3.new(2, 2, 2) * scale
        else
            self.TrackedBalls[model] = nil
        end
    end
end

function HitboxModule:ClearAllHitboxes()
    for _, hitbox in pairs(self.TrackedBalls) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end
    self.TrackedBalls = {}
end

function HitboxModule:ProcessNewBall(model)
    if not self.Enabled then return end
    task.wait(0.1)
    
    if model.Parent and model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
        self:CreateBallHitbox(model, self.CurrentScale)
    end
end

function HitboxModule:RebuildAllHitboxes()
    self:ClearAllHitboxes()
    for _, model in ipairs(Services.Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            self:ProcessNewBall(model)
        end
    end
end

function HitboxModule:SetupListeners()
    Services.Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name:match("^CLIENT_BALL_%d+$") then
            self:ProcessNewBall(child)
        end
    end)
    
    task.spawn(function()
        for _, model in ipairs(Services.Workspace:GetChildren()) do
            if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
                self:ProcessNewBall(model)
            end
        end
    end)
end

function HitboxModule:Initialize(tab)
    tab:CreateSection("Hitbox Ball")
    
    tab:CreateSlider({
        Name = "Hitbox Size",
        Range = {0, 20},
        Increment = 0.1,
        Suffix = "x",
        CurrentValue = self.CurrentScale,
        Flag = "HitboxSize",
        Callback = function(val)
            self.CurrentScale = val
            if self.Enabled then
                self:UpdateAllHitboxes(val)
            end
        end
    })
    
    tab:CreateToggle({
        Name = "Enable Hitboxes",
        CurrentValue = self.Enabled,
        Flag = "HitboxToggle",
        Callback = function(val)
            self.Enabled = val
            if val then
                self:RebuildAllHitboxes()
                UIManager:Notify("Hitboxes Enabled", "Ball hitboxes created", "check")
            else
                self:ClearAllHitboxes()
                UIManager:Notify("Hitboxes Disabled", "Ball hitboxes removed", "x")
            end
        end
    })
    
    self:SetupListeners()
end

-- Section 4: Character Module
local CharacterModule = {
    DirectionalJump = true,
    AirMovement = false,
    AirMoveSpeed = 50,
    IsJumping = false,
    
    CloneESP = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Folder = nil,
        Clones = {},
        RenderConnection = nil
    }
}

function CharacterModule:SetupCharacter(character)
    self.Humanoid = character:WaitForChild("Humanoid")
    self.HRP = character:WaitForChild("HumanoidRootPart")
    
    self.Humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Landed then
            self.Humanoid.AutoRotate = true
        end
    end)
    
    if self.CloneESP.Enabled then
        self:CreateCloneESP(character)
    end
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

local VALID_BODY_PARTS = {
    Head = true, Torso = true, UpperTorso = true, LowerTorso = true,
    LeftArm = true, RightArm = true, LeftUpperArm = true, RightUpperArm = true,
    LeftLowerArm = true, RightLowerArm = true, LeftHand = true, RightHand = true,
    LeftLeg = true, RightLeg = true, LeftUpperLeg = true, RightUpperLeg = true,
    LeftLowerLeg = true, RightLowerLeg = true, LeftFoot = true, RightFoot = true,
    HumanoidRootPart = true
}

function CharacterModule:CloneESPCleanup()
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

function CharacterModule:CreateCloneESP(character)
    if not character then return end
    
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
                if child:IsA("Script") or child:IsA("Motor6D") then
                    child:Destroy()
                end
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

function CharacterModule:Initialize(tab)
    self.Humanoid = nil
    self.HRP = nil
    
    tab:CreateSection("Movement")
    
    tab:CreateToggle({
        Name = "Directional Jump",
        CurrentValue = self.DirectionalJump,
        Flag = "DirectionalJump",
        Callback = function(val)
            self.DirectionalJump = val
            if not val and self.Humanoid then
                self.Humanoid.AutoRotate = true
            end
        end
    })
    
    tab:CreateParagraph({
        Title = "How to Use",
        Content = "Turn off shift-lock. Character auto-steers to where you look."
    })
    
    tab:CreateToggle({
        Name = "Air Movement",
        CurrentValue = self.AirMovement,
        Flag = "AirMoveToggle",
        Callback = function(val)
            self.AirMovement = val
        end
    })
    
    tab:CreateSlider({
        Name = "Air Move Speed",
        Range = {10, 150},
        Increment = 5,
        Suffix = "studs/s",
        CurrentValue = self.AirMoveSpeed,
        Flag = "AirMoveSpeed",
        Callback = function(val)
            self.AirMoveSpeed = val
        end
    })
    
    tab:CreateSection("Visual")
    
    tab:CreateToggle({
        Name = "Clone ESP",
        CurrentValue = self.CloneESP.Enabled,
        Flag = "CloneESP_Toggle",
        Callback = function(val)
            self.CloneESP.Enabled = val
            if val then
                if LocalPlayer.Character then
                    self:CreateCloneESP(LocalPlayer.Character)
                end
            else
                self:CloneESPCleanup()
            end
        end
    })
    
    tab:CreateColorPicker({
        Name = "Clone ESP Color",
        Color = self.CloneESP.Color,
        Flag = "CloneESP_Color",
        Callback = function(color)
            self.CloneESP.Color = color
            for _, clone in pairs(self.CloneESP.Clones) do
                if clone and clone:IsA("BasePart") then
                    clone.Color = color
                end
            end
        end
    })
    
    self:SetupCharacterListeners()
    if LocalPlayer.Character then
        self:SetupCharacter(LocalPlayer.Character)
    end
end

-- Section 5: Visual Helpers
local VisualHelpers = {
    LinesEnabled = true,
    LineDistance = 50,
    MaxLines = 6,
    Beams = {},
    
    AutoTiltEnabled = false,
    TiltHotkey = Enum.KeyCode.Z,
    
    JumpESPEnabled = true,
    JumpHighlights = {}
}

function VisualHelpers:CreateBeamForPlayer(player, index)
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

function VisualHelpers:UpdateLinePosition(player)
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

function VisualHelpers:ClearLine(player)
    local data = self.Beams[player]
    if not data then return end
    
    if data.beam then data.beam:Destroy() end
    if data.target then data.target:Destroy() end
    if data.attachment then data.attachment:Destroy() end
    
    self.Beams[player] = nil
end

function VisualHelpers:ApplyTilt()
    if not self.AutoTiltEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        local dir = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
        if dir.Magnitude > 0 then
            humanoid:Move(dir.Unit, false)
        end
    end
end

function VisualHelpers:IsEnemy(player)
    return player ~= LocalPlayer and 
           player.Team and LocalPlayer.Team and 
           player.Team ~= LocalPlayer.Team
end

function VisualHelpers:CreateJumpESP(player)
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

function VisualHelpers:RemoveJumpESP(player)
    if self.JumpHighlights[player] then
        self.JumpHighlights[player]:Destroy()
        self.JumpHighlights[player] = nil
    end
end

function VisualHelpers:SetupPlayerJumpESP(player)
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
    
    if player.Character then
        MonitorCharacter(player.Character)
    end
    
    player.CharacterAdded:Connect(MonitorCharacter)
end

function VisualHelpers:SetupListeners()
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
                if not self.Beams[player] then
                    self:CreateBeamForPlayer(player, i)
                end
                self:UpdateLinePosition(player)
            end
            
            for player in pairs(self.Beams) do
                if not table.find(enemies, player) then
                    self:ClearLine(player)
                end
            end
        end
        
        self:ApplyTilt()
    end)
    
    Services.Players.PlayerRemoving:Connect(function(player)
        self:ClearLine(player)
        self:RemoveJumpESP(player)
    end)
    
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.TiltHotkey then
            self.AutoTiltEnabled = not self.AutoTiltEnabled
        end
    end)
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        self:SetupPlayerJumpESP(player)
    end
    Services.Players.PlayerAdded:Connect(function(player)
        self:SetupPlayerJumpESP(player)
    end)
end

function VisualHelpers:Initialize(tab)
    tab:CreateSection("Directional Lines")
    
    tab:CreateToggle({
        Name = "Enable Lines",
        CurrentValue = self.LinesEnabled,
        Callback = function(val)
            self.LinesEnabled = val
            if not val then
                for player, data in pairs(self.Beams) do
                    self:ClearLine(player)
                end
            end
        end
    })
    
    tab:CreateSlider({
        Name = "Line Distance",
        Range = {10, 100},
        Increment = 10,
        CurrentValue = self.LineDistance,
        Suffix = " studs",
        Callback = function(val)
            self.LineDistance = val
        end
    })
    
    tab:CreateSection("Auto Tilt")
    
    tab:CreateToggle({
        Name = "Auto Tilt",
        CurrentValue = self.AutoTiltEnabled,
        Callback = function(val)
            self.AutoTiltEnabled = val
        end
    })
    
    tab:CreateInput({
        Name = "Key Toggle (PC)",
        CurrentValue = "Z",
        PlaceholderText = "Ex: Z",
        RemoveTextAfterFocusLost = true,
        Flag = "TiltKeyInput",
        Callback = function(text)
            text = text:upper()
            local key = Enum.KeyCode[text]
            if key then
                self.TiltHotkey = key
            end
        end
    })
    
    tab:CreateParagraph({
        Title = "How to use",
        Content = "Auto-steers in air based on camera direction."
    })
    
    tab:CreateSection("Enemy Detection")
    
    tab:CreateToggle({
        Name = "Enemy Jump ESP",
        CurrentValue = self.JumpESPEnabled,
        Callback = function(val)
            self.JumpESPEnabled = val
            if not val then
                for player in pairs(self.JumpHighlights) do
                    self:RemoveJumpESP(player)
                end
            end
        end
    })
    
    self:SetupListeners()
end

-- Section 6: Main
Services.CoreGui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") and child.Name == "ErrorPrompt" then
        task.wait(2)
        Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

if not UIManager:LoadRayfield() then
    return
end

UIManager:CreateWindow()

local GameTab = UIManager.Window:CreateTab("Game", "flame")
local CharTab = UIManager.Window:CreateTab("Character", "user-round")
local VisualTab = UIManager.Window:CreateTab("Visual Helpers", "eye")
local AimTab = UIManager.Window:CreateTab("Aim Assist", "crosshair")

HitboxModule:Initialize(GameTab)
CharacterModule:Initialize(CharTab)
VisualHelpers:Initialize(VisualTab)
AimAssist:Initialize(AimTab)

Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        AimAssist:Toggle()
    end
    
    if input.KeyCode == Enum.KeyCode.P then
        HitboxModule.Enabled = false
        HitboxModule:ClearAllHitboxes()
        
        CharacterModule.DirectionalJump = false
        CharacterModule.AirMovement = false
        CharacterModule:CloneESPCleanup()
        
        VisualHelpers.LinesEnabled = false
        for player in pairs(VisualHelpers.Beams) do
            VisualHelpers:ClearLine(player)
        end
        
        VisualHelpers.AutoTiltEnabled = false
        VisualHelpers.JumpESPEnabled = false
        for player in pairs(VisualHelpers.JumpHighlights) do
            VisualHelpers:RemoveJumpESP(player)
        end
        
        AimAssist.Enabled = false
        AimAssist:CleanupVisuals()
        
        UIManager:Notify("PANIC MODE", "All features disabled", "skull")
    end
end)

UIManager:Notify(
    "ZeckHub v2.1 Loaded",
    "Press " .. tostring(CONFIG.UIKey) .. " to toggle interface\nF = Toggle Aim Assist\nP = Panic Mode",
    "check"
)

-- Section 7: Cleanup
local function CleanupAll()
    HitboxModule:ClearAllHitboxes()
    CharacterModule:CloneESPCleanup()
    
    for player in pairs(VisualHelpers.Beams) do
        VisualHelpers:ClearLine(player)
    end
    
    for player in pairs(VisualHelpers.JumpHighlights) do
        VisualHelpers:RemoveJumpESP(player)
    end
    
    AimAssist:CleanupVisuals()
    
    warn("ZeckHub: Cleanup complete")
end

game:BindToClose(function()
    CleanupAll()
end)
