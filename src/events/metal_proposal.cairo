use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct MetalProposalCreated {
    pub proposal_id: u256,
    pub asset_id: u256,
    // pub creator: ContractAddress, 
    pub description: felt252, 
    pub voting_end_time: u64,
}

#[derive(Drop, starknet::Event)]
pub struct MetalProposalExecuted {
    pub proposal_id: u256,
}

