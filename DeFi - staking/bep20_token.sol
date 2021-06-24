// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;
 
import "./ibep20.sol";

contract myToken is IBEP20 {
    using SafeMath for uint;

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _faucet;
    mapping (address => staked) public _userStaking;

    uint8 _decimals;
    uint256 _totalSupply;
    string _name;
    string _symbol;
    address _owner;

    struct staked {
        bool isStaked;
        uint timestamp;
        uint amount;
        uint reward;
        uint stakingPackID;
    }

    constructor() {
        _name = "Yolo Token";
        _symbol = "YTK";
        _decimals = 8;
        _totalSupply = 10000000000000000;
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "caller is not the owner");
        _;
    }

    struct stakingPack {
        uint rate;
        uint period;
    }

    uint8 public penalty;

    stakingPack[] public tabStakingPack;

    function setPenalty(uint8 penaltyRate) external onlyOwner returns (bool) {
        penalty = penaltyRate;
        return true;
    }

    function addStakingPack(uint packRate, uint packPeriod) external onlyOwner returns (bool) {
        tabStakingPack.push(stakingPack(packRate, packPeriod));
        return true;
    }

    function getRewards(uint amount, uint stakingPackID) public view returns (uint) {
        uint rate = tabStakingPack[stakingPackID].rate;
        uint period = tabStakingPack[stakingPackID].period;

        uint newPeriod = period.mul(10000);
        uint timeRatio = newPeriod.div(365 days);
        uint reward = timeRatio.mul(rate.mul(amount));
        reward = reward.div(1000000);
        return reward;
    }

    function stake(uint amount, uint stakingPackID) external returns (bool) {
        require(tabStakingPack.length > stakingPackID, "Invalid Pack Id");
        require(_userStaking[msg.sender].isStaked == false, "address already staking");
        require(_balances[msg.sender] >= amount, "no sufficient funds");
        uint reward = getRewards(amount, stakingPackID);

        // remove amount from totalsupply to cover the reward, if the totalSupply was locked
        _userStaking[msg.sender] = staked(true, block.timestamp, amount, reward, stakingPackID);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        return true;
    }

    function withdraw() external returns (bool) {
        require(_userStaking[msg.sender].isStaked, "not yet staked");
        
        uint period = tabStakingPack[_userStaking[msg.sender].stakingPackID].period;
        if (_userStaking[msg.sender].timestamp.add(period) >= block.timestamp) {
            mint(msg.sender, _userStaking[msg.sender].reward);
            _balances[msg.sender] = _balances[msg.sender].add(_userStaking[msg.sender].amount);
            emit Transfer(address(this), msg.sender, _userStaking[msg.sender].amount);
            delete _userStaking[msg.sender];
        } else {
          uint appliedPenalty = _userStaking[msg.sender].amount.mul(penalty).div(100);
          _balances[msg.sender] = _balances[msg.sender].add(_userStaking[msg.sender].amount);
          burn(appliedPenalty);
        }
        return true;
    }

    function sendFaucet() external {
        require(_faucet[msg.sender] == false, "already received faucet");
        mint(msg.sender, 100);
        _faucet[msg.sender] = true;
    }

    function mint(address recipient, uint256 amount) internal {
        require(recipient != address(0), "mint to the zero address");
        
        _totalSupply = _totalSupply.add(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(address(0), recipient, amount);
    }

    function burn(uint256 amount) public {
        _balances[msg.sender] = _balances[msg.sender].sub(amount, "no sufficient funds");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function transfer(address recipient, uint256 amount) override external returns (bool) {
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        _balances[msg.sender] = _balances[msg.sender].sub(amount, "no sufficient funds");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function totalSupply() override external view returns (uint256) {
        return _totalSupply;
    }
 
    function decimals() override external view returns (uint8) {
        return _decimals;
    }

    function symbol() override external view returns (string memory) {
        return _symbol;
    }

    function name() override external view returns (string memory) {
        return _name;
    }

    function getOwner() override external view returns (address) {
        return _owner;
    }

    function balanceOf(address account) override external view returns (uint256) {
        return _balances[account];
    }
}
