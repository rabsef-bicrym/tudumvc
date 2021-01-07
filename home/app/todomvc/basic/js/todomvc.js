window.urb = new channel();

const subscribeTodoMVC = () => {
    console.log(`window.ship: ${window.ship}`);
    // subscriptions
    window.urb.subscribe(window.ship, 'todomvc', '/mytasks', (err) => console.log("Sub Error"), (data) => console.log(JSON.stringify(data)), () => console.log("Sub Quit"));
};

const login =  async (pass) => {
    let loginRes = await fetch('/~/login', {
        method: 'POST',
        body: `password=${pass}`
    });
    console.log(loginRes.status);
    if (loginRes.status != 204) {
        return;
    }
    console.log("logged in");

    const res = await fetch('/~landscape/js/session.js');
    const sessionCode = await res.text();
    eval(sessionCode);


    subscribeTodoMVC();
};

const passwords = {'pen': 'bolrym-dibred-haltug-torryp'};
Object.keys(passwords).forEach(ship => login(passwords[ship]));