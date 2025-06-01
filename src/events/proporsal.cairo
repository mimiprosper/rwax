use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct ProposalCreated {
    pub proposal_id: u256,
    pub property_id: u256,
    pub creator: ContractAddress,
    pub description: felt252,
    pub voting_end_time: u64,
}

#[derive(Drop, starknet::Event)]
pub struct ProposalExecuted {
    pub proposal_id: u256,
}
