#[starknet::contract]
mod PreciousMetalsFractionalOwnership {
     // ========== Openzeppelin ==========
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc1155::{ERC1155Component, ERC1155HooksEmptyImpl};  

    // ========== Interfaces ==========
    use rwax::interfaces::iprecious_metal::IPreciousMetalsFractional; 

    // ========== rwax events ========== 
    use rwax::events::metal_property::{AssetAdded};
    use rwax::events::metal_finance::{PriceUpdated, PhysicalRedemptionRequested, StorageFeeRefundDistributed};
    use rwax::events::metal_proposal::{MetalProposalCreated, MetalProposalExecuted};
    use rwax::events::metal_bulk_sales::{BulkSaleTriggered};
    use rwax::events::metal_vote::VoteCast;
    
    // ========== rwax structs ========== 
    use rwax::structs::metal_property::MetalAssetDetails;
    use rwax::structs::metal_proposal::MetalProposal;
    
    // ========== Starknet modules ==========  
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address, get_contract_address};

    component!(path: ERC1155Component, storage: erc1155, event: ERC1155Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // External
    #[abi(embed_v0)]
    impl ERC1155MixinImpl = ERC1155Component::ERC1155MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    // Internal
    impl ERC1155InternalImpl = ERC1155Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc1155: ERC1155Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        
        // Asset registry
        asset_count: u256,
        asset_details: Map<u256, MetalAssetDetails>,
        
        // Vault operators
        vault_operators: Map<u256, ContractAddress>,
        
        // Revenue tracking
        total_revenue: Map<u256, u256>,
        claimed_revenue: Map<(u256, ContractAddress), u256>,
        revenue_per_share: Map<u256, u256>,
        
        // Redemption tracking
        redemption_requests: Map<(u256, ContractAddress), u256>,
        
        // Governance
        proposals: Map<u256, MetalProposal>,
        proposal_count: u256,
        decision_threshold: u8, // Percentage needed to approve (e.g. 51)
        
        // Bulk sale status
        bulk_sale_active: Map<u256, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC1155Event: ERC1155Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        // Custom events
        AssetAdded: AssetAdded,
        PriceUpdated: PriceUpdated,
        PhysicalRedemptionRequested: PhysicalRedemptionRequested,
        // RevenueDistributed: RevenueDistributed,
        StorageFeeRefundDistributed: StorageFeeRefundDistributed,
        // RevenueClaimed: RevenueClaimed,
        MetalProposalCreated: MetalProposalCreated,
        VoteCast: VoteCast,
        MetalProposalExecuted: MetalProposalExecuted,
        BulkSaleTriggered: BulkSaleTriggered,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        initial_owner: ContractAddress,
        uri: ByteArray,
        decision_threshold: u8,
    ) {
        self.erc1155.initializer(uri);
        self.ownable.initializer(initial_owner);

        assert(decision_threshold > 50 && decision_threshold <= 100, 'Invalid threshold');

        // Initialize contract parameters
        self.decision_threshold.write(decision_threshold);
        self.asset_count.write(0);
        self.proposal_count.write(0);
    }

    #[abi(embed_v0)]
    // This error would go off when all the traits has been implemented.
    impl PreciousMetalsFractionalImpl of IPreciousMetalsFractional<ContractState> {
        // ========== Asset Management ==========
        fn add_metal_asset(
            ref self: ContractState,
            // asset_id: u256,
            metal_type: felt252,
            purity: u8,
            weight_grams: u256,
            vault_location: felt252,
            assay_report_uri: felt252,
            total_shares: u256,
            share_price: u256,
            initial_owner: ContractAddress,
            vault_operator: ContractAddress,
        ) {
            // Only contract owner can add assets
            self.ownable.assert_only_owner();

            let asset_id = self.asset_count.read();

            // Create asset details
            let details = MetalAssetDetails {
                purity,
                metal_type,
                initial_owner,
                vault_operator,
                weight_grams,
                total_shares,
                share_price,
            };

            // Mint all shares to initial owner
            // TODO: implement mint on erc1155
            // self.erc1155._mint(initial_owner, asset_id, total_shares, array![].span());

            // Store asset details and vault operator
            self.asset_details.write(asset_id, details);
            self.vault_operators.write(asset_id, vault_operator);

            // Increment asset count
            self.asset_count.write(asset_id + 1);

            // Emit event
            self.asset_details.write(asset_id, details);
             self.emit(AssetAdded { asset_id, metal_type, weight_grams, total_shares});
        }

        fn get_asset_details(self: @ContractState, asset_id: u256) -> MetalAssetDetails {
            self.asset_details.read(asset_id)
        }

        fn get_vault_operator(self: @ContractState, asset_id: u256) -> ContractAddress {
            self.vault_operators.read(asset_id)
        }
        
        // ========== Price & Redemption ==========
        fn update_spot_price(ref self: ContractState, asset_id: u256, new_price: u256) {
            // Only vault operator or oracle can update price
            let operator = self.vault_operators.read(asset_id);
            assert(get_caller_address() == operator, 'Only vault operator');

            let mut details = self.asset_details.read(asset_id);
            self.asset_details.write(asset_id, details);
            self.emit(PriceUpdated { asset_id, new_price});
        }

        fn request_physical_redemption(
            ref self: ContractState, 
            asset_id: u256, 
            grams_to_redeem: u256,
            shipping_address: felt252,
        ) {
            let caller = get_caller_address();
            let details = self.asset_details.read(asset_id);

            // Calculate shares needed for redemption
            let shares_to_burn = (grams_to_redeem * details.total_shares) / details.weight_grams;
            let balance = self.erc1155.balance_of(caller, asset_id);

            assert(balance >= shares_to_burn, 'Insufficient shares');
            assert(grams_to_redeem > 0, 'Zero amount');

            // Record redemption request
            self.redemption_requests.write((asset_id, caller), grams_to_redeem);

            // In real implementation: 
            // 1. Burn shares
            // 2. Initiate physical delivery process
            // self.erc1155._burn(caller, asset_id, shares_to_burn);

            self.emit(
                PhysicalRedemptionRequested {
                    asset_id,
                    grams_to_redeem,
                    shipping_address,
                },
            );
        }

        // ========== Revenue Distribution ==========
        fn distribute_storage_fee_refund(ref self: ContractState, asset_id: u256, amount: u256) {
            // Only vault operator can distribute refunds
            let operator = self.vault_operators.read(asset_id);
            assert(get_caller_address() == operator, 'Only vault operator');

            let details = self.asset_details.read(asset_id);
            let total_shares = details.total_shares;
            let refund_per_share = amount / total_shares;

            // Update tracking
            self.total_revenue.write(asset_id, self.total_revenue.read(asset_id) + amount);
            self.revenue_per_share.write(
                asset_id, self.revenue_per_share.read(asset_id) + refund_per_share,
            );

            self.emit(
                StorageFeeRefundDistributed {
                    asset_id, 
                    amount, 
                },
            );
        }

        // fn claim_metal_revenue 

        // ========== Governance ==========
        fn create_metal_proposal(
            ref self: ContractState,
            asset_id: u256,
            description: felt252,
            value: u256,
            recipient: ContractAddress,
            voting_period: u64,
            
        ) {
            // Only vault operator or significant shareholders can create proposals
            let caller = get_caller_address();
            let operator = self.vault_operators.read(asset_id);
            let balance = self.erc1155.balance_of(caller, asset_id);
            let details = self.asset_details.read(asset_id);

            assert(
                caller == operator || balance > details.total_shares / 10_u256,
                'Not authorized to propose',
            );

            let proposal_id = self.proposal_count.read();
            let voting_end_time = get_block_timestamp() + voting_period;

            let proposal = MetalProposal {
                description,
                value,
                recipient,
                voting_end_time,
            };

            // Store proposal
            self.proposals.write(proposal_id, proposal);
            self.proposal_count.write(proposal_id + 1);

            self.emit(
                MetalProposalCreated {
                    proposal_id, 
                    asset_id, 
                    // creator,
                    description, 
                    voting_end_time,
                },
            );
        }

        

        
        
    }
}
