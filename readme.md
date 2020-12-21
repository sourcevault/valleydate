
![](https://raw.githubusercontent.com/sourcevault/valleydate/dev/logo.jpg)

**Install**

```js
npm install valleydate
////| github.com | much install
npm install sourcevault/valleydate#dist
```

[![Build Status](https://travis-ci.org/sourcevault/valleydate.svg?branch=dev)](https://travis-ci.org/sourcevault/valleydate)

valleydate is a functional approach to schema validation that puts composability and extensibility as it's core feature.
1. [Introduction](#introduction)
1. [Initializing Validator](#initializing-validator)
1. [Chainable Functions](#chainable-functions)
      - [and](#--and)
      - [or](#--or)
      - [alt](#--alt)
      - [map](#--map)
      - [on](#--on)
      - [cont](#--cont)
      - [fix](#--fix)
      - [err](#--err)
      - [jam](#--jam)
1. [Creating Custom Basetypes](#creating-custom-basetypes)
1. [Context Variable](#context-variable)
1. [Helper Validators](#helper-validators)
      - [required](#helper-validators)
      - [integer](#helper-validators)
      - [maybe\*](#maybe)
1. [.grexato](#grexato)

.. **quick examples** ..

🟡 Object with required properties `foo` and `bar`.

```js
var IS = require("valleydate")

var V = IS.required("foo","bar")

console.log(V.auth({}))

/*
{
  continue: false,
  error: true,
  value: {},
  message: [ 'foo', 'bar' ],
  path: [ 'foo' ]
}
*/
```

🟡 Object with required properties `name` `age` and `address`, with `address` having required fields of `city` and `country.`


```js

var IS = require("valleydate")

var address = IS.required("city","country")
.on("city",IS.str)
.on("country",IS.str)

var V = IS.required("address","name","age")
.on("address",address)
.on("name",IS.str)
.on("age",IS.num)


var sample =
  {
    name:"Fred",
    age:30,
    address:
      {
        city:"foocity"
      }
  }

console.log(V.auth(sample))

/*{
  continue: false,
  error: true,
  value: { name: 'Fred', age: 30, address: { city: 'foocity' } },
  message: [ 'city', 'country' ],
  path: [ 'address', 'country' ]
}*/

```

🟢 Table 1 - method names and their mapping to which underlying type check.


```
SHORTHANDS     ..FOR
-------------------------------
obj            Object
arr            Array
undef          Undefined
bool           Boolean
null           Null
num            Number
str            String
fun            Function
arg            Argument
-------------------------------
cont           continue
err            error
alt            alternative
```

#### Introduction
***.. why another schema validator ?***

- Monadic chainable functions.

- custom validators that are easy to build and extend.

`valleydate` exposes few key operators for creating data validators, for handling arbitrary complex data types.

We start by defining our basetypes:

- `num`,`arr`,`str`,`null`,`bool`,`undef`,`arg`,`obj` and `fun`.

.. then chainable units :

- `and`,`or`,`alt`,`map`,`on`.

.. and finally consumption units :

- `cont`,`jam`, `err` and `fix`.


#### Initializing Validator

Each validator chain starts with a *basetype*.

```js
var V = IS.num
V(1) // {continue: true, error: false, value:1}
```

```js
var V = IS.obj
V({}) // {continue: true, error: false, value:{}}
```

```js
var V = IS.arr
V([]) // {continue: true, error: false, value:[]}
```

```js
var V = IS.obj
V([]) // {continue: false, error: true, message:"not an array",path:[]}
```

The return object will always return `.continue`, `.error` and `.value`. First two are boolean, and will always be opposite in value. The final output is kept in the `.value` attribute.

⚠️ `.value` may be **modified** if consumption units are used in the chain , so be careful. ⚠️

If `{cotinue:false,error:true,...}` the return object would also have attributes `.message` and `.path`, both are `Array` , with message values :

- `message`- that passes along error messages from the validator.
- `path` - in case the input is of type array or object, the path within the object where the validator function failed.


#### Chainable Functions

After initilizating a validator with its basetype, you are returned a unit object that can be chained ( infinitely ) using a few operators.

These operators all accept custom validators but also other `valleydate` objects.

### - `and`

- when validators need to be combined, and data has to satisfy conditions set by **both** validator.

- a common situation is validating string enums.

```js

var G7 = new Set([
  "USA","EU","UK","Japan","Italy","Germany","France"
]);

var valG7 = function(s){
  if (G7.has(s)){
   return true
  }
  else {
   return [false,"not in G7"]
  }
}
var isG7 = IS.str.and(valG7)

isG7.auth("UK")

//{ continue: true, error: false, value: 'UK' }

isG7.auth("Spain")

/*{ continue: false,
  error: true,
  message: [ 'not in G7' ],
  value: 'Spain'
  }
*/
```

⛔️ `valG7` is a **custom validator** in the above example, they can be any function that returns `boolean` or `[boolean,string]`.

### - `or`

- when validators need to be combined, here data can satisfy **either** validator.

- a useful example would be accepting a single string or multiple strings in an array to define ipaddress to use in an application.

```js
var canbeIP = IS.str.or(IS.arr.map(IS.str))
```

### - `alt`

- functionally similar to `or` using **either** condition **but** the result ( or error ) is merged with upstream validator chain.

```js
var canbeIP = IS.str.or(IS.arr.map(IS.str))
```

### - `map`

###### `⛔️ .map only works for basetype Array, Object and Argument. ⛔️`

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
var ratifydata = IS.obj.map(IS.num);
```

### - `on`

###### `⛔️ .on only works for basetype Array, Object and Argument. ⛔️`

- apply validator to specific value in an object or array.

- if there are multiple `on`, instead of chaining them, you could just pass an object with the validator for each key.

```js


var V = IS.obj
.on("foo",IS.num)
.on("bar",IS.num)

V.auth((foo:1,bar:2))

// Also ...

var V1 = IS.obj.on({foo:IS.num,bar:IS.num})

V1.auth((foo:1,bar:2))

// Also ...

var V2 = IS.obj.on(["foo","bar"],IS.num)

V2.auth((foo:1,bar:2))

```

### - `cont`

- accepts functions that run based on output of validation.

- After validating some data, it needs to be consumed ( if valid ) or throw an error.

- `.cont`,`jam`,`fix` and `err` are consumption unit function that can be used to do just that.

- return value of consumption units are important, they replace some parts of return object.

using the IP example from above :

```js
var sendData = function(data){...}

var data = ["209.85.231.104","207.46.170.123"]

var V = canbeIP
.cont(sendDate) // <-- only this is called as data is valid
.err(console.log)

```

🟡 `.cont` can be used to making values **consistent**, using the IP address validator from above :


```js
IS = require("valleydate")

var canbeIP = IS.arr.map(IS.str)
.or(IS.str.cont (x) => [x]) // <-- we want string to go inside an array
// so we do not have to do extra prcessing downstream.

var ret = canbeIP.auth("209.85.231.104")

console.log(ret)
//{error: false, continue: true, value: ['209.85.231.104']}
//                                           ↑  ↑  ↑
//                                       value is an array
```

### - `fix`

- When errors can be dealt with locally without being passed upstream.

- Used commonly in creating default, using the IP address from above :

```js
IS = require("valleydate")

var canbeIP = IS.arr.map(IS.str)
.or(IS.string.cont((x) => [x]))
.fix(["127.0.0.1"])

var ret = canbeIP.auth(null)

console.log(ret) // ["127.0.0.1"]
```

### - `err`

- When validation fails, callback provided to `.err` is invoked.

- The return value of `.err` replaces the `.error` message to be sent upstream.

### - `jam`

- `jam` allows to "jam" (raise an error) within a validation chain.

- The return value of `.jam` replaces the `.error` message to be sent upstream.


#### Creating Custom Basetypes

In case defaults are not sufficient, clean validators can be easily created.

1. create a validator function with return types :
  - `boolean`
  - `[boolean,any]`

2. provide it as first argument into `valleydate` as shown below :

```js
var IS = require("valleydate")

var simpleEmail = function(value){

var isemail = value.match (/[\w-]+@([\w-]+\.)+[\w-]+/)

if (isemail) {return true}
else {return [false,"not a valid email address"] }
}

var isEmail = IS(simpleEmail)

// isEmail is now a valleydate validator which means it gets

// .and, .or, .cont, .err , .jam and .fix methods.

isEmail.and
isEmail.or
isEmail.cont
```

#### Context Variable

- `.auth` actually accepts **any number** of arguments.

- but expects the first argument to be what needs to be validated.

🟡 *so, what does `valleydate` do with the extra arguments ?*

- It simply passes it downstream ( as subsequent ) arguments in case they need them.

- We refer to these extra arguments as ***context variables***.

- In cases where `.map` of `.on` are used, the context variables are appended with the key value.

🟡 These context variables are useful in two important ways :

- data needs to be provided to `.err` to create better error message, it could be things like filename.

- `.map`, `on` modification is index / key dependant.

#### Helper Validators

Some validators are common enough to be added in core.

- `required` - accepts a list of strings and checks *if they are not undefined*  in an object.

- `restricted` - checks if object has properties that are restricted to provided keys. examples

- `int` - checks if input is a integer

🟡 using `int` :

```js
var IS = require("valleydate")

IS.int(2)
//{continue:true,error:false,value:1}

IS.int(-1.1) //{continue:false,error:true,message:['not an integer']}

IS.int(2.1)
//{continue:false,error:true,message:['not an integer']}
```

#### `maybe.*`

- maybe namespace can be used to validate optional value that conform to a type.

- The function exposed through `maybe.*` using `IS.int` :

```js
var IS = require("valleydate")

var V = IS.maybe.int

V.auth(undefined) // { continue: true, error: false, value: undefined }

V.auth(2) // { continue: true, error: false, value: 2}

V.auth("foo bar")

/*{
  continue: false,
  error: true,
  message: [ 'not an integer ( or number )', 'not undefined' ],
  value: 'foo bar'
}*/

```

🟢 All possible primitive and helper function provided in core.

```js
// how to see both helper and primitive validators
> console.log((require("valleydate")))
{.*}
int.neg              int.pos
list.ofint           list.ofnum
list.ofstr           maybe.arr
maybe.bool           maybe.boolnum
maybe.fun            maybe.int.neg
maybe.int.pos        maybe.list.ofint
maybe.list.ofnum     maybe.list.ofstr
maybe.null           maybe.num
maybe.obj            maybe.str
maybe.undef          not.arr
not.bool             not.fun
not.null             not.num
not.obj              not.str
not.undef            arg
arr                  bool
boolnum              fun
grexato              null
num                  obj
reqres               required
restricted           str
undef                undefnull
```

####  `.grexato`

`.err` function by default gives the raw chain of errors.

untangling it gets quite messy 🤷🏼‍♂️.

`valleydate` provides a helper function `.grexato` *( translation : untangle error )* to smoothly untangle raw error values.

but it requires your messages to follow some basic rules :

- error should be a tuple ( an array of 2 value ) with the second value being an array.

- first value of error should always be a string that starts with a colon ":".

- to help with sorting, a number can be provided after a second colon (":") to tell grexato the hierarchy of your messages.

```js
// Examples of message that grexato matches against
[
  ':not_tuple',
  [' value is not tuple type.']
]

[
  ':not_tuple:1',
  ['length',' value is not tuple type.']
]

[
  ':not_tuple:2',
  ['innertype',' value is not tuple type.']
]
```

## LICENCE

- Code released under BSD-3-Clause Licence.
- Documentation and Images released under CC BY-NC-ND 4.0.
- details can be found [here](https://github.com/sourcevault/valleydate/blob/dev/COPYING.txt).