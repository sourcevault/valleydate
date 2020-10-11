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

# V = be.obj.on do
#   \foo
#   be.obj.on do
#     \bar
#     be.num.cont (x,j,k) ->
#       z "first: ",j,k
#       x
#   .on \bar, be.str.and (x,j,k) ->
#     z "second: ",j,k
#     true
# .on [\foo,\bar] do
#   (val,j,k) ->

#     z j,k

#     true

# V.auth {foo:{bar:1}},\hello,\world


