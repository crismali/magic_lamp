describe('Foo', function() {
  it('interacts with the template', function() {
    MagicLamp.load('orders/form');
    expect($('.foo').length).to.equal(1);
  });
});
