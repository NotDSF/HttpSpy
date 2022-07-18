# HttpSpy
A powerful and highly efficient network debugging tool for Roblox (and exploits)

## Usage
> Be sure to execute the HttpSpy before the target script!
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/HttpSpy/main/init.lua"))({
    AutoDecode = true, -- Automatically decodes JSON
    Highlighting = true, -- Highlights the output
    SaveLogs = true, -- Save logs to a text file
    CLICommands = true, -- Allows you to input commands into the console
    ShowResponse = true, -- Shows the request response
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
- CLI Commands
- Supported on multiple exploits (including S^X and SW)

## Preview
![](https://i.imgur.com/hnnMiLA.png)

## API
```lua
HttpSpy:HookSynRequest(<string url>, <function hook>); -- hook is called with <<table> Response>
HttpSpy:BlockUrl(<string url>);
HttpSpy:WhitelistUrl(<string url>);
```

### Example
```lua
local HttpSpy = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/HttpSpy/main/init.lua"))({
    AutoDecode = true, -- Automatically decodes JSON
    Highlighting = true, -- Highlights the output
    SaveLogs = true, -- Save logs to a text file
    CLICommands = true, -- Allows you to input commands into the console
    ShowResponse = true, -- Shows the request response
    BlockedURLs = {} -- Blocked urls
});

HttpSpy:HookSynRequest("https://httpbin.org/get", function(response) 
    response.Body = "hi";
    return response;
end);

print(syn.request({ Url = "https://httpbin.org/get" }).Body);
