pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";

contract Umbra is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    event EthAnnouncement(address indexed receiver, uint256 indexed amount, string note);
    event TokenAnnouncement(address indexed receiver, uint256 indexed amount, address indexed token, string note);

    uint256 public toll;

    constructor(uint256 _toll) public {
        initialize(msg.sender);
        toll = _toll;
    }

    function setToll(uint256 _newToll) public onlyOwner {
        toll = _newToll;
    }

    function sendEth(address payable _receiver, string memory _announcement) public payable nonReentrant {
        require(msg.value > toll, "Umbra: Must pay more than the toll");

        uint256 amount = msg.value.sub(toll);
        emit EthAnnouncement(_receiver, amount, _announcement);

        _receiver.transfer(amount);
    }

    function sendToken(address _receiver, string memory _announcement, address _tokenAddr, uint256 _amount) public payable nonReentrant {
        require(msg.value == toll, "Umbra: Must pay the exact toll");

        emit TokenAnnouncement(_receiver, _amount, _tokenAddr, _announcement);

        SafeERC20.safeTransferFrom(IERC20(_tokenAddr), msg.sender, _receiver, _amount);
    }
}
