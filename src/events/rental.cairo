use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct RentalIncomeDistributed {
    pub property_id: u256,
    pub amount: u256,
    pub timestamp: u64,
}

#[derive(Drop, starknet::Event)]
pub struct RentalIncomeClaimed {
    pub property_id: u256,
    pub owner: ContractAddress,
    pub amount: u256,
}
