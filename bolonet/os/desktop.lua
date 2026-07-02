local G = require("/bolonet/lib/globals")
local user = G.session.GetUser()

if user == nil then error("User is nil.", 1) end

--Updates the position info of icons for specific users
local function updateInfo(icon)
    local tbl = G.files.getTable("/bolonet/system/desktop.db")

    if tbl == nil then error("Table returned nil", 1)  end
    
    tbl[user].icons[icon.name].x = icon.x
    tbl[user].icons[icon.name].y = icon.y

    G.files.setTable("/bolonet/system/desktop.db", tbl)
end






local function desktop()
    local isAdmin = true --G.userF.isAdmin(user)
    while true do
        local tbl = G.files.getTable("/bolonet/system/desktop.db")

        G.icons.drawDesktop(isAdmin, tbl, user)

        local event, button, x, y = os.pullEvent("mouse_click")

        if button == 1 then --Leftclick
            --Return the icon we just clicked
            local icon = G.icons.getClickedIcon(x, y, isAdmin)

            --If icon exists, continue
            if icon then
                local hasDragged = false
                local clickedIcon = icon
            
                repeat
                    local event, _, x, y = os.pullEvent()

                    --If we are dragging an icon, set hasdragged to true and update desktop
                    if event == "mouse_drag" then
                        hasDragged = true
                        G.icons.dragIcon(icon,x,y)
                        G.icons.drawDesktop(isAdmin)
                        sleep(0.05)
                    
                    --if mouse is let go, save postion and exit the repeat loop
                    elseif event == "mouse_up" then
                        updateInfo(icon)

                        break
                    end
                --repeat forever
                until false

                --If it was not a drag event, then click should open the program
                if not hasDragged then
                    G.icons.launch(clickedIcon)
                end
            end
        elseif button == 2 then --Rightclick
            --Add some rightclick function
            
        end
    end
end

desktop()