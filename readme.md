
<!-- ![](https://raw.githubusercontent.com/sourcevault/valleydate/readme/logo.jpg) -->

![](./logo.jpg)


```js
//                                              npm | github                                             ..much install
                             npm install valleydate | npm install sourcevault/valleydate#dist
```

[![Build Status](https://travis-ci.org/sourcevault/valleydate.svg?branch=dev)](https://travis-ci.org/sourcevault/valleydate)


valleydate is a functional approach to schema validation that puts composability and extensibility as it's core feature.
1. [Introduction](#introduction)
1. [Initializing Validator](#initializing-validator)
1. [Chainable Functions](#chainable-functions)
	- [and](#--and)
	- [or](#--or)
	- [map](#--map)
	- [on](#--on)
	- [continue and error](#--continue-and-error)
	- [fix](#--fix)
1. [Creating Custom Validators](#creating-custom-validators)
1. [Helper Validators](#helper-validators)
	- [required](#helper-validators)
	- [integer](#helper-validators)

.. **quick examples** ..

🟡 Object with required properties `foo` and `bar`.

```js
var V = IS.required("foo","bar")

console.log(V({foo:1}))
/*
{
  continue: false,
  error: true,
  value: {foo:1},
  message: 'required value .bar is not present.'
}
*/
```

🟡 Object with required properties `name` `age` and `address`, with `address` having required fields of `city` and `country.`


```js

var address = IS.required("city","country")
.on("city",IS.string)
.on("country",IS.string)

var V = IS.required("address","name","age")
.on("address",address)
.on("name",IS.string)
.on("age",IS.number)


var sample = 
  {
    name:"Fred",
    age:30,
    address:
      {
        city:"foocity",
        country:null
      }
  }

console.log(V(sample))
/*
{                                                                      
  continue: false,                                                     
  error: true,                                                         
  value: {name:"Fred", age:30, address: {city:"foocity", country:null}},
  path: [ 'address', "country" ],                                                 
  message: 'required value .country not present.'                      
}                                                                      */
```



#### Introduction
***.. why another schema validator ?***

- Monadic chainable functions.

- custom validators which are easy to build and extend.

`valleydate` uses few operators to abstract away building complex data validator for handling arbitrary complex data types.

We start by defining our basetypes:

- `number`,`array`,`string`,`null`,`undef`,`object`,`function`, and `string`.

.. then chainable units :

- `and`,`or`,`map`,`on`.

.. and finally consumption units :

- `continue`, `error` and `fix`.



#### Initializing Validator

Each validator chain starts with a *basetype*.

```js
var V = IS.number;
V(1) // {continue: true, error: false, value:1}
```

```js
var V = IS.object;
V({}) // {continue: true, error: false, value:{}}
```

```js
var V = IS.array;
V([]) // {continue: true, error: false, value:[]}
```

```js
var V = IS.object;
V([]) // {continue: false, error: true, message:"not an array",path:[]}
```

The return object will always return `.continue`, `.error` and `.value`. First two are boolean, and will always be opposite in value. The final output is kept in the `.value` attribute.

⚠️ `.value` may be **modified** if consumption units are used in the chain , so be careful. ⚠️

If `{cotinue:false,error:true,...}` the return object would also have attributes `.message` and `.path`, both are `Array` , with `string` values :

- `message`- that passes along error messages from the validator.
- `path` - in case the input is of type array or object, the path within the object where the validator function failed.


#### Chainable Functions

After initilizating a validator with its basetype, you are returned a unit object that can be chained ( infinitely ) using a few operators.

These operators all accept custom validators but also other `valleydate` objects.

### - `and`

- when validators need to be combined, and data has to satisfy conditions set by **both** validator.

- a common situation is validating string enums. 

```js

var G7 = new Set(["USA","EU","UK","Japan","Italy","Germany","France"]);

var valG7 = function(s){
  if (G7.has(s)){
   return true
  }
  else {
   return [false,"not in G7"]
  }
}
var isG7 = IS.string.and(valG7)

isG7("UK")

//{ continue: true, error: false, value: 'UK' }

isG7("Spain")

// { continue: false, error: true, message: [ 'not in G7' ] }

```

⛔️ `valG7` is a **custom validator** in the above example, they can be any function that returns `boolean` or `[boolean,string]`.

### - `or`

- when validators need to be combined, here data can satisfy **either** validator.

- a useful example would be accepting a single string or multiple strings in an array to define ipaddress to use in an application.

```js
var canbeIP = IS.string.or(IS.array.map(IS.string))
```


### - `map`

###### `⛔️ .map only works for basetype Array and Object. ⛔️`

- map allows to run validators on each value in an array or object.

- an example of this would be an object of names with age.

	```js
	  var example = {
	  "adam":22,
	  "charles":35,
	  "henry":30,
	  "joe":24
	  }
	```

	A validator for it would look something like this :

	```js
	var ratifydata = IS.object.map(IS.number);
	```


### - `on`

###### `⛔️ .on only works for basetype Array and Object. ⛔️`

- apply validator to specific value in an object or array.

- if there are multiple `on`, instead of chaining them, you could just pass an object with the validator for each key.

```js

var V = IS.object.on({foo:IS.number,bar:IS.number})

V((foo:1,bar:2))
```

### - `continue` and `error`

- accepts functions that run based on output of validation.

- After validating some data, it needs to be consumed ( if valid ) or throw an error.

- `.continue` and `.error`  are consumption unit function that can be used to do just that.

- return value of consumption units are important, they replace final `.value` of output.

using the IP example from above :

```js
var sendData = function(data){...}

var data = ["209.85.231.104","207.46.170.123"]

var V = canbeIP
.continue(sendDate) // <-- only this is called as data is valid
.error(console.log) 

```

🟡 `.contine` can be used to making values **consistent**, using the IP address validator from above :


```js
IS = require("valleydate")

var canbeIP = IS.array.map(IS.string)
.or(IS.string.continue (x) => [x]) // <-- we want string to go inside an array 
// so we do not have to do extra prcessing downstream.

var ret = canbeIP("209.85.231.104")

console.log (ret) 
//{ error: false, continue: true, value: [ '209.85.231.104' ] } <-- value is an array.
```

### - `fix`

- When errors can be dealt with locally without being passed upstream.

- Used commonly in creating default, using the IP address from above :

```js
IS = require("valleydate")

var canbeIP = IS.array.map(IS.string)
.or(IS.string.continue (x) => [x])
.fix(["127.0.0.1"])

var ret = canbeIP(null)

console.log (ret) // ["127.0.0.1"]
```

#### Creating Custom Validators

In case defaults are not sufficient, clean validators can be easily created.

1. create a validator function with return types :
	- `boolean` 
	- `[boolean,string]`

2. pass it into `IS` :

```js
var simpleEmail = function(value){

var isemail = value.match (/[\w-]+@([\w-]+\.)+[\w-]+/)

if (isemail) {return true}
else {return [false,"not a valid email address"] }
}

var isEmail = IS(simpleEmail) 
// isEmail is now a valleydate validator with .and, .or, .continue, .error and .fix methods.
```

#### Helper Validators

Some validators are common enough to be added in core.

- `required` - accepts a list of strings and checks if they are present as keys in an object.

- `integer` - checks if input is a integer. 

🟡 using `IS.integer` :

```js
IS = require("valleydate")

IS.integer(2) // { continue: true, error: false, value: 1 }

IS.integer(-1.1) // { continue: false, error: true, message: [ 'not an integer' ] }

IS.integer(2.1) // { continue: false, error: true, message: [ 'not an integer' ] }
```

## LICENCE
 
- Code released under MIT Licence, see [LICENSE](https://github.com/sourcevault/valleydate/blob/dist/LICENCE) for details.

- Documentation and Images released under CC-BY-4.0 see [LICENSE](https://github.com/sourcevault/test/blob/dist/LICENCE1) for details.






