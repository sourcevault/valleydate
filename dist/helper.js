// Generated by LiveScript 1.6.0
(function(){
  var reg, com, pkg, loopError, print, already_created, z, l, R, j, hop, deepFreeze, uic, be, list, maybe, required, reqE, showAttr, G, integer, boolnum, slice$ = [].slice, arrayFrom$ = Array.from || function(x){return slice$.call(x);};
  reg = require("./registry");
  com = reg.com, pkg = reg.pkg, loopError = reg.loopError, print = reg.print;
  already_created = reg.already_created;
  z = com.z, l = com.l, R = com.R, j = com.j, hop = com.hop, deepFreeze = com.deepFreeze, uic = com.uic;
  be = pkg;
  list = function(F){
    return be.arr.map(F);
  };
  maybe = function(F){
    return be(F).or(be.undef);
  };
  maybe[uic] = print.inner;
  list[uic] = print.inner;
  be.maybe = maybe;
  be.list = list;
  required = function(props){
    return function(UFO){
      var I, nI, key;
      I = 0;
      nI = props.length;
      while (I < nI) {
        key = props[I];
        if (UFO[key] === undefined) {
          return [false, "required value ." + key + " is not present (or is undefined)."];
        }
        I += 1;
      }
      return [true];
    };
  };
  reqE = hop.immutable.wh(function(){
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
  showAttr = function(props){
    return "has to be an object with required attributes:\n." + props.join(" .");
  };
  G = reqE.def(function(){
    var props, F;
    props = R.flatten(arrayFrom$(arguments));
    F = required(props);
    return be.obj.and(F).err(showAttr(props));
  });
  be.required = G;
  G = reqE.def(function(){
    var props, F;
    props = R.flatten(arrayFrom$(arguments));
    F = required(props);
    return maybe.obj.and(F).err(showAttr(props));
  });
  maybe.required = G;
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
  already_created.add(integer);
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
  already_created.add(boolnum);
  be.int = be(integer);
  be.boolnum = be(boolnum);
  maybe.int = be.int.or(be.undef);
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
  maybe.boolnum = be.boolnum.or(be.undef);
  maybe.obj = be.obj.or(be.undef);
  maybe.arr = be.arr.or(be.undef);
  maybe.num = be.num.or(be.undef);
  maybe.str = be.str.or(be.undef);
  maybe.fun = be.fun.or(be.undef);
  maybe.bool = be.bool.or(be.undef);
  list.str = list(be.str).err(function(msg, arg$){
    var key;
    key = arg$[0];
    return "value at index " + key + " is not of string type";
  });
  list.num = list(be.num).err(function(msg, arg$){
    var key;
    key = arg$[0];
    return "value at index " + key + " is not of number type";
  });
  maybe.list = {};
  maybe.list.str = maybe(list.str);
  maybe.list.num = maybe(list.num);
}).call(this);
