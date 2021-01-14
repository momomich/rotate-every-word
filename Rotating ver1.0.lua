local tr = aegisub.gettext
script_name = tr("Rotate Every Word")
script_description = tr("Add frz tags to every word in selected lines")
script_author = "momomich"
script_version = "1.0"

include("unicode.lua")

-- UTF8字符串在lua的截取和字数统计部分
-- credit to: GitHub:pangliang
-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function utf8len(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        len = len +1
    end
    return len
end

-- 截取utf8 字符串
-- str:            要截取的字符串
-- startChar:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
function utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

-- 主函数
function rotate(subtitles, selected_lines, active_line)
  -- 随机旋转的角度范围，目前为(-3,3)
	deg = 3
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		if l.class == "dialogue" then
			local Tafter  = ""
			local Tbefore = l.text
			local Tnow    = ""
			local mark    = 0
			local degtemp = 0
			local len = utf8len(Tbefore)
			for n = 1, len do
				Tnow = utf8sub(Tbefore, n, 1)
				if Tnow == "{" then
					mark = 1
				elseif mark == 1 then
					if Tnow == "}" then
						mark = 0
					end
				else
					degtemp = math.random(-deg, deg)
					Tafter = Tafter..string.format("{\\frz%d}", degtemp)
				end
				Tafter = Tafter..Tnow
			end
			l.text = Tafter
			subtitles[i] = l
		end
	end
	aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, rotate)
