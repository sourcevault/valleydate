common = require "../dist/common"

print = require "../dist/print"

be = require "../dist/main"

{z,j,noop} = common

p = print.fail "test/test3.js"

SA = be.str.or be.arr.or be.num

main = be.obj.on do
  "chokidar"
  be.obj
  .on "path",SA

ret = main.auth ({chokidar:{}})

try

  if not ((ret.path.join ".") is "chokidar.path")

    p ".path is mangled"

catch

    p "something has gone wrong with .path"




