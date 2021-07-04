assert(is_synapse_function, "Synapse only!");

local Serializer = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/Lua-Serializer/main/Serializer.lua"))();

local function formatArgs(tbl)
    local Serialized = ""; 
    for i,v in pairs(tbl) do
        if type(v) == "string" then
            Serialized = Serialized .. "\"" .. v .. "\", ";
        else
            Serialized = Serialized .. tostring(v) .. ", ";
        end;
    end;
    return Serialized:sub(0, -3);
end;

-- Roblox HTTP Functions

local OldNameCall;
local RBXMethods = {
    ["HttpGet"] = true;
    ["HttpGetAsync"] = true;
    ["GetObjects"] = true;
    ["HttpPost"] = true;
    ["HttpPostAsync"] = true;
}

OldNameCall = hookmetamethod(game, "__namecall", function(self, ...) 
    local method = getnamecallmethod();
    local args = {...};

    if RBXMethods[method] then
        rconsoleinfo(("game:%s(%s)"):format(
            method,
            formatArgs(args)
        ));
    end;

    return OldNameCall(self, ...);
end);

-- Synapse HTTP Functions

setreadonly(syn, false);

local BackupSynReq = syn.request;

syn.request = function(request) 
    local ResponseData = BackupSynReq(request); -- Emulate an actual syn.request call
    
    rconsoleinfo(("syn.request(%s)\n\nResponse Data: %s"):format(
        Serializer.Serialize(request),
        Serializer.Serialize(ResponseData)
    ));

    return ResponseData;
end;

setreadonly(syn, true);

warn("HTTP Spy; Created by dsf");
