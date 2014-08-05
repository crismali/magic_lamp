(function(global) {

  function Genie() {
    this.cache = {};
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
      this.fixtureContainer.remove();
      this.fixtureContainer = undefined;
    }
  };

  MagicLamp.Genie = Genie;
})(this);
