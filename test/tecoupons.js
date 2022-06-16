const Tecoupons = artifacts.require('Tecoupons');

contract('Tecoupons', (accounts) => {
  it('Create coupon', async () => {
    const my_contract = await Tecoupons.deployed();
    const accountOne = accounts[0];
    await my_contract.createCoupon(accountOne, 'abc');
    let ownerOf = await my_contract.ownerOf(1);
    assert.equal(accountOne, ownerOf);
  });

  it('Get Token URI', async () => {
    const my_contract = await Tecoupons.deployed();
    const accountOne = accounts[0];
    await my_contract.createCoupon(accountOne, 'abc');
    let token_uri = await my_contract.tokenURI(1);
    assert.equal('abc', token_uri);
  });

  it('Burn a coupon', async () => {
    const my_contract = await Tecoupons.deployed();
    const accountOne = accounts[0];
    // Create coupon
    await my_contract.createCoupon(accountOne, 'abc');
    let token_uri = await my_contract.tokenURI(1);
    assert.equal(token_uri, 'abc');

    await my_contract.redeemCoupon(1);
    let token_uri2 = await my_contract.tokenURI(1);
    assert.equal(
      token_uri2,
      'https://ipfs.io/ipfs/QmQtqQYkcTRA4uw4mNQVXLX6JXBWWcjrTLs5GdigGynUhU'
    );
  });
});
