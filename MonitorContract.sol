pragma solidity ^0.4.0;

contract Monitor {
    
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
    
    event newMonitorRecord();
    
    function submitMonitoringRequest (address serviceAddress, bytes32 url){
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

    event jobMonitorEvent(address sender,uint jobIndex);
    function getMonitoringRequest(){
        if(jobsAvailable.length != 0){
            uint job = jobsAvailable[0];
            jobMonitorEvent(msg.sender,job);
            delete jobsAvailable[0];
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
