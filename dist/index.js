var model = getModel()
var app = Elm.Main.fullscreen(model);

/**
 * on elm's modelChange save the model to localStorage
 * @param  {object} model
 */

app.ports.modelChange.subscribe(function(model) {
  localStorage.setItem('slackm8Model', JSON.stringify(model));
});


app.ports.logExternalOut.subscribe(function (value) {
  console.info("logs:", value);
});

/**
 * getModel
 * Return a parsed model or null
 */

function getModel () {
  var model = localStorage.getItem('slackm8Model');
  return model ? JSON.parse(model) : null;
}
