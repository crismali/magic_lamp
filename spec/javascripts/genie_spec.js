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

  describe('namespace', function() {
    it('is MagicLamp', function() {
      expect(subject.namespace).to.equal(MagicLamp);
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

  describe('#emptyFixtureContainer', function() {
    beforeEach(function() {
      subject.createFixtureContainer();
      subject.appendFixtureContainer();
    });

    afterEach(function() {
      removeNode(subject.fixtureContainer);
    });

    it('empties the fixture container', function() {
      testFixtureContainer().innerHTML = 'foo';
      subject.emptyFixtureContainer();
      expect(testFixtureContainer().innerHTML).to.equal('');
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

  describe('#request', function() {
    var callback;
    var callbackCalled;
    var path;

    beforeEach(function() {
      callbackCalled = 0;
      callback = function() { callbackCalled += 1 };
      path = 'foo/bar';
      stub(subject, 'handleError', true);
    });

    it('makes an get request to the specified path', function() {
      var xhr = sinon.useFakeXMLHttpRequest();
      var requests = [];
      xhr.onCreate = function(xhr) {
        requests.push(xhr);
      };
      subject.request(path, callback);
      var request = requests[0];
      request.respond(200);
      xhr.restore();

      expect(request.method).to.equal('GET');
      expect(request.url).to.have.string(path);
    });

    it('calls its callback', function() {
      subject.request(path, callback);
      expect(callbackCalled).to.equal(1);
    });

    it('calls handleError if the status is not 200', function() {
      subject.request(path, callback);
      expect(subject.handleError).to.have.been.calledOnce;
    });
  });
});
