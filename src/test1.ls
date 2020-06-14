{l,noops} = require "./common"

IS = require "./main"

address = IS.required "city","country"
.on "city",IS.string
.on "country",IS.string

V = IS.required "address","name","age"
.on "address",address
.on "name",IS.string
.on "age",IS.number

sample =
	name:"Fred"
	age:30
	address:
		city:"foocity"
		country:null


l V sample











