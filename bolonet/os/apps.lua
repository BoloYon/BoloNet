local G = require("/bolonet/lib/globals")

G.icons.drawWindowedBackground()

while true do
    local _, button, x, y = os.pullEvent("mouse_click") 
    if button == 1 then --leftclick
        local exit = G.icons.clickedExit(x,y)
        if exit then
            return
        end
    end
end