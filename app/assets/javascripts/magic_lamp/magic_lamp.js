(function(global) {
  var MagicLamp = {
    initialize: function() {
      this.genie = new this.Genie();
    },

    fixtureNames: function() {
      return this.genie.fixtureNames();
    },

    globalize: function() {
      window.clean = this.clean;
      window.load = this.load;
      window.loadJSON = this.loadJSON;
      window.loadRaw = this.loadRaw;
    },

    preload: function() {
      this.genie.preload.apply(this.genie, arguments);
    },

    genericError: 'Something went wrong, please check the server log, run `rake magic_lamp:lint`, or visit `/magic_lamp/lint` for more information'
  };

  MagicLamp.clean = function() {
    MagicLamp.genie.removeFixtureContainer();
  }

  MagicLamp.load = function() {
    MagicLamp.genie.load.apply(MagicLamp.genie, arguments);
  };

  MagicLamp.loadRaw = function() {
    return MagicLamp.genie.retrieveFixture.apply(MagicLamp.genie, arguments);
  };

  MagicLamp.loadJSON = function(fixtureName) {
    return JSON.parse(MagicLamp.loadRaw(fixtureName));
  };

  global.MagicLamp = MagicLamp;
})(this);

// aliases
MagicLamp.rub = MagicLamp.load;
MagicLamp.wish = MagicLamp.load;
MagicLamp.massage = MagicLamp.preload;
MagicLamp.wishForMoreWishes = MagicLamp.preload;
MagicLamp.polish = MagicLamp.clean;
