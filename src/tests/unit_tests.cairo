use erc721::ERC721;
use zeroable::Zeroable;
use starknet::get_caller_address;
use starknet::ContractAddressZeroable;
use starknet::ContractAddressIntoFelt;
use starknet::FeltTryIntoContractAddress;
use traits::Into;
use traits::TryInto;
use array::ArrayTrait;
use option::OptionTrait;

////////////////////////////////
// VIEWS
////////////////////////////////
#[test]
#[available_gas(2000000)]
fn test_get_name() {
    ERC721::constructor('Foo', 'BAR');

    assert(ERC721::get_name() == 'Foo', 'wrong name');
}

#[test]
#[available_gas(2000000)]
fn test_get_symbol() {
    ERC721::constructor('Foo', 'BAR');

    assert(ERC721::get_symbol() == 'BAR', 'wrong symbol');
}

#[test]
#[available_gas(2000000)]
fn test_balance_of() {
    ERC721::constructor('Foo', 'BAR');
    let me: felt = 123;
    ERC721::balances::write(me, 1.into());

    let balance = ERC721::balance_of(me);
    assert(balance == 1.into(), 'wrong balance');
}

#[test]
#[available_gas(2000000)]
fn test_owner_of() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let owner = ERC721::owner_of(nft_id);
    assert(owner.into() == 123, 'wrong owner');
}

#[test]
#[available_gas(2000000)]
fn test_get_approved() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = 1.into();
    let me: felt = 123;
    ERC721::owners::write(nft_id, me);
    ERC721::balances::write(me, 1.into());

    let me: ContractAddress = me.try_into().unwrap();
    let friend: ContractAddress = 456.try_into().unwrap();

    starknet_testing::set_caller_address(me);
    ERC721::approve(friend, nft_id);

    let approved = ERC721::get_approved(nft_id);
    assert(approved == friend, 'wrong approved');
}

#[test]
#[available_gas(2000000)]
fn test_is_approved_for_all() {
    ERC721::constructor('Foo', 'BAR');
    let me: felt = 123;
    let friend: felt = 456;

    let me: ContractAddress = me.try_into().unwrap();
    let friend: ContractAddress = friend.try_into().unwrap();

    starknet_testing::set_caller_address(me);
    ERC721::set_approval_for_all(friend, true);

    let is_approved = ERC721::is_approved_for_all(me, friend);
    assert(is_approved, 'not approved for all');
}

#[test]
#[available_gas(2000000)]
fn test_get_token_uri() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = 1.into();
    ERC721::token_uri::write(nft_id, 'https://example.com/1');

    let uri = ERC721::get_token_uri(nft_id);
    assert(uri == 'https://example.com/1', 'wrong uri');
}

////////////////////////////////
// EXTERNAL
////////////////////////////////

#[test]
#[available_gas(2000000)]
fn test_transfer_from() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);
    ERC721::balances::write(123, 1.into());

    let me = starknet::contract_address_const::<123>();
    let friend = starknet::contract_address_const::<456>();
    starknet_testing::set_caller_address(me);
    ERC721::transfer_from(me, friend, nft_id);

    let new_owner = ERC721::owners::read(nft_id);
    assert(new_owner == 456, 'wrong new owner');
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from_approved() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = 1.into();
    let me: felt = 123;
    ERC721::owners::write(nft_id, me);
    ERC721::balances::write(me, 1.into());

    let me: ContractAddress = me.try_into().unwrap();
    let friend: ContractAddress = 456.try_into().unwrap();

    starknet_testing::set_caller_address(me);
    ERC721::approve(friend, nft_id);

    starknet_testing::set_caller_address(friend);
    ERC721::transfer_from(me, 789.try_into().unwrap(), nft_id);
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from_approved_for_all() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = 1.into();
    let me: felt = 123;
    ERC721::owners::write(nft_id, me);
    ERC721::balances::write(me, 1.into());

    let me: ContractAddress = me.try_into().unwrap();
    let friend: ContractAddress = 456.try_into().unwrap();

    starknet_testing::set_caller_address(me);
    ERC721::approve(friend, nft_id);

    starknet_testing::set_caller_address(friend);
    ERC721::transfer_from(me, 789.try_into().unwrap(), nft_id);
}

#[test]
#[available_gas(2000000)]
#[should_panic]
fn test_transfer_from_not_approved() {
    ERC721::constructor('Foo', 'BAR');
    let nft_id: u256 = 1.into();
    let me: felt = 123;
    ERC721::owners::write(nft_id, me);
    ERC721::balances::write(me, 1.into());

    let me: ContractAddress = me.try_into().unwrap();
    let friend: ContractAddress = 456.try_into().unwrap();
    // random caller address
    starknet_testing::set_caller_address(127846125.try_into().unwrap());
    ERC721::approve(friend, nft_id);
    ERC721::transfer_from(friend, starknet::contract_address_const::<789>(), nft_id);
}
