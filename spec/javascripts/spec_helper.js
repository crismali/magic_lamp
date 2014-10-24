// Teaspoon includes some support files, but you can use anything from your own support path too.
// require support/expect
// require support/sinon
// require support/chai
// require support/your-support-file
//
// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/bind-poly
//
// Deferring execution
// If you're using CommonJS, RequireJS or some other asynchronous library you can defer execution. Call
// Teaspoon.execute() after everything has been loaded. Simple example of a timeout:
//
// Teaspoon.defer = true
// setTimeout(Teaspoon.execute, 1000)
//
// Matching files
// By default Teaspoon will look for files that match _spec.{js,js.coffee,.coffee}. Add a filename_spec.js file in your
// spec path and it'll be included in the default suite automatically. If you want to customize suites, check out the
// configuration in config/initializers/teaspoon.rb
//
// Manifest
// If you'd rather require your spec files manually (to control order for instance) you can disable the suite matcher in
// the configuration and use this file as a manifest.
//
// For more information: http://github.com/modeset/teaspoon
//
// Chai
// If you're using Chai, you'll probably want to initialize your preferred assertion style. You can read more about Chai
// at: http://chaijs.com/guide/styles
//
// window.assert = chai.assert;
// window.expect = chai.expect;
// window.should = chai.should();
//
// You can require your own javascript files here. By default this will include everything in application, however you
// may get better load performance if you require the specific files that are being used in the spec that tests them.
//= require magic_lamp/application
//= require support/underscore-1.6
//= require support/chai
//= require support/chai-fuzzy
//= require support/sinon
//= require support/sinon-chai
window.expect = chai.expect;

var spies;
var stubs;
var xhr;
var requests;

function spyOn(object, method, returnValue) {
  var spy = sinon.spy(object, method);
  spies.push(spy);
  return spy;
}

function stub(object, method, retVal) {
  var stubObj;
  if (_.isFunction(retVal)) {
    stubObj = sinon.stub(object, method, retVal);
  } else {
    stubObj = sinon.stub(object, method).returns(retVal);
  }
  stubs.push(stubObj);
  return stubObj;
}

function findByClassName(className) {
  return document.getElementsByClassName(className)[0];
}

function testFixtureContainer() {
  return findByClassName('magic-lamp');
}

function removeNode(node) {
  if (!!node && node.parentNode) {
    node.parentNode.removeChild(node);
  }
}

function stubNetwork() {
  xhr = sinon.useFakeXMLHttpRequest();
  xhr.onCreate = function(xhr) {
    requests.push(xhr);
  };
}

beforeEach(function() {
  spies = [];
  stubs = [];
  requests = [];
});

afterEach(function() {
  _(spies).each(function(spy) {
    spy.restore();
  });

  _(stubs).each(function(stub) {
    stub.restore();
  });

  xhr && xhr.restore();

  requests = undefined;
  xhr = undefined;
  subject = undefined;
});
