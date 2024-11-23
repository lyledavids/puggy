#[starknet::contract]
mod NFTMarketplace {
    use starknet::{ContractAddress, get_caller_address};
    use zeroable::Zeroable;
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use option::OptionTrait;
    use integer::u256_from_felt252;
    use starknet::storage::StorageMap;

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Listing {
        seller: ContractAddress,
        price: u256,
        is_active: bool,
    }

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        owners: StorageMap::<u256, ContractAddress>,
        balances: StorageMap::<ContractAddress, u256>,
        token_uri: StorageMap::<u256, felt252>,
        token_id: u256,
        listings: StorageMap::<u256, Listing>,
        operator_approvals: StorageMap::<(ContractAddress, ContractAddress), bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        TokenListed: TokenListed,
        TokenSold: TokenSold,
        TokenMinted: TokenMinted,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        approved: ContractAddress,
        token_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenListed {
        token_id: u256,
        seller: ContractAddress,
        price: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenSold {
        token_id: u256,
        seller: ContractAddress,
        buyer: ContractAddress,
        price: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenMinted {
        to: ContractAddress,
        token_id: u256,
        token_uri: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, name_: felt252, symbol_: felt252) {
        self.name.write(name_);
        self.symbol.write(symbol_);
        self.token_id.write(0);
    }

    #[starknet::interface]
    trait IERC721<TContractState> {
        fn name(self: @TContractState) -> felt252;
        fn symbol(self: @TContractState) -> felt252;
        fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
        fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
        fn get_token_uri(self: @TContractState, token_id: u256) -> felt252;
        fn transfer(ref self: TContractState, to: ContractAddress, token_id: u256);
        fn approve(ref self: TContractState, approved: ContractAddress, token_id: u256);
    }

    #[starknet::interface]
    trait IMarketplace<TContractState> {
        fn mint(ref self: TContractState, token_uri: felt252);
        fn list_token(ref self: TContractState, token_id: u256, price: u256);
        fn buy_token(ref self: TContractState, token_id: u256);
        fn cancel_listing(ref self: TContractState, token_id: u256);
        fn get_listing(self: @TContractState, token_id: u256) -> Listing;
    }

    #[abi(embed_v0)]
    impl IERC721Impl of IERC721<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            self.balances.read(owner)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let owner = self.owners.read(token_id);
            assert(!owner.is_zero(), 'ERC721: invalid token ID');
            owner
        }

        fn get_token_uri(self: @ContractState, token_id: u256) -> felt252 {
            self.token_uri.read(token_id)
        }

        fn transfer(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let caller = get_caller_address();
            self._transfer(caller, to, token_id);
        }

        fn approve(ref self: ContractState, approved: ContractAddress, token_id: u256) {
            let caller = get_caller_address();
            let owner = self.owner_of(token_id);
            assert(caller == owner, 'Not token owner');
            self.operator_approvals.write((owner, approved), true);
            self.emit(Event::Approval(Approval { owner, approved, token_id }));
        }
    }

    #[abi(embed_v0)]
    impl MarketplaceImpl of IMarketplace<ContractState> {
        fn mint(ref self: ContractState, token_uri: felt252) {
            let caller = get_caller_address();
            let token_id = self.token_id.read() + 1;
            
            self.token_id.write(token_id);
            self._mint(caller, token_id, token_uri);
        }

        fn list_token(ref self: ContractState, token_id: u256, price: u256) {
            let caller = get_caller_address();
            assert(self.owner_of(token_id) == caller, 'Not token owner');
            assert(price > 0, 'Price must be > 0');

            self.listings.write(token_id, Listing { seller: caller, price, is_active: true });
            self.emit(Event::TokenListed(TokenListed { token_id, seller: caller, price }));
        }

        fn buy_token(ref self: ContractState, token_id: u256) {
            let caller = get_caller_address();
            let listing = self.listings.read(token_id);
            
            assert(listing.is_active, 'Token not listed');
            assert(caller != listing.seller, 'Seller cannot buy');

            self._transfer(listing.seller, caller, token_id);
            self.listings.write(token_id, Listing { seller: listing.seller, price: listing.price, is_active: false });
            
            self.emit(Event::TokenSold(TokenSold { 
                token_id, 
                seller: listing.seller,
                buyer: caller,
                price: listing.price
            }));
        }

        fn cancel_listing(ref self: ContractState, token_id: u256) {
            let caller = get_caller_address();
            let listing = self.listings.read(token_id);
            
            assert(listing.is_active, 'Token not listed');
            assert(caller == listing.seller, 'Not the seller');

            self.listings.write(token_id, Listing { seller: listing.seller, price: listing.price, is_active: false });
        }

        fn get_listing(self: @ContractState, token_id: u256) -> Listing {
            self.listings.read(token_id)
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _mint(ref self: ContractState, to: ContractAddress, token_id: u256, token_uri: felt252) {
            assert(!to.is_zero(), 'Invalid recipient');
            assert(self.owners.read(token_id).is_zero(), 'Token already minted');

            self.owners.write(token_id, to);
            self.balances.write(to, self.balances.read(to) + 1);
            self.token_uri.write(token_id, token_uri);

            self.emit(Event::Transfer(Transfer { from: Zeroable::zero(), to, token_id }));
            self.emit(Event::TokenMinted(TokenMinted { to, token_id, token_uri }));
        }

        fn _transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            assert(!to.is_zero(), 'Invalid recipient');
            let owner = self.owner_of(token_id);
            assert(from == owner, 'Not token owner');

            self.owners.write(token_id, to);
            self.balances.write(from, self.balances.read(from) - 1);
            self.balances.write(to, self.balances.read(to) + 1);

            self.emit(Event::Transfer(Transfer { from, to, token_id }));
        }
    }
}