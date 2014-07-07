describe('Something that depends on the dom', function() {

  it('depends on the dom', function() {
    fixture.load("foo.html");
    expect($('.foo').length).to.equal(1);
  });

  it('still depends on the dom', function() {
    expect($('.foo').length).to.equal(0);
  });
});
