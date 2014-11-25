(function(global) {

  function Genie() {
    this.cache = {};
    this.cacheOnly = false;
    this.namespace = MagicLamp;
  }

  Genie.prototype = {

    load: function(path) {
      this.removeFixtureContainer();
      this.createFixtureContainer();
      this.fixtureContainer.innerHTML = this.retrieveFixture(path);
      this.appendFixtureContainer();
    },

    retrieveFixture: function(path) {
      var fixture = this.cache[path];

      if (!fixture && this.cacheOnly) {
        throw new Error('The fixture "' + path + '" was not preloaded. Is the fixture registered? Call `MagicLamp.fixtureNames()` to see what is registered.');
      } else if (!fixture) {
        var xhr = this.xhrRequest(getPath() + '/' + path);
        this.cache[path] = fixture = xhr.responseText;
      }
      return fixture;
    },

    preload: function() {
      var xhr = this.xhrRequest(getPath());
      var json = JSON.parse(xhr.responseText);
      this.cache = json;
      this.cacheOnly = true;
    },

    fixtureNames: function() {
      var names = [];
      for (fixtureName in this.cache) {
        if (this.cache.hasOwnProperty(fixtureName)) {
          names.push(fixtureName);
        }
      }
      var sortedNames = names.sort();
      for (var i = 0; i < sortedNames.length; i++) {
        console.log(sortedNames[i]);
      };

      return sortedNames;
    },

    createFixtureContainer: function() {
      var div = document.createElement('div');
      div.setAttribute('class', this.namespace.class || 'magic-lamp');
      this.fixtureContainer = div;
    },

    appendFixtureContainer: function() {
      document.body.appendChild(this.fixtureContainer);
    },

    removeFixtureContainer: function() {
      if (this.fixtureContainer) {
        remove(this.fixtureContainer);
        this.fixtureContainer = undefined;
      }
    },

    handleError: function(errorMessage) {
      throw new Error(errorMessage);
    },

    xhrRequest: function(path) {
      var xhr = newXhr();

      xhr.open('GET', path, false);
      xhr.send();

      if (this.xhrStatus(xhr) === 400) {
        this.handleError(xhr.responseText);
      } else if (this.xhrStatus(xhr) === 500) {
        this.handleError('Something went wrong, please check the server log or run `rake magic_lamp:lint` for more information');
      }
      return xhr;
    },

    xhrStatus: function(xhr) {
      return xhr.status;
    }
  };

  // private

  function getPath() {
    return MagicLamp.path || '/magic_lamp';
  }

  function remove(node) {
    var parentNode = node.parentNode;
    parentNode && parentNode.removeChild(node);
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
