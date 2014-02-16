# TodoList domain model

The domain model contains all of the business logic, i.e. the code that acts on and retrieves the data,
ensuring it is left in a legal and consistent state and that the business rules are followed.

I'm using [nedb](https://github.com/louischatriot/nedb), a pure javascript MongoDB clone, for persistence.
    
    Datastore = require 'nedb'

    class exports.TodoList
        
A todo list is stored in the database as one document.  In order to retrieve it, we need the path to the
data file and the name of the list.

        constructor: (datapath, name) ->
            @db = new Datastore {filename: datapath, autoload: true}
            @list = {name: name, items: []}


The load function loads the todo list data from the database, if it exists.  So that we know when it has
completed, it accepts a callback function.

        load: (callback) ->
            @busy = true
            @db.findOne {name: @list.name}, (err, doc) =>
                if not err? and doc?

It is intended that consumers bind to the list property of the class, so we need to be careful when
updating it: if we were just to do `@list = doc` it would break the model binding.

                    @list._id = doc._id
                    @list.items.push item for item in doc.items

                @busy = false
                callback? err
                return
                

We can add new items to the list.  Items consist of a description and an indication of whether or not
they are completed, which starts off false.
    
        addItem: (description) ->
            @list.items.push {description: description, completed: false}

We can also remove items by their index in the list.
        
        removeItem: (index) ->
            @list.items.splice index, 1

If the list gets tasks added or removed, or tasks get changed externally, we need to be able to save
the list back to the database.

        save: ->
            @busy = true
            @db.update {name: @list.name}, @list, {upsert: true}, (err) =>
                throw err if err
                @busy = false
            