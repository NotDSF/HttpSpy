# HttpSpy
A powerful and highly efficient network debugging tool for Roblox (and exploits)

## Usage
> Be sure to execute the HttpSpy before the target script!
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/HttpSpy/main/init.lua"))({
    AutoDecode = true, -- Automatically decodes JSON
    Highlighting = true, -- Highlights the output
    SaveLogs = true, -- Save logs to a text file
    CLICommands = true -- Allows you to input commands into the console
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

## Preview
![](https://i.imgur.com/hnnMiLA.png)

## Command List

### Block URL
Blocks any request with the specified url, however the request will still be shown on the spy.
```
block[=url]
```

### Unblock URL
Will unblock the specified url.
```
unblock[=url]
```

### Clear Console
Will clear the synapse console.
```
cls
```

### Enable Spy
Will enable the spy.
```
enable
```

### Disable Spy
Will disable the spy.
```
disable
```
