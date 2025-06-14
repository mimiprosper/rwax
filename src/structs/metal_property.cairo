use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct MetalAssetDetails {   
    pub purity: u8, 
    pub metal_type: felt252,
    pub total_shares: u256,
    pub share_price: u256,
    pub weight_grams: u256,
    pub initial_owner: ContractAddress,
    pub vault_operator: ContractAddress,

}
