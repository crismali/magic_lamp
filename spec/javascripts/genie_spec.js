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

  describe('#appendFixtureContainer', function() {
    beforeEach(function() {
      subject.createFixtureContainer();
    });

    afterEach(function() {
      subject.fixtureContainer && subject.fixtureContainer.remove();
    });

    it('appends the fixtureContainer to the body', function() {
      expect(testFixtureContainer()).to.equal(null);
      subject.appendFixtureContainer();
      expect(testFixtureContainer()).to.equal(subject.fixtureContainer);
    });
  });

  describe('removeFixtureContainer', function() {
    beforeEach(function() {
      subject.createFixtureContainer();
      subject.appendFixtureContainer();
    });

    it('removes the fixture container from the dom', function() {
      expect(testFixtureContainer()).to.equal(subject.fixtureContainer);
      subject.removeFixtureContainer();
      expect(testFixtureContainer()).to.equal(null);
      expect(subject.fixtureContainer).to.be.undefined;
    });

    it('removes the fixture container from the genie instance', function() {
      expect(testFixtureContainer()).to.equal(subject.fixtureContainer);
      subject.removeFixtureContainer();
      expect(subject.fixtureContainer).to.be.undefined;
    });
  });
});
