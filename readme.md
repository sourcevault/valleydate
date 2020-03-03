
<!-- ![](https://raw.githubusercontent.com/sourcevault/valleydate/readme/logo.jpg) -->

![](./logo.jpg)


```js
//                                              npm | github                                             ..much install
                             npm install valleydate | npm install sourcevault/valleydate#dist
```

[![Build Status](https://travis-ci.org/sourcevault/valleydate.svg?branch=dev)](https://travis-ci.org/sourcevault/valleydate)


valleydate is a functional approach to schema validation, addressing concerns such as composability and extensibility that seems absent with current schema validators.


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


##### Why introduce another schema validator ?

Current schema validators were not easy to extend with custom validators, valleydate makes custom validators first class citizens. 

It relies on the realization that there are few key operations that abstract away the building of arbitrarily complex data types.

- `and`,`or`,`map`,`on` and `edit`.

with basetypes.

- `number`,`array`,`string`,`null`,`undefined`,`object`,`function`, and `string`.

This idea combined with immutability makes it really easy to build validator chains that are quite difficult to express under a different set of functions.


#### initializing validators ..

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

the return value can have attributes `.continue`,`.error`,`.message`,`path` and `value`.

- on success it provides `.value`, that just returns the original value ( it's possible use `.edit` to change the original value ).
- on `.error` you have two important attributes `.message` that pass along error messages from the validator and `path` in case the value is of type array or object.

## API

#### *unit functions*

After initilizating a validator with its basetype, you are returned a unit object that can be infinitely chained using a few functions:

### - `and`

- when validators need to be combined, and data has to satisfy conditions set by **both** validator.

### - `or`

- when validators need to be combined, here data can satisfy **either** validator.

- a useful example would be accepting single or multiple ipaddress to send data.

```js
var canbeIP = IS.string.or(IS.array.map(IS.string));
```

### - `map`

- map allows to run validators on each value in an array or object.

- an example of this with objects would be an object of names with age.

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

- **NOTE:** if value doesn't exist then validator is not called, combine it with `IS.required` if value should also exist.

- if there are multiple `on`, instead of chaining them, you can also pass an object for describing validators.

```js

var V = IS.object.on({foo:IS.number,bar:IS.number})

V((foo:1,bar:2))


```

### - `edit`

- edit allows to change value **in place** for arrays and objects ( other basetypes are immutable by default ).

- lets take the IP example from before :

	```js
	var canbeIP = IS.string.or(IS.array.map(IS.string));
	```

	Imagine the IP addresses are locations to send data to, allowing user to provide a string type **or** an array type reduces user hassle but we still have to deal with two different types. 

	In this application senario a single string IP can be considered equivalent to an array of string IP where the size of the array is just **one**, hence we can use edit to unify our types into just arrays of strings.


	```js
	var canbeIP = IS.string.edit ((str) => [str]) 
	.or(IS.array.map(IS.string));
	```


	Traditionally validation assumes two binary outcomes for data - error or ok, but sometimes it is possible to fix data by making small changes, in many situations a `null` or `undefined` should be changed to `0`, empty string, array or object.

	Finally for arrays and objects, a tricky question arises when edit is used, should we **mutate** the original value or create a new value ?

	valleydate was created to work on data extracted from configration files, it makes little sense to deeply clone the "dirty" values.


### - `continue` and `error`

- accepts functions that run based on output of validation.

- normally after validating some data, it needs to be consumed (if valid) or throws an error.

- `.continue` and `.error` are helper unit function that can be used to do just that.

- using the IP example from above.


	```js
	var sendData = function(data){...}

	var data = ["209.85.231.104","207.46.170.123"]

	var V = canbeIP
	.continue(sendDate) // <-- only this is called as data is valid
	.error(console.log) 

	V(data);
	```


### - `tap`

- takes callback that is run regardless of error or success state, mainly used for debugging.


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







