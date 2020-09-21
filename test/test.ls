reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop,slist} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]

# put = V do
#   {
#     foo:{
#       bar:\world
#     }
#   }

# if not (ret.message is "not string")
  # p!

test = -> [false,'foo']



z be