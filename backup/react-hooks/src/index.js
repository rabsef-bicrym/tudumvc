import "core-js/es6/map";
import "core-js/es6/set";
import "raf/polyfill";

import React from "react";
import ReactDOM from "react-dom";

import "./index.css";
import App from "./App/App";
import * as serviceWorker from "./serviceWorker";
import useApi from "./hooks/useApi";

const root = document.getElementById("root");

// We need to make the React.DOM asynchronously await the completion
// of the promise of useApi (defined in useApi.js)
//
(async () => {
    const api = await useApi();
    ReactDOM.render(<App api={api} />, root);
})();

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.register();
