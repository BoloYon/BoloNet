local G = ...

--Consts
local W,H = G.constants.W, G.constants.H
local ROOT = G.constants.ROOT_TERMINAL


--Once drawn, our current terminal is win
local win = G.windows.createWindow("Settings", term.current(), 1, 1, W, H, ROOT)


--Add all necessary globals to the window object
win.user = G.session.GetUser()
local isAdmin = G.userF.IsAdmin(win.user)

local iconsTbl = G.icons.getIconsTable()
if not iconsTbl then
    iconsTbl = G.files.getTable("/bolonet/system/desktop.db")
end

win.redrawDesktop = function() G.icons.drawDesktop(ROOT, isAdmin, iconsTbl, win.user) end


local rtn = false
while not rtn do
    rtn = G.windows.determineEvent(win, os.pullEvent())
end