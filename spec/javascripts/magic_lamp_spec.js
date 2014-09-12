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

  describe('#fixtureNames', function() {
    beforeEach(function() {
      subject.initialize();
      stub(subject.genie, 'fixtureNames', true);
      subject.fixtureNames();
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('passes through to its genie instance', function() {
      expect(subject.genie.fixtureNames).to.have.been.calledOnce;
    });

    it('returns the genie instance\'s return value', function() {
      expect(subject.fixtureNames()).to.equal(true);
    });
  });

  describe('#globalize', function() {
    beforeEach(function() {
      subject.globalize();
    });

    afterEach(function() {
      _(['load', 'preload', 'clean']).each(function(method) {
        delete window[method];
      });
    });

    it('puts #load on window', function() {
      expect(window.load).to.be.a('function');
    });

    it('binds #load', function() {
      stub(subject, 'load', true);
      load('orders/foo');
      expect(subject.load).to.have.been.calledWith('orders/foo');
    });

    it('puts #clean on window', function() {
      expect(window.clean).to.be.a('function');
    });

    it('binds #clean', function() {
      stub(subject, 'clean', true);
      clean();
      expect(subject.clean).to.have.been.calledOnce;
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

    it('preload as "wishForMoreWishes"', function() {
      expect(subject.wishForMoreWishes).to.equal(subject.preload);
    });

    it('load as "rub"', function() {
      expect(subject.rub).to.equal(subject.load);
    });

    it('load as "wish"', function() {
      expect(subject.wish).to.equal(subject.load);
    });

    it('clean as "polish"', function() {
      expect(subject.polish).to.equal(subject.clean);
    });
  });

  describe('integration', function() {
    beforeEach(function() {
      subject.initialize();
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('can load the foo template and clean up', function() {
      expect(testFixtureContainer()).to.be.undefined;
      subject.load('orders/foo');
      expect(testFixtureContainer().innerHTML).to.equal('foo\n');
      subject.clean();
      expect(testFixtureContainer()).to.be.undefined;
    });

    it('can preload the templates and clean up', function() {
      subject.preload();
      expect(testFixtureContainer()).to.be.undefined;
      subject.load('orders/foo');
      expect(testFixtureContainer().innerHTML).to.equal('foo\n');
      subject.clean();
      expect(testFixtureContainer()).to.be.undefined;
      subject.load('orders/bar');
      expect(testFixtureContainer().innerHTML).to.equal('bar\n');
      _(3).times(function() { subject.clean(); });
      expect(testFixtureContainer()).to.be.undefined;
    });

    it('can specify the class used for the fixture container', function() {
      var newClass = subject.class = 'the-eye';
      subject.load('orders/foo');
      expect(testFixtureContainer()).to.be.undefined;
      expect(findByClassName(newClass)).to.exist;
      expect(findByClassName(newClass).innerHTML).to.equal('foo\n');
      subject.clean();
      expect(findByClassName(newClass)).to.not.exist;
      delete subject.class;
    });

    it('throws an error when it cannot find the template', function() {
      expect(function() {
        subject.load('not/gonna/happen');
      }).to.throw(/'not\/gonna\/happen' is not a registered fixture$/);
      _(3).times(function() { subject.clean(); });
      subject.clean();
      expect(testFixtureContainer()).to.be.undefined;
    });

    it('throws an error when it cannot find the preloaded template', function() {
      subject.preload();
      expect(function() {
        subject.load('still/not/gonna/happen');
      }).to.throw();
      _(3).times(function() { subject.clean(); });
      expect(testFixtureContainer()).to.be.undefined;
    });
  });
});
