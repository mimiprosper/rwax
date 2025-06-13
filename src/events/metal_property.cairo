use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct AssetAdded {
    pub asset_id: u256,
    pub metal_type: felt252,
    pub weight_grams: u256,
    pub total_shares: u256
}

