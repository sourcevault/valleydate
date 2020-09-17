// Generated by LiveScript 1.6.0
(function(){
  var reg, com, already_created, pkgname, z, l, R, j, main, sanatize, settle, slice$ = [].slice, arrayFrom$ = Array.from || function(x){return slice$.call(x);};
  reg = require("./registry");
  com = reg.com, already_created = reg.already_created, pkgname = reg.pkgname;
  z = com.z, l = com.l, R = com.R, j = com.j;
  main = {};
  sanatize = function(F, x){
    var UFO, cont, unknown, msg;
    UFO = F(x);
    switch (R.type(UFO)) {
    case 'Boolean':
    case 'Null':
    case 'Undefined':
    case 'Number':
      if (UFO) {
        return {
          'continue': true,
          error: false,
          value: x
        };
      } else {
        return {
          'continue': false,
          error: true,
          value: x,
          message: "",
          path: []
        };
      }
    case 'Array':
      cont = UFO[0], unknown = UFO[1];
      if (cont) {
        return {
          'continue': true,
          error: false,
          value: x
        };
      } else {
        switch (typeof unknown) {
        case 'string':
          msg = unknown;
          break;
        default:
          msg = "[" + pkgname + "][error][user-supplied-validator] message has to be string.";
        }
        return {
          'continue': false,
          error: true,
          value: x,
          message: msg,
          path: []
        };
      }
    }
  };
  settle = function(fun, x, type){
    var patt, F, G, I, In, put, arr, path, ob, key, val, patt1, data, shape, ref$;
    patt = fun[0], F = fun[1];
    switch (patt) {
    case 's':
      return F(x);
    case 'f':
      return sanatize(F, x);
    case 'map':
      switch (type) {
      case 'arr':
        patt = F[0], G = F[1];
        I = 0;
        In = x.length;
        put = null;
        arr = [];
        while (I < In) {
          put = (fn$());
          if (put.path) {
            path = put.path;
          } else {
            path = [];
          }
          if (put.error) {
            return {
              'continue': false,
              error: true,
              value: x,
              message: put.message,
              path: [I].concat(arrayFrom$(path))
            };
          }
          arr.push(put.value);
          I += 1;
        }
        return {
          'continue': true,
          error: false,
          value: arr
        };
      case 'obj':
        ob = {};
        put = null;
        patt = F[0], G = F[1];
        for (key in x) {
          val = x[key];
          put = (fn1$());
          if (put.path) {
            path = put.path;
          } else {
            path = [];
          }
          if (put.error) {
            return {
              'continue': false,
              error: true,
              value: x,
              message: put.message,
              path: [key].concat(arrayFrom$(path))
            };
          }
          ob[key] = put.value;
        }
        return {
          'continue': true,
          error: false,
          value: ob
        };
      }
      break;
    case 'on':
      patt1 = F[0], data = F[1];
      switch (patt1) {
      case 'string':
        key = data[0], shape = data[1], G = data[2];
        put = (function(){
          switch (shape) {
          case 's':
            return G(x[key]);
          case 'f':
            return sanatize(G, x[key]);
          }
        }());
        if (put.path) {
          path = put.path;
        } else {
          path = [];
        }
        if (put.error) {
          return {
            'continue': false,
            error: true,
            value: x,
            message: put.message,
            path: [key].concat(arrayFrom$(path))
          };
        }
        x[key] = put.value;
        return {
          'continue': true,
          error: false,
          value: x
        };
      case 'array':
        arr = data[0], shape = data[1], G = data[2];
        I = 0;
        In = arr.length;
        while (I < In) {
          key = arr[I];
          put = (fn2$());
          if (put.path) {
            path = put.path;
          } else {
            path = [];
          }
          if (put.error) {
            return {
              'continue': false,
              error: true,
              value: x,
              message: put.message,
              path: [key].concat(arrayFrom$(path))
            };
          }
          if (!(put.value === undefined)) {
            x[key] = put.value;
          }
          I += 1;
        }
        return {
          'continue': true,
          error: false,
          value: x
        };
      case 'object':
        I = 0;
        In = data.length;
        while (I < In) {
          ref$ = data[I], key = ref$[0], shape = ref$[1], G = ref$[2];
          put = (fn3$());
          if (put.path) {
            path = put.path;
          } else {
            path = [];
          }
          if (put.error) {
            return {
              'continue': false,
              error: true,
              value: x,
              message: put.message,
              path: [key].concat(arrayFrom$(path))
            };
          }
          x[key] = put.value;
          I += 1;
        }
        return {
          'continue': true,
          error: false,
          value: x
        };
      }
    }
    function fn$(){
      switch (patt) {
      case 's':
        return G(x[I]);
      case 'f':
        return sanatize(G, x[I]);
      }
    }
    function fn1$(){
      switch (patt) {
      case 's':
        return G(x[key]);
      case 'f':
        return sanatize(G, x[key]);
      }
    }
    function fn2$(){
      switch (shape) {
      case 's':
        return G(x[key]);
      case 'f':
        return sanatize(G, x[key]);
      }
    }
    function fn3$(){
      switch (shape) {
      case 's':
        return G(x[key]);
      case 'f':
        return sanatize(G, x[key]);
      }
    }
  };
  reg.tightloop = function(state){
    return function(x){
      var all, type, I, put, nI, each, J, ref$, patt, cont, plant, F, pin;
      all = state.all, type = state.type;
      I = 0;
      put = null;
      nI = all.length;
      do {
        each = all[I];
        switch (I % 2) {
        case 0:
          J = 0;
          do {
            put = settle(each[J], x, type);
            if (put.error) {
              break;
            }
            J += 1;
          } while (J < each.length);
          if (put['continue']) {
            I += 2;
          } else {
            I += 1;
          }
          break;
        case 1:
          J = 0;
          do {
            put = settle(each[J], x, type);
            if (put['continue']) {
              break;
            }
            J += 1;
          } while (J < each.length);
          if (put['continue']) {
            I += 1;
          } else {
            return put;
          }
        }
      } while (I < nI);
      if (put['continue'] && state.cont) {
        ref$ = state.cont, patt = ref$[0], cont = ref$[1];
        switch (patt) {
        case 'jam':
          plant = (function(){
            switch (typeof cont) {
            case 'function':
              return cont(put.value);
            default:
              return cont;
            }
          }());
          return {
            'continue': false,
            error: true,
            value: put.value,
            message: plant
          };
        case 'cont':
          plant = (function(){
            switch (typeof cont) {
            case 'function':
              return cont(put.value);
            default:
              return cont;
            }
          }());
          return {
            'continue': true,
            error: false,
            value: plant
          };
        }
      } else if (put.error && state.err) {
        ref$ = state.err, patt = ref$[0], F = ref$[1];
        switch (patt) {
        case 'fix':
          pin = (function(){
            switch (typeof F) {
            case 'function':
              return F(put.value);
            default:
              return F;
            }
          }());
          return {
            'continue': true,
            error: false,
            value: pin
          };
        case 'err':
          put.message = (function(){
            switch (typeof F) {
            case 'function':
              return F(put.message, put.path);
            default:
              return F;
            }
          }());
          return put;
        }
      } else {
        return put;
      }
    };
  };
}).call(this);