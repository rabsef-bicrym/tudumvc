window.urb = new channel();

//This function gives us the Urbit List reformatted exactly as it exists in the localStorage item
var reformatUrbitObject = function(tasklist) {
    return tasklist.map(function(tasklist) {
      var reForm = {};
      reForm["title"] = tasklist.title;
      reForm["completed"] = tasklist.completed;
      reForm["id"] = parseInt(tasklist.id, 10);
      //return reForm;
    });
};

//This function simply serves to provide a unique-value-only array from our concatenation of
// our Urbit List and the existing localStorage Item
function arrayUnique(array) {
    var a = array.concat();
    for(var i=0; i<a.length; ++i) {
        for(var j=i+1; j<a.length; ++j) {
            if(a[i] === a[j])
                a.splice(j--, 1);
        }
    }

    return a;
};

//This function handles incoming urbit data.  It makes an array out of both the localStorage Item and
// the incoming urbit data.  It then combines only the unique elements out of both lists and stores them
// as a string, back in the localStorage Item
var dataFromUrbit = function(data) {
    var urbitList = new Array();
    var todoList = new Array();

    urbitList = reformatUrbitObject(Object.values(data));
    todoList = JSON.parse(localStorage.getItem("todos-vanillajs"));
    localStorage.setItem("todos-vanillajs", JSON.stringify(arrayUnique(todoList.concat(urbitList))));
    window.location.reload(false);
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