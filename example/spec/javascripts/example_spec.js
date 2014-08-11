describe('This example passes', function() {
  beforeEach(function() {
    MagicLamp.load('things/show');
  });

  afterEach(function() {
    MagicLamp.clean();
  });

  it('depends on the dom', function() {
    expect($('#magic-lamp .show-class').length).to.equal(1);
  });
});

describe('This example fails', function() {
  it('depends on the dom', function() {
    expect($('#magic-lamp .show-class').length).to.equal(1);
  });
});
