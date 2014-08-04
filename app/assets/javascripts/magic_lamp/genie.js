(function(global) {

  function Genie() {
    this.cache = {};
  }

  Genie.prototype.createFixtureContainer = function() {
    var div = document.createElement('div');
    div.setAttribute('id', 'magic-lamp');
    this.fixtureContainer = div;
  };

  MagicLamp.Genie = Genie;
})(this);
