pub mod interfaces {
    pub mod iprecious_metal;
    pub mod ireal_estate;
}

pub mod contracts {
    pub mod real_estate;
    pub mod precious_metal;
}

pub mod events {
    // real estate events
    pub mod property;
    pub mod proporsal;
    pub mod rental;
    pub mod vote;

    // metal events
    pub mod metal_property;
    pub mod metal_proposal;
    pub mod metal_vote;
    pub mod metal_finance;
    pub mod metal_bulk_sales;
}

pub mod structs {
    // real estate structs
    pub mod property;
    pub mod proporsal;

    // metal structs
    pub mod metal_property;
    pub mod metal_proposal;
}
