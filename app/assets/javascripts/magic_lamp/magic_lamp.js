var MagicLamp = {

  initialize: function() {
    this.genie = new this.Genie();
  },

  fixtureNames: function() {
    return this.genie.fixtureNames();
  },

  globalize: function() {
    var context = this;
    window.load = function(path) {
      context.load(path);
    };
    window.clean = function() {
      context.clean();
    };
  },

  load: function() {
    this.genie.load.apply(this.genie, arguments);
  },

  loadRaw: function() {
    this.genie.retrieveFixture.apply(this.genie, arguments);
  },

  loadJSON: function(fixtureName) {
    return JSON.parse(this.loadRaw(fixtureName));
  },

  preload: function() {
    this.genie.preload.apply(this.genie, arguments);
  },

  clean: function() {
    this.genie.removeFixtureContainer();
  }
};

// aliases
MagicLamp.rub = MagicLamp.load;
MagicLamp.wish = MagicLamp.load;
MagicLamp.massage = MagicLamp.preload;
MagicLamp.wishForMoreWishes = MagicLamp.preload;
MagicLamp.polish = MagicLamp.clean;
