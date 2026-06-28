local ui = {}

--Calculates the center of the terminal and prints
function ui.CalcCenter(text, xOffset, yOffset, cmd, color)
    local w, h = term.getSize()

    if cmd == print then
        term.setCursorPos(w/2 - #text/2 + (xOffset or 0) + 1, h/2 + yOffset)
        term.setTextColor(color or colors.white)
        print(text)
        term.setTextColor(colors.white)
    elseif cmd == write then
        term.setCursorPos(w/2 - #text/2 + (xOffset or 0) + 1, h/2 + yOffset)
        term.setTextColor(color or colors.white)
        write(text)
        term.setTextColor(colors.white)
    end
end

--Calculates the HORIZONTAL center only
function ui.CalcHCenter(text, xOffset, y, cmd, color)
    local w = term.getSize()

    if cmd == print then
        term.setCursorPos(w/2 - #text/2  + (xOffset or 0) + 1, y)
        term.setTextColor(color or colors.white)
        print(text)
        term.setTextColor(colors.white)
    elseif cmd == write then
        term.setCursorPos(w/2 - #text/2 + (xOffset or 0) + 1, y)
        term.setTextColor(color or colors.white)
        write(text)
        term.setTextColor(colors.white)
    end
end

--Helps navigate listed options
function ui.Navigate(options, actions, title)
    local selected = 1

    while true do
        term.clear()
        ui.CalcCenter(title, 0, -1, write, colors.white)

        for i, opt in ipairs(options) do
            if i == selected then
                ui.CalcCenter((" > "..opt), -2, i, write, colors.lightBlue)
            else
                ui.CalcCenter(("   "..opt), -2, i, write, colors.lightGray)
            end
        end

        local _, key = os.pullEvent("key")

        if key == keys.w or key == keys.up then selected = selected - 1
            if selected < 1 then selected = #options end
        elseif key == keys.s or key == keys.down then selected = selected + 1
            if selected > #options then selected = 1 end
        elseif key == keys.enter then
            local action = actions[selected]
            --This checks if actions[selected] exists, then runs the func
            if action and action() then return end
        end
    end
end

--Goes back a page (used when there is no exit option)
function ui.GoBackText()
    local _, h = term.getSize()
    ui.CalcHCenter("Press 'TAB' to return.", 0, h, write, colors.red) --Always on the bottom!
end

--Clears a line on a specific y axis (avoids writing multiple lines)
function ui.ClearLine(y)
    term.setCursorPos(0, y)
    term.clearLine()
end

--My very own read function. Will exit if ` is pressed
function ui.Read(masked) --Masked is a string
    local input = ""
    term.setCursorBlink(true)

    while true do
        local event, key = os.pullEvent()
        
        if event == "char" then
            input = input..key
            if masked then
                write(masked)
            else
                write(key)
            end
        elseif event == "key" then
            if key == keys.enter then
                print()
                term.setCursorBlink(false)
                return input, false
            elseif key == keys.backspace then
                if #input > 0 then
                    input = input:sub(1,-2)

                    local x, y = term.getCursorPos()
                    term.setCursorPos(x - 1, y)
                    write(" ")
                    term.setCursorPos(x - 1, y)
                end
            elseif key == keys.tab then
                print()
                term.setCursorBlink(false)
                return nil, true
            end
        end
    end
end


return ui