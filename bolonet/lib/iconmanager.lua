local iconshandler = {}

iconshandler.icons ={
    {
        name = "Apps",
        icon = "/bolonet/assets/icons/desktop/file.nfp",
        x = 2,
        y = 2,
        w = 4,
        h = 4,
        program = "/bolonet/os/apps.lua"
    },

    {
        name = "Settings",
        icon = "/bolonet/assets/icons/desktop/settings.nfp",
        x = 10,
        y = 2,
        w = 4,
        h = 4,
        program = "/bolonet/os/settings.lua"
    },
    
    {
        name = "Admin Menu",
        icon = "/bolonet/assets/icons/desktop/admin.nfp",
        x = 34,
        y = 2,
        w = 4,
        h = 4,
        program = "/bolonet/os/adminmenu.lua",
        adminOnly = true
    },

    {
        name = "Shutdown",
        icon = "/bolonet/assets/icons/desktop/shutdown.nfp",
        x = 18,
        y = 2,
        w = 4,
        h = 4,
        program = "/bolonet/os/shutdown.lua"
    },

    {
        name = "Logout",
        icon = "/bolonet/assets/icons/desktop/logout.nfp",
        x = 26,
        y = 2,
        w = 4,
        h = 4,
        program = "/bolonet/os/logout.lua"
    }
}

--For access to the icon table when outside of desktop.lua during runtime
iconshandler.desktopState = {}

function iconshandler.drawDesktopBackground()
    term.setBackgroundColor(colors.black)
    term.clear()

    local bg = paintutils.loadImage("/bolonet/assets/desktopbg.nfp")

    if bg then
        paintutils.drawImage(bg, 1, 1)
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

function iconshandler.formatName(name)
    local str = ""
    local tbl = {}

    --Sparse at every 4 letters
    for i = 1, #name do
        local letter = string.sub(name, i, i)
        str = str..letter
        if i % 4 == 0 then
            table.insert(tbl, str)
            str = ""
        end
    end
    --If str still contains something
    if str ~= nil then
            table.insert(tbl, str)
        end
    
    return tbl
   
end

function iconshandler.drawIcons(isAdmin, tbl, user)
    for _, icon in ipairs(iconshandler.icons) do
        --If icon is not for admins only or if we are an admin,
        if not icon.adminOnly or isAdmin then
            --In cases where we are constantly updating every frame tbl will be nil
            if tbl ~= nil then
                --Use the desktop.db to set the x, y of the icons
                icon.x = tbl[user].icons[icon.name].x
                icon.y = tbl[user].icons[icon.name].y
            end

            --load the icon
            local img = paintutils.loadImage(icon.icon)

            --If it exists, paint it
            if img then
                paintutils.drawImage(img, icon.x, icon.y)
            end

            --Set up cursor position
            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.white)

            local _, cursY = term.getCursorPos()
            local _, h = term.getSize()

            if cursY > h - 2 then
                term.setBackgroundColor(colors.lightGray)
            end
            
            --Make sure names do not pass respective borders
            local nameT = iconshandler.formatName(icon.name)
            --Safety check
            if nameT == nil then return end

            --For every line of string in the name table, 
            for i, str in ipairs(nameT) do
                --Set the cursor pos to under the icon with respect to previous string
                term.setCursorPos(icon.x, icon.y + icon.h + (i - 1))

                local _, cursY = term.getCursorPos()
                local _, h = term.getSize()

                if cursY > h - 2 then
                    term.setBackgroundColor(colors.lightGray)
                end
                --If string is 3-4 chars long, just write it out
                if #str >= 3 then
                    write(str)
                --If string is 1-2 chars long, add a space to center
                else
                    write(" "..str)
                end
            end
        end
    end
end

function iconshandler.getClickedIcon(x, y, isAdmin)
    --When a click occurs, for each icon
    for _, icon in ipairs(iconshandler.icons) do
        --Respect admin 
        if not icon.adminOnly or isAdmin then
            --Compare leftmost x and rightmost x to click pos
            if x >= icon.x and x <= icon.x + icon.w - 1 then
                --Compare topmost and bottommost y to click pos
                if y >= icon.y and y <= icon.y + icon.h - 1 then
                        return icon
                end
            end
        end
    end
    return nil
end

function iconshandler.dragIcon(icon, x, y)
    if icon == nil then return end
   
    icon.x = x
    icon.y = y

end

function iconshandler.drawIcon(icon)
    local img = paintutils.loadImage(icon.icon)

    --If it exists, paint it
    if img then
        paintutils.drawImage(img, icon.x, icon.y)
    end

    --Set up cursor position
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
            
    --Make sure names do not pass respective borders
    local nameT = iconshandler.formatName(icon.name)
    --Safety check
    if nameT == nil then return end

    --For every line of string in the name table, 
    for i, str in ipairs(nameT) do
        --Set the cursor pos to under the icon with respect to previous string
        term.setCursorPos(icon.x, icon.y + icon.h + (i - 1))

        local _, cursY = term.getCursorPos()
        local _, h = term.getSize()

        if cursY > h - 2 then
            term.setBackgroundColor(colors.lightGray)
        end
        --If string is 3-4 chars long, just write it out
        if #str >= 3 then
            write(str)
        --If string is 1-2 chars long, add a space to center
        else
            write(" "..str)
        end
    end
end

function iconshandler.launch(icon, G)
    --Will add some extra stuff in the future!
    local app = loadfile(icon.program)
    if app ~= nil then app(G) end
end

function iconshandler.setIconsTable(tbl)
    iconshandler.desktopState.tbl = tbl
end

function iconshandler.getIconsTable()
    return iconshandler.desktopState.tbl
end

function iconshandler.drawDesktop(ROOT, isAdmin, tbl, user)
    --Helpful when redrawing desktop behind another window
    local win = term.current()
    term.redirect(ROOT)

    iconshandler.drawDesktopBackground()
    iconshandler.drawIcons(isAdmin, tbl, user)

    --Switch back if needed
    term.redirect(win)
end



return iconshandler