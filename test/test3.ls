common = require "../dist/common"

print = require "../dist/print"

IS = require "../dist/main"

{z,j,noop} = common

{pp} = common

p = print.fail "test/test3.js"


SA = IS.string.or IS.array.dis -> z ":hello from dis"

# SAU = SA.or IS.undef

main = IS.object.on do
	"chokidar"
	IS.object
	.on "path",SA
	# .on "paths",SAU


z SA null
# z main {chokidar:{}}


