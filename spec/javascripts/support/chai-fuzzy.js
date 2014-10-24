(function(plugin){
  if (
    typeof require === "function"
    && typeof exports === "object"
    && typeof module === "object"
  ) {
    // NodeJS
    module.exports = plugin;
  } else if (
    typeof define === "function"
    && define.amd
  ) {
    // AMD
    define(function () {
      return plugin;
    });
  } else {
    // Other environment (usually <script> tag): plug in to global chai instance directly.
    chai.use(plugin);
  }
}(function(chai, utils){
  var _;

  if (
    typeof window === "object"
    && typeof window._ == "function"
  ) {
    // browser-side
    _ = window._;
  } else {
    // server-side
    _ = require('underscore');
  }

  // contain => _.where, check _.isEqual
  // containOnce => contain, check size of returned array
  // like => _.isEqual

  chai.Assertion.addMethod('like', function(expected){
    var obj = this._obj
    this.assert(
      _.isEqual(obj, expected)
      , "expected #{this} to be like #{exp}"
      , "expected #{this} not to be like #{exp}"
      , expected
      , obj
      , true
    )
  });

  chai.Assertion.addMethod('jsonOf', function(expected){
    var obj            = this._obj;
    var expectedAsJSON = JSON.parse(JSON.stringify(expected));

    this.assert(
      _.isEqual(obj, expectedAsJSON)
      , "expected #{this} to be like JSON #{exp}"
      , "expected #{this} not to be like JSON #{exp}"
      , expectedAsJSON
      , obj
      , true
    )
  });

  chai.Assertion.addMethod('containOneLike', function(expected){
    var obj = this._obj

    var _obj = _(obj);

    if (!_obj.isObject() && !_obj.isArray()) {
      this.assert(
        false
        , "expected #{this} to be an array, object, or string"
        , "expected #{this} to be an array, object, or string"
      )
    }

    var found = _obj.some(function(needle){
      return _.isEqual(needle,expected);
    });

    this.assert(
      found
      , "expected #{this} to contain one thing like #{exp}"
      , "expected #{this} not to contain one thing like #{exp}"
      , expected
    )
  });

  //export tdd style
  var assert = chai.assert;
  assert.like = function (val, exp, msg) {
    new chai.Assertion(val, msg).to.be.like(exp);
  };
  assert.notLike = function (val, exp, msg) {
    new chai.Assertion(val, msg).to.not.be.like(exp);
  };
  assert.containOneLike = function (val, exp, msg) {
    new chai.Assertion(val, msg).to.containOneLike(exp);
  };
  assert.notContainOneLike = function (val, exp, msg) {
    new chai.Assertion(val, msg).to.not.containOneLike(exp);
  };
  assert.jsonOf = function (val, exp, msg) {
    new chai.Assertion(val, msg).to.be.jsonOf(exp);
  };
  assert.notJsonOf = function (val, exp, msg) {
    new chai.Assertion(val, msg).to.not.be.jsonOf(exp);
  };
}));
