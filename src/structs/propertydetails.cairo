
#[derive(Drop, Serde)]
struct Propertydetails {
    property_id: u256,
    property_address: felt252,
    property_description: felt252,
    property_value: u256,
    property_image_uri: felt252,
    total_shares: u256,
    share_price: u256,
}