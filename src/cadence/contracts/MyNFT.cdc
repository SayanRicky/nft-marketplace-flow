import NonFungibleToken from 0x01

pub contract MyNFT: NonFungibleToken {
    pub var totalSupply: UInt64

	pub event ContractInitialized()
	pub event Withdraw(id: UInt64, from: Address?)
	pub event Deposit(id: UInt64, to: Address?)

    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        pub let ipfsHash: String
        pub var metadata: (String: String)

        init(_ipfsHash: String, _metadata: {String: String}) {
            self.id = MyNFT.totalSupply
            MyNFT.totalSupply = MyNFT.totalSupply + 1

            self.ipfsHash = _ipfsHash
            self.metadata = _metadata
        }
    }

    pub resource Collection: NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic {
        //the id of the NFT --> the NFT with that id
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let myToken <- token as! @MyNFT.NFT
            emit Deposit(id: myToken.id, to: self.owner?.address)
            self.ownedNFTs[myToken.id] <-! myToken
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT{
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This NFT does not exist")
            emit withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }
        
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT( id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        init(){
            self.ownedNFTs <- {}
        }
        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @Collection {
        return <-create Collection()
    }

    pub fun createToken(ipfsHash: String, metadata: {String: String}): @MyNFT.NFT {
        return <- create NFT(_ipfsHash: ipfsHash, _metadata: metadata)
    }

   init(){
	self.totalSupply = 0
   }
}
