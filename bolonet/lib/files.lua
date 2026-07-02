local files = {}

function files.getTable(path)
    local file = fs.open(path, "r")
    if file == nil then error("Could not open file: "..path, 2) end
    local content = file.readAll() or ""
    --Save table to then update information and upload to desktop.db 
    local tbl

    --If the file is empty, make a new table
    if content == "" then
        tbl = {}
    --Otherwise, check if table is currpoted
    else
        tbl = textutils.unserialize(content)
        
        --Check if tble is corrupt
        if tbl == nil then
            error("File is corrupted. Refusing to unserialize.", 2)
        end
    end

    return tbl -- A table is returned either way
end

function files.setTable(path, tbl)
    local file = fs.open(path, "w")
    if file == nil then error("Could not open file: "..path, 2) end
    if tbl == nil then error("Given table was nil", 2) end
    file.write(textutils.serialize(tbl))
    file.close()
end






return files