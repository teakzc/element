
local Package = script
local Packages = Package.Parent
local ObjectCache = require(Packages.objectcache)

local element = {}

local CachedTable = {}

local CustomCache = {}
local CachedTable2 = {}
CustomCache.__index = CustomCache

function CustomCache:Clone(): Instance
    if #(self.Storage) > 0 then
        local Clone: Instance = self.Part:Clone()
        Clone.Parent = self.CacheFolder
        table.insert(self.Usage, Clone)

        return Clone
    else
        local Clone: Instance = self.Storage[1]
        
        table.insert(self.Usage, Clone)
        self.Storage[table.find(self.Storage, Clone)] = nil

        return Clone
    end
end

function CustomCache:Return(Part: Instance)
    table.insert(self.Storage, Part)
    self.Usage[table.find(self.Usage, Part)] = nil
    Part.Parent = self.CacheFolder
end


function element.CreateCustomCache(Part: Instance)
    local self = setmetatable({
        Part = Part,
        Storage = {},
        Usage = {}
    }, CustomCache)

     if workspace:FindFirstChild("Container") == nil then
        local Container = Instance.new("Folder")
        Container.Name = "Container"
        Container.Parent = workspace
    end

    local Folder = Instance.new("Folder")
    Folder.Parent = workspace.Container
    Folder.Name =  Part.Name.."Cache"

    self.CacheFolder = Folder

    for i = 1, 10 do
        local Clone = Part:Clone()
        Clone.Parent = Folder
        table.insert(self.Storage, Clone)
    end

    CachedTable2[Part.Name] = self
end

function element:SetCache(Template: BasePart | Model, CacheSize: number)
    if workspace:FindFirstChild("Container") == nil then
        local Container = Instance.new("Folder")
        Container.Name = "Container"
        Container.Parent = workspace
    end

    CachedTable[Template.Name] = ObjectCache.new(Template, CacheSize, workspace.Container)
end

function element:Return(Part: Instance)
    if Part:IsA("BasePart") or Part:IsA("Model") then
        local Cache : nil | any = CachedTable[Part.Name]
        if Cache ~= nil then
            Cache:ReturnPart(Part);

            (Part :: any).Parent = Cache.CacheHolder;
        else
            error("Returning a part without a cache!")
        end
    else
        local Cache : nil | any = CachedTable2[Part.Name]
        if Cache == nil then
            CachedTable2[Part.Name] = element.CreateCustomCache(Part)
        end

        CachedTable2[Part.Name]:Return(Part)
    end
end

function element:Clone(Part: Instance, NewCFrame: CFrame?)
    if Part:IsA("BasePart") or Part:IsA("Model") then
        local Cache : nil | any = CachedTable[Part.Name]
        if Cache == nil then
            element:SetCache(Part, 10)
        end

        return CachedTable[Part.Name]:GetPart(NewCFrame)
    else
        local Cache : nil | any = CachedTable2[Part.Name]
        if Cache == nil then
            CachedTable2[Part.Name] = element.CreateCustomCache(Part)
        end

        return CachedTable2[Part.Name]:Clone()
    end
end

return element
