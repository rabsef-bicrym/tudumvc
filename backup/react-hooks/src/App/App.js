import React from "react";
import { HashRouter, Route } from "react-router-dom";
import "todomvc-app-css/index.css";

import Footer from "../components/Footer";
import TodoList from "../containers/TodoList";

export default function App(props) {
  const { api } = props;
  return (
    <HashRouter>
      <React.Fragment>
        <div className="todoapp">
          <Route key="my-route" path="/:filter?" render={(props) => {
            return <TodoList api={api} {...props} />
          }} />
        </div>
        <Footer />
      </React.Fragment>
    </HashRouter>
  );
}
