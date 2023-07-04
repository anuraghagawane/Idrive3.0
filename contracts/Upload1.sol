// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
contract Upload1 {
    struct Access{
        address user;
        bool access;
    }
    struct shared_add{
        string value;
        bool access;
    }
    mapping(address=>string[]) value;
    mapping(address=>mapping(address=>shared_add[])) shared_address;
    mapping(address=>mapping(address=>bool)) ownership;
    mapping(address => mapping(string => Access[])) accessList;

    function add(address _user, string memory url) external {
        value[_user].push(url);
    }

    function allow(address toShare, string memory url) external {
        ownership[msg.sender][toShare] = true;
        bool urlExists = false;

        for (uint i = 0; i < shared_address[msg.sender][toShare].length; i++) {
            if (keccak256(abi.encodePacked(shared_address[msg.sender][toShare][i].value)) == keccak256(abi.encodePacked(url))) {
                shared_address[msg.sender][toShare][i].access = true;
                urlExists = true;
                break;
            }
        }

        if (!urlExists) {
            shared_address[msg.sender][toShare].push(shared_add(url, true));
            accessList[msg.sender][url].push(Access(toShare, true));
        }
        
    }

    function disallow(address toRevoke, string memory url) external {
        require(msg.sender != toRevoke, "You cannot revoke access from yourself");

        for (uint256 i = 0; i < accessList[msg.sender][url].length; i++) {
            if (accessList[msg.sender][url][i].user == toRevoke) {
                accessList[msg.sender][url][i].access = false;
                break;
            }
        }
        for (uint i = 0; i < shared_address[msg.sender][toRevoke].length; i++) {
            if (keccak256(abi.encodePacked(shared_address[msg.sender][toRevoke][i].value)) == keccak256(abi.encodePacked(url))) {
                shared_address[msg.sender][toRevoke][i].access = false;
                break;
            }
        }
    }


    function display(address owner) external view returns (string[] memory) {
        require(owner == msg.sender || ownership[owner][msg.sender], "You don't have access to view shared files");

        if(owner == msg.sender){
            return value[owner];
        }

        uint256 sharedFilesTotalCount = shared_address[owner][msg.sender].length;
        uint256 sharedFilesCount = 0;

        for (uint256 i = 0; i < sharedFilesTotalCount; i++) {
            if(shared_address[owner][msg.sender][i].access == true){
                sharedFilesCount++;  
            }
        }
        string[] memory sharedFiles = new string[](sharedFilesCount);
        uint j = 0;
        for (uint256 i = 0; i < sharedFilesTotalCount; i++) {
            if(shared_address[owner][msg.sender][i].access == true){
                sharedFiles[j] =  shared_address[owner][msg.sender][i].value;
                j++;
            }
        }

        return sharedFiles;
    }
    function shareAccess(string memory url) public view returns(Access[] memory){
        uint256 accessListTotalCount = accessList[msg.sender][url].length;
        uint256 accessListCount = 0;

        for (uint256 i = 0; i < accessListTotalCount; i++) {
            if(accessList[msg.sender][url][i].access == true){
                accessListCount++;
            }
        }

        Access[] memory userWithAccess = new Access[](accessListCount);
        uint256 j = 0;
        for (uint256 i = 0; i < accessListTotalCount; i++) {
            if(accessList[msg.sender][url][i].access == true){
                userWithAccess[j] = accessList[msg.sender][url][i];
                j++;
            }
        }


        return userWithAccess;
    }
}