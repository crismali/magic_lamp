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

  describe('cacheOnly', function() {
    it('is false by default', function() {
      expect(subject.cacheOnly).to.equal(false);
    });
  });

  describe('namespace', function() {
    it('is MagicLamp', function() {
      expect(subject.namespace).to.equal(MagicLamp);
    });
  });

  describe('#preload', function() {
    it('requests all of the fixtures and puts them in the cache', function() {
      subject.preload();
      expect(subject.cache).to.have.keys(['orders/foo', 'orders/bar', 'orders/form']);
    });

    it('sets cacheOnly to true', function() {
      subject.preload();
      expect(subject.cacheOnly).to.equal(true);
    });

    it('makes a request to the specified path if defined', function() {
      var path = MagicLamp.path = '/normal_lamp';
      stub(subject, 'xhrRequest', { responseText: '{}' });
      subject.preload();

      delete MagicLamp.path;

      expect(subject.xhrRequest).to.have.been.calledWith(path);
    });
  });

  describe('#createFixtureContainer', function() {
    it('creates a div with an id of "magic-lamp" and caches it', function() {
      subject.createFixtureContainer();
      expect(subject.fixtureContainer.tagName).to.equal('DIV');
      expect(subject.fixtureContainer.id).to.equal('magic-lamp');
    });

    it('creates a div with an id of MagicLamp.id if present', function() {
      var id = MagicLamp.id = 'footastic';
      subject.createFixtureContainer();
      delete MagicLamp.id;
      expect(subject.fixtureContainer.id).to.equal(id);
    });
  });

  describe('#appendFixtureContainer', function() {
    beforeEach(function() {
      subject.createFixtureContainer();
    });

    afterEach(function() {
      removeNode(subject.fixtureContainer);
    });

    it('appends the fixtureContainer to the body', function() {
      expect(testFixtureContainer()).to.equal(null);
      subject.appendFixtureContainer();
      expect(testFixtureContainer()).to.equal(subject.fixtureContainer);
    });
  });

  describe('#removeFixtureContainer', function() {
    beforeEach(function() {
      subject.createFixtureContainer();
      subject.appendFixtureContainer();
    });

    afterEach(function() {
      removeNode(subject.fixtureContainer);
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

  describe('#handleError', function() {
    it('throws an informative error', function() {
      var path = 'foo/bar';
      var response = 'some sort of response';

      expect(function() {
        subject.handleError(path, response);
      }).to.throw(/Couldn't find fixture/);
    });
  });

  describe('#xhrRequest', function() {
    var path;

    beforeEach(function() {
      path = '/foo/bar';
    });

    it('makes an get request to the specified path', function() {
      stubNetwork();
      subject.xhrRequest(path);
      var request = requests[0];
      request.respond(200);

      expect(request.method).to.equal('GET');
      expect(request.url).to.have.string(path);
    });

    it('returns the xhr object', function() {
      path = '/magic_lamp';
      var result = subject.xhrRequest(path);

      expect(result.constructor).to.equal(XMLHttpRequest);
    });

    it('calls handleError if the status is not 200', function() {
      stub(subject, 'handleError', true);
      subject.xhrRequest(path);
      expect(subject.handleError).to.have.been.calledOnce;
    });
  });
});
