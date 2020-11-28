reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop,j} = com

p = print.fail "test/test5.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]

V = be.arr.map be.str
.or be.str
.or be.obj
.and F

ret = V.auth null

if not (ret.message[0][0] is "not array")
  p!

