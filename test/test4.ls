common = require "../dist/common"

print = require "../dist/print"

be = require "../dist/main"

{z,j,noop} = common

p = print.fail "test/test4.js"

inn = be.str.or be.num.or (be.obj.on "age",be.num)

main = be.obj.map inn

example =
  \adam : {age:null}
  \charles : 35
  \henry : (age: \foobar)
  \joe : 33

ret = main.auth example