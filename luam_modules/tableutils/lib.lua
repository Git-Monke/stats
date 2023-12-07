require ".luam"

function table:imap(fn)
    local newTable = T {}
    for i = 1, #self do
        table.insert(newTable, fn(self[i], i, self))
    end
    return newTable
end

function table:map(fn)
    local newTable = T {}
    for key, value in pairs(self) do
        newTable[key] = fn(value, key, self)
    end
    return newTable
end

function table:iforeach(fn)
    for i = 1, #self do
        fn(self[i], i, self)
    end
end

function table:foreach(fn)
    for key, item in pairs(self) do
        fn(item, key, self)
    end
end

function table:reduce(fn, a)
    for key, item in pairs(self) do
        a = fn(a, item, key, self)
    end
    return a
end

function table:ireduce(fn, a)
    for i = 1, #self do
        a = fn(a, self[i], i, self)
    end
    return a
end

function table:sum()
    local sum = 0
    for i = 1, #self do
        sum = sum + self[i]
    end
    return sum
end

function table:every(fn)
    for key, item in pairs(self) do
        if not fn(item, key, self) then
            return false
        end
    end
    return true
end

function table:ievery(fn)
    for i = 1, #self do
        if not fn(self[i], i, self) then
            return false
        end
    end
    return true
end

function table:any(fn)
    for key, value in pairs(self) do
        if fn(value, key, self) then
            return true
        end
    end
    return false
end

function table:iany(fn)
    for i = 1, #self do
        if fn(self[i], i, self) then
            return true
        end
    end
    return false
end

function table:filter(fn)
    local result = T {}
    for key, value in pairs(self) do
        if fn(value, key, self) then
            result[key] = value
        end
    end
    return result
end

function table:ifilter(fn)
    local result = T {}
    for i = 1, #self do
        if fn(self[i], i, self) then
            table.insert(result, self[i])
        end
    end
    return result
end

local colorKey = {
    string = 0x400,
    number = 0x4000,
    table = 0x8,
    ["function"] = 0x10,
}

local booleanColors = {
    [true] = 0x8,
    [false] = 0x800
}

local function writeColoredByType(value)
    local inputType = type(value)
    local color

    if inputType == "boolean" then
        color = booleanColors[value]
    else
        color = colorKey[inputType]
    end

    term.setTextColor(color)
    local text = tostring(value)

    if type(value) == "string" then
        text = '"' .. text .. '"'
    end

    if type(value) == "function" then
        local info = debug.getinfo(value)
        text = info.short_src .. " ln." .. info.linedefined
    end

    term.write(text)
    term.setTextColor(0x1)
end

local function printKey(key, tab)
    if type(key) == "string" and key:find("%W") then
        term.write(tab .. '[')
        writeColoredByType(key)
        term.write(']: ')
    else
        term.write(tab)
        writeColoredByType(key)
        term.write(": ")
    end
end

--- Recursively prints the contents of a table
function table:print(nest, tab)
    assert(type(self) == "table", "Cannot print a non table value")

    term.write("{")
    print()

    nest = nest or {}
    tab = tab or "  "

    nest[self] = true
    for key, value in pairs(self) do
        if type(value) == "table" and not nest[value] then
            printKey(key, tab)
            table.print(value, nest, tab .. "  ")
        else
            printKey(key, tab)
            writeColoredByType(value)
            print()
        end
    end
    nest[self] = false

    local subtab = tab:sub(3, #tab)
    term.write(subtab .. "}")

    print()
end

function table:indexOf(item)
    for i = 1, #self do
        if self[i] == item then
            return i
        end
    end
end

function table:lastIndexOf(item)
    for i = #self, 1, -1 do
        if self[i] == item then
            return i
        end
    end
end

function table:findFirstKey(item)
    for key, value in pairs(self) do
        if value == item then
            return key
        end
    end
end

function table.build(length, initalizer)
    assert(initalizer, "Must have either a value or function to initialize a table")
    local result = T {}
    if type(initalizer) == "function" then
        for i = 1, length do
            local value = initalizer(i)
            if value then
                table.insert(result, value)
            end
        end
    else
        for i = 1, length do
            table.insert(result, initalizer)
        end
    end
    return result
end

function table:slice(start, _end)
    assert(start, "A starting index is required")

    if start and not _end then
        if start < 0 then
            start = #self + start + 1
            _end = #self
        else
            _end = start
            start = 0
        end
    end

    if start and _end then
        if start < 0 then
            start = #self + start
        end

        if _end < 0 then
            _end = #self + _end
        end
    end

    local result = T {}
    for i = start, _end do
        table.insert(result, self[i])
    end
    return result
end

function table:join(delim)
    if #self == 0 then return "" end
    delim = delim or ", "
    local result = self[1]
    for i = 2, #self do
        result = result .. delim .. tostring(self[i])
    end
    return result
end

function table:reverse()
    local result = T {}
    for i = #self, 1, -1 do
        table.insert(result, self[i])
    end
    return result
end

--- Constructs a new extended table
---
--- @param o table
--- @return table
---
function T(o)
    setmetatable(o, { __index = table })
    return o
end
