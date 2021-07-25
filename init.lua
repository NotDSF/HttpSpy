assert(hookmetamethod, "Unsupported exploit");
assert(syn or http, "Unsupported exploit");

if getgenv().HttpSpy then
  return warn("HTTP Spy already loaded. Run getgenv().HttpSpy:Destroy() to destroy the thread.");
end;

local Serialize = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/Lua-Serializer/main/Serializer.lua"))();

local __namecall;
local spyEnabled = true;
local format     = string.format;
local getmethod  = getnamecallmethod;
local rconsolei  = rconsoleprint;
local backupSYN  = (syn or http).request;
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

setreadonly(syn or http, false);

(syn or http).request = function(request) 
  local ResponseData = backupSYN(request); -- Emulate an actual syn.request call

  rconsolei(format("%s.request(%s)\n\nResponse Data: %s\n", syn and "syn" or "http", Serialize(request), Serialize(ResponseData)));

  return ResponseData;
end;

setreadonly(syn or http, true);

local HttpSpy = {};
function HttpSpy:Destroy()
  getgenv().HttpSpy = nil;
  (syn or http).request = backupSYN;
  spyEnabled = false;
end;

getgenv().HttpSpy = HttpSpy;

warn("HTTP Spy; Created by dsf");
