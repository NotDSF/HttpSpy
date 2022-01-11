--[[
    HttpSpy v1.0.3
]]

assert(syn, "Unsupported exploit");

local logname = string.format("HttpSpy/logs/%s-log.txt", os.date("%d_%m_%y")); -- americans malding rn
if not isfolder("HttpSpy") then makefolder("HttpSpy") end;
if not isfolder("HttpSpy/logs") then makefolder("HttpSpy/logs") end;
if not isfile("HttpSpy/serializer.lua") then writefile("HttpSpy/serializer.lua", game:HttpGet("https://raw.githubusercontent.com/NotDSF/Lua-Serializer/main/Serializer%20Highlighting.lua")) end;
if not isfile(logname) then writefile(logname, "") end;

local Serialize = loadstring(readfile("HttpSpy/serializer.lua"))()
local pconsole = rconsoleprint;
local format = string.format;
local gsub = string.gsub;
local append = appendfile;
local methods = {
    HttpGet = true,
    HttpGetAsync = true,
    GetObjects = true,
    HttpPost = true,
    HttpPostAsync = true
}

local function printf(...) 
    append(logname, gsub(format(...), "%\27%[%d+m", ""));
    return pconsole(format(...));
end;

local __namecall, __request;
__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod();

    if methods[method] then
        printf("game:%s(%s)\n", method, Serialize.serializeArgs(...));
    end;

    return __namecall(self, ...);
end));

__request = hookfunction(syn.request, newcclosure(function(req) 
    local BE = Instance.new("BindableEvent");
    coroutine.wrap(function() 
        local ResponseData = __request(req);
        local BackupData = {};

        for i,v in pairs(ResponseData) do
            BackupData[i] = v;
        end;

        if BackupData.Headers["Content-Type"] == "application/json" then
            local body = BackupData.Body;
            local ok, res = pcall(game.HttpService.JSONDecode, game.HttpService, body);
            
            if ok then
                BackupData.Body = res;
            end;
        end;

        printf("syn.request(%s)\n\nResponse Data: %s\n", Serialize(req), Serialize(BackupData));
        BE.Fire(BE, ResponseData);
    end)();
    return BE.Event:Wait();
end));

if messagebox("The websocket spy can be easily detected, are you sure you want to use it?", "Alert", 1) == 1 then
    local id = 1;
    __websocket = hookfunction(syn.websocket.connect, function(url) 
        local BE = Instance.new("BindableEvent");
        coroutine.wrap(function() 
            local WebsocketId = "WS_" .. id;
            local WebSocket = __websocket(url);
            local mt = getrawmetatable(WebSocket);
            local __send, __close = WebSocket.Send, WebSocket.Close;
    
            printf("local %s = syn.websocket.connect(%s)\n", WebsocketId, Serialize.serializeArgs(url));
            
            mt.__newindex = function(self, ...) 
                return rawset(self, ...);
            end;
    
            WebSocket.Send = function(self, message) 
                __send(self, message);
                printf("%s:Send(%s)\n", WebsocketId, Serialize.serializeArgs(message));
            end;
    
            WebSocket.Close = function(self) 
                __close(self);
                printf("%s:Close()\n", WebsocketId);
            end;
    
            WebSocket.OnMessage:Connect(function(message) 
                printf("%s recieved message: %s\n", WebsocketId, Serialize.serializeArgs(message));
            end);
    
            WebSocket.OnClose:Connect(function()
                printf("%s closed!\n", WebsocketId);
            end);

            BE.Fire(BE, WebSocket);
        end)();
        id++;
        return BE.Event:Wait();
    end);
end;

local RecentCommit = game.HttpService:JSONDecode(game.HttpGet(game, "https://api.github.com/repos/NotDSF/HttpSpy/commits?per_page=1&path=init.lua"))[1].commit.message;

for method in pairs(methods) do
    local b;
    b = hookfunction(game[method], newcclosure(function(self, ...) 
        printf("game.%s(game, %s)\n", method, Serialize.serializeArgs(...));
        return b(self, ...);
    end));
end;

pconsole(format("HttpSpy v1.0.3\nCreated by dsf#2711\nChange Logs:\n\t%s\nLogs are automatically being saved to: %s\n", RecentCommit, logname))
