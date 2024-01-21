#!/usr/bin/lua

local arg1, arg2 = ...
local file = ''
local doBytes, doLines, doWords, doChars = 0, 0, 0, 0
local sizeMod = 1;

-- Only input from STDIN with no flags so default to -c, -l and -w
if arg1 == nil then
    doBytes, doLines, doWords = 1, 1, 1
else
    -- Check if first option starts with '-'
    if string.sub(arg1, 1, 1) == '-' then
        if arg1 == '-c' then
            doBytes = 1
        elseif arg1 == '-l' then
            doLines = 1
        elseif arg1 == '-w' then
            doWords = 1
        elseif arg1 == '-m' then
            doChars = 1
        else
            print(string.format("Invalid command line switch: %s", arg1))
            os.exit(1)
        end

        if arg2 ~= nil then
            file = arg2
        end
    else
        -- No flags passed so default to -c, -l and -w
        file = arg1
        doBytes, doLines, doWords = 1, 1, 1
    end

    sizeMod = 0
end

local fh = (file == '' and io.stdin) or io.open(file, 'rb')
local bytes, lines, words, chars = 0, 0, 0, 0

for line in fh:lines('L') do
    bytes = bytes + line:len()
    lines = lines + 1
    _, n = line:gsub("%S+", "")
    words = words + n
    chars = chars + utf8.len(line)
end

fh:close()

local bytesSize = string.len(bytes)
local output = ''
local fmt = ''

if doLines == 1 then
    fmt = ("%s%_d "):gsub("_", (doBytes == 1 and bytesSize or string.len(lines)) + sizeMod)
    output = string.format(fmt, output, lines)
end

if doWords == 1 then
    fmt = ("%s%_d "):gsub("_", (doBytes == 1 and bytesSize or string.len(words)) + sizeMod)
    output = string.format(fmt, output, words)
end

if doBytes == 1 then
    fmt = ("%s%_d "):gsub("_", bytesSize + sizeMod)
    output = string.format(fmt, output, bytes)
end

if doChars == 1 then
    output = string.format("%s%d ", output, chars)
end

output = output .. file

print(output)

