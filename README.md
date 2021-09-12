# HttpSpy
A tool to easily reconstruct HTTP(s) requests sent by the client. \w Syntax highlighting support

## Usage
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/HttpSpy/main/init.lua"))();
```

## Features
- HTTP(s) Request Reconstructing
- Syntax Highlighting
- Lightweight
- Supports Synapse X & Script-Ware
- Auto JSON Decoding
- Easy to use

## Tutorial
1. Execute HTTP(s) spy.
2. Execute target script.

## Examples
```lua
syn.request({
    ["Url"] = "https://httpbin.org/get"
})
```

## Preview
![](https://cdn.avonis.app/2cd7b683.png)
