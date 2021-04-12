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

  // Here we're importing the Urbit API from useApi which was passed as a prop
  // to this component/container
  const urb = props.api

  // And here we're subscribing to our Urbit app and setting our listening
  // path to '/mytasks'
  useEffect(() => { const sub = urb.subscribe({ app: 'tudumvc', path: '/mytasks', event: data => {
    setLocalTodos(data);
  }}, [todos, setLocalTodos])
  }, []);

  // We've added "deleteTodo" and "addTodo"
  const poker = () => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': 'from Earth to Mars'}});
  };

  const deleteTodo = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'remove-task': num}})
  };

  const addTodo = (task) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'add-task': task}})
  };

  const setDone = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'mark-complete': num}})
  };

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
        addTodo(newValue);
        setNewValue("");
      }
    },
    [newValue]
  );

  const {api} = props;
  return (
    <React.Fragment>
      <header className="header">
        <h1>todos</h1>
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
            <Route key={`todoItem-${todo.id}`} render={(props) => {
              console.log(`todoItem-${todo.id}`);
              return <TodoItem todo={todo} api={api} {...props}/>
            }} />
          ))}
        </ul>
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
          <li>
            <button className="clear-completed" onClick={poker}>
              Test Button
            </button>
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
