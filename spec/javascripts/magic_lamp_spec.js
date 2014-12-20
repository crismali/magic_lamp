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
      _(['load', 'loadRaw', 'loadJSON', 'clean']).each(function(method) {
        delete window[method];
      });
    });

    it('puts #load on window', function() {
      expect(window.load).to.equal(subject.load);
    });

    it('puts #clean on window', function() {
      expect(window.clean).to.equal(subject.clean);
    });

    it('puts #loadRaw on window', function() {
      expect(window.loadRaw).to.equal(subject.loadRaw);
    });

    it('puts #loadJSON on window', function() {
      expect(window.loadJSON).to.equal(subject.loadJSON);
    });
  });

  describe('#load', function() {
    beforeEach(function() {
      subject.initialize();
      stub(subject.genie, 'load', true);
      var dummy =  { load: subject.load };
      dummy.load('foo', 'bar', 'baz');
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('passes through to its genie instance (and is bound)', function() {
      expect(subject.genie.load).to.have.been.calledWith('foo', 'bar', 'baz');
    });
  });

  describe('#loadRaw', function() {
    var dummy;
    var value;

    beforeEach(function() {
      subject.initialize();
      value = 'the fixture';
      stub(subject.genie, 'retrieveFixture', value);
      dummy = { loadRaw: subject.loadRaw };
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('calls through to its genie\'s #retrieveFixture  (and is bound)', function() {
      expect(dummy.loadRaw('foo')).to.equal(value);
      expect(subject.genie.retrieveFixture).to.have.been.calledWith('foo');
    });
  });

  describe('#loadJSON', function() {
    var json;
    var dummy;

    beforeEach(function() {
      json = { foo: 'bar' };
      subject.initialize();
      dummy = { loadJSON: subject.loadJSON };
      stub(subject, 'loadRaw', JSON.stringify(json));
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('returns the parsed JSON from the fixture (and is bound)', function() {
      expect(dummy.loadJSON('foo')).to.be.like(json);
      expect(subject.loadRaw).to.have.been.calledWith('foo');
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
      var dummy = { clean: subject.clean };
      dummy.clean();
    });

    afterEach(function() {
      delete subject.genie;
    });

    it('calls removeFixtureContainer on its genie instance (and is bound)', function() {
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
      subject.clean();
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
      _(2).times(function() { subject.load('orders/foo'); });
      expect(document.getElementsByClassName('magic-lamp').length).to.equal(1);
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

    it('can load fixtures with specified names', function() {
      subject.load('custom_name');
      expect(testFixtureContainer().innerHTML).to.equal('foo\n');
    });

    it('can load fixtures with extensions', function() {
      subject.load('orders/needs_extending');
      expect(testFixtureContainer().innerHTML).to.equal('Stevenson\nPaulson\n');
    });

    it('can load fixtures with specified names and controllers', function() {
      subject.load('orders/super_specified')
      expect(testFixtureContainer().innerHTML).to.equal('foo\n');
    });

    it('can load fixtures deeply nested in define blocks', function() {
      subject.load('arbitrary/orders/other_admin_extending');
      expect(testFixtureContainer().innerHTML).to.equal('Stevenson\nPeterson\n');

      subject.load('arbitrary/orders/admin_extending');
      expect(testFixtureContainer().innerHTML).to.equal('Stevenson\nPaulson\n');
    });

    it('can load multiple fixtures', function() {
      subject.load('arbitrary/orders/admin_extending', 'orders/foo');
      expect(testFixtureContainer().innerHTML).to.equal('Stevenson\nPaulson\nfoo\n');
    });

    it('can load JSON', function() {
      var json = subject.loadJSON('hash_to_jsoned');
      expect(json).to.be.like({ foo: 'bar' });
    });

    it('can load strings', function() {
      var string = subject.loadRaw('just_some_string');
      expect(string).to.equal("I'm a super awesome string");
    });

    it('can load rendered json', function() {
      var json = subject.loadJSON('rendered_json');
      expect(json).to.be.like({ foo: 'baz' })
    });
  });
});
