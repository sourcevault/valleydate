common = require "../dist/common"

print = require "../dist/print"

IS = require "../dist/main"

{z,j,noop} = common

p = print.fail "test/test3.js"

SA = IS.string.or IS.array.or IS.number

main = IS.object.on do
	"chokidar"
	IS.object
	.on "path",SA

ret = main {chokidar:{}}


try

	if not (ret.message[2][2][0] is ":or")
		p ":or is not present in (deep) .message"

catch

	p "something has gone wrong with .message"




