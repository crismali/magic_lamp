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

  describe('#fixtureNames', function() {
    beforeEach(function() {
      stub(console, 'log', true);
      subject.cache = { foo: 'template', bar: 'other template' };
    });

    it('returns all of the fixtures named in the cache', function() {
      expect(subject.fixtureNames()).to.be.like(['bar', 'foo']);
      console.log.restore();
    });

    it('logs all of the fixture names in the cache', function() {
      subject.fixtureNames();
      expect(console.log).to.have.been.calledWith('bar');
      expect(console.log).to.have.been.calledWith('foo');
      expect(console.log.args).to.be.like([['bar'], ['foo']]);
      console.log.restore();
    });
  });

  describe('#load', function() {
    var path;
    var fixtureContent;
    beforeEach(function() {
      path = 'orders/foo';
      fixtureContent = 'foo\n';
    });

    afterEach(function() {
      removeNode(subject.fixtureContainer);
    });

    it('does not double append fixture containers', function() {
      subject.cache[path] = fixtureContent;
      subject.cacheOnly = true;
      _(2).times(function() { subject.load(path); });
      expect(document.getElementsByClassName('magic-lamp').length).to.equal(1);
    });

    it('appends the fixture container with the fixture to the dom', function() {
      spyOn(subject, 'retrieveFixture');
      expect(testFixtureContainer()).to.be.undefined;
      subject.load(path);
      expect(subject.retrieveFixture).to.have.been.calledWith(path);
      expect(testFixtureContainer().innerHTML).to.equal(fixtureContent);
    });

    describe('multiple fixtures requested', function() {
      it('appends the fixture container with all of the fixtures to the dom', function() {
        expect(testFixtureContainer()).to.be.undefined;
        subject.load(path, path, path, path);
        var largeFixtureContent = fixtureContent + fixtureContent + fixtureContent + fixtureContent;
        expect(testFixtureContainer().innerHTML).to.equal(largeFixtureContent);
      });
    });
  });

  describe('#retrieveFixture', function() {
    var path;
    var fixtureContent;
    beforeEach(function() {
      path = 'orders/foo';
      fixtureContent = 'foo\n';
    });

    describe('cacheOnly false', function() {
      it('requests the fixture and adds it to the cache', function() {
        spyOn(subject, 'xhrRequest');
        subject.retrieveFixture(path);
        expect(subject.xhrRequest).to.have.been.calledOnce;
        expect(subject.cache[path]).to.equal(fixtureContent);
      });

      it('returns the fixture', function() {
        expect(subject.retrieveFixture(path)).to.equal(fixtureContent);
      });

      it('throws an error if the fixture is an empty string', function() {
        stub(subject, 'xhrRequest', { responseText: '' });
        expect(function() {
          subject.retrieveFixture(path);
        }).to.throw(/The fixture "orders\/foo" is an empty string. Run `rake magic_lamp:lint` for more information./);
      });

      describe('cached', function() {
        beforeEach(function() {
          fixtureContent = subject.cache[path] = 'howdy';
        });

        it('does not make a request', function() {
          spyOn(subject, 'xhrRequest');
          subject.retrieveFixture(path);
          expect(subject.xhrRequest).to.not.have.been.calledOnce;
        });

        it('returns the fixture', function() {
          expect(subject.retrieveFixture(path)).to.equal(fixtureContent);
        });

        it('throws an error if the fixture is an empty string', function() {
          subject.cache[path] = '';
          expect(function() {
            subject.retrieveFixture(path);
          }).to.throw(/The fixture "orders\/foo" is an empty string. Run `rake magic_lamp:lint` for more information./);
        });
      });
    });

    describe('cacheOnly true', function() {
      beforeEach(function() {
        subject.cacheOnly = true;
      });

      it('does not make a request', function() {
        spyOn(subject, 'xhrRequest');
        subject.cache[path] = fixtureContent;
        subject.retrieveFixture(path);
        expect(subject.xhrRequest).to.not.have.been.calledOnce;
      });

      it('returns the fixture', function() {
        subject.cache[path] = fixtureContent;
        expect(subject.retrieveFixture(path)).to.equal(fixtureContent);
      });

      it('throws an error if the fixture is not in the cache', function() {
        expect(function() {
          subject.retrieveFixture(path);
        }).to.throw(/The fixture "orders\/foo" was not preloaded. Is the fixture registered\? Call `MagicLamp.fixtureNames\(\)` to see what is registered./);
      });

      it('throws an error if the fixture is an empty string', function() {
        subject.cache[path] = '';
        expect(function() {
          subject.retrieveFixture(path);
        }).to.throw(/The fixture "orders\/foo" is an empty string. Run `rake magic_lamp:lint` for more information./);
      });
    });
  });

  describe('#preload', function() {
    it('requests all of the fixtures and puts them in the cache', function() {
      subject.preload();
      expect(subject.cache).to.have.keys([
        'from_test_directory',
        'hash_to_jsoned',
        'rendered_json',
        'just_some_string',
        'orders/foo',
        'orders/bar',
        'orders/form',
        'custom_name',
        'orders/super_specified',
        'orders/needs_extending',
        'orders/errors/foos/bar/baz',
        'arbitrary/orders/other_admin_extending',
        'arbitrary/orders/admin_extending'
      ]);
    });

    it('sets cacheOnly to true', function() {
      subject.preload();
      expect(subject.cacheOnly).to.equal(true);
    });

    it('does not set cacheOnly to true if the request fails', function() {
      subject.xhrRequest = function() { throw new Error(); }
      expect(function() { subject.preload(); }).to.throw();
      expect(subject.cacheOnly).to.equal(false);
    });

    it('does not set cacheOnly to true if the response cannot be parsed', function() {
      var path = MagicLamp.path = '/normal_lamp';
      stub(subject, 'xhrRequest', { responseText: '<html></html>' });
      stub(console, 'error', true);

      expect(function() { subject.preload(); }).to.throw();
      expect(subject.xhrRequest).to.have.been.calledWith(path);
      expect(subject.cacheOnly).to.equal(false);
      expect(console.error).to.have.been.calledWith(
        'The response could not be parsed: responseText="<html></html>", error="JSON Parse error: Unrecognized token \'<\'"'
      );

      delete MagicLamp.path;
      console.error.restore();
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
    it('creates a div with a class of "magic-lamp" and caches it', function() {
      subject.createFixtureContainer();
      expect(subject.fixtureContainer.tagName).to.equal('DIV');
      expect(subject.fixtureContainer.className).to.equal('magic-lamp');
    });

    it('creates a div with a class of MagicLamp.class if present', function() {
      var specifiedClass = MagicLamp.class = 'footastic';
      subject.createFixtureContainer();
      delete MagicLamp.class;
      expect(subject.fixtureContainer.className).to.equal(specifiedClass);
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
      expect(testFixtureContainer()).to.be.undefined;
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
        expect(function() {
          _(3).times(function() { subject.removeFixtureContainer(); });
        }).to.not.throw()
      });
    });

    describe('with the fixture container created', function() {
      beforeEach(function() {
        subject.createFixtureContainer();
      });

      it('removes the fixture container from the genie instance', function() {
        expect(subject.fixtureContainer).to.be.defined;
        subject.removeFixtureContainer();
        expect(subject.fixtureContainer).to.be.undefined;
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
        expect(testFixtureContainer()).to.be.undefined;
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

    it('calls handleError with the response text if the status was 400', function() {
      stub(subject, 'handleError', true);
      var path = '/magic_lamp/foo/bar';
      var xhr = subject.xhrRequest(path);
      expect(subject.handleError).to.have.been.calledWith(xhr.responseText);
    });

    it('calls handleError with the default error message if the status was 500', function() {
      stub(subject, 'handleError', true);
      stub(subject, 'xhrStatus', 500);
      var path = '/magic_lamp/foo/bar';
      subject.xhrRequest(path);
      expect(subject.handleError).to.have.been.calledWith(MagicLamp.genericError);
    });

    it('calls handleError with the default error message if the status was 404', function() {
      stub(subject, 'handleError', true);
      stub(subject, 'xhrStatus', 404);
      var path = '/magic_lamp/foo/bar';
      subject.xhrRequest(path);
      expect(subject.handleError).to.have.been.calledWith(MagicLamp.genericError);
    });
  });

  describe('#xhrStatus', function() {
    it('returns the status of the xhr', function() {
      var status = 200;
      expect(subject.xhrStatus({ status: status })).to.equal(status);
    });
  });
});
