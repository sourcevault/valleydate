reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,hop,slist,R} = com

p = print.fail "test/test.js"

be = valleydate

T = (x) -> true

F = (x)  -> [false,\foobar]


# V = be.maybe.int
# .cont -> console.log("success !")

# V.auth undefined

# V.auth 2
