pragma solidity ^0.4.0;

contract Monitor {
    
    struct monitorJob {
        address serviceAddress;  
        string serviceUrl;
        bool done;
        uint result;
        address monitorAddress;
    }
    
    uint public jobsCount;
    
    mapping(uint => monitorJob) public monitorJobs;
    uint [] public jobsAvailable;
    
    event newMonitorRecord();
    
    function submitMonitoringRequest (address serviceAddress, string url){
        jobsCount += 1;
        monitorJobs[jobsCount] = monitorJob({
            serviceAddress :serviceAddress,
            serviceUrl : url, 
            done : false,
            result : 0,
            monitorAddress : address(0)
            
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
        if(jobsAvailable.length != 0){
            uint index = rand(0,jobsAvailable.length-1);
            uint job = jobsAvailable[index];
            jobMonitorEvent(msg.sender,job);
            jobsAvailable[index] = jobsAvailable[jobsAvailable.length-1]; 
            delete jobsAvailable[jobsAvailable.length-1];
            monitorJobs[job].monitorAddress = msg.sender;
        }
    }
    
    function saveMonitoringResults(uint jobIndex,uint result){
        if(monitorJobs[jobIndex].monitorAddress == msg.sender){
            monitorJobs[jobIndex].result = result;
            monitorJobs[jobIndex].done = true;
        }
    }
}
