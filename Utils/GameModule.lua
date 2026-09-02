return(function(Installer)
    local _ENV = (getgenv or getrenv or getfenv)()

    local Module = {}

    local Cached = {
        Bring = {},
        Enemies = {}
    }

    local Owner = "imdogkung3"
    local Repository = "Xynapse"

    local Configuration = Installer.Configurations
    local Connect = Installer.Connect

    local function fetch(owner, repo, file)
        local URL = string.format(
            "https://raw.githubusercontent.com/%s/%s/main/%s",
            Owner, Repository, file
        )

        return loadstring(game:HttpGet(URL))()
    end

    local function AddModule(Name, Insert)
        do Module[Name] = Insert()
            return Module[Name] 
        end
    end

    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService('UserInputService')
    local TeleportService = game:GetService("TeleportService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService('Lighting')
    local Players = game:GetService("Players")

    local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
    local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")

    local CommF: RemoteFunction = Remotes:WaitForChild("CommF_")
    local CommE: RemoteEvent = Remotes:WaitForChild("CommE")

    local Net: Folder = Modules:WaitForChild("Net")

    local ChestModels: Folder = workspace:WaitForChild("ChestModels")
    local WorldOrigin: Folder = workspace:WaitForChild("_WorldOrigin")
    local Characters: Folder = workspace:WaitForChild("Characters")
    local SeaBeasts: Folder = workspace:WaitForChild("SeaBeasts")
    local Enemies: Folder = workspace:WaitForChild("Enemies")
    local Boats: Folder = workspace:WaitForChild("Boats")
    local Map: Folder = workspace:WaitForChild("Map")

    local NPCs: Folder = workspace:WaitForChild('NPCs')

    local ReplicatedNPCs: Folder = ReplicatedStorage:WaitForChild('NPCs')

    local EnemySpawns: Folder = WorldOrigin:WaitForChild("EnemySpawns")
    local Locations: Folder = WorldOrigin:WaitForChild("Locations")

    local RenderStepped = RunService.RenderStepped
    local Heartbeat = RunService.Heartbeat
    local Stepped = RunService.Stepped

    local LocalPlayer = Players.LocalPlayer

    local PlayerScripts: PlayerScripts = LocalPlayer.PlayerScripts
    local PlayerGui: PlayerGui = LocalPlayer.PlayerGui
    local Backpack: Backpack = LocalPlayer.Backpack

    local Data: Folder = LocalPlayer:WaitForChild("Data")

    local Fragments: IntValue = Data:WaitForChild("Fragments")
    local Level: IntValue = Data:WaitForChild("Level")
    local Money: IntValue = Data:WaitForChild("Beli")

    local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid: Humanoid = Character and Character:WaitForChild('Humanoid', 10)
    local HumanoidRootPart: Part = Character and Character:WaitForChild('HumanoidRootPart', 10)
    local Head: Part = Character and Character:WaitForChild('Head', 10)

    local StorageNPCs: Folder = ReplicatedStorage:WaitForChild('NPCs')
    local ServerOwnerId: IntValue = ReplicatedStorage:FindFirstChild("PrivateServerOwnerId")
    local IsPrivateServer: boolean = ServerOwnerId and ServerOwnerId.Value ~= 0 or true
    local Mobile: boolean = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and true) or false

    local SubmarineWorkerSpeak: RemoteFunction = Net:WaitForChild('RF/SubmarineWorkerSpeak')

    local empty = (function(...) return (...) end)

    local fireproximityprompt = fireproximityprompt or empty
    local fireclickdetector = fireclickdetector or empty
    local restorefunction = restorefunction or empty
    local hookfunction = hookfunction or empty
    local getsenv = getsenv or empty

    local BRING_TAG = _ENV._Bring_Tag or tostring(math.random(80, 2e4))
    local KILLAURA_TAG = _ENV._KillAura_Tag or tostring(math.random(120, 2e4))

    _ENV._Bring_Tag = BRING_TAG 
    _ENV._KillAura_Tag = KILLAURA_TAG

    local function GetEnemyName(strings)
        return (strings:find("Lv. ") and strings:gsub(" %pLv. %d+%p", "") or strings):gsub(" %pBoss%p", "")
    end

    local function CreateDictionary(array, value)
        local Dictionary = {}

        for _, strings in ipairs(array) do
            Dictionary[strings] = type(value) == "table" and {} or value
        end

        return Dictionary
    end

    local function ValidData(filter, enemy)
        if filter == nil then return true end

        if type(filter) == "table" then
            return table.find(filter, enemy.Name) ~= nil
        end

        if type(filter) == "string" then
            return enemy.Name == filter
        end

        return false
    end

    local function IsAlive()
        if not Character then return end

        if not Humanoid then return end

        if not HumanoidRootPart then return end

        if not Head then return end

        if not Backpack then return end

        return (Humanoid and Humanoid.Health > 0) or HumanoidRootPart ~= nil
    end

    do
        function Module:Unit(BasePart)
            return (BasePart.Position - HumanoidRootPart.Position).Unit
        end

        function Module:IsAlive(Character)
            return Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") and Character.Humanoid.Health > 0
        end

        function Module:Distance(Position)
            return Position and ((typeof(Position) == 'CFrame' and LocalPlayer:DistanceFromCharacter(Position.Position)) or LocalPlayer:DistanceFromCharacter(Position))
        end

        function Module:IsPortal()
            return Module.Sea ~= 3 or self:HaveItem('Valkyrie Helm')
        end

        function Module:HaveItem(name)
            if not IsAlive() then return end
            if not Backpack then return end

            if Character and Character:FindFirstChild(name) then
                return true
            end

            if Backpack:FindFirstChild(name) then
                return true
            end

            local Inventory = Module:ComF("getInventoryWeapons")

            for _, v in pairs(Inventory) do
                if v.Name == name then
                    return true
                end
            end

            return false
        end

        function Module:Equip(Name, Tooltip)
            if not IsAlive() then return end

            for _, v in Backpack:GetChildren() do
                if v:IsA("Tool") and ((Tooltip and v.ToolTip == Name) or (not Tooltip and v.Name == Name)) then
                    if v:GetAttribute("Locks") then
                        v:SetAttribute("Locks", nil)
                    end

                    if Character and not Character:FindFirstChild(v.Name) then
                        Humanoid:EquipTool(v)
                    end
                end
            end
        end

        function Module:ComF( ... )
            return CommF:InvokeServer( ... )
        end

        function Module:ComE( ... )
            return CommE:FireServer( ... )
        end

        function Module:TravelTo(Sea)
            self:ComF("Travel" .. self.SeaName[Sea])
        end

        function Module:BringEnemies(ToEnemy, SuperBring, CustomCFrame, Distance)
            if not Module:IsAlive(ToEnemy) or not ToEnemy.PrimaryPart then
                return nil
            end

            pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)

            if Distance or Configuration['Enabled Bring'] then
                Module.IsSuperBring = SuperBring and true or false

                local Name = ToEnemy.Name
                local BringPositionTag = SuperBring and "ALL_MOBS" or Name
                local Target = CustomCFrame or ToEnemy.PrimaryPart.CFrame
                local MaxDistance = Distance or Configuration['Bring Distance']

                if not Cached.Bring[BringPositionTag] or (Target.Position - Cached.Bring[BringPositionTag].Position).Magnitude > 25 then
                    Cached.Bring[BringPositionTag] = Target
                end

                local EnemyList = (not SuperBring and self.EnemiesModule:GetTagged(Name)) or Enemies:GetChildren()

                for i = 1, #EnemyList do
                    local Enemy = EnemyList[i]

                    if (SuperBring or Enemy.Name == Name)
                        and Enemy.Parent == Enemies
                        and not Enemy:HasTag(BRING_TAG)
                        and Enemy:FindFirstChild("CharacterReady") then

                        local PrimaryPart = Enemy.PrimaryPart

                        if Module:IsAlive(Enemy) and PrimaryPart then
                            if LocalPlayer:DistanceFromCharacter(PrimaryPart.Position) < MaxDistance then
                                Enemy.Humanoid.WalkSpeed = 0
                                Enemy.Humanoid.JumpPower = 0
                                Enemy:AddTag(BRING_TAG)
                            end
                        end
                    end
                end
            else
                if not Cached.Bring[ToEnemy] then
                    Cached.Bring[ToEnemy] = ToEnemy.PrimaryPart.CFrame
                end

                ToEnemy.PrimaryPart.CFrame = Cached.Bring[ToEnemy]
            end
        end
    end

    do
        Module.PirateRaid = 0
        Module.IsSuperBring = false
        Module.EnemyLocations = {}
        Module.SpawnLocations = {}
        Module.SeaName = { "Main", "Dressrosa", "Zou" }
        Module.IsPrivateService = IsPrivateServer
        Module.IsMobile = Mobile

        Module.RaidList = (function()
            local Success, RaidModule = pcall(require, ReplicatedStorage:WaitForChild("Raids"))

            if not Success or type(RaidModule) ~= "table" then
                return {
                    "Phoenix", "Dough", "Flame", "Ice", "Quake", "Light";
                    "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand";
                }
            end

            local AdvancedRaids = RaidModule.advancedRaids or {}
            local NormalRaids = RaidModule.raids or {}
            local RaidList = {}

            for i = 1, #AdvancedRaids do table.insert(RaidList, AdvancedRaids[i]) end
            for i = 1, #NormalRaids do table.insert(RaidList, NormalRaids[i]) end

            return RaidList
        end)()

        Module.Sea = (function()
            local Current = workspace:GetAttribute('MAP') do
                if Current == 'Sea1' then return 1 end
                if Current == 'Sea2' then return 2 end
                if Current == 'Sea3' then return 3 end 
            end
        end)()

        Module.GateList = {
            [1] = {
                Vector3.new(3864, 5, -1926), -- Gate
                Vector3.new(61163, 5, 1819), -- Under Water
                Vector3.new(-7894, 5545, -380), -- Sky 2
                Vector3.new(-4607, 872, -1667) -- Sky 1
            },
            [2] = {
                Vector3.new(923, 125, 32852), -- Ghost Ship
                Vector3.new(-288, 200, 611), -- Mansion
                Vector3.new(2283, 60, 905), -- Swan
                Vector3.new(-6505, 125, -130) -- Out Ghost Ship
            },
            [3] = {
                Vector3.new(-5076, 314, -3151), -- Castle on the Sea
                Vector3.new(5657, 1013, -338), -- Hydra
                Vector3.new(-12479, 375, -7566) -- Mansion 
            }
        }
    end

    AddModule("Aimbot", function()
        local Aimbot = {
            _index = {}
        }

        _ENV.Target = Vector3.new(0, 0, 0)

        function Aimbot:Check()
            for _,v in pairs(self._index) do
                if Configuration[v] == true then
                    return true 
                end 
            end 

            return false 
        end

        function Aimbot:Import(Name)
            if not self.index[Name] then
                table.insert(self._index, Name)
            end
        end

        function Aimbot:SetTarget(v3)
            _ENV.Target = (typeof(v3) == 'CFrame' and v3.Position) or v3
        end

        return Aimbot
    end)

    AddModule("Combat", function()
        local Combat = {
            RANGE = 67
        }

        Combat.Slash = {} do
            function Combat:Insert(Name, Data)
                self.Slash[`{Name}-{Name}`] = function(Remote, Unit)
                    Remote:FireServer(Unit, unpack(Data))
                end
            end

            do
                Combat:Insert("Control", { 1, true })
            end
        end

        local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
        local RegisterHit = Net:WaitForChild("RE/RegisterHit")

        local HIT_FUNCTION; task.defer(function()
            local LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")

            while not LocalScript do
                PlayerScripts.ChildAdded:Wait()
                LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")
            end

            if getsenv then
                local Success, ScriptEnv = pcall(getsenv, LocalScript)

                if Success and ScriptEnv then
                    HIT_FUNCTION = ScriptEnv._G.SendHitsToServer
                end
            end
        end)

        function Combat:GetFolder()
            return { Enemies, Configuration['Attack Players'] and Characters or nil }
        end

        function Combat:Process(Closest)
            local BladeHits = {}

            local Folders = self:GetFolder()

            for _, List in ipairs(Folders) do

                if not List then continue end

                for _, Enemy in List:GetChildren() do

                    if Enemy == Closest then continue end

                    if not Module:IsAlive(Enemy) then continue end

                    local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart")

                    if not HumanoidRootPart then continue end

                    table.insert(BladeHits, { Enemy, HumanoidRootPart })
                end
            end

            return BladeHits
        end

        function Combat:Fired(Target, Data)
            RegisterAttack:FireServer(0.5)

            if HIT_FUNCTION then
                return HIT_FUNCTION(Target, Data)
            end

            RegisterHit:FireServer(Target, Data)
        end

        function Combat:Attack()
            local Folders = self:GetFolder()

            for _, List in ipairs(Folders) do

                if not List then continue end

                for _, Enemy in List:GetChildren() do

                    if Enemy == Character then continue end

                    if not Module:IsAlive(Enemy) then continue end

                    if Module:Distance(Enemy:GetPivot()) >= Combat.RANGE then continue end

                    local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart")

                    if not HumanoidRootPart then continue end

                    Combat:Fired(HumanoidRootPart, Combat:Process(Enemy))
                end
            end
        end

        function Combat:Slash(Tool)
            local LeftClickRemote = Tool:FindFirstChild('LeftClickRemote')

            if not LeftClickRemote then return end

            local Folders = self:GetFolder()

            for _, List in ipairs(Folders) do

                if not List then continue end

                for _, Enemy in List:GetChildren() do

                    if Enemy == Character then continue end

                    if not Module:IsAlive(Enemy) then continue end

                    if Module:Distance(Enemy:GetPivot()) >= Combat.RANGE then continue end

                    local BasePart = Enemy:FindFirstChild("HumanoidRootPart")

                    if not BasePart then continue end

                    local Unit = Module:Unit(BasePart)

                    if Data[tostring(Tool)] then
                        Data[tostring(Tool)](LeftClickRemote, Unit)
                    else
                        LeftClickRemote:FireServer(Unit, 1)
                    end
                end
            end
        end

        Connect(RenderStepped, function()
            if not Configuration['Fast Attack'] then return end

            if not IsAlive() then return end

            if not Backpack then return end

            local Equiped = Character and Character:FindFirstChildOfClass("Tool")

            if not Equiped then return end

            local Name = tostring(Equiped)

            if Name == 'Ice-Ice' or Name == 'Light-Light' or Equiped.ToolTip ~= 'Blox Fruit' then
                return Combat:Attack()
            end

            return Combat:Slash(Equiped)
        end)

        return Combat
    end)

    AddModule("Quest", function()
        local Quest = {
            Quests = require(ReplicatedStorage:WaitForChild('Quests')),
            GuideModule = require(ReplicatedStorage:WaitForChild('GuideModule')),
            Blacklist = { "BartiloQuest", "MarineQuest", "CitizenQuest" },
        }

        function Quest:GetMonster(CurrentLevel)
            local Data, Levels = {}, {}
            local Maximum = ({ {0, 700}, {700, 1500}, {1500, math.huge} })[Module.Sea]

            for name, task in pairs(Quest.Quests) do

                if table.find(Quest.Blacklist, name) then
                    continue
                end

                for num, mission in pairs(task) do
                    local Level = mission.LevelReq
                    local Monster, Value = next(mission.Task)

                    if Level >= Maximum[1] and Level < Maximum[2] and CurrentLevel >= Level and Value > 1 then

                        table.insert(Levels, Level)

                        Data[tostring(Level)] = {
                            Name = mission.Name,
                            Level = num,
                            Monster = Monster,
                        }
                    end
                end
            end

            return Data[tostring(math.max(unpack(Levels)))]
        end

        function Quest:NPCsData(CurrentLevel)
            local Data, Levels = {}, {}

            for _, Npcs in pairs(Quest.GuideModule['Data']['NPCList']) do
                local Level = Npcs.Levels[1]

                if CurrentLevel >= Level then

                    table.insert(Levels, Level)

                    Data[tostring(Level)] = {
                        ['Position'] = Npcs.Position,
                        ['Quest'] = Npcs.InternalQuestName,
                    }
                end
            end

            return Data[tostring(math.max(unpack(Levels)))]
        end

        function Quest:GetQuest(CurrentLevel)
            local Level = CurrentLevel.Value

            if Level == 1 and Level <= 9 then
                if tostring(LocalPlayer.Team) == "Marines" then
                    return {
                        ['Name'] = "Trainees",
                        ['Monster'] = "Trainee",
                        ['Level'] = 1,
                        ['Quest'] = "MarineQuest",
                        ['Position'] = CFrame.new(1059, 15, 1550),
                    }
                elseif tostring(LocalPlayer.Team) == "Pirates" then
                    return {
                        ['Name'] = "Bandits",
                        ['Monster'] = "Bandit",
                        ['Level'] = 1,
                        ['Quest'] = "BanditQuest1",
                        ['Position'] = CFrame.new(-2711, 24, 2104),
                    }
                end

                return
            end

            local Data = self:GetMonster(Level)
            local NPCsData = self:NPCsData(Level)

            Data['Quest'] = NPCsData.Quest
            Data['Position'] = CFrame.new(NPCsData.Position)

            return Data
        end

        return Quest
    end)

    AddModule("EnemiesModule", function()
        local EnemiesModule = CreateDictionary({
            "__CakePrince", "__PirateRaid", "__RaidBoss", "__TyrantSkies", "__Bones", "__Elite", "__Others", 
        }, {})

        local SeaCastle = CFrame.new(-5556, 314, -2988)

        local TagsMobs = {
            __Elite = CreateDictionary({ "Deandre", "Diablo", "Urban" }, true),
            __Bones = CreateDictionary({ "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy" }, true),
            __CakePrince = CreateDictionary({ "Head Baker", "Baking Staff", "Cake Guard", "Cookie Crafter" }, true),
            __TyrantSkies = CreateDictionary({ "Sun-kissed Warrior", "Skull Slayer", "Isle Champion", "Serpent Hunter" }, true)
        }

        local Attachment = Instance.new("Attachment") do
            local AlignPosition = Instance.new("AlignPosition")
            AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
            AlignPosition.Position = Vector3.new(0, 20, 0)
            AlignPosition.Responsiveness = 200
            AlignPosition.MaxForce = math.huge
            AlignPosition.Parent = Attachment
            AlignPosition.Attachment0 = Attachment
        end

        local function New(list, NewEnemy)
            if table.find(list, NewEnemy) then return end

            local Humanoid = NewEnemy:WaitForChild("Humanoid")

            if Humanoid and Humanoid.Health > 0 then
                table.insert(list, NewEnemy)

                Humanoid.Died:Wait()

                local index = table.find(list, NewEnemy)

                if index then table.remove(list, index) end
            end
        end

        local function IsFromPiratesSea(Enemy)
            if not Enemy:WaitForChild("Humanoid") or Enemy.Humanoid.Health <= 0 then return end

            local HumanoidRootPart = Enemy:WaitForChild("HumanoidRootPart")

            if HumanoidRootPart and (Enemy.Name ~= "rip_indra True Form" and Enemy.Name ~= "Blank Buddy") then
                if (HumanoidRootPart.Position - SeaCastle.Position).Magnitude <= 750 then
                    task.spawn(New, EnemiesModule.__PirateRaid, Enemy)
                    Module.PirateRaid = tick()
                end
            end
        end

        local function NewEnemyAdded(Enemy)
            local EnemyName = Enemy.Name
            local Others = EnemiesModule.__Others

            Others[EnemyName] = Others[EnemyName] or {}
            task.spawn(New, Others[EnemyName], Enemy)

            if Module.Sea == 3 then
                task.spawn(IsFromPiratesSea, Enemy)
            end

            if Enemy:GetAttribute("RaidBoss") then
                task.spawn(New, EnemiesModule.__RaidBoss, Enemy)
            elseif EnemiesModule["__" .. EnemyName] then
                task.spawn(New, EnemiesModule["__" .. EnemyName], Enemy)
            else
                for Tag, Mobs in pairs(TagsMobs) do
                    if Mobs[EnemyName] then
                        task.spawn(New, EnemiesModule[Tag], Enemy)
                        break
                    end
                end
            end
        end

        function EnemiesModule:IsSpawned(EnemyName)
            local Cached = Module.SpawnLocations[EnemyName]

            if Cached and Cached.Parent then
                return (Cached:GetAttribute("Active") or EnemiesModule:GetEnemyByTag(EnemyName)) and true or false
            end

            return EnemiesModule:GetEnemyByTag(EnemyName) and true or false
        end

        function EnemiesModule:GetTagged(TagName)
            return self["__" .. TagName] or self.__Others[TagName]
        end

        function EnemiesModule:GetEnemyByTag(TagName)
            local CachedEnemy = Cached.Enemies[TagName]

            if CachedEnemy and IsAlive(CachedEnemy) then
                return CachedEnemy
            end

            local Enemies = self:GetTagged(TagName)

            if Enemies and #Enemies > 0 then
                for i = 1, #Enemies do
                    local Enemy = Enemies[i]

                    if Module:IsAlive(Enemy) then
                        Cached.Enemies[TagName] = Enemy
                        return Enemy
                    end
                end
            end
        end

        function EnemiesModule:GetClosest(Enemies)
            local SpecialTag = table.concat(Enemies, ".")
            local CachedEnemy = Cached.Enemies[SpecialTag]

            if CachedEnemy and Module:IsAlive(CachedEnemy) then
                return CachedEnemy
            end

            local Distance, Nearest = math.huge, nil

            for i = 1, #Enemies do
                local Enemy = self:GetClosestByTag(Enemies[i])
                local Magnitude = Enemy and LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

                if Enemy and Magnitude <= Distance then
                    Distance, Nearest = Magnitude, Enemy
                end
            end

            if Nearest then
                Cached.Enemies[SpecialTag] = Nearest
                return Nearest
            end
        end

        function EnemiesModule:GetClosestByTag(TagName)
            local CachedEnemy = Cached.Enemies[TagName]

            if CachedEnemy and Module:IsAlive(CachedEnemy) then
                return CachedEnemy
            end

            local Enemies = self:GetTagged(TagName)

            if Enemies and #Enemies > 0 then
                local Distance, Nearest = math.huge, nil

                local Position = Character and Character:GetPivot().Position

                for i = 1, #Enemies do
                    local Enemy = Enemies[i]
                    local PrimaryPart = Enemy.PrimaryPart

                    if PrimaryPart and Module:IsAlive(Enemy) then
                        local Magnitude = (Position - PrimaryPart.Position).Magnitude

                        if Magnitude <= 15 then
                            Cached.Enemies[TagName] = Enemy
                            return Enemy
                        elseif Magnitude <= Distance then
                            Distance, Nearest = Magnitude, Enemy
                        end
                    end
                end

                if Nearest then
                    Cached.Enemies[TagName] = Nearest
                    return Nearest
                end
            end
        end

        function EnemiesModule:GetReplicated(name)
            local Nearest, Distance = nil, math.huge
            local EnemiesList = ReplicatedStorage:GetChildren()

            for i = 1, #EnemiesList do
                local Enemy = EnemiesList[i]

                if not Enemy:IsA('Model') then continue end

                if not Enemy.PrimaryPart then continue end

                if not ValidData(name, Enemy) then continue end

                if not Module:IsAlive(Enemy) then continue end

                local Magnitude = Module:Distance(Enemy.PrimaryPart.Position)

                if Magnitude <= Distance then
                    Distance, Nearest = Magnitude, Enemy
                end
            end

            return Nearest
        end

        function EnemiesModule:GetEnemies(Range, Name)
            local Nearest, Distance = nil, math.huge
            local EnemiesList = Enemies:GetChildren()

            for i = 1, #EnemiesList do
                local Enemy = EnemiesList[i]

                if not Enemy.PrimaryPart then continue end

                if not ValidData(Name, Enemy) then continue end

                if not Module:IsAlive(Enemy) then continue end

                local Magnitude = Module:Distance(Enemy.PrimaryPart.Position)

                if (not Range or Magnitude < Range) and Magnitude < Distance then
                    Distance, Nearest = Magnitude, Enemy
                end
            end

            return Nearest
        end

        local function Bring(Enemy)
            local RootPart = Enemy:WaitForChild("HumanoidRootPart")
            local Humanoid = Enemy:WaitForChild("Humanoid")
            local EnemyName = Enemy.Name

            local CloneAttachment = Attachment:Clone()
            local AlignPosition = CloneAttachment.AlignPosition
            CloneAttachment.Parent = RootPart

            while Enemy and Enemy.Parent == Enemies and Enemy:HasTag(BRING_TAG) do
                if not Humanoid or Humanoid.Health <= 0 then break end
                if not RootPart or RootPart.Parent ~= Enemy then break end

                local Target = Cached.Bring[Module.IsSuperBring and "ALL_MOBS" or EnemyName]

                if Target and (Target.Position - RootPart.Position).Magnitude <= Configuration["Bring Distance"] then
                    if AlignPosition.Position ~= Target.Position then
                        AlignPosition.Position = Target.Position
                    end
                else
                    break
                end;task.wait()
            end

            if Enemy and Enemy:HasTag(BRING_TAG) then Enemy:RemoveTag(BRING_TAG) end
            if CloneAttachment then CloneAttachment:Destroy() end
        end

        local function KillAura(Enemy)
            local Humanoid = Enemy:FindFirstChild("Humanoid")
            local RootPart = Enemy:FindFirstChild("HumanoidRootPart")

            pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)

            if Humanoid and RootPart then
                RootPart.CanCollide = false
                RootPart.Size = Vector3.new(60, 60, 60)

                Humanoid:ChangeState(15)
                Humanoid.Health = 0

                task.wait()

                Enemy:RemoveTag(KILLAURA_TAG)
            end
        end

        for _, Enemy in CollectionService:GetTagged("BasicMob") do NewEnemyAdded(Enemy) end
        Connect(CollectionService:GetInstanceAddedSignal("BasicMob"), NewEnemyAdded)
        Connect(CollectionService:GetInstanceAddedSignal(KILLAURA_TAG), KillAura)
        Connect(CollectionService:GetInstanceAddedSignal(BRING_TAG), Bring)

        return EnemiesModule
    end)

    AddModule("BodyVelocity", function()
        local BodyVelocity = Instance.new("BodyVelocity") do
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.P = 1000
        end

        local Highlight = Instance.new("Highlight") do
            Highlight.FillColor = Color3.fromRGB(255, 0, 127)
            Highlight.OutlineColor = Color3.fromRGB(255, 0, 127)
            Highlight.FillTransparency = 0.3
        end

        if _ENV.tween_bodyvelocity then
            _ENV.tween_bodyvelocity:Destroy()
        end

        if _ENV.highlight then
            _ENV.highlight:Destroy()
        end

        _ENV.highlight = Highlight
        _ENV.tween_bodyvelocity = BodyVelocity

        local CanCollideObjects = {}

        local function AddObjectToBaseParts(Object)
            if Object:IsA("BasePart") and Object.CanCollide then
                table.insert(CanCollideObjects, Object)
            end
        end

        local function RemoveObjectsFromBaseParts(BasePart)
            local index = table.find(CanCollideObjects, BasePart)

            if index then
                table.remove(CanCollideObjects, index)
            end
        end

        local function NewCharacter(Character)
            if not Character then return end

            table.clear(CanCollideObjects)

            for _, Object in Character:GetDescendants() do AddObjectToBaseParts(Object) end
            Character.DescendantAdded:Connect(AddObjectToBaseParts)
            Character.DescendantRemoving:Connect(RemoveObjectsFromBaseParts)
        end

        Connect(LocalPlayer.CharacterAdded, NewCharacter)
        task.spawn(NewCharacter, Character)

        local function NoClipOnStepped(Character)
            if _ENV.OnFarm then
                for i = 1, #CanCollideObjects do
                    CanCollideObjects[i].CanCollide = false
                end
            elseif Character.PrimaryPart and not Character.PrimaryPart.CanCollide then
                for i = 1, #CanCollideObjects do
                    CanCollideObjects[i].CanCollide = true
                end
            end
        end

        local function UpdateVelocityOnStepped(Character)
            local BasePart = Character:FindFirstChild("UpperTorso")
            local Humanoid = Character:FindFirstChild("Humanoid")
            local BodyVelocity = _ENV.tween_bodyvelocity
            local Highlight = _ENV.highlight

            if _ENV.OnFarm and BasePart and Humanoid and Humanoid.Health > 0 then
                if BodyVelocity.Parent ~= BasePart then
                    BodyVelocity.Parent = BasePart
                end

                if Highlight.Parent ~= Character then
                    Highlight.Parent = Character
                end
            elseif BodyVelocity.Parent then
                BodyVelocity.Parent = nil
                Highlight.Parent = nil
            end

            if BodyVelocity.Velocity ~= Vector3.zero and (not Humanoid or not Humanoid.SeatPart or not _ENV.OnFarm) then
                BodyVelocity.Velocity = Vector3.zero
                Highlight.Parent = nil
            end
        end

        Connect(RunService.Stepped, function()
            if IsAlive() then
                UpdateVelocityOnStepped(Character)
                NoClipOnStepped(Character)
            end
        end)

        return BodyVelocity
    end)

    AddModule("Inventory", function()
        local Cache = {
            ['Unlocked'] = setmetatable({}, { __index = function() return false end }),
            ['Mastery'] = setmetatable({}, { __index = function() return 0 end }),
            ['Count'] = setmetatable({}, { __index = function() return 0 end }),
            ['MasteryRequirements'] = {},
            ['Items'] = {},
        }

        function Cache:Counts(str)
            return self.Count[str]
        end

        function Cache:HaveFruit()
            if not IsAlive() then return end

            if not Backpack then return end

            for _, v in Backpack:GetChildren() do
                if string.find(v.Name,"Fruit") then
                    return true
                end
            end

            for _, v in Character:GetChildren() do
                if string.find(v.Name,"Fruit") then
                    return true
                end
            end

            return false
        end

        function Cache:Fruit(IsNotLower)
            local Fruits = {}

            for _, v in next, Module:ComF("GetFruits") do
                if IsNotLower and v.Price >= 999999 or v.Price <= 999999 then
                    Fruits[v.Name] = v.Price
                end
            end

            return Fruits
        end 

        function Cache:Search(High)
            local MaxValue, Fruits = math.huge, nil
            local List = self:Fruit(High)

            for _, v in Module:ComF("getInventory") do
                if v['Type'] ~= "Blox Fruit" then continue end

                for Name, Value in List do
                    if v.Name ~= Name then continue end

                    if tonumber(Value) < tonumber(MaxValue) then
                        MaxValue = Value
                        Fruits = Name
                    end
                end
            end

            return Fruits
        end

        function Cache:UnStore(IsHigh)
            local Fruits = self:Search(IsHigh)

            if self:HaveFruit() or not Fruits then return end

            return Module:ComF("LoadFruit", Fruits)
        end

        function Cache:UpdateItem(item)
            if type(item) == "table" then
                if item.Type == "Wear" then
                    item.Type = "Accessory"
                end

                local Name = item.Name

                self.Items[Name] = item

                if not self.Unlocked[Name] then self.Unlocked[Name] = true end
                if item.Count then self.Count[Name] = item.Count end
                if item.Mastery then self.Mastery[Name] = item.Mastery end
                if item.MasteryRequirements then self.MasteryRequirements[Name] = item.MasteryRequirements end
            end
        end

        function Cache:RemoveItem(ItemName)
            if type(ItemName) == "string" then
                self.Unlocked[ItemName] = nil
                self.Mastery[ItemName] = nil
                self.Count[ItemName] = nil
                self.Items[ItemName] = nil
            end
        end

        local function OnClientEvent(Method, ...)
            if Method == "ItemChanged" then
                Cache:UpdateItem(...)
            elseif Method == "ItemAdded" then
                Cache:UpdateItem(...)
            elseif Method == "ItemRemoved" then
                Cache:RemoveItem(...)
            end
        end

        task.spawn(function()
            Connect(CommE.OnClientEvent, OnClientEvent)

            local InventoryItems = nil

            repeat
                task.wait(1)
                InventoryItems = Module:ComF("getInventory")
            until type(InventoryItems) == "table"

            for index = 1, #InventoryItems do
                Cache:UpdateItem(InventoryItems[index])
            end
        end)

        return Cache
    end)

    AddModule("Workspace", function()
        local Workspace = {}

        local ColorMap = {
            ["Really red"] = "Pure Red",
            ["Oyster"]    = "Snow White",
            ["Hot pink"]  = "Winter Sky"
        }

        function Workspace:Chest()
            local Chests = CollectionService:GetTagged("_ChestTagged")
            local Distance, Nearest = math.huge, nil

            for i = 1, #Chests do
                local Chest = Chests[i]
                local Magnitude = (Chest:GetPivot().Position - HumanoidRootPart.Position).Magnitude

                if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
                    Distance, Nearest = Magnitude, Chest
                end
            end

            return Nearest
        end

        function Workspace:Berry()
            local Position = HumanoidRootPart.Position
            local BerryBush = CollectionService:GetTagged("BerryBush")

            local Distance = math.huge
            local Nearest = nil

            for i = 1, #BerryBush do
                local Bush = BerryBush[i]

                for _, BerryName in pairs(Bush:GetAttributes()) do
                    local BushPosition = Bush.Parent:GetPivot().Position
                    local Magnitude = Module:Distance(BushPosition)

                    if Magnitude < Distance then
                        Nearest = Bush
                        Distance = Magnitude
                    end
                end
            end

            return Nearest
        end

        function Workspace:Raid()
            for i = 5, 1, -1 do
                local Name = "Island " .. i

                for _, Island in ipairs(Locations:GetChildren()) do
                    if Island.Name ~= Name then continue end

                    if Module:Distance(Island.Position) < 3500 then
                        return Island
                    end
                end
            end
        end

        function Workspace:Tree(EagleBossArena)
            local Nearest = nil
            local Distance = math.huge

            for _, v in EagleBossArena:GetChildren() do
                if v.Name ~= "Tree" then continue end

                if not v:IsA("Model") then continue end

                if not v.PrimaryPart then continue end

                local Magnitude = Module:Distance(v.PrimaryPart.Position)

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Workspace:Players(MaxDistance)
            local Nearest = nil
            local Distance = math.huge

            for _, v in Characters:GetChildren() do
                if v == Character then continue end

                if not Module:IsAlive(v) then continue end

                local Magnitude = Module:Distance(v:GetPivot())

                if (not MaxDistance or Magnitude < MaxDistance) and Magnitude < Distance then
                    Nearest = v
                    Distance = Magnitude
                end
            end

            return Nearest
        end

        function Workspace:GetShip(name)
            for _, v in Boats:GetChildren() do
                if v.Name == name and v.Name ~= LocalPlayer.Name then
                    return v
                end
            end
        end

        function Workspace:GetLavaRocks(VolcanoRocks)
            local Nearest = nil
            local Distance = math.huge

            for _, v in VolcanoRocks:GetChildren() do
                local LavaEffect = v:FindFirstChild("At1Beam", true)

                if not v:IsA("Model") then continue end

                if not LavaEffect then continue end

                if not LavaEffect.Enabled then continue end

                local Magnitude = Module:Distance(v:GetPivot())

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Workspace:GetGift()
            for _, v in WorldOrigin:GetChildren() do
                if v.Name ~= "Present" then continue end

                local Name = v:FindFirstChild('Value', true)

                if not Name then continue end

                if tostring(Name.Value) == LocalPlayer.Name then
                    return v
                end
            end
        end

        function Workspace:ParseTime(timeText)
            local hours, minutes, seconds = timeText:match("(%d+):(%d+):(%d+)")

            if hours and minutes and seconds then
                return tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
            end

            local mins, secs = timeText:match("(%d+):(%d+)")

            if mins and secs then
                return tonumber(mins) * 60 + tonumber(secs)
            end

            return 0
        end

        function Workspace:ValidColors(Part)
            if Part and Part.BrickColor then
                return tostring(Part.BrickColor) == "Lime green"
            end

            return false
        end

        function Workspace:CalculateColors(Part)
            if Part and Part.BrickColor then
                return ColorMap[tostring(Part.BrickColor)]
            end
        end

        function Workspace:GetPartColors(Circle)
            for _, v in Circle:GetChildren() do
                if v:IsA("Part") and not self:ValidColors(v) then
                    return v
                end
            end
        end

        return Workspace
    end)

    AddModule("Ocean", function()
        local Ocean = {}

        local ZoneCoordinates = {
            ['Infinite - ∞'] = {-9999999, 9999999},
            ['Low - 1'] = {-21227, 4047},
            ['Meduim - 2'] = {-24237, 6381},
            ['High - 3'] = {-27105, 8959},
            ['Extreme - 4'] = {-29350, 11744},
            ['Crazy - 5'] = {-32404, 16208},
            ['??? - 6'] = {-35611, 20548},
        }

        local TargetAnims = {
            "rbxassetid://8708225668",
            "rbxassetid://8708223619",
            "rbxassetid://8708222938"
        }

        function Ocean:Zone()
            local Coords = ZoneCoordinates[Configuration['Select Zone']]

            if Coords then
                return CFrame.new(Coords[1], 100, Coords[2])
            end

            return CFrame.new(-9999999, 100, 9999999)
        end

        function Ocean:IsAlive(v)
            return v:FindFirstChild("Health") and v.Health.Value > 0
        end

        function Ocean:RemoveBoatCollision(Boat)
            local Objects = Boat:GetDescendants()

            for i = 1, #Objects do
                local BasePart = Objects[i]

                if BasePart:IsA("BasePart") and BasePart.CanCollide then
                    BasePart.CanCollide = false
                end
            end
        end

        local function IsOwnerShip(Model)
            local Owner = Model:FindFirstChild("Owner")

            if not Owner or not Owner:IsA("ObjectValue") then
                return
            end

            if tostring(Owner.Value) ~= LocalPlayer.Name then
                return
            end

            return true
        end

        function Ocean:Ship(name)
            local Nearest = nil
            local Distance = 5000

            for _, v in Boats:GetChildren() do
                if v.Name ~= name then continue end

                if not v:GetAttribute("IsBoat") then continue end

                if not IsOwnerShip(v) then continue end

                local Humanoid = v:FindFirstChild("Humanoid")

                if not Humanoid then continue end

                if tonumber(Humanoid.Value) <= 0 then continue end

                local Magnitude = Module:Distance(v:GetPivot())

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Ocean:Drive(Ship, Target, High)
            local VehicleSeat = Ship:FindFirstChild("VehicleSeat")

            local Position = VehicleSeat.Position
            local Distance = (Position.Position - Target.Position).Magnitude

            local BodyPosition = VehicleSeat:FindFirstChild("BodyPosition")
            local BodyVelocity = BodyPosition and BodyPosition:FindFirstChild("BodyVelocity")

            if not BodyVelocity then return end

            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyPosition.MaxForce = Vector3.zero
            BodyVelocity.P = 0

            local Info = TweenInfo.new(Distance / 300, Enum.EasingStyle.Linear)
            local Tween = TweenService:Create(VehicleSeat, Info, { CFrame = Position })

            _ENV.StopShip = function()
                if Tween then Tween:Cancel() end
            end

            VehicleSeat.CFrame = CFrame.new(Position.X, High or 100, Position.Z)

            Tween:Play()
        end

        function Ocean:Seabeast()
            local Nearest = nil
            local Distance = 5000

            for _, v in SeaBeasts:GetChildren() do
                if not self:IsAlive(SeaBeasts) then continue end

                local HumanoidRootPart = HumanoidRootPart:FindFirstChild("HumanoidRootPart")

                if not HumanoidRootPart then continue end

                local Magnitude = Module:Distance(HumanoidRootPart.Position)

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        function Ocean:IsSeaBeastHiding(Animator)
            for _, Track in Animator:GetPlayingAnimationTracks() do
                if TargetAnims[Track.Animation.AnimationId] then
                    return true
                end
            end
        end

        function Ocean:GetEnemiesShip(Name)
            local Nearest = nil
            local Distance = 5000

            for _, v in Enemies:GetChildren() do
                if not table.find(Name, v.Name) then continue end

                if not self:IsAlive(v) then continue end

                if not v:FindFirstChild("Seat", true) then continue end

                local Magnitude = Module:Distance(v:GetPivot().Position)

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        return Ocean
    end)

    AddModule("Skill", function()
        local SkillModule = {}

        local CurrentTool, LastSkillUse = nil, 0
        local Skills = PlayerGui.Main.Skills
        local IsReloading = false
        local OnFirstTime = true

        local function GetEnabledSkills()
            return {
                ['Melee'] = Configuration['Melee'] or { "Z", "X", "C" },
                ['Sword'] = Configuration['Sword'] or { "Z", "X" },
                ['Gun'] = Configuration['Gun'] or { "Z", "X" },
                ['Blox Fruit'] = Configuration['Blox Fruit'] or { "Z", "X", "C" }
            }
        end

        local function GetEnabledList(ToolName)
            local Tool = Backpack:FindFirstChild(ToolName) or Character:FindFirstChild(ToolName)

            return Tool and GetEnabledSkills()[Tool.ToolTip] or {}
        end

        local function IsToolValid(ToolFrame)
            if not ToolFrame or not ToolFrame:IsA("Frame") then return false end

            local Tool = Backpack:FindFirstChild(ToolFrame.Name) or Character:FindFirstChild(ToolFrame.Name)

            if not Tool then return false end

            local EnabledList = GetEnabledSkills()[Tool.ToolTip]

            return EnabledList and #EnabledList > 0
        end

        local function IsSkillUnlocked(Skill)
            local Title = Skill:FindFirstChild("Title")

            return Title and Title.TextColor3 == Color3.fromRGB(255, 255, 255)
        end

        local function IsSkillOnCooldown(Skill)
            local Cooldown = Skill:FindFirstChild("Cooldown")

            return Cooldown and Cooldown.Size.X.Scale > 0
        end

        local function IsSkillReady(Skill, ToolName)
            return table.find(GetEnabledList(ToolName), Skill.Name) and IsSkillUnlocked(Skill) and not IsSkillOnCooldown(Skill)
        end

        local function FindReadySkill(ToolContainer, ToolName)
            for _, Skill in ToolContainer:GetChildren() do
                if not Skill:IsA("Frame") or Skill.Name == "Template" then continue end

                if IsSkillReady(Skill, ToolName) then
                    return Skill.Name
                end
            end
        end

        local function FindLowestCooldownSkill(ToolContainer, ToolName)
            local SelectedSkill, LowestCooldown = nil, math.huge
            local EnabledList = GetEnabledList(ToolName)

            for _, Skill in ToolContainer:GetChildren() do
                if not Skill:IsA("Frame") or Skill.Name == "Template" then continue end

                if not IsSkillUnlocked(Skill) or not table.find(EnabledList, Skill.Name) then continue end

                local Cooldown = Skill:FindFirstChild("Cooldown")

                if not Cooldown or Cooldown.Size.X.Scale >= LowestCooldown then continue end

                LowestCooldown, SelectedSkill = Cooldown.Size.X.Scale, Skill.Name
            end

            return SelectedSkill
        end

        local function GetBestSkill(CurrentToolName)
            if CurrentToolName then
                local ToolContainer = Skills:FindFirstChild(CurrentToolName)

                if ToolContainer and IsToolValid(ToolContainer) then
                    local SkillName = FindReadySkill(ToolContainer, CurrentToolName)

                    if SkillName then
                        return CurrentToolName, SkillName
                    end
                end
            end

            local BestTool, BestSkill, LowestCooldown = nil, nil, math.huge

            for _, Tool in Skills:GetChildren() do
                if not Tool:IsA("Frame") or Tool.Name == "Container" then continue end

                if not IsToolValid(Tool) then continue end

                if Tool.Name == CurrentToolName then continue end

                local SkillName = FindReadySkill(Tool, Tool.Name)

                if SkillName then return Tool.Name, SkillName end

                local LowestSkill = FindLowestCooldownSkill(Tool, Tool.Name)

                if not LowestSkill then continue end

                local SkillFrame = Tool:FindFirstChild(LowestSkill)
                local Cooldown = SkillFrame and SkillFrame:FindFirstChild("Cooldown")

                if not Cooldown or Cooldown.Size.X.Scale >= LowestCooldown then continue end

                LowestCooldown, BestTool, BestSkill = Cooldown.Size.X.Scale, Tool.Name, LowestSkill
            end

            if not BestTool and CurrentToolName then
                local ToolContainer = Skills:FindFirstChild(CurrentToolName)

                if ToolContainer and IsToolValid(ToolContainer) then
                    local LowestSkill = FindLowestCooldownSkill(ToolContainer, CurrentToolName)

                    if LowestSkill then
                        return CurrentToolName, LowestSkill
                    end
                end
            end

            return BestTool, BestSkill
        end

        local function EquipTool(ToolName)
            if not IsAlive() then return false end

            local Tool = Backpack:FindFirstChild(ToolName)

            if not Tool then return false end

            if Tool:GetAttribute("Locks") then
                Tool:SetAttribute("Locks", nil)
            end

            if not Character:FindFirstChild(ToolName) then
                Humanoid:EquipTool(Tool)

                local Timeout = tick() + 1

                while not Character:FindFirstChild(ToolName) and tick() < Timeout do
                    task.wait()
                end
            end

            return Character:FindFirstChild(ToolName) ~= nil
        end

        local function OnToolAdded(Tool)
            if not Tool:IsA("Tool") then return end

            local EnabledSkills = GetEnabledSkills()

            if not EnabledSkills[Tool.ToolTip] then return end

            if Skills:FindFirstChild(Tool.Name) then return end

            IsReloading = true

            task.wait(0.5)

            Humanoid:UnequipTools()

            CurrentTool = nil

            Module:Equip(Tool.ToolTip, true)

            Humanoid:UnequipTools()

            IsReloading = false
        end

        local function BindBackpack()
            if _ENV.Reload then _ENV.Reload:Disconnect() end
            _ENV.Reload = Connect(Backpack.ChildAdded, OnToolAdded)
        end

        function SkillModule:Use()
            if OnFirstTime then
                OnFirstTime = false do
                    return Module:Equip("Melee", true) 
                end
            end

            if IsReloading then return end
            if tick() - LastSkillUse < 0.2 then return end

            local ToolName, SkillName = GetBestSkill(CurrentTool)

            if not ToolName or not SkillName then return end

            if CurrentTool ~= ToolName then
                if not EquipTool(ToolName) then
                    Humanoid:UnequipTools()
                    task.wait(0.25)

                    for _, ToolType in pairs({"Melee", "Sword", "Gun", "Blox Fruit"}) do
                        Module:Equip(ToolType, true)
                        task.wait(0.15)
                    end

                    return
                end

                CurrentTool = ToolName
                task.wait(0.15)
            end

            if not Character:FindFirstChild(ToolName) then
                CurrentTool = nil
                return
            end

            LastSkillUse = tick()

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[SkillName], false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[SkillName], false, game)
        end

        task.spawn(BindBackpack)

        Connect(LocalPlayer.CharacterAdded, function(v)
            Character = v
            Head = v:WaitForChild("Head", 10)
            Humanoid = v:WaitForChild("Humanoid", 10)
            HumanoidRootPart = v:WaitForChild("HumanoidRootPart", 10)
            Backpack = LocalPlayer.Backpack

            CurrentTool = nil
            IsReloading = false

            warn("Spawn", Character, Humanoid, HumanoidRootPart, Backpack)

            BindBackpack()
        end)

        return SkillModule
    end)

    task.spawn(function()
        local SpawnLocations = Module.SpawnLocations
        local EnemyLocations = Module.EnemyLocations

        local function NewIslandAdded(Island)
            if Island.Name:find("Island") then
                Cached.RaidIsland = nil
            end
        end

        local function NewSpawn(Part)
            local EnemyName = GetEnemyName(Part.Name)
            EnemyLocations[EnemyName] = EnemyLocations[EnemyName] or {}

            local EnemySpawn = Part.CFrame + Vector3.new(0, 25, 0)
            SpawnLocations[EnemyName] = Part

            if not table.find(EnemyLocations[EnemyName], EnemySpawn) then
                table.insert(EnemyLocations[EnemyName], EnemySpawn)
            end
        end

        for _, Spawn in EnemySpawns:GetChildren() do NewSpawn(Spawn) end
        Connect(EnemySpawns.ChildAdded, NewSpawn)
        Connect(Locations.ChildAdded, NewIslandAdded)

        local function ShouldStop(Breake)
            return not _ENV.OnFarm or not IsAlive() or (Breake and Breake())
        end

        local function WaitAtSpawnPoints(enemyName, spawnPoints, Breake, Teleport)
            if ShouldStop(Breake) then return end

            for _, spawnCFrame in pairs(spawnPoints) do
                if ShouldStop(Breake) then return end
                if Module.EnemiesModule:GetClosestByTag(enemyName) then return end

                Teleport(spawnCFrame)

                local waitStart = tick()
                local waitDelay = Configuration['Wait Enemies Delay'] or 0.75

                while tick() - waitStart < waitDelay do
                    if ShouldStop(Breake) then return end
                    if Module.EnemiesModule:GetClosestByTag(enemyName) then return end

                    task.wait(0.1)
                end

                if Module.EnemiesModule:GetClosestByTag(enemyName) then
                    return
                end

            end

            if not ShouldStop(Breake) and not Module.EnemiesModule:GetClosestByTag(enemyName) then
                WaitAtSpawnPoints(enemyName, spawnPoints, Breake, Teleport)
            end
        end

        local function WaitForEnemySpawn(Name, Breake, Teleport)
            if ShouldStop(Breake) then return end

            local enemyNames = type(Name) == "table" and Name or {Name}

            for _, enemyName in ipairs(enemyNames) do
                if ShouldStop(Breake) then return end
                if Module.EnemiesModule:GetClosestByTag(enemyName) then return end

                if Module.EnemiesModule:IsSpawned(enemyName) then
                    local spawnPoints = EnemyLocations[enemyName]

                    if spawnPoints then
                        WaitAtSpawnPoints(enemyName, spawnPoints, Breake, Teleport)
                    end
                end

                if ShouldStop(Breake) then return end
                if Module.EnemiesModule:GetClosestByTag(enemyName) then return end
            end
        end

        function Module:WaitForEnemy(Name, Breake, Teleport)
            return WaitForEnemySpawn(Name, Breake, Teleport)
        end
    end)

    task.defer(function()
        local function Log(code, message, context)
            return warn(string.format("[ Forbidden ] [ %03d ] [ %s ] \n%s",code,context,message))
        end

        if not _ENV._0riginal then
            local _Old

            _Old = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()

                if tostring(self) == "PlayerGui" then
                    if method == "Destroy" or method == "Remove" or method == "ClearAllChildren" then
                        return Log(
                            403,
                            "Access denied - PlayerGui:Destroy()",
                            "PlayerGui was locked by Antigravity."
                        )
                    end
                end

                if method == "FireServer" or method == "InvokeServer" then
                    local arg1, arg2 = ...

                    if method == "InvokeServer" and arg1 == 'X' and typeof(arg2) == 'Vector3' and self.Name == "" then
                        if Module.Aimbot:Check() then
                            return _Old(self, arg1, _ENV.Target)
                        end

                        return _Old(self, ...)
                    end

                    if method == "FireServer" and self.Name == "RemoteEvent" and typeof(arg1) == "Vector3" and arg2 == nil then
                        if Module.Aimbot:Check() then
                            return _Old(self, _ENV.Target)
                        end

                        return _Old(self, ...)
                    end
                end

                return _Old(self, ...)
            end)

            _ENV._0riginal = _Old

            do
                local Effect = ReplicatedStorage:WaitForChild('Effect')
                local Container = Effect:WaitForChild('Container')

                local Death = require(Container:WaitForChild('Death'))
                local Respawn = require(Container:WaitForChild('Respawn'))

                pcall(hookfunction, Death, function( ... )
                    return ( ... )
                end)

                pcall(hookfunction, Respawn, function( ... )
                    return ( ... )
                end)
            end
        end
    end)

    return Module
end)
