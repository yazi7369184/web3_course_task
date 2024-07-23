// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract TodoList {
    struct Todo {
        string name;
        bool isCompleted;
    }
    Todo[] public list;

    function create(string memory name_) external {
        list.push(Todo({
            name: name_,
            isCompleted: false
        }));
    }

    function modiName1(uint256 index_, string memory name_) external {
        list[index_].name = name_;
    }

    function modiName2(uint256 index_, string memory name_) external {
        Todo storage temp = list[index_];
        temp.name = name_;
    }

    function modiStatus1(uint256 index_, bool status_) external {
        list[index_].isCompleted = status_;
    }

    function modiStatus2(uint256 index_, bool status) external {
        list[index_].isCompleted = !list[index_].isCompleted;
    }

    function get1(uint256 index_) external view
        returns (string memory name_, bool status_) {
        Todo memory temp = list[index_];
        return (temp.name, temp.isCompleted);        
    }

    // 获取任务2: storage : 1次拷贝
    // 预期：get2 的 gas 费用比较低（相对 get1）
    // 29388 gas
    function get2(uint256 index_) external view 
        returns (string memory name_, bool status) {
            Todo storage temp = list[index_];
            return (temp.name, temp.isCompleted);
        }

}