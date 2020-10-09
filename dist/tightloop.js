// Generated by LiveScript 1.6.0
(function(){
  var reg, com, already_created, pkgname, sig, z, l, R, j, main, sanatize, blunder, settle, slice$ = [].slice, arrayFrom$ = Array.from || function(x){return slice$.call(x);};
  reg = require("./registry");
  com = reg.com, already_created = reg.already_created, pkgname = reg.pkgname, sig = reg.sig;
  z = com.z, l = com.l, R = com.R, j = com.j;
  main = {};
  sanatize = function(x, UFO){
    var cont, unknown;
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
          message: ""
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
        return {
          'continue': false,
          error: true,
          value: x,
          message: unknown
        };
      }
    default:
      return {
        'continue': false,
        error: true,
        value: x,
        message: "[" + pkgname + "][typeError][user-supplied-validator] undefined return value."
      };
    }
  };
  blunder = function(fun, put, extra1){
    var patt, F, message;
    patt = fun[0], F = fun[1];
    switch (patt) {
    case 'err':
      message = (function(){
        switch (typeof F) {
        case 'function':
          return F(put.message, put.path, extra1);
        default:
          return F;
        }
      }());
      put.message = message;
      return put;
    case 'fix':
      put.value = (function(){
        switch (typeof F) {
        case 'function':
          return F(put.value, put.path, extra1);
        default:
          return F;
        }
      }());
      put['continue'] = true;
      put.error = false;
      return put;
    default:
      return put;
    }
  };
  settle = function(fun, put, type, extra1, extra2){
    var patt, F, value, G, I, In, arr, val, path, ob, key, patt1, data, shape, ref$, i$, len$, nput;
    patt = fun[0], F = fun[1];
    value = put.value;
    switch (patt) {
    case 'd':
      return F(value);
    case 'i':
      return F.auth(value, extra1, extra2);
    case 'f':
      return sanatize(value, F(value, extra1));
    case 'map':
      switch (type) {
      case 'arr':
        patt = F[0], G = F[1];
        I = 0;
        In = value.length;
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
              value: value,
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
        for (key in value) {
          val = value[key];
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
              value: value,
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
          case 'd':
            return G(value[key]);
          case 'i':
            return G.auth(value[key], key, extra1);
          case 'f':
            val = value[key];
            return sanatize(val, G(val, key, extra1));
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
            value: value,
            message: put.message,
            path: [key].concat(arrayFrom$(path))
          };
        }
        value[key] = put.value;
        return {
          'continue': true,
          error: false,
          value: value
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
              value: value,
              message: put.message,
              path: [key].concat(arrayFrom$(path))
            };
          }
          value[key] = put.value;
          I += 1;
        }
        return {
          'continue': true,
          error: false,
          value: value
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
              value: value,
              message: put.message,
              path: [key].concat(arrayFrom$(path))
            };
          }
          value[key] = put.value;
          I += 1;
        }
        return {
          'continue': true,
          error: false,
          value: value
        };
      }
      break;
    case 'cont':
      put.value = (function(){
        switch (typeof F) {
        case 'function':
          return F(value, extra1);
        default:
          return F;
        }
      }());
      return put;
    case 'jam':
      put.message = (function(){
        switch (typeof F) {
        case 'function':
          return F(value, extra1);
        default:
          return F;
        }
      }());
      put['continue'] = false;
      put.error = true;
      return put;
    case 'alt':
      for (i$ = 0, len$ = F.length; i$ < len$; ++i$) {
        ref$ = F[i$], patt = ref$[0], G = ref$[1];
        nput = (fn4$());
        if (nput['continue']) {
          return nput;
        }
      }
      return nput;
    default:
      return put;
    }
    function fn$(){
      switch (patt) {
      case 'd':
        return G(value[I]);
      case 'i':
        return G.auth(value[I], I, extra1);
      case 'f':
        val = value[I];
        return sanatize(val, G(val, I, extra1));
      }
    }
    function fn1$(){
      switch (patt) {
      case 'd':
        return G(value[key]);
      case 'i':
        return G.auth(value[I], key, extra1);
      case 'f':
        val = value[key];
        return sanatize(val, G(val, key, extra1));
      }
    }
    function fn2$(){
      switch (shape) {
      case 'd':
        return G(value[key]);
      case 'i':
        return G.auth(value[key], key, extra1);
      case 'f':
        val = value[key];
        return sanatize(val, G(val, key, extra1));
      }
    }
    function fn3$(){
      switch (shape) {
      case 'd':
        return G(value[key]);
      case 'i':
        return G.auth(value[key], key, extra1);
      case 'f':
        val = value[key];
        return sanatize(val, G(val, key, extra1));
      }
    }
    function fn4$(){
      switch (patt) {
      case 'd':
        return G(value);
      case 'i':
        return G.auth(value, extra1);
      case 'f':
        return sanatize(val, G(value, extra1));
      }
    }
  };
  reg.tightloop = function(x, extra1, extra2){
    var state, all, type, I, put, nI, each, J, nJ, fun, patt, nput;
    state = this[sig];
    all = state.all, type = state.type;
    I = 0;
    put = {
      'continue': true,
      error: false,
      value: x
    };
    nI = all.length;
    do {
      each = all[I];
      switch (I % 2) {
      case 0:
        J = 0;
        nJ = each.length;
        do {
          fun = each[J];
          if (put.error) {
            put = blunder(fun, put, extra1, extra2);
          } else {
            put = settle(fun, put, type, extra1, extra2);
          }
          J += 1;
        } while (J < nJ);
        if (put.error) {
          I += 1;
        } else {
          I += 2;
        }
        break;
      case 1:
        J = 0;
        nJ = each.length;
        do {
          patt = each[J][0];
          nput = settle(each[J], put, type, extra1, extra2);
          if (nput['continue'] && patt === 'alt') {
            put = nput;
            J = nJ;
          } else if (nput['continue']) {
            put = nput;
            I = nI;
            J = nJ;
          } else if (nput.error) {
            J += 1;
          }
        } while (J < nJ);
        I += 1;
      }
    } while (I < nI);
    return put;
  };
}).call(this);
