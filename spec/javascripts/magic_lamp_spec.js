describe('MagicLamp', function() {
  var subject;
  beforeEach(function() {
    subject = MagicLamp;
  });

  it('is an object', function() {
    expect(subject).to.be.a('object');
  });

  describe('#initialize', function() {
    it('sets genie to a new genie instance', function() {
      subject.initialize();
      expect(subject.genie).to.be.an.instanceof(subject.Genie);
    });
  });
});
