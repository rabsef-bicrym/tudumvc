import React, { useCallback, useRef, useState } from "react";
import useOnClickOutside from "use-onclickoutside";

import useDoubleClick from "../hooks/useDoubleClick";
import useOnEnter from "../hooks/useOnEnter";
import useTodos from "../reducers/useTodos";

export default function TodoItem(props) {
  const [label, setLabel] = useState(props.todo.label);

  const [id, setID] = useState(props.todo.id);
  
  const [editing, setEditing] = useState(false);

  const urb = props.api;

  const deleteTodo = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'remove-task': parseInt(num)}})
  };

  const toggleDone = (num) => {
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'mark-complete': parseInt(num)}})
  };

  const onBlur = () => {
    console.log(`setting urbit state to ${label} for task ${id}`);
    urb.poke({app: 'tudumvc', mark: 'tudumvc-action', json: {'edit-task': {'id': parseInt(id), 'label': label}}})
  };

  const onDelete = useCallback(() => deleteTodo(id), [id]);
  const onDone = useCallback(() => toggleDone(id), [id]);
  const onChange = event => {
    setLabel(event.target.value);
  };

  const handleViewClick = useDoubleClick(null, () => setEditing(true));
  const finishedCallback = useCallback(
    () => {
      onBlur();
      setEditing(false);
    },
    [label]
  );

  const onEnter = useOnEnter(finishedCallback, [label]);
  const ref = useRef();
  useOnClickOutside(ref, finishedCallback);

  return (
    <li
      onClick={handleViewClick}
      className={`${editing ? "editing" : ""} ${props.todo.done ? "completed" : ""}`}
    >
      <div className="view">
        <input
          type="checkbox"
          className="toggle"
          checked={props.todo.done}
          onChange={onDone}
          autoFocus={true}
        />
        <label>{label}</label>
        <button className="destroy" onClick={onDelete} />
      </div>
      {editing && (
        <input
          ref={ref}
          className="edit"
          value={label}
          id={id}
          // On change needs to happen component local
          // on blur needs to send to urbit
          onChange={onChange}
          onKeyPress={onEnter}
        />
      )}
    </li>
  );
}
