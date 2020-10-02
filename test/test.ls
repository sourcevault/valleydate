reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop,slist,R} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]

# V = be.maybe.obj
# .on \foo do
#   be.obj.or be.undef
#   # .on \bar, be.str

# z V.auth {foo:undefined}
