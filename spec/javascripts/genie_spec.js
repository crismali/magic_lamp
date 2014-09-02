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

  describe('#load', function() {
    var path;
    beforeEach(function() {
      path = 'orders/foo';
    });

    afterEach(function() {
      removeNode(subject.fixtureContainer);
    });

    describe('cacheOnly false', function() {
      it('requests the fixture and adds it to the cache', function() {
        spyOn(subject, 'xhrRequest');
        subject.load(path);
        expect(subject.xhrRequest).to.have.been.calledOnce;
        expect(subject.cache[path]).to.equal('foo\n');
      });

      it('appends the fixture container with the fixture to the dom', function() {
        expect(testFixtureContainer()).to.equal(null);
        subject.load(path);
        expect(testFixtureContainer().innerHTML).to.equal('foo\n');
      });


      describe('cached', function() {
        beforeEach(function() {
          subject.cache[path] = 'howdy';
        });

        it('does not make a request', function() {
          spyOn(subject, 'xhrRequest');
          subject.load(path);
          expect(subject.xhrRequest).to.not.have.been.calledOnce;
        });

        it('appends the fixture container to the dom with the cached fixture', function() {
          expect(testFixtureContainer()).to.equal(null);
          subject.load(path);
          expect(testFixtureContainer().innerHTML).to.equal('howdy');
        });
      });
    });

    describe('cacheOnly true', function() {
      beforeEach(function() {
        subject.cacheOnly = true;
      });

      it('does not make a request', function() {
        spyOn(subject, 'xhrRequest');
        subject.cache[path] = 'howdy';
        subject.load(path);
        expect(subject.xhrRequest).to.not.have.been.calledOnce;
      });

      it('throws an error if the fixture is not in the cache', function() {
        expect(function() {
          subject.load(path);
        }).to.throw(/The fixture "orders\/foo" was not preloaded. Is the fixture registered\? Such a bummer./);
      });
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
    afterEach(function() {
      removeNode(subject.fixtureContainer);
    });

    describe('without the fixture container', function() {
      it('logs a message saying that this is a weird thing to do', function() {
        spyOn(console, 'log');
        subject.removeFixtureContainer();
        expect(console.log).to.have.been.calledWith('Tried to remove the fixture container but it was\'t there. Did you forget to load the fixture?')
      });
    });

    describe('with the fixture there', function() {
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

  describe('#handleError', function() {
    it('throws an informative error', function() {
      var message = 'something informative';

      expect(function() {
        subject.handleError(message);
      }).to.throw(message);
    });
  });

  describe('#xhrRequest', function() {
    it('makes an get request to the specified path', function() {
      var xhrProto = XMLHttpRequest.prototype;
      stub(subject, 'handleError', true);
      stub(xhrProto, 'open', true);
      stub(xhrProto, 'send', true);
      var path = '/magic_lamp';
      subject.xhrRequest(path);

      expect(xhrProto.open).to.have.been.calledWith('GET', path, false);
      expect(xhrProto.send).to.have.been.calledOnce;

    });

    it('returns the xhr object', function() {
      var path = '/magic_lamp';
      var result = subject.xhrRequest(path);

      expect(result.constructor).to.equal(XMLHttpRequest);
    });

    it('calls handleError if the status is not 200', function() {
      stub(subject, 'handleError', true);
      var path = '/magic_lamp/foo/bar';
      var xhr = subject.xhrRequest(path);
      expect(subject.handleError).to.have.been.calledWith(xhr.responseText);
    });
  });
});
