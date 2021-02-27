import React from "react";
import { HashRouter, Route } from "react-router-dom";
import "todomvc-app-css/index.css";

import Footer from "../components/Footer";
import TodoList from "../containers/TodoList";

// We've added props to what App.js receives
//
export default function App(props) {
  // And we're creating a const object of api from that prop
  // Further - in the return, below, we're passing the unpacked version
  // of props, and the api to TodoList.js
  //
  const {api} = props;
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
