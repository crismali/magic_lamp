(function(global) {

  function Genie() {
    this.cache = {};
    this.namespace = MagicLamp;
  }

  Genie.prototype = {

    createFixtureContainer: function() {
      var div = document.createElement('div');
      div.setAttribute('id', 'magic-lamp');
      this.fixtureContainer = div;
    },

    appendFixtureContainer: function() {
      document.body.appendChild(this.fixtureContainer);
    },

    removeFixtureContainer: function() {
      remove(this.fixtureContainer);
      this.fixtureContainer = undefined;
    },

    handleError: function(path, response) {
      throw new Error("Couldn't find fixture");
    },

    request: function(path, callback) {
      var xhr = newXhr();
      var self = this;
      xhr.onreadystatechange = function(x) {
        if (xhr.readyState !== 4) {
          return;
        }
        if (xhr.status !== 200) {
          self.handleError(path);
        }
        callback();
      };
      xhr.open('GET', path, false);
      xhr.send();
    }
  };

  // private

  function remove(node) {
    node.parentNode.removeChild(node);
  }

  function newXhr() {
    var xhr;
    if (window.XMLHttpRequest) { // Mozilla, Safari, ...
      xhr = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // IE
      try {
        xhr = new ActiveXObject('Msxml2.XMLHTTP');
      } catch (error) {
        try {
          xhr = new ActiveXObject('Microsoft.XMLHTTP');
        } catch (e) {
          // let it go
        }
      }
    }
    if (!xhr) {
      throw('Unable to make Ajax Request');
    }
    return xhr;
  }

  MagicLamp.Genie = Genie;
})(this);
