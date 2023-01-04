// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract TodoList {
    // Todo object defined as "struct"
    struct Todo {
        string mission;
        bool completed;
    }

    // array of todo objects defined
    Todo[] public todos;

    // a new todo task can be created.
    function createMission(string calldata _mission) external {
        Todo memory todo;
        todo = Todo({mission: _mission, completed: false});

        todos.push(todo);
    }

    // task name of given index can be updated.
    function updateMission(uint256 _index, string calldata _mission) external {
        todos[_index].mission = _mission;
    }

    // task of the given index can be viewed.
    function viewMission(uint256 _index)
        external
        view
        returns (string memory, bool)
    {
        Todo memory todo = todos[_index];
        return (todo.mission, todo.completed);
    }

    // the "completed" status of the task for the given index can be updated.
    function toggleCompleted(uint256 _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
}
