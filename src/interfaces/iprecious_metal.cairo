use starknet::ContractAddress;

use rwax::structs::metal_property::MetalAssetDetails;
use rwax::structs::metal_proposal::MetalProposal;


#[starknet::interface]
pub trait IPreciousMetalsFractional<TContractState> {
    // ========== Asset Management Interface ==========
    fn add_metal_asset(
        ref self: TContractState,
        metal_type: felt252,
        purity: u8,
        weight_grams: u256,
        vault_location: felt252,
        assay_report_uri: felt252,
        total_shares: u256,
        share_price: u256,
        initial_owner: ContractAddress,
        vault_operator: ContractAddress,
    );

    fn get_asset_details(self: @TContractState, asset_id: u256) -> MetalAssetDetails;
    fn get_vault_operator(self: @TContractState, asset_id: u256) -> ContractAddress;

    // ========== Price & Redemption Interface ==========
    fn update_spot_price(ref self: TContractState, asset_id: u256, new_price: u256);
    fn request_physical_redemption(
        ref self: TContractState, asset_id: u256, grams_to_redeem: u256, shipping_address: felt252,
    );

    // ========== Revenue Distribution Interface ==========
    fn distribute_storage_fee_refund(ref self: TContractState, asset_id: u256, amount: u256);
    fn claim_metal_revenue(ref self: TContractState, asset_id: u256);

    // ========== Governance Interface ==========
    fn create_metal_proposal(
        ref self: TContractState,
        asset_id: u256,
        description: felt252,
        value: u256,
        recipient: ContractAddress,
        voting_period: u64,
    );

    fn cast_metal_vote(ref self: TContractState, proposal_id: u256, support: bool);
    fn execute_metal_proposal(ref self: TContractState, proposal_id: u256);
    fn get_metal_proposal(self: @TContractState, proposal_id: u256) -> MetalProposal;

    // ========== Asset Liquidation Interface ==========
    fn trigger_bulk_sale(ref self: TContractState, asset_id: u256);
}

