pragma solidity ^0.4.2;

contract baseContract{

	address public owner;

	function baseContract(){
		owner = msg.sender;
	}

  	modifier onlyOwner{
  		if(msg.sender != owner){
    			throw;
  		}
  		else{
    			_;
  		}
	}
	
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
        else{
            throw;
        }
    }

	function kill() onlyOwner{
  		suicide(owner);
	}
}

contract Service is baseContract{

	uint public servicePrice;
	uint public usersCount;
	bytes32 public publicKey;
	bytes32 public ipfsHash;
	uint public locked;

	mapping (address => user ) public users;
	struct user{
		bytes32 publicKey;
		uint lastUpdate;
		uint countUsage;
	}

	function Service(){
		owner = msg.sender;
	}

	function setPrice(uint _price) onlyOwner{
		servicePrice = _price;
	}

	function setPublicKey(bytes32 _publicKey) onlyOwner{
		publicKey = _publicKey;
	}
	
	function setIpfsHash(bytes32 _ipfsHash) onlyOwner{
		ipfsHash = _ipfsHash;
	}

	function consume(bytes32 _publicKey, address userAddress) payable costs(servicePrice){
		if(users[userAddress].publicKey == 0){
			users[userAddress] = user({
	   			publicKey:_publicKey,
	   			lastUpdate:now,
	   			countUsage:1,
	  		});
			usersCount+=1;
		}
		else{
			users[userAddress].lastUpdate = now;
			users[userAddress].countUsage += 1;
		}
  	}

	function withdraw()onlyOwner {
		if (!owner.send(this.balance)) throw;
	}

}

contract User is baseContract {

	bytes32 public publicKey;
	uint public eth;
	
	uint public consumedServicesCount;
	uint public providedServicesCount;
	
	mapping(address => ServiceInfo) public myConsumedServices;
	mapping(address => ServiceInfo) public myProvidedServices;
	
	mapping(uint => address) public consumedServices;
	mapping(uint => address) public providedServices;

    struct ServiceInfo{
        address serviceAddress;
        bytes32 publicKey;
        uint lastUsage;
        uint256 countUsage;
    }

    function User(){
        owner = msg.sender;
    }

	function setPublicKey(bytes32 _publicKey) onlyOwner{
		publicKey = _publicKey;
	}
	function fund() onlyOwner payable{
	    eth += msg.value;    
	}
    
    function consumeService(address _serviceAddress) onlyOwner {
        if(myConsumedServices[_serviceAddress].serviceAddress == 0){
            myConsumedServices[_serviceAddress] = ServiceInfo({
                serviceAddress:_serviceAddress,
                publicKey : 0,
                lastUsage:now,
                countUsage:1
            });
            consumedServicesCount++;
            consumedServices[consumedServicesCount] = _serviceAddress;
        }
        else{
            myConsumedServices[_serviceAddress].lastUsage = now;
            myConsumedServices[_serviceAddress].countUsage++;
        }
        Service service = Service(_serviceAddress);
		service.consume.value(service.servicePrice())(publicKey,owner); //not always working
        myConsumedServices[_serviceAddress].publicKey = service.publicKey();
    }
    
    function deployServiceContract() onlyOwner {
        Service newService = new Service();
        myProvidedServices[newService] = ServiceInfo({
                serviceAddress:newService,
                publicKey : 0,
                lastUsage: 0,
                countUsage:0
        });
        providedServicesCount++;
        providedServices[providedServicesCount] = newService;
    }
}

