reg = require "../dist/registry"

valleydate = require "../dist/main"

{com,print} = reg

{z,l,hop,slist,R} = com

p = print.fail "test/test7.js"

be = valleydate

wait = (t,f) -> setTimeout f,t

T = (x) -> true

F = (x)  -> [false,\foobar]

V = be.restricted [0,1]

ret = V.auth [\a,\b,\c]

if not (ret.message[0] is \:res)

  p ".restricted message is not accurate."

