reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x) ->

  if (x is \world)
    return [false,\foo]
  else
    return true

# put = V do
#   {
#     foo:{
#       bar:\world
#     }
#   }

