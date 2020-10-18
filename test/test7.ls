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


# V = be.str
# .cont ->

  # z arguments

# V.auth "data",2,3,4,5,6,7,8,9,10




