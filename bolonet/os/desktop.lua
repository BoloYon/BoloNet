local G = ...
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

local function drawWallpaperRegion(x, y, w, h, textRows)
    --For each row
    for row = y, y + (h - 1) + textRows do
        term.setBackgroundColor(colors.gray)
        if row > G.constants.H - 2 then
            term.setBackgroundColor(colors.lightGray)
        end
        --Set cursor to left side
        term.setCursorPos(x, row)
        --Place a background pixel width amount of times
        write(string.rep(" ", w))
    end
end

local function rectsOverlap(aX, aY, aW, aH, bX, bY, bW, bH)
    return aX < bX + bW and --Is A's left edge before B's right edge
        bX < aX + aW and --Is B's left edge before A's right edge?
        aY < bY + bH and --Is A's top edge above B's bottom edge
        bY < aY + aH --Is B's top edge above A's bottom edge?

end

local function redrawRegion(x, y, w, h, skippedIcon)
    local iconTable = G.icons.icons
    local textRows = math.ceil(#skippedIcon.name / 4)

    --Repaint wallpaper only inside the previous box where the icon was
    drawWallpaperRegion(x, y, w, h, textRows)

    for _, icon in ipairs(iconTable) do
        local textRowsNew = math.ceil(#skippedIcon.name / 4)
        if icon ~= skippedIcon and rectsOverlap(x, y , w, h + textRows, icon.x, icon.y, icon.w, icon.h + textRowsNew) then
            G.icons.drawIcon(icon)
        end
    end
    
end





local function desktop()
    local isAdmin = G.userF.IsAdmin(user)
    while true do
        local tbl = G.files.getTable("/bolonet/system/desktop.db")
        G.icons.setIconsTable(tbl) --Avoid repeated system I/O by storing it during runtime
        G.icons.drawDesktop(G.constants.ROOT_TERMINAL, isAdmin, tbl, user)
        

        local _, button, x, y = os.pullEvent("mouse_click")

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
                        --Save previous X and Y
                        local prevX = icon.x
                        local prevY = icon.y
                        
                        hasDragged = true
                        G.icons.dragIcon(icon,x,y)
                        redrawRegion(prevX, prevY, icon.h, icon.w, icon)
                        G.icons.drawIcon(icon)
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
                    G.icons.launch(clickedIcon, G)
                end
            end
        elseif button == 2 then --Rightclick
            --Add some rightclick function
            
        end
    end
end

desktop()