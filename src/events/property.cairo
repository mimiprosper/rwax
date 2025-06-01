use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct PropertyAdded {
    pub property_id: u256,
    pub property_address: felt252,
    pub total_shares: u256,
}

#[derive(Drop, starknet::Event)]
pub struct PropertyListed {
    pub property_id: u256,
    pub sale_price: u256,
}

#[derive(Drop, starknet::Event)]
pub struct PropertySold {
    pub property_id: u256,
    pub buyer: ContractAddress,
    pub sale_price: u256,
}
