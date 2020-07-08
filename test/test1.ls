{z,noops} = require "../dist/common"

print = require "../dist/print"

IS = require "../dist/main"

p = print.fail "test/test1.js"


address = IS.required \city
.on \city,IS.string
.on \country,IS.string.fix \France

V = IS.required \address,\name,\age
.on \address,address
.on \name,IS.string
.on \age,IS.number

sample = 
	*name:"Fred"
		age:30
		address:
			*city:"foocity"
				country:null

ret = V sample

if not (ret.value.address.country is \France)

	p!


















