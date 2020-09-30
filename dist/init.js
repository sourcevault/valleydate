// Generated by LiveScript 1.6.0
(function(){
  var reg, com, pkg, loopError, print, internal, cache, z, l, R, j, hop, deepFreeze, uic, custom, define, be, props, base, not_base, maybe_base, i$, len$, ref$, name, type, A, B, C, reqError, integer, boolnum, maybe_boolnum, maybe, undefnull, list, slice$ = [].slice, arrayFrom$ = Array.from || function(x){return slice$.call(x);};
  reg = require("./registry");
  com = reg.com, pkg = reg.pkg, loopError = reg.loopError, print = reg.print;
  internal = reg.internal, cache = reg.cache;
  z = com.z, l = com.l, R = com.R, j = com.j, hop = com.hop, deepFreeze = com.deepFreeze, uic = com.uic;
  custom = internal.custom, define = internal.define;
  be = custom;
  props = [['obj', 'Object'], ['arr', 'Array'], ['undef', 'Undefined'], ['null', 'Null'], ['num', 'Number'], ['str', 'String'], ['fun', 'Function'], ['bool', 'Boolean']];
  base = function(type){
    return function(UFO){
      var str;
      if (R.type(UFO) === type) {
        return {
          'continue': true,
          error: false,
          value: UFO
        };
      } else {
        str = R.toLower("not " + type);
        return {
          error: true,
          'continue': false,
          message: str,
          value: UFO
        };
      }
    };
  };
  not_base = function(type){
    return function(UFO){
      var str;
      if (R.type(UFO) === type) {
        str = R.toLower("is " + type);
        return {
          error: true,
          'continue': false,
          message: str,
          value: UFO
        };
      } else {
        return {
          'continue': true,
          error: false,
          value: UFO
        };
      }
    };
  };
  maybe_base = function(type){
    return function(UFO){
      var ref$, str;
      if ((ref$ = R.type(UFO)) === 'Undefined' || ref$ === type) {
        return {
          'continue': true,
          error: false,
          value: UFO
        };
      } else {
        str = R.toLower("not " + type);
        return {
          error: true,
          'continue': false,
          message: str,
          value: UFO
        };
      }
    };
  };
  be.not = function(F){
    return be(function(x){
      return !F(x)['continue'];
    });
  };
  be.maybe = function(F){
    return be(F).or(be.undef);
  };
  be.list = function(F){
    return be.arr.map(F);
  };
  be.list[uic] = print.inner;
  be.maybe[uic] = print.inner;
  be.not[uic] = print.inner;
  for (i$ = 0, len$ = props.length; i$ < len$; ++i$) {
    ref$ = props[i$], name = ref$[0], type = ref$[1];
    A = base(type);
    base(name, A);
    define.basis(name, A);
    be[name] = A;
    B = not_base(type);
    define.basis(name, B);
    be.not[name] = B;
    C = maybe_base(type);
    define.basis(name, C);
    be.maybe[name] = C;
  }
  reqError = hop.immutable.wh(function(){
    var args, i$, len$, key, ref$;
    args = R.flatten(arrayFrom$(arguments));
    for (i$ = 0, len$ = args.length; i$ < len$; ++i$) {
      key = args[i$];
      if (!((ref$ = R.type(key)) === 'String' || ref$ === 'Number')) {
        print.route(['required_input']);
        return true;
      }
    }
    return false;
  }, loopError);
  be.required = reqError.def(function(){
    var props;
    props = R.flatten(arrayFrom$(arguments));
    return be.obj.on(props, be.not.undef.err(props));
  });
  be.maybe.required = function(){
    var req;
    req = be.required.apply(be, arguments);
    return be.maybe(req);
  };
  integer = function(UFO){
    var residue;
    if (!(R.type(UFO) === 'Number')) {
      return {
        'continue': false,
        error: true,
        message: "not an integer ( or number )",
        value: UFO
      };
    }
    residue = Math.abs(UFO - Math.round(UFO));
    if (residue > 0) {
      return {
        'continue': false,
        error: true,
        message: "not an integer",
        value: UFO
      };
    } else {
      return {
        'continue': true,
        error: false,
        value: UFO
      };
    }
  };
  cache.def.add(integer);
  boolnum = function(UFO){
    var ref$;
    if ((ref$ = R.type(UFO)) === 'Boolean' || ref$ === 'Number') {
      return {
        'continue': true,
        error: false,
        value: UFO
      };
    } else {
      return {
        'continue': false,
        error: true,
        message: "not a number or boolean",
        value: UFO
      };
    }
  };
  cache.def.add(boolnum);
  maybe_boolnum = function(UFO){
    var ref$;
    if ((ref$ = R.type(UFO)) === 'Undefined' || ref$ === 'Boolean' || ref$ === 'Number') {
      return {
        'continue': true,
        error: false,
        value: UFO
      };
    } else {
      return {
        'continue': false,
        error: true,
        message: "not a number or boolean",
        value: UFO
      };
    }
  };
  cache.def.add(maybe_boolnum);
  be.int = be(integer);
  be.boolnum = be(boolnum);
  be.maybe.int = be.int.or(be.undef);
  maybe = be.maybe;
  maybe.int.pos = maybe.int.and(function(x){
    if (x >= 0) {
      return true;
    } else {
      return [false, "not a positive integer"];
    }
  });
  maybe.int.neg = maybe.int.and(function(x){
    if (x <= 0) {
      return true;
    } else {
      return [false, "not a negative integer"];
    }
  });
  maybe.boolnum = be(maybe_boolnum);
  undefnull = function(UFO){
    var ref$;
    if ((ref$ = R.type(UFO)) === 'Undefined' || ref$ === 'Null') {
      return {
        'continue': true,
        error: false,
        value: UFO
      };
    } else {
      return {
        'continue': false,
        error: true,
        message: "not undefined or null",
        value: UFO
      };
    }
  };
  cache.def.add(undefnull);
  be.undefnull = be(undefnull);
  list = be.list;
  list.ofstr = list(be.str).err(function(msg, key){
    switch (R.type(key)) {
    case 'Undefined':
      return "not a list of string.";
    default:
      return "not string type at ." + key[0];
    }
  });
  list.ofnum = list(be.num).err(function(msg, key){
    switch (R.type(key)) {
    case 'Undefined':
      return "not a list of number.";
    default:
      return "not number type at ." + key[0];
    }
  });
  maybe.list = {};
  maybe.list.ofstr = maybe(list.ofstr);
  maybe.list.ofnum = maybe(list.ofnum);
  module.exports = be;
}).call(this);
