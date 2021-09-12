assert(hookmetamethod, "Unsupported exploit");
assert(syn or http, "Unsupported exploit");

if getgenv().HttpSpy then
  return warn("HTTP(s) Spy already loaded. Run getgenv().HttpSpy:Destroy() to destroy the thread.");
end;

local Serialize = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/Lua-Serializer/main/Serializer%20Highlighting.lua"))();

local __namecall;
local spyEnabled = true;
local gsub       = string.gsub;
local format     = string.format;
local getmethod  = getnamecallmethod;
local rconsolei  = rconsoleprint;
local httplib    = syn or http;
local backupSYN  = httplib.request;
local RBXMethods = {
  ["HttpGet"] = true;
  ["HttpGetAsync"] = true;
  ["GetObjects"] = true;
  ["HttpPost"] = true;
  ["HttpPostAsync"] = true;
}

-- What the fuck script ware
if consolecreate then
  consolecreate();
end;

__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...) 
  local method = getmethod();

  if RBXMethods[method] and spyEnabled then
    rconsolei(format("game:%s(%s)\n", method, Serialize.serializeArgs({...})))
  end;

  return __namecall(self, ...);
end));

setreadonly(httplib, false);

httplib.request = function(request) 
  local ResponseData = backupSYN(request); -- Emulate an actual syn.request call

  if ResponseData.Headers["Content-Type"] == "application/json" then
    local body = ResponseData.Body;
    local ok, res = pcall(game.HttpService.JSONDecode, game.HttpService, body);

    if ok then
      ResponseData.Body = res;
      ResponseData.RawBody = gsub(body, "%s", ""); 
    end;
  end;

  rconsolei(format("%s.request(%s)\n\nResponse Data: %s\n", syn and "syn" or "http", Serialize(request), Serialize(ResponseData)));

  return ResponseData;
end;

setreadonly(httplib, true);

local HttpSpy = {};
function HttpSpy:Destroy()
  setreadonly(httplib, false);

  getgenv().HttpSpy = nil;
  httplib.request = backupSYN;
  spyEnabled = false;

  setreadonly(httplib, true);
end;

getgenv().HttpSpy = HttpSpy;

warn("HTTP(s) Spy; Created by dsf");
