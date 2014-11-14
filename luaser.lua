-- 这里是一个简单的 Lua table 序列化函数，只支持 number 或 string 做 key ，但是 value 可以是一个 table ，并支持循环引用：

function serialize(t)
	local mark={}
	local assign={}

	local function ser_table(tbl,parent)
		mark[tbl]=parent
		local tmp={}
		for k,v in pairs(tbl) do
			local key= type(k)=="number" and "["..k.."]" or k
			if type(v)=="table" then
				local dotkey= parent..(type(k)=="number" and key or "."..key)
				if mark[v] then
					table.insert(assign,dotkey.."="..mark[v])
				else
					table.insert(tmp, key.."="..ser_table(v,dotkey))
				end
			else
				table.insert(tmp, key.."="..v)
			end
		end
		return "{"..table.concat(tmp,",").."}"
	end

	return "do local ret="..ser_table(t,"ret")..table.concat(assign," ").." return ret end"
end

t = { a = 1, b = 2}
g = { c = 3, d = 4,  t}
t.rt = g

-- print(serialize(t))

-- do local ret={a=1,rt={c=3,d=4},b=2}ret.rt[1]=ret return ret end
local pairs = pairs
local type = type
local print = print

local table_ser = function(tablevar)
	local container = {}
	for k, v in pairs(tablevar) do
		-- serialize key
		local keytype = type(k)
		local keystr = nil
		if keytype == "string" then
			keystr = string.format(".%s", k)
		elseif keytype == "number" then
			keystr = string.format("[%d]", k)
		elseif keytype == "table" then
			keystr = string.format("[%s]", table_ser(k))
		else print("luaser: key type not support")
		end
		-- serialize value
		local valuetype = type(v)
		local valuestr = nil
		if valuetype == "table" then
			valuestr = table_ser(v)
		elseif valuetype == "function" then
			valuestr = string.dump(v)
		else
			valuestr = tostring(v)
			if not valuestr then print("luaser: value type not support")
			end
		end
		local keyvaluestr = string.format("%s=%s", keystr, valuestr)
		table.insert(container, keyvaluestr)
	end
	return string.format("{%s}", table.concat(container, ","))
end


local s= table_ser({
"nihao",
fun=function () return "hello" end
})

print(s)
function ser(tablevar)

end
