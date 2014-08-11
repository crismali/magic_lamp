var MagicLamp = {

  initialize: function() {
    this.genie = new MagicLamp.Genie();
  },

  load: function() {
    this.genie.load.apply(this.genie, arguments);
  },

  preload: function() {
    this.genie.preload.apply(this.genie, arguments);
  }
};
