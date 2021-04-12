import React, { useCallback, useMemo, useState, useEffect } from "react";
import { NavLink, Route } from "react-router-dom";
import useRouter from "use-react-router";

import useInput from "../hooks/useInput";
import useOnEnter from "../hooks/useOnEnter";
import useTodos from "../reducers/useTodos";
import TodoItem from "./TodoItem";

export default function TodoList(props) {
  const router = useRouter();

  const [todos, setLocalTodos] = useState([]);
  const [fullTodos, setFullTodos] = useState([]);
  const [subList, setSubList] = useState([]);
  const [selected, setSelected] = useState([0])

  // Here we're importing the Urbit API from useApi which was passed as a prop
  // to this component/container
  const urb = props.api

  // And here we're subscribing to our Urbit app and setting our listening
  // path to '/mytasks'
  useEffect(() => { const sub = urb.subscribe({ app: 'tudumvc', path: '/mytasks', event: data => {
    var tempSubs = [];
    setFullTodos(data);

    Object.keys(data).map((key) => {
      tempSubs.push([key, Object.keys(data[parseInt(key)])[0]]);
      return true;
    });
    setSubList(tempSubs);
    setLocalTodos(data[document.getElementById("partner").selectedIndex][tempSubs[document.getElementById("partner").selectedIndex][1]])
  }}, [fullTodos, subList, todos])
  }, []);

  // We've added "deleteTodo" and "addTodo"
  const deleteTodo = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-frontend', json: {'remove-task': {'ship': subList[selected][1], 'id': parseInt(num)}}})
  };

  const addTodo = (label) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-frontend', json: {'add-task': {'ship': subList[selected][1], 'label': label}}})
  };

  const setDone = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'mark-complete': {'ship': subList[selected][1], 'id': parseInt(num)}}})
  };

  const addSub = (sub) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'sub': sub}})
  }

  const left = useMemo(() => todos.reduce((p, c) => p + (c.done ? 0 : 1), 0), [
    todos
  ]);

  const visibleTodos = useMemo(
    () =>
      router.match.params.filter
        ? todos.filter(i =>
            router.match.params.filter === "active" ? !i.done : i.done
          )
        : todos,
    [todos, router.match.params.filter]
  );

  const anyDone = useMemo(() => todos.some(i => i.done), [todos]);
  const allSelected = useMemo(() => visibleTodos.every(i => i.done), [
    visibleTodos
  ]);

  const onToggleAll = useCallback(
    () => {
      visibleTodos.forEach(i => setDone(i.id, !allSelected));
    },
    [visibleTodos, allSelected]
  );

  const onClearCompleted = useCallback(
    () => {
      todos.forEach(i => {
        if (i.done) {
          deleteTodo(i.id);
        }
      });
    },
    [todos]
  );

  const [newValue, onNewValueChange, setNewValue] = useInput();
  const onAddTodo = useOnEnter(
    () => {
      if (newValue) {
        console.log(newValue)
        addTodo(newValue);
        setNewValue("");
      }
    },
    [newValue]
  );

  const [newSub, onNewSubChange, setNewSub] = useInput();
  const onAddSub = useOnEnter(
    () => {
      if (newSub) {
        addSub(newSub);
        setNewSub("");
      }
    },
    [newSub]
  );

  function subSelect (event) {
    console.log(event.target.value)
    setSelected(event.target.value)
    var selection = subList[event.target.value]
    setLocalTodos(fullTodos[selection[0]][selection[1]])
  }

  const {api} = props;
  return (
    <React.Fragment>
      <header className="header">
        <h1>{
            (typeof subList[selected] == 'undefined') ? 'Loading...'
            : `${subList[selected][1]}'s todos`
          }</h1>

        <input
          className="new-todo"
          placeholder="What needs to be done?"
          onKeyPress={onAddTodo}
          value={newValue}
          onChange={onNewValueChange}
        />
      </header>

      <section className="main">
        <input
          id="toggle-all"
          type="checkbox"
          className="toggle-all"
          checked={allSelected}
          onChange={onToggleAll}
        />
        <label htmlFor="toggle-all" />
        <ul className="todo-list">
        {visibleTodos && visibleTodos.map(todo => (
            // Each item is an instance of Route and wants
            // a key
            <Route key={`todoItem-${selected}-${todo.id}`} render={(props) => {
              return <TodoItem todo={todo} api={api} ship={subList[selected][1]} {...props}/>
            }} />
          ))}
        </ul>
      </section>
      <section>
        <span style={{paddingRight: "30px"}}>
          <span style={{paddingRight: "10px"}}>Select Todo List:</span>
          <select id="partner" onChange={subSelect}>
            {subList.map(item => {
              return(<option key={parseInt(item[0])} value={item[0]}>{item[1]}</option>)
            })}
          </select>
          </span>
        <span>
          <span style={{paddingRight: "10px"}}>
            Subscribe to new partner:
          </span>
          <input 
            id="new-subscriber"
            type="text"
            className="new-Todo"
            onKeyPress={onAddSub}
            value={newSub}
            onChange={onNewSubChange}
            >

          </input>
        </span>
      </section>

      <footer className="footer">
        <span className="todo-count">
          <strong>{left}</strong> items left
        </span>
        <ul className="filters">
          <li>
            <NavLink exact={true} to="/" activeClassName="selected">
              All
            </NavLink>
          </li>
          <li>
            <NavLink to="/active" activeClassName="selected">
              Active
            </NavLink>
          </li>
          <li>
            <NavLink to="/completed" activeClassName="selected">
              Completed
            </NavLink>
          </li>
        </ul>
        {anyDone && (
          <button className="clear-completed" onClick={onClearCompleted}>
            Clear completed
          </button>
        )}
      </footer>

    </React.Fragment>
  );
}

