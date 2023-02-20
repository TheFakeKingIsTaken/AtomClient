repeat wait() until game:IsLoaded() == true

local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local setthreadidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity
local getthreadidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity
local getasset = getsynasset or getcustomasset
local cachedthings = {}
local cachedthings2 = {}
local cachedsizes = {}

local function betterisfile(path)
    if cachedthings2[path] == nil then
        cachedthings2[path] = isfile(path)
    end
    return cachedthings2[path]
end

local function getcustomassetfunc(path)
	if not isfile(path) then
		spawn(function()
            setthreadidentity(7)
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = game.CoreGui.RobloxGui
			repeat wait() until isfile(path)
			textlabel:Remove()
            setthreadidentity(2)
		end)
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/TheFakeKingIsTaken/AtomClient/main/"..path,
			Method = "GET"
		})
		writefile(path, req.Body)
	end
    if cachedthings[path] == nil then
        cachedthings[path] = getasset(path)
    end
	return cachedthings[path]
end

local function cachesize(image)
    local thing = Instance.new("ImageLabel")
    thing.Image = getcustomassetfunc(image)
    thing.Size = UDim2.new(1, 0, 1, 0)
    thing.ImageTransparency = 0.999
    thing.BackgroundTransparency = 1
    thing.Parent = game.CoreGui.RobloxGui
    spawn(function()
        cachedsizes[image] = 1
        repeat wait() until thing.IsLoaded and thing.ContentImageSize ~= Vector2.new(0, 0)
        local oldidentity = getthreadidentity()
        setthreadidentity(7)
        cachedsizes[image] = thing.ContentImageSize.X / 256
        setthreadidentity(oldidentity)
        thing:Remove()
    end)
end

local function downloadassets(path2)
    local json = requestfunc({
        Url = "https://api.github.com/repos/TheFakeKingIsTaken/AtomClient/contents/"..path2,
        Method = "GET"
    })
    local decodedjson = game:GetService("HttpService"):JSONDecode(json.Body)
    for i2,v2 in pairs(decodedjson) do
        if v2["type"] == "file" then
			getcustomassetfunc(path2.."/"..v2["name"])
		end
    end
end

if isfolder("AtomClient") == false then
	makefolder("AtomClient")
end
if isfolder("AtomClient/GameAssets") == false then
	makefolder("AtomClient/GameAssets")
end
if isfolder("AtomClient/Main") == false then
	makefolder("AtomClient/Main")
end
if isfile("AtomClient/Main/test") == false then
	makefile("AtomClient/Main/test")
end
downloadassets("AtomClient/GameAssets")
downloadassets("AtomClient/Main")
downloadassets("AtomClient/Main/test")
