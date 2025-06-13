use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct RevenueClaimed {
    pub asset_id: u256, 
    pub owner: ContractAddress, 
    pub amount: u256,    
}

#[derive(Drop, starknet::Event)]
pub struct PriceUpdated {
    pub asset_id: u256,
    pub new_price: u256,
    // pub timestamp: get_block_timestamp(),
}

#[derive(Drop, starknet::Event)]
pub struct PhysicalRedemptionRequested {
    pub asset_id: u256,
    pub grams_to_redeem: u256,
    pub shipping_address: felt252,
    // pub timestamp: get_block_timestamp()
}

#[derive(Drop, starknet::Event)]
pub struct StorageFeeRefundDistributed {
    pub asset_id: u256,
    pub amount: u256,
    // pub timestamp: get_block_timestamp(),
}

