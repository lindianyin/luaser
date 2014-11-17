luaser
======

lua序列化
---

*	支持key类型为string, number
*	支持value类型为string, number, table
*	支持循环引用
*	支持加密序列化
*	支持loadstring反序列化

**使用示例**
---
```
local t = { a = 1, b = 2}
local g = { c = 3, d = 4,  t}
t.rt = g
local ser_str = ser(g)
local unser_table = loadstring(sered)()
```
output: local ret={[1]={["a"]=1,["b"]=2},["c"]=3,["d"]=4} ret[1]["rt"]=ret return ret
