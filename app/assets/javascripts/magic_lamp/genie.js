(function(global) {

  function Genie() {
    this.cache = {};
  }

  Genie.prototype.createFixtureContainer = function() {
    var div = document.createElement('div');
    div.setAttribute('id', 'magic-lamp');
    this.fixtureContainer = div;
  };

  Genie.prototype.appendFixtureContainer = function() {
    document.body.appendChild(this.fixtureContainer);
  };

  MagicLamp.Genie = Genie;
})(this);
