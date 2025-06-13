use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct VoteCast {
    pub proposal_id: u256,
    pub voter: ContractAddress,
    pub supports: bool,
    pub voting_power: u256,
}