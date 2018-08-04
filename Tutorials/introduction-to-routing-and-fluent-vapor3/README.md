![Header Image](https://raw.githubusercontent.com/calebkleveter/Tutorials/master/introduction-to-routing-and-fluent-vapor3/header.png)

# Diving into Vapor, Part 3: Introduction to Routing and Fluent in Vapor 3

In that [last tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-2-persisting-data-in-vapor-3-c927638301e8), we learned how to connect a database to our app and save models to it. In this tutorial, we will learn how to query that database to get, update, or delete that data.

**Note:** I know I promised we would discuss querying and routing in this tutorial. I tried but it just was getting too long for that 😞. We will dive a little deeper next time where we will look at more complex querying pivot tables.

---

Before we start adding routes though, we are going to make a change to the `User` model. As it currently is built, the unique property of the model is the `id` property, which is a UUID. Wouldn't it make sense to have the `username` property be unique? It's actually pretty simple to do that.

The `PostgreSQLUUIDModel` sets the `Database` and `ID` types and `idKey` property of the model that conforms to it. To make the `ID` type a string, we need to conform to `Model` and implement the requirements manually:

https://gist.github.com/calebkleveter/4bb5ed95ec995d0f091d0bdb8dc5fad1

Then remove the `id` property from the `User` model and make the `username` property optional:

https://gist.github.com/calebkleveter/35bc4275ef699ef3d8a5a3f6fd2bba97

We need to update the database structure for this change.  Add the following snippet to the global `configure` method:

https://gist.github.com/calebkleveter/ab75958a9acc187eb42a1a3805838cc5

Then go to the project in the terminal and run `vapor build && vapor run revert --all`.

---

# [Routing 101](https://docs.vapor.codes/3.0/getting-started/routing/)

Routing is based around the idea of a [controller](https://docs.vapor.codes/3.0/getting-started/controllers/). A controller is simply a set of methods that take in a request and return a response, wrapped in a class.

We will create a simple API for our `User` model. Create a `UserController.swift` file in the `Controllers` directory using `touch Sources/App/Controllers/UserController.swift` and regenerate your Xcode project. Import both the Vapor and Fluent modules.

As said before, a controller is a class. Create a new `UserController` class marked `final` and conforming to `RouteCollection`. To conform to `RouteCollection`, you need a method with the signature `boot(router: Router)throws`. Leave the body of the method empty for now.

https://gist.github.com/calebkleveter/ac7c5a460fa5976b617efae7016b61e1

A RESTful API typically allows you to run [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on a model. We will follow the same model. We will start with the read operation because it is easier to understand the mechanics.

Add the following method to your `UserController` class:

https://gist.github.com/calebkleveter/d7ffd5b802b9fa1d2f96bec34ee4687c

This method takes in a `Request` object and returns an array of `User` models wrapped in a `Future`.

A `Request` is actually closer to a request container than an actual request. It has additional functions such as an event loop and the ability to create a connection to the database. The actual request data is in `request.http`.

The reason we return a `Future` instead of a straight `User` model array is because Vapor 3 is asynchronous. Fetching data from the database takes time, and we don't want to hog up threads, so instead we while we wait for the operation to complete, we allow other requests to run.

---

# [The Basics of Querying](https://docs.vapor.codes/3.0/fluent/querying/)

In the body of the index method, we run query on the `User` model. We create the query with the `User.query(on: request)` method. When we use `.all()`, we run the query and fetch all the results of the query as an array. Because we don't need to run any operations on those users, we just return them from the method.

Create another route handler with the name `show` that returns a single `User` model in a `Future`. This route will be used to get a user with a given username. The path for this route will look like `/users/:username`. For this to work, we need to conform `User` to `Parameter`. The implementation is already done for us, so we don't have to worry about that.

The body for the `show` handler is also very simple. All we have to do is get the `User` model from the request's parameters as return it:

https://gist.github.com/calebkleveter/b54ff245aaca7372f2e6ad791d17aa73

To create a new `User` and save it to the database, we need to decode the `User` from the request's body and call `.save(on:)` on it. Vapor has built in router methods that decode the body for you, so all we need to do is accept a `User` model as a second parameter in our route handler:

https://gist.github.com/calebkleveter/6608eef0b0634aefc48c702eaea3917e

To update a user, we will take in a decoded request body and update the user's properties with the values. We will get the user from the route parameters. We then save the user and return it.

The type used to update will look like the following. Place it in `UserController.swift` (or a new file if you prefer):

https://gist.github.com/calebkleveter/324a596616d1b8134f96c090043ffb5e

The `update` method will look like this:

https://gist.github.com/calebkleveter/b7d43f414921548067f8e31c2c101fbc

Finally we will add a `delete` route handler where we get a user from the route parameters and call `.delete(on:)`. According to [RFC 7231](https://devdocs.io/http/rfc7231#section-6.3.5), a 204 (No Content) status code should be returned when a there is no additional content to send in the response body, so we will chain a `.transform(to:)` call to the `delete`:

https://gist.github.com/calebkleveter/fb2c10243d47183617f1d5398588b8e6

# [Registering Routes](https://docs.vapor.codes/3.0/routing/getting-started/#registering-a-route-using-vapor)

To register a route handler with a given path, we use the methods on the router that map to HTTP methods (`.get`, `.post`, `.delete`, etc.). These methods take in the path, then the handler. HTTP methods that support a body can also take in a type conforming to `Content` that the request body will be decoded to before the handler is run.

All the handlers in the `UserController` will have a root path of `/users`. We could ad this to the front of every path, but it makes more sense to create a route group. You could think of this as another router that automatically adds a root path and/or middleware to the handlers registered to it. Create the group in the `UserController.boot(router:)` method:

https://gist.github.com/calebkleveter/6a7b01aedb94fc665ea4993431dc79fe

We then register each handler according to the HTTP method it needs:

https://gist.github.com/calebkleveter/1637ba2cc214551732b57e783f67ac53

The routes that start with `User.self` and `UserContent.self` will decode the body of the request to that type and pass it in to the handler.

If you want to better understand the path names for each handler, [this resource](http://www.restapitutorial.com/lessons/restfulresourcenaming.html) will be helpful.

Your `UserController.swift` file should now look like this:

https://gist.github.com/calebkleveter/d007af07f5ba1a92ad98dba482fb2430

Finally, to register the routes with application's route, go to the global `routes(_:)` function, delete the current implementation, and call `router.register(controller:)`:

https://gist.github.com/calebkleveter/f6a60627ac13a1d5c9ed4280fadcae12

---

Great Job! You have implemented the basic CRUD operations for the `User` model! The source-code for this project can be found [here](https://github.com/calebkleveter/chatter/tree/basic-routing-and-fluent). If you have any questions, comments, or just want to chat, head over to our [Discord server](https://discord.gg/7PWxvX9). See you there!