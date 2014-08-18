var MagicLamp = {

  initialize: function() {
    this.genie = new this.Genie();
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
