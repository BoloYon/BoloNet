local function translateClicks(win, globalX, globalY)
    --Get win position
    local localX = globalX - win.x + 1
    local localY = globalY - win.y + 1

    return localX, localY
end


local windows = {}

windows.data = {}



function windows.clickedWindow(win, x, y)
    --Calculate offset due to different window size
    local localX, localY = translateClicks(win, x, y)
    local cmd = nil

    --Top 2 rows (titlebar)
    if localY < 3 and localY > 0 then --If titlebar is clicked
        -- X button
        if localX >= win.w - 3 and localX <= win.w - 1 then
            term.clear()
            term.redirect(win.root)
            cmd = "exit"
        -- + Button
        elseif localX >= win.w - 6 and localX <= win.w - 4 then
            --Reshape window
            cmd = "reshape"
            if win.isMaximized == true then
                windows.reshapeWindow(win, false) --Always minimize by the same amount
            else
                windows.reshapeWindow(win, true)
            end
        -- - Button
        elseif localX >= win.w - 9 and localX <= win.x - 7 then
            cmd = "minimize"

        --If no button was pressed, that means titlebar, therefore send a move cmd
        else
            cmd = "move"
        end
    --Bottom left (for resizing window)
    elseif localY == win.h and localX == win.w and not win.isMaximized then
        cmd = "resize"
    end
    return cmd
end

function windows.drawBorder(win)
    --Completely reset window
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()

    local w, h = win.w, win.h

    --==BORDER--

    --Paint the border
    local bg = paintutils.loadImage("/bolonet/assets/windowedbg.nfp")
    --Draw img
    if bg then
        paintutils.drawImage(bg, 1, 1)
    end

    --Draw side borders based on window size
    for row = 1, h do
        term.setBackgroundColor(colors.lightGray)

        term.setCursorPos(1, row)
        write(" ")

        term.setCursorPos(w, row)
        write(" ")

        if row == h then
            term.setCursorPos(1, row)
            write(string.rep(" ", w))
        end
    end

    --==TITLE BAR==--

    --Exit button
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.setCursorPos(win.w - 3, 1)
    write(" x ")

    --Maximize button
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(win.w - 6, 1)
    write(" + ")

    --Minimize button
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(win.w - 9, 1)
    write(" - ")

    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)

    term.setCursorPos(2, 1)
    write(win.type)

    term.setBackgroundColor(colors.black)
end

--Adds data to a window object ONLY on creation.
--Returns the window object.
function windows.addData(type, x, y, w, h, term, isMaximized, parent, root)
    local W, H = root.getSize()

    local tbl = {
        --Basic info for positioning, size, and filtering
        type = type,
        x = x,
        y = y,
        w = w,
        h = h,

        --Important info needed by all window objects
        term = term,
        isMaximized = isMaximized,
        parent = parent,
        root = root,

        --Stores data of the minimized window, below is default minimized size
        miniData ={
            x = 3,
            y = 2,
            w = W - 5,
            h = H - 5,
        },
    }
    table.insert(windows.data, tbl)
    return tbl
end

function windows.reshapeWindow(win, isMaximized)
    local x, y, w, h

    --If we just maximized the window, basically fullscreen it
    if isMaximized then
        local W, H = win.root.getSize()
        x, y, w, h = 1, 1, W, H
    else
        --If we just minimized the window
        local m = win.miniData
        x, y, w, h = m.x, m.y, m.w, m.h
    end

    --Update values
    win.term.reposition(x, y, w, h, win.root)
    win.x = x
    win.y = y
    win.w = w
    win.h = h
    win.isMaximized = isMaximized
end

--Ran when resizing window to minimized data
function windows.updateMiniData(win)
    local x, y, w, h = win.x, win.y, win.w, win.h

    win.miniData.x = x
    win.miniData.y = y
    win.miniData.w = w
    win.miniData.h = h
end

function windows.determineEvent(win, event, button, x, y)
    local screenW, screenH = win.root.getSize()

    --If the left mouse button was clicked
    if event == "mouse_click" and button == 1 then

        local cmd = windows.clickedWindow(win, x, y)

        if cmd == "exit" then
                return true

        elseif cmd == "reshape" then
            --All redraws here
            win.redrawDesktop(win.root, win.isAdmin, win.icons, win.user)
            windows.drawBorder(win)

        elseif cmd == "move" then
            local localX, localY = translateClicks(win, x, y)
            local offsetX, offsetY = localX - 1,  localY - 1
            repeat
                local event, _, x, y = os.pullEvent()

                if event == "mouse_drag" then
                    --Get translatedX/Y for calculating the offset 
                    local newX, newY = x - offsetX, y - offsetY

                    --Make sure that window is NOT maxed, bool check to avoid uneeded redraws
                    if win.isMaximized then
                        windows.reshapeWindow(win, false)
                    end
                    win.redrawDesktop(win.root, win.isAdmin, win.icons, win.user)

                    --Clamp y ever so slightly
                    if newY < 1 then
                        newY = 1
                    end

                    win.term.reposition(newX, newY, win.w, win.h, win.root)
                    windows.drawBorder(win)
                    
                    win.x = newX
                    win.y = newY
                elseif event == "mouse_up" then
                    --Save the positions of the miniwindow AND regular window
                    windows.updateMiniData(win)
                    if win.y < 2 then
                        windows.reshapeWindow(win, true)
                        windows.drawBorder(win)
                    end
                    break
                end
            until false
        elseif cmd == "resize" then 
            --Goal: visually update window until mouse up THEN save size
            local original = {x = win.x, y = win.y, w = win.w, h = win.h}
            local fakeWin

            repeat
                local event, _, x, y = os.pullEvent()

                if event == "mouse_drag" then
                    local localX, localY = translateClicks(win, x, y)
                    local clampX, clampY = math.max(12 + #win.type, localX), math.max(8, localY)

                    fakeWin = {
                        x = original.x,
                        y = original.y,
                        w = math.max(clampX),
                        h = math.max(clampY),
                        type = win.type
                    }


                    win.term.reposition(original.x, original.y, clampX, clampY)

                    --Avoid uneeded redraws
                    if localX >= clampX or localY >= clampY then
                        win.redrawDesktop()
                        windows.drawBorder(fakeWin)
                    end

                elseif event == "mouse_up" then
                    win.w, win.h = fakeWin.w, fakeWin.h
                    windows.updateMiniData(win)
                    break
                end
            until false
        end
    end
end




function windows.createWindow(type, parent, x, y, w, h, root)
    local win = window.create(parent, x, y, w, h)
    term.redirect(win)

    local tbl = windows.addData(type, x, y, w, h, win, true, parent, root)

    windows.drawBorder(tbl)

    return tbl
end



return windows