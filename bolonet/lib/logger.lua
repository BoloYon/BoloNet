local log = {}

function log.Log(title, message)
    local day = os.day() 
    local time = textutils.formatTime(os.time(), false) --False makes it 12 hrs

    --Nil handeling
    if title == nil then title = "UNKNOWN" end
    if message == nil then message = "UNKNOWN" end

    --Ensure all titles are fully capitalized
    title = string.upper(title)

    --Construct string
    local str = ("[Day "..day.." | "..time.."] - ["..title.."]: "..message)

    local file = fs.open("/bolonet/system/log.txt", "a")
    if file ~= nil then 
        file.writeLine(str)
        file.close()
    end


    
end

return log