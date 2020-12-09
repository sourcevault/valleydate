reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,l,hop,R} = com

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
#     be.num.cont (x,a,b,c,d) ->
#       z "first: ",a,b,c,d
#       x
#   .on \bar, be.str.and (x,j,k) ->
#     z "second: ",j,k
#     true
# .on [\foo,\bar] do
#   (val,j,k) ->

#     z j,k

#     true

# V.auth {foo:{bar:1}},[\data],[\file]


# V = be.required [\remotehost,\remotefold]

# .on [\remotehost,\remotefold],be.str

# .err (msg) ->

#   z msg

# V.auth {remotehost:"str",remotefold:1}
