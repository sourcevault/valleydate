reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop} = com

p = print.fail "test/test5.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]

V = be.arr.map be.str
.or be.str
.and F

ret = V null

if not (ret.message is "not string")
  p!

