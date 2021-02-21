window.urb = new channel();

//This function gives us the Urbit List reformatted exactly as it exists in the localStorage item
var reformatUrbitObject = function(tasklist) {
    return tasklist.map(function(tasklist) {
      var reForm = {};
      reForm["title"] = tasklist.title;
      reForm["completed"] = tasklist.completed;
      reForm["id"] = parseInt(tasklist.id, 10);
      return reForm;
    });
};

//This function simply serves to provide a unique-value-only array from our concatenation of
// our Urbit List and the existing localStorage Item
function arrayUnique(arrayOfObjects) {
    console.log(arrayOfObjects);
    var newArray = arrayOfObjects.filter((object,index) => index === arrayOfObjects.findIndex(obj => JSON.stringify(obj) === JSON.stringify(object)));
    console.log(newArray);
    return newArray;
};

//This function handles incoming urbit data.  It makes an array out of both the localStorage Item and
// the incoming urbit data.  It then combines only the unique elements out of both lists and stores them
// as a string, back in the localStorage Item
var dataFromUrbit = function(data) {
    var urbitList = new Array();
    var todoList = new Array();
    urbitList = reformatUrbitObject(Object.values(data));
    console.log(urbitList);
    todoList = JSON.parse(localStorage.getItem("todos-vanillajs"));
    localStorage.setItem("todos-vanillajs", JSON.stringify(arrayUnique(todoList.concat(urbitList))));
    window.urb.poke(window.ship, 'todomvc', 'todomvc-action', {'update-tasks': JSON.parse(localStorage.getItem("todos-vanillajs"))}, () => console.log("Successful poke"), (err) => console.log(err));
};



const subscribeTodoMVC = () => {
    console.log(`window.ship: ${window.ship}`);
    // subscriptions
    window.urb.subscribe(window.ship, 'todomvc', '/mytasks', (err) => console.log("Sub Error"), (data) => dataFromUrbit(data), () => console.log("Sub Quit"));
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