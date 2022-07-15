pragma solidity >=0.8.0 <0.9.0;
contract Crowdfunding {
    // 创作者
    address public author;
    // 参与金额
    mapping(address => uint) public joined;
    // 众筹目标
    uint constant Target = 10 ether;
    // 众筹截止时间
    uint public endTime;
    // 记录当前众筹价格
    uint public price = 0.02 ether;
    // 作者提取资金之后，关闭众筹
    bool public closed = false;
    // （构造函数）部署合约时，初始化作者及众筹结束时间
    constructor() public {
        author = msg.sender;
        endTime = block.timestamp + 30 days;
    }
    // 更新价格，这是一个内部函数
    function updatePrice() internal {
        uint rise = address(this).balance / 1 ether * 0.002 ether;
        price = 0.02 ether + rise;
    }
    // 用户向合约转账时，触发的回调函数
    receive() external payable {
        require(block.timestamp < endTime && !closed, "Crowdfunding is over!");
        require(joined[msg.sender] == 0, "You have participated in crowdfunding!");
        require(msg.value >= price, "You should offer a higher price!");
        joined[msg.sender] = msg.value;
        updatePrice();
    }
    // 作者提取资金
    function withdrawFund() external payable {
        require(msg.sender == author, "You are not the author!");
        require(address(this).balance >= Target, "Not achieve the goal!");
        closed = true;
        // 从合约向msg.sender转账全部资金
        payable(msg.sender).transfer(address(this).balance);
    }
    // 读者赎回资金
    function withdraw() external payable {
        require(block.timestamp > endTime, "Crowdingfunding is getting on!");
        require(!closed, "Goal achieved and Funds withdrawn.");
        require(Target > address(this).balance, "Goal achieved.Your fund cannot be withdrawn");
        payable(msg.sender).transfer(joined[msg.sender]);
    }
}