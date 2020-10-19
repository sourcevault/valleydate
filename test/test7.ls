reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,l,hop,slist,R} = com

p = print.fail "test/test.js"

be = valleydate

wait = (t,f) -> setTimeout f,t

T = (x) -> true

F = (x)  -> [false,\foobar]


data =
  *foo:
    bar:null

# V = be.num
# .or be.undef
# .and be.int

# z V.auth null




