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
	uint public activeBalance;
	address public monitorAddress;
	string public serviceUrl;
	uint public sla;

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
	
	function setSla(uint _sla) onlyOwner{
		sla = _sla;
	}

	function setPublicKey(bytes32 _publicKey) onlyOwner{
		publicKey = _publicKey;
	}
	
	function setIpfsHash(bytes32 _ipfsHash) onlyOwner{
		ipfsHash = _ipfsHash;
	}
	
	function setServiceUrl(string url) onlyOwner{
		serviceUrl = url;
	}
	
	function setMonitorAddress(address monitor) onlyOwner{
		monitorAddress = monitor;
	}

	function consume(bytes32 _publicKey, address userAddress, uint refund) payable costs(servicePrice){
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
		if(refund != 0){
		    locked++;
		    Monitor monitor = Monitor(monitorAddress);
		    monitor.submitMonitoringRequest(this,userAddress, serviceUrl);
		}else{
		    activeBalance+=servicePrice;
		}
  	}

	function withdraw()onlyOwner {
		if (!owner.send(activeBalance)) throw;
	}
	
	function notifyMe(address useAddress, uint result){
	    if (result < sla){
	        User user = User(useAddress);
	        user.refund.value(servicePrice)();
	    }else{
	        activeBalance+=servicePrice;
	    }
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
	
	function refund() payable{
	    eth += msg.value;
	}   
    
    function consumeService(address _serviceAddress, uint refund) onlyOwner {
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
		service.consume.value(service.servicePrice())(publicKey,this,refund);
        myConsumedServices[_serviceAddress].publicKey = service.publicKey();
        eth -= service.servicePrice();
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

contract UserRegistry is baseContract{
    
    mapping (address => address) public userContracts;
    
    function UserRegistry(){
        owner = msg.sender;
    }

    function setUserContractAddress() {
        if(userContracts[msg.sender] == address(0)){
            User newUser = new User();
            userContracts[msg.sender] = newUser;
        }
    }
}

contract Monitor {
    
    struct monitorJob {
        address serviceAddress;  
        string serviceUrl;
        bool done;
        uint result;
        address monitorAddress;
        address userAddress;
    }
    
    uint public jobsCount;
    
    mapping(uint => monitorJob) public monitorJobs;
    uint [] public jobsAvailable;
    
    event newMonitorRecord();
    
    function submitMonitoringRequest (address serviceAddress,address userAddress, string url){
        jobsCount += 1;
        monitorJobs[jobsCount] = monitorJob({
            serviceAddress :serviceAddress,
            serviceUrl : url, 
            done : false,
            result : 0,
            monitorAddress: address(0),
            userAddress : userAddress
            
        });
        jobsAvailable.push(jobsCount);
        newMonitorRecord();
        
    }
    uint nonce = 0;
    function rand(uint min, uint max) public returns (uint){
        nonce++;
        return uint(sha3(nonce))%(min+max)-min;
    }
      
    event jobMonitorEvent(address sender,uint jobIndex);
    function getMonitorRequest(){
        if(jobsAvailable.length > 0){
            uint index = rand(0,jobsAvailable.length);
            uint job = jobsAvailable[index];
            jobMonitorEvent(msg.sender,job);
            jobsAvailable[index] = jobsAvailable[jobsAvailable.length-1]; 
            delete jobsAvailable[jobsAvailable.length-1];
            jobsAvailable.length--;
            monitorJobs[job].monitorAddress = msg.sender;
        }
    }
    
    function saveMonitoringResults(uint jobIndex,uint result){
        if(monitorJobs[jobIndex].monitorAddress == msg.sender){
            monitorJobs[jobIndex].result = result;
            monitorJobs[jobIndex].done = true;
            Service service = Service(monitorJobs[jobIndex].serviceAddress);
            service.notifyMe(monitorJobs[jobIndex].userAddress, result);
        }
    }
}

