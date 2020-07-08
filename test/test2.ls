{z,noops} = require "../dist/common"

print = require "../dist/print"

IS = require "../dist/main"

p = print.fail "test/test1.js"

G7 = new Set ["USA","EU","UK","Japan","Italy","Germany","France"]

valG7 = (s)->

	if (G7.has s) then return true

	else return [false,"not in G7"]

isG7 = IS.string.and valG7


ret1 = isG7 "UK"

ret2 = isG7 "Spain"

if not (ret1.value is \UK)

	p!

if not ((Array.isArray ret2.message) and (ret2.message[0] is "not in G7"))

	p!


if not (ret2.value is undefined)

	p ".value can't be passed to {..error:true..}."




