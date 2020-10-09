reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,l,hop,slist,R} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]


data =
  *foo:
      bar:"hello world"


# V = be.maybe.obj
# .on [\foo] do
#   be.obj.cont (x,j,k) ->
#       l "first: ",j,k
#       x
#   .on \bar, be.str.and (x,j,k) ->
#     z "second: ",j,k
#     true
# .on [\foo,\bar] do
#   (val,j,k) ->

#     z j,k

#     true
# V.auth data,"filename.txt"

