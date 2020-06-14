{l,noops} = require "./common"

print = require "./print"

IS = require "./main"

V = IS.object.on "foo",(x) -> true


G = V.edit (x)->

	x.foo = 0

	x


out = G {foo:69}

if not (out.value.foo is 0)

	print.fail "test2.js"