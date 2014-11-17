local pairs = pairs
local type = type
local print = print
local table = table
local string = string

local function table_ser(tablevar, parent, mark, assign)
	-- 标记当前table, 并记录其key名
	mark[tablevar] = parent
	-- 记录表中各项
	local container = {}
	for k, v in pairs(tablevar) do
		-- 序列化key
		local keystr = nil
		if type(k) == "string" then 
			keystr = string.format("[\"%s\"]", k)
		elseif type(k) == "number" then 
			keystr = string.format("[%d]", k)
		end

		-- 序列化value
		local valuestr = nil
		if type(v) == "string" then 
			valuestr = string.format("\"%s\"", tostring(v))
		elseif type(v) == "number" then 
			valuestr = tostring(v)
		elseif type(v) == "table" then
			-- 获得从根表到当前表项的完整key， parent(代表父表key)， mark[v]代表table v的key
			local fullkey = string.format("%s%s", parent, keystr)
			if mark[v] then table.insert(assign, string.format("%s=%s", fullkey, mark[v]))
			else valuestr = table_ser(v, fullkey, mark, assign)
			end
		end

		if keystr and valuestr then
			local keyvaluestr = string.format("%s=%s", keystr, valuestr)
			table.insert(container, keyvaluestr)
		end
	end
	return string.format("{%s}", table.concat(container, ","))
end

-- string, number, function, table
local function ser(var, enc)
	assert(type(var)=="table")
	-- 标记所有出现的table, 并记录其key, 用于处理循环引用
	local mark = {}
	-- 用于记录循环引用的赋值语句
	local assign = {}
	-- 序列化表, ret字符串必须与后面的loca ret=%s中的ret相同，因为这个ret可能也会组织到结果字符串中。
	local ret = table_ser(var, "ret", mark, assign)
	local ret = string.format("local ret=%s %s return ret", ret, table.concat(assign, ";"))
	return (enc==nil or enc==true) and string.dump(loadstring(ret)) or ret
end
