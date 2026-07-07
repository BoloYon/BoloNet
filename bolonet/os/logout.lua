local G = ...

term.setBackgroundColor(colors.black)
term.clear()

local w, h = term.getSize()

local bg = paintutils.loadImage("/bolonet/assets/logoutscreen.nfp")
if bg ~= nil then paintutils.drawImage(bg, 1, 1) end

G.ui.CalcCenter("Are you sure you want to log out?", 0, -1, write, colors.white)
local xYes, yOptions, txtLenYes = G.ui.CalcCenter(" Yes ", 14, 4, write, colors.white, colors.green)
local xNo, txtLenNo = G.ui.CalcCenter(" No ", -14, 4, write, colors.white, colors.red)



--Await response
while true do
    local _, button, x, y = os.pullEvent("mouse_click")
    if button == 1 then
        --print("Clicked: ("..x..",".. y..")", "Actual (xNo,xYes) = ("..xNo..","..xYes..")Y = "..yOptions )
        if y == yOptions then 
            if x >= xYes and x <= xYes + txtLenYes then
                G.logger.Log("AUTH", "Logged out '"..G.session.GetUser().."'.")
                G.session.ClearUser()
                G.files.runScript("/bolonet/os/login.lua", G)
            elseif x >= xNo and x <= xNo + txtLenNo then
                return
            end
        end
    end
end