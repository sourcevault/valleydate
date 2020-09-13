// Generated by LiveScript 1.6.0
(function(){
  var ref$, z, noops, print, be, p, address, V, sample, ret;
  ref$ = require("../dist/common"), z = ref$.z, noops = ref$.noops;
  print = require("../dist/print");
  be = require("../dist/main");
  p = print.fail("test/test1.js");
  address = be.required('city').on('city', be.str).on('country', be.str.fix('France'));
  V = be.required('address', 'name', 'age').on('address', address).on('name', be.str).on('age', be.num);
  sample = {
    name: "Fred",
    age: 30,
    address: {
      city: "foocity",
      country: null
    }
  };
  ret = V(sample);
  if (!(ret.value.address.country === 'France')) {
    p();
  }
}).call(this);
