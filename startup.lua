--This is where the computer starts off when automatically rebooting
-- Super simple, shows a splash screen of BOLONET OS for a couple seconds and runs login

--==Globals==--
local G = require("/bolonet/lib/globals")

local w, h = term.getSize()

local file, ver = fs.open("/bolonet/version.txt", "r")
if file then ver = file.readAll() end
local version = ver

term.clear()

--Debugging specific files
--shell.run("/bolonet/os/apps.lua")






local function doSplashScreen()


    local splashText = ("BoloNet OS v"..version)

    local logo = paintutils.loadImage("/bolonet/assets/logo.nfp")
    if logo ~= nil then
        paintutils.drawImage(logo, 2, 1)
    end


    term.setBackgroundColor(colors.black)

    G.ui.CalcCenter(splashText, 1, 9, write, colors.purple)
    G.ui.CalcCenter("Press Enter", 0, 10, write, colors.lightGray)
    

    while true do
        local _, key = os.pullEvent("key")
        if key == keys.enter then break end
    end

    G.logger.Log("SYSTEM", "BoloNet started.")

    --Once done with that, go to login menu OR if last user was not signed out, go to login screen
    local userLoggedIn = "false"
    if G.session.GetUser() then
        userLoggedIn = "true"
    end

    G.files.runScript("/bolonet/os/login.lua", G, userLoggedIn)
end

doSplashScreen()
