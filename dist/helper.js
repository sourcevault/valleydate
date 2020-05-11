// Generated by LiveScript 1.6.0
(function(){
  var ref$, l, SI, R, guard, noops, moduleName, unfinished, sim, utilInspectCustom, registry, print, isString, isNumber, required, check_if_string, slice$ = [].slice, arrayFrom$ = Array.from || function(x){return slice$.call(x);};
  ref$ = require("./common"), l = ref$.l, SI = ref$.SI, R = ref$.R, guard = ref$.guard, noops = ref$.noops, moduleName = ref$.moduleName;
  ref$ = require("./common"), unfinished = ref$.unfinished, sim = ref$.sim, utilInspectCustom = ref$.utilInspectCustom;
  registry = require("./registry");
  print = require("./print");
  isString = R.is(String);
  isNumber = R.is(Number);
  noops = function(){};
  required = function(props, val){
    var i$, len$, I;
    for (i$ = 0, len$ = props.length; i$ < len$; ++i$) {
      I = props[i$];
      if (val[I] === undefined) {
        return [false, "required value ." + I + " is not present (or is undefined)."];
      }
    }
    return [true];
  };
  check_if_string = function(){
    var args, i$, len$, n, I;
    args = R.flatten(arrayFrom$(arguments));
    for (i$ = 0, len$ = args.length; i$ < len$; ++i$) {
      n = i$;
      I = args[i$];
      if (!(isString(I) || isNumber(I))) {
        print.requiredError(n);
        return false;
      }
    }
    return true;
  };
  registry.helper.required = guard(check_if_string, function(){
    var args;
    args = R.flatten(arrayFrom$(arguments));
    return registry.is.object.and(function(val){
      return required(args, val);
    });
  }).any(noops);
}).call(this);
