![Vapor Logo: Header](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/VaporHeader.png?raw=true)

# Diving into Vapor, Part 1: Up and Running with Vapor 3

In this tutorial we will cover setting up an environment for building web apps with Swift, creating a Vapor project, look at the structure of a project, and create a simple route. I will be using Xcode and Homebrew, so if you are on Linux, I would suggest taking a look at the [respective docs](https://docs.vapor.codes/3.0/install/ubuntu/) and you can ignore anything that is Xcode specific.

Swift 4.1 is the first requirement for using Vapor 3, so install that if you don’t have it already. You can do this by either downloading that latest [Xcode 9.3 beta](https://developer.apple.com/download/) or installing the latest [4.1 snapshot](https://swift.org/download/#snapshots) and access it through the Xcode ‘Toolchains’ menu.

The next step is installing the Vapor Toolbox. The preferred way of doing this is through [Homebrew](https://brew.sh/). You can do this by adding the Vapor tap and then installing it:

https://gist.github.com/calebkleveter/cf7a268e7846fa786edcce1c33a1dc59#file-toolboxinstall-sh

You could also try building it from source if you don’t use Homebrew (I haven’t done that before).

Now that you have the environment set up, it’s time to create your project!

In your terminal, `cd` to the directory you want the project in, then run `vapor new <PROJECT_NAME> --branch=beta`. This will create a new Vapor 3 project in a directory with the name you passed into the `vapor new` command, along with a git repository. The `--branch=beta` flag tells Toolbox to use the template for Vapor 3 instead of Vapor 2. This will be changed when Vapor 3 is officially released, and you won’t have to pass in that flag anymore. I will be naming my project `chatter` and will continue to build on it as we learn more about Vapor 3.

![Console output when generating a new project](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/ConsoleOutput.png?raw=true)

Next, you’re going to `cd` into the new project and run `vapor xcode -y`. This will generate an Xcode project for you, and then open it (because you passed in the `-y` flag).

With your Xcode project open, change the target you are on from `<PROJECT_NAME>-Package` to `Run`.


![Select the Run target to run your app](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/Schemes.png?raw=true)

You can now run your Vapor app by clicking the run button in the Xcode navigation bar or using the keyboard shortcut, `cmd+R`. You can also run `vapor build` and `vapor run` in the command-line. You will get an output that looks something like this in the Xcode console or terminal (depending on where you ran the app):

![Output to Xcode console when the app has finished booting](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/RunOutput.png?raw=true)

With the application running, navigate to `localhost:8080/hello` in your browser. We have a running application!

![Response from localhost:8080/hello route](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/HelloWorld.png?raw=true)

---

Before we get into creating an application, we have some house work to do. The Vapor template has some examples of how to create a REST API with a model and controller, but we won’t need those, so we will delete them. Delete the following files:

- `Sources/App/Models/Todo.swift`
- `Sources/App/Controllers/TodoController.swift`

Along with deleting those files, we will also clean up a few others. Your `Sources/configure.swift` should look like this:

https://gist.github.com/calebkleveter/df66d995d8b3d3d98dfbb88c2d1921b7#file-configure-swift

And your Sources/routes.swift should look like this:

https://gist.github.com/calebkleveter/463fb3ce2026bbde6cc8b4a9bfc39761#file-routes-swift

I am going to move the `configure.swift`, `routes.swift`, and `boot.swift` into a `Configuration` folder to help keep the project organized, but that is not necessary. After reorganizing the files, you will need to regenerate your Xcode project (`vapor xcode -y`).


![The contents of the Sources/App/ directory](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/ProjectStructure.png?raw=true)

---

At this point, it is worth covering how the `configure` function works. We’ll step through its body block by block. But first, what are services?

Services are modular types (classes or structs) that are used to run various actions (database interaction, client requests, etc.) from a worker. Because Vapor 3 is async and multi-threaded, you can’t store this kind of functionality globally because you would have thread collisions (trying to read or write a variable at the same time for example). This could be solved with locks, but this results in a slow product because a certain functionality can only be accessed by one thread at a time.

To solve this problem, you registering these functionalities with the app’s services. These services are then added to each worker, allowing them to safely access the functionality without the risk of colliding with another worker.

Now that you understand services, let’s take a look at configuration.

https://gist.github.com/calebkleveter/00f415cca9b7cdfc4291b9a0ffe04a1a#file-routerconfig-swift

This registers a pre-implemented router with the worker’s services, allowing it to take in requests and send responses to the client. The `routes` function that we are calling registers our application’s routes with the router, so the requests from the client can be sent into them.

https://gist.github.com/calebkleveter/ac12d0e3391121ebb8d795f778c52d23#file-middlewareconfig-swift

Here, we are registering middleware with the services. Middleware is a logic chain between the client and the server’s routes, allowing you to mutate or get information from a request or response. We register the middleware so Vapor will pass the requests and response through them. The `DateMiddleware` adds a `Date` header to a response with the current timestamp. `ErrorMiddleware` catches all the errors that are thrown in the app, and uses them to set the responses body and status code, and then outputs the error if you are in a development environment.

https://gist.github.com/calebkleveter/2b38344a4359999253e81c726564fc64#file-persistenceconfig-swift

In this final snippet, we register the `DatabaseConfig`, which is used to setup the database that we are using with the app. We also register MigrationConfig, which is used to create database tables for our app’s models. We will cover both of these in a later tutorial.

---

We haven’t written any code for our application yet, so let’s create a simple route before closing out this tutorial. Go to your `routes.swift` file, and in the `routes` function, add the following:

https://gist.github.com/calebkleveter/f7d0f472ee3387c28213cea9826c5850#file-firstroute-swift

You might remember that the default routes in the template had a parameter that was a string, whereas we don’t have that in this route. That parameter that was passed into the other routes was that route’s path which had to be called by the client to access it. Since we didn’t pass a path into this route, it gets set as the root route. If you run your app and navigate to `localhost:8080` in the your browser, you will see the string that you returned from the route:

![Response from localhost:8080 route](https://github.com/calebkleveter/Tutorials/blob/master/up-and-running-with-vapor3/HelloVapor.png)

Now we have the knowledge to create our own project and get it ready to build. We can also create a route that returns any string we want. In the next tutorial, we will cover how to connect your application to a relational database and creating models to store data.

If you are interested in downloading the project, it is hosted [on GitHub](https://github.com/calebkleveter/chatter/tree/up-and-running-with-vapor3). If you ever run into any issues, or just want to chat with other Vapor users (AKA, droplets), pop over to the [Slack community](https://vapor.team/). We’d love to hear from you!