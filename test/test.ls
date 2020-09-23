reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop,slist} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]

V = be.obj
.on \foo do
  be.obj.and -> [false,[\foo,\bar]]
