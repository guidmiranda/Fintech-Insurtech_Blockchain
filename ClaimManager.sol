//SPDX-License-Identifier: MIT


pragma solidity >=0.5.0 <0.9.0;

struct S_Claim{
    address ClientAdress;
    uint256 ClaimAmount;
    string StateClaim;
}

contract ClaimManager{
      

    address Admin;
    
    uint256 totalSupply;
    
    //Creating S_Claim
    enum State {Submitted, Approved, Paid}
    State public StateClaim;

    constructor() payable{
        totalSupply = 0;     
        Admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        claim.ClientAdress = msg.sender;
        claim.ClaimAmount = totalSupply;
        StateClaim = State.Submitted;
    }
    
    S_Claim public claim;

    mapping (address => uint256) public C_amount;
    mapping (address => uint256) public kycMapping;

    function changeClaim(address _addr, uint _amount, string memory _State_Claim) public{
        if (StateClaim == State.Submitted){
            S_Claim memory myclaim = S_Claim({
                ClientAdress: _addr,
                ClaimAmount: _amount,
                StateClaim: _State_Claim              
                });
            claim = myclaim;
        }
    }

    function submitClaim(uint amount) public returns(bool){
        require(msg.sender != Admin,"Transfer failed, you are the Admin!!" );
        uint256 Totalamount = C_amount[msg.sender] + amount;
        C_amount[msg.sender] = Totalamount;
        kycMapping[msg.sender] = 1;
        return true;
    }

    function kyc(address _addr) public view returns(bool){
        require(msg.sender == Admin,"Only Admin can submit to kyc!!");
        require(StateClaim == State.Submitted,"kyc Statement failure, ClaimAmount not Submitted yet");
        if (kycMapping[_addr] == 1 ){
            return true;
        }
        else{
            return false;
        }
    }

    function askApproval() public {
        require(msg.sender != Admin,"Asking Approval, you must not be the Admin!!" );
        require(StateClaim == State.Submitted,"Asking Approval, ClaimAmount not Approved yet" );
        
        StateClaim = State.Approved;
    }

    function triggerPayment(address _addr) external payable returns(bool){

        require(msg.sender == Admin,"Transfer failed, you are not the owner!!" );
        require(StateClaim == State.Approved,"Transfer failed, ClaimAmount not Approved yet" );

        address payable recipient;
        
        recipient = payable (_addr);

        if(address(Admin).balance > claim.ClaimAmount){
            recipient.transfer(claim.ClaimAmount);
            StateClaim = State.Paid;
            C_amount[_addr] = 0;
            return true;
        }
        else{
            return false;
        }    
            


    }
}
