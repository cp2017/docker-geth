pragma solidity ^0.4.0;

contract monitorContract {
    
    struct monitorJob {
        address serviceAddress;  // could change this into other address
        bytes32 serviceUrl;
        bool done;
        uint result;
        address monitorAddress;
    }
    
    uint public jobsCount;
    
    mapping(uint => monitorJob) public monitorJobs;
    uint []jobsAvailable;
    
    event newMonitorRecord(address buyerAddress, bytes32 url);
    
    function monitor (address serviceAddress, bytes32 url){
        jobsCount += 1;
        monitorJobs[jobsCount] = monitorJob({
            serviceAddress :serviceAddress,
            serviceUrl : url, 
            done : false,
            result : 0,
            monitorAddress : address(0)
            
        });
        jobsAvailable.push(jobsCount);
        newMonitorRecord(serviceAddress, url);
        
    }
    uint nonce = 0;
    function rand(uint min, uint max) public returns (uint){
        nonce++;
        return uint(sha3(nonce))%(min+max)-min;
}
    
    

    event jobMonitorEvent(uint jobIndex);
    function getMonitorRequest(){
        
        if(jobsAvailable.length != 0){
            uint index = rand(0,jobsAvailable.length);
            uint job = jobsAvailable[index];
            jobMonitorEvent(job);
            delete jobsAvailable[index];
            monitorJobs[job].monitorAddress = msg.sender;
        }
    }
    
    function saveMonitorResults(uint jobIndex,uint result){
        if(monitorJobs[jobIndex].monitorAddress == msg.sender){
            monitorJobs[jobIndex].result = result;
            monitorJobs[jobIndex].done = true;
        }
    }
}