(function(global) {

  function Genie() {
    this.cache = {};
    this.cacheOnly = false;
    this.namespace = MagicLamp;
  }

  Genie.prototype = {

    preload: function() {
      this.cacheOnly = true;
      var xhr = this.xhrRequest(this.namespace.path || '/magic_lamp');
      var json = JSON.parse(xhr.responseText);
      this.cache = json;
    },

    createFixtureContainer: function() {
      var div = document.createElement('div');
      div.setAttribute('id', this.namespace.id || 'magic-lamp');
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
      throw new Error('Couldn\'t find fixture');
    },

    xhrRequest: function(path) {
      var xhr = newXhr();

      xhr.open('GET', path, false);
      xhr.send();

      if (xhr.status !== 200) {
        this.handleError(path);
      }
      return xhr;
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
      throw('Unable to make request');
    }
    return xhr;
  }

  MagicLamp.Genie = Genie;
})(this);
