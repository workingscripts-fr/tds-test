local ok1, source = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/workingscripts-fr/tds-test/main/tds%20test.lua")
end)

if not ok1 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "HTTP Failed",
            Text = tostring(source),
            Duration = 10
        })
    end)
    return
end

local fn, compileErr = loadstring(source)

if not fn then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Compile Error",
            Text = tostring(compileErr),
            Duration = 10
        })
    end)
    return
end

local ok2, runtimeErr = pcall(fn)

if not ok2 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Runtime Error",
            Text = tostring(runtimeErr),
            Duration = 10
        })
    end)
end
