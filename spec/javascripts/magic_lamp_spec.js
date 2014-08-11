describe('MagicLamp', function() {
  var subject;
  beforeEach(function() {
    subject = MagicLamp;
  });

  it('is an object', function() {
    expect(subject).to.be.a('object');
  });

  describe('#initialize', function() {
    beforeEach(function() {
      subject.initialize();
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('sets genie to a new genie instance', function() {
      expect(subject.genie).to.be.an.instanceof(subject.Genie);
    });
  });

  describe('#load', function() {
    beforeEach(function() {
      subject.initialize();
      stub(subject.genie, 'load', true);
      subject.load('foo', 'bar', 'baz');
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('passes through to its genie instance', function() {
      expect(subject.genie.load).to.have.been.calledWith('foo', 'bar', 'baz');
    });
  });

  describe('#preload', function() {
    beforeEach(function() {
      subject.initialize();
      stub(subject.genie, 'preload', true);
      subject.preload('foo', 'bar', 'baz');
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('passes through to its genie instance', function() {
      expect(subject.genie.preload).to.have.been.calledWith('foo', 'bar', 'baz');
    });
  });

  describe('#clean', function() {
    beforeEach(function() {
      subject.initialize();
      stub(subject.genie, 'removeFixtureContainer', true);
      subject.clean();
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('calls removeFixtureContainer on its genie instance', function() {
      expect(subject.genie.removeFixtureContainer).to.have.been.calledOnce;
    });
  });

  describe('aliases', function() {
    it('preload as "massage"', function() {
      expect(subject.massage).to.equal(subject.preload);
    });

    it('load as "rub"', function() {
      expect(subject.rub).to.equal(subject.load);
    });

    it('clean as "polish"', function() {
      expect(subject.polish).to.equal(subject.clean);
    });
  });
});
