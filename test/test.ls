reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,l,hop,slist,R} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]


# V = be.maybe.obj
# .on [\foo] do
#   be.obj.cont (x,k) -> l k;x
#   .on \bar, be.str.cont (x,k) ->
#     z k
#     x
# .cont (x,name) ->

#   z name

# V.auth data,"filename.txt"

