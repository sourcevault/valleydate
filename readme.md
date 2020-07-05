
<!-- ![](https://raw.githubusercontent.com/sourcevault/valleydate/readme/logo.jpg) -->

![](./logo.jpg)


```js
//                                              npm | github                                             ..much install
                             npm install valleydate | npm install sourcevault/valleydate#dist
```

[![Build Status](https://travis-ci.org/sourcevault/valleydate.svg?branch=dev)](https://travis-ci.org/sourcevault/valleydate)


valleydate is a functional approach to schema validation that puts composability and extensibility as it's main features. 


.. **quick examples** ..


1. Object with required properties `foo` and `bar`.

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

2. Object with required properties `name` `age` and `address`, with `address` having required fields of `city` and `country.`


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

console.log(V(sample));
/*
{                                                                      
  continue: false,                                                     
  error: true,                                                         
  value: {name:"Fred", age:30, address: {city:"foocity", country:null}},
  path: [ 'address', "country" ],                                                 
  message: 'required value .country not present.'                      
}                                                                      */
```



####  *why another schema validator ?*

- Small API surface that can handle arbitrarily complex validators for arbitrarily complex data types.

- Monadic chainable functions. 

- custom validators are first class citizens, and easy to build and extend.

Current schema validators were not easy to extend with custom validators, nor did they offer  valleydate makes custom validators first class citizens. 

It relies on the fact that there are few key operations that abstract away the building of arbitrarily complex data types.


First we define basetypes:

- `number`,`array`,`string`,`null`,`undef`,`object`,`function`, and `string`.

.. then chainable units :

- `and`,`or`,`map`,`on`.

.. and finally consumption units :

- `continue`, `error` and `fix`.


### ***Initializing Validator***

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

the return object will always return `.continue`, `.error` and `.value`. First two are boolean types, and hold opposite values to each other. `.value` is just the input,( which may be **modified** if consumption units are used in the chain ), so be careful.

the return value ***can*** also have attributes :

- `message`- `Array` type, with `string` values, containing messages from the validator functions that failed.
- `path` - `Array` type, with `string` values, path to error value, provided for array and object type.
- `value`- the return value, same as input.


`{cotinue:true,error:false,...}`

on success it provides :

- `value` - that just returns the original value ( it's possible to use consumption units to change the original value ).

`{cotinue:false,error:true,...}`

on `.error` you have two important **new** attributes:

- `.message` -  that pass along error messages from the validator 

- `path` - in case the input is of type array or object, the path within the object where the validator function failed.

## *chainables functions*

After initilizating a validator with its basetype, you are returned a unit object that can be chained ( infinitely ) using a few functions:

### - `and`

- when validators need to be combined, and data has to satisfy conditions set by **both** validator.

### - `or`

- when validators need to be combined, here data can satisfy **either** validator.

- a useful example would be accepting a single string or multiple strings in an array to define ipaddress to use in an application.

```js
var canbeIP = IS.string.or(IS.array.map(IS.string));
```
### - `map`

- map allows to run validators on each value in an array or object.

- an example of this would be an object of names with age.

	```js
	  var example = {
	  "adam":22,
	  "charles":35,
	  "henry":30,
	  "joe":24
	  };
	```

	A validator for it would look something like this :

	```js
	var ratifydata = IS.object.map(IS.number);
	```


### - `on`

- apply validator to specific value in an object or array.

- **NOTE:** if value is `undefined` then validator would not throw an error, combine it with `IS.required` if value should also exist.

You could alternati

- if there are multiple `on`, instead of chaining them, you can also pass an object for describing validators.

```js

var V = IS.object.on({foo:IS.number,bar:IS.number})

V((foo:1,bar:2))


```

### - `continue` and `error`

- accepts functions that run based on output of validation.

- normally after validating some data, it needs to be consumed (if valid) or throws an error.

- `.continue` and `.error`  are consumption unit function that can be used to do just that.

- return value of consumption units are important, they replace final `.value` of output.

using the IP example from above:

	```js
	var sendData = function(data){...}

	var data = ["209.85.231.104","207.46.170.123"]

	var V = canbeIP
	.continue(sendDate) // <-- only this is called as data is valid
	.error(console.log) 

	V(data);
	```


### - `def`

- `def` stands for default. 

- Useful in scenarios where errors can be dealt with locally without passing it upstream.

example :

```js

IS = require "valleydate"

var isCountry = IS.string



```

#### *custom validators*

all unit operators accept functions that can describe custom logic for validation :

```js

var simpleEmail = function(value)
{

 var isemail = value.match (/[\w-]+@([\w-]+\.)+[\w-]+/)

 if (isemail)
 {
  return true
 }
 else
 {
  return [false,"not a valid email address"]
 }
}

var isEmail = IS.string.and(simpleEmail);


```

The function passed to a unit function recieve the value being passed along the chain and *should* return tuple ( array of 2 values ), the first value being a boolean where false means error, and the second value an error mesaage.


The only exception is `.edit` which doesn't help with validation  change the value itself.

#### *common validators*

Some validators are common enough to be added in core.

### - `required`

- accepts a list of strings and checks if they are present as keys on an object. 





## LICENCE
 
- Code, documentation and images released under MIT Licence, see [LICENSE](https://github.com/sourcevault/binapi/blob/dist/LICENCE) for details.







