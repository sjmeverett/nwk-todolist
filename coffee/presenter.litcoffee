#TodoList presenter

The presenter deals with wiring the view up to the domain model.  I'm using Ractive.js for this,
because it's cool and is written by those swell folks at the Guardian.

First we'll grab a reference to the node webkit gui object and the path api - we need these to
figure out where our data file is.

    gui = require 'nw.gui'
    path = require 'path'
    dataDir = path.join gui.App.dataPath, 'todolist.db'

We need to instantiate our [domain model](todolist.litcoffee).
    
    td = require './coffee/todolist.js'
    todolist = new td.TodoList dataDir, 'test'

Let's create the Ractive object, passing the `list` property of the `TodoList` object as the
view model.

    app = new Ractive
        el: '#main'
        template: '#template'
        noIntro: true
        data: todolist.list

We also need to wire up the events.  The `remove` event is fired when the user clicks the cross
beside the todo item, and just delegates to the domain model.

    app.on
        remove: (event, i) ->
            todolist.removeItem i

The `create` event is fired when the user hits the enter key in the new item textbox.  It needs
to add the item to the domain model and clear the textbox read for the next input.

        create: (event) ->
            todolist.addItem event.node.value
            event.node.value = ''

The `edit` event is fired when the user clicks an item.  It sets the `editing` property to `true`
and the view takes care of making the item editable.

        edit: (event) ->
            @set event.keypath + '.editing', true

The `edited` event is fired when the user clicks away from or presses enter on an item they are
editing.  It needs to set the `editing` property to `false` so that the view hides the textbox.

        edited: (event) ->
            @set event.keypath + '.editing', false

Ractive allows us to observe changes in the view model, allowing us to register a handler that
updates the database when anything changes.


    todolist.load()
    app.observe 'items', (items) -> todolist.save()

