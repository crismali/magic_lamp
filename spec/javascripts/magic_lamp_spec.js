describe('MagicLamp', function() {
  var subject;
  beforeEach(function() {
    subject = MagicLamp;
  });

  it('is an object', function() {
    expect(subject).to.be.a('object');
  });
});

describe('Genie', function() {
  var subject;
  beforeEach(function() {
    subject = new MagicLamp.Genie;
  });

  describe('class', function() {
    it('is a function', function() {
      expect(MagicLamp.Genie).to.be.a('function');
    });
  });

  describe('cache', function() {
    it('is an object', function() {
      expect(subject.cache).to.be.a('object');
    });
  });

  describe('#createFixtureContainer', function() {
    it('creates a div with an id of "magic-lamp" and caches it', function() {
      subject.createFixtureContainer();
      expect(subject.fixtureContainer.tagName).to.equal('DIV');
      expect(subject.fixtureContainer.id).to.equal('magic-lamp');
    });
  });
});
