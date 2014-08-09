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
    }
  };

  // private

  function remove(node) {
    node.parentNode.removeChild(node);
  }

  MagicLamp.Genie = Genie;
})(this);
