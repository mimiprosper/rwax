#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct MetalAssetDetails {
    pub property_id: u256,
    pub property_address: felt252,
    pub property_description: felt252,
    pub property_value: u256,
    pub property_image_uri: felt252,
    pub total_shares: u256,
    pub share_price: u256,
}
