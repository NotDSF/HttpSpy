# HttpSpy
A powerful and highly efficient network debugging tool for Roblox (and exploits)

## Alert
This project is no longer maintained (and won't be until I finish some other stuff), if you'd like to make a pull request feel free to do so and I might accept it

## Usage
> Be sure to execute the HttpSpy before the target script!
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/HttpSpy/main/init.lua"))({
    AutoDecode = true, -- Automatically decodes JSON
    Highlighting = true, -- Highlights the output
    SaveLogs = true, -- Save logs to a text file
    CLICommands = true, -- Allows you to input commands into the console
    ShowResponse = true, -- Shows the request response
    API = true, -- Enables the script API
    BlockedURLs = {} -- Blocked urls
});
```

## Features
- Request Reconstructing
- Syntax Highlighting
- WebSocket support
- Lightweight
- Auto JSON Decoding
- Easy to use
- Script API
- Supported on multiple exploits (including S^X and SW)

## Preview
![](https://i.imgur.com/hnnMiLA.png)

## API
```lua
HttpSpy:HookSynRequest(<string url>, <function hook>); -- hook is called with <<table> Response>
HttpSpy:BlockUrl(<string url>);
HttpSpy:WhitelistUrl(<string url>);
HttpSpy:ProxyHost(<string host>, <string proxy>);
HttpSpy:RemoveProxy(<string host>);
HttpSpy:UnHookSynRequest(<string url>);
HttpSpy.OnRequest<event>(<table request>);
```

### Example
```lua
local HttpSpy = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/HttpSpy/main/init.lua"))({
    AutoDecode = true, -- Automatically decodes JSON
    Highlighting = true, -- Highlights the output
    SaveLogs = true, -- Save logs to a text file
    CLICommands = true, -- Allows you to input commands into the console
    ShowResponse = true, -- Shows the request response
    API = true, -- Enables the script API
    BlockedURLs = {} -- Blocked urls
});

HttpSpy.OnRequest:Connect(function(req) 
    warn("request made:", req.Url);    
end);

HttpSpy:HookSynRequest("https://httpbin.org/get", function(response) 
    response.Body = "hooked!";
    return response;
end);

print(syn.request({ Url = "https://httpbin.org/get" }).Body);

HttpSpy:UnHookSynRequest("https://httpbin.org/get");
HttpSpy:ProxyHost("httpbin.org", "google.com");

print(syn.request({ Url = "https://httpbin.org/get" }).Body);
```
