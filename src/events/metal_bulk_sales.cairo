// use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct BulkSaleTriggered {
    pub asset_id: u256,
    // pub timestamp: get_block_timestamp(),
}

