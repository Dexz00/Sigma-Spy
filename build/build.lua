--// Libraries
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local Base64 = require("../lib/reselim/base64@3.0.0/Base64")

--// Configuration
local ConfigFile = fs.readFile(process.args[1])
local Config = serde.decode("json", ConfigFile)

local OutputFile = Config.output
local Tags = Config.tags
local DarkluaConfig = Config.darkluaconfig

local Frame = fs.readFile(Config.frame)
local MainFile = fs.readFile(Config.main)

local function GetTagPath(Tag: string, Path: string): string
    local TagPath = Tags[Tag]
    return Path:gsub(Tag, TagPath)
end

--// Good enough
local function GetPath(Path: string): string
    local IsTag = Path:sub(1,1) == "@"
    if IsTag then
        local Tag = Path:split("/")[1]
        Path = GetTagPath(Tag, Path)
    end

    return Path
end

-- Format: --COMPILE: path
local function ReplaceCompiles(Content: string): string
    local Match = '[%-]*%s*"(%s*COMPILE:%s*@[^"]+)"'

    for String in Content:gmatch(Match) do
        local PathReference = String:match('%s*COMPILE:%s*(@[^"]+)')
        local Path = GetPath(PathReference)

        local Contents = fs.readFile(Path)
        local ContentBuffer = buffer.fromstring(Contents)
        local Replacement = Base64:Encode(ContentBuffer)

        Content = Content:gsub(String, function()
            return buffer.tostring(Replacement)
        end)
    end

    return Content
end

-- Format: --INSERT: path
local function ReplaceInserts(Content: string): string
    local Match = "(%-%-%s*INSERT:%s*@?[^%s]+)"

    for String in Content:gmatch(Match) do
        local PathReference = String:match('%s*INSERT:%s*(@[^"]+)')
        local Path = GetPath(PathReference)

        local Contents = fs.readFile(Path)
        Content = Content:gsub(String, function()
            return Contents
        end)
    end

    return Content
end

--// Compile
local Processed = ReplaceCompiles(MainFile)
Processed = ReplaceInserts(Processed)
fs.writeFile(OutputFile, Processed)

local DarkLuaResponce = process.spawn("darklua", {
	"process",
	OutputFile,
	OutputFile,
	"-c",
	DarkluaConfig,
})

--// Print error message
if not DarkLuaResponce.ok then
	print(DarkLuaResponce.stderr)
	return
end

local Compiled = Frame
local DarkluaOut = fs.readFile(OutputFile)
Compiled ..= `\n{DarkluaOut}`

fs.writeFile(OutputFile, Compiled)