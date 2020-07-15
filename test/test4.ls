common = require "../dist/common"

print = require "../dist/print"

IS = require "../dist/main"

{z,j,noop} = common

p = print.fail "test/test4.js"

inn = IS.string.or IS.number.or (IS.obj.on "age",IS.number)

main = IS.obj.map inn

example =
	\adam : 22
	\charles : 35
	\henry : (age: \foobar)
	\joe : 33

ret = main example

try

	msg = ret.message[3]

	cor = 0

	cor += (msg[0] is ":on")

	cor += (msg[1] is "age")

	cor += (msg[2] is "not a number")

	if not (cor is 2)

		p "something went wrong with .map"

catch

	p "something has gone wrong with .message"


