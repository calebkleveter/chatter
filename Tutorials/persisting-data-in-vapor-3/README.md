![Header](https://github.com/calebkleveter/Tutorials/blob/master/persisting-data-in-vapor-3/VaporDatabaseHeader.png?raw=true)

# Diving into Vapor, Part 2: Persisting Data in Vapor 3

In the [previous tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-1-up-and-running-with-vapor-3-edab3c79aab9), we looked at how to setup a Vapor project. It's a good place to start, but not very fun. Let's get our application off the ground by adding data persistence!

In this tutorial, we will be covering how to connect to a relational database (both PostgreSQL and MySQL) and then storing data in it.

The first part will cover connecting to a MySQL database, the second covers connecting to a PostgreSQL database, and the third covers how to create and store models (you almost do the same thing for each DB).

---

# [MySQL](https://docs.vapor.codes/3.0/mysql/getting-started/)

Open your terminal and run `brew tap homebrew/services && brew install mysql && brew services start mysql`. This will install MySQL and boot it up. MySQL will subsequently boot whenever you login, so you won't have to do that again. 

We also need to create that database for our app to connect to. Run `mysql -u root -p` and press enter twice (you shouldn't need to enter a password). Run this command in the MySQL prompt:

https://gist.github.com/calebkleveter/c510f93c3f78213d1a6bb85dced707a9

You can change the name of the database if you want, but make sure you do that in the reset of this tutorial also. I prefer to just use the name of my application for the database name. 

You can exit the MySQL prompt by running `QUIT`

We need to install the package for MySQL in our application, so replace the reference to `FluentSQLite` with this package instance in your manifest's `dependencies` array:

https://gist.github.com/calebkleveter/0adec972862d9bb1404d57d265392b5c

Make sure you replace `FluentSQLite` with `FluentMySQL` in the `dependencies` array of you `App` target. Then run `vapor update -y` or `swift package update`.

Now we need to add Fluent and the MySQL database to our app's configuration. Go to `Configuration/configure.swift` and replace the `Fluent` import with `FluentMySQL`. At the top of your `configure` function, add this:

https://gist.github.com/calebkleveter/014e1d0229bd32a61f4cc42154e6ef60

This provider handles operations such as creating tables in our database when we boot the application.

Below where you initialize `DatabaseConfig`, add the MySQL database configuration:

https://gist.github.com/calebkleveter/3b4f8b7a12e10f41d71ba3613cbd5652

Your `configure.swift` file should look like this now:

https://gist.github.com/calebkleveter/dcc6cb4dc2d70024770e1bc58fa0c305

You now have MySQL configured with your Vapor application!


# [PostgreSQL](https://docs.vapor.codes/3.0/postgresql/getting-started/)

Open your terminal and run `brew tap homebrew/services && brew install postgres && brew services start postgres`. This will install and boot Postgres. Postgres will subsequently boot whenever you login, so you shouldn't have to start it again.

We also need to create the database our app will connect to. You can do this by running `createdb <NAME>` in your terminal. I will name it `chatter` to match the name of the application.

To interact with the database, we need to install `FluentPostgreSQL` to our app. Replace the `FluentSQLite` dependency with this declaration in your manifest's `dependencies` array:

https://gist.github.com/calebkleveter/c2ef099ac7a1a5457995d180a05b271a

Make sure you also replaced `FluentSQLite` in the `App` target's dependencies with `FluentPostgreSQL`. You also need to update your packages by running `vapor update -y` or `swift package update`.

Now we need to add `Fluent` and the PostgreSQL database to our app's configuration. Go to `Configuration/configure.swift` and replace the `Fluent` import with `FluentPostgreSQL`. At the top of your configure function, add this:

https://gist.github.com/calebkleveter/4720018fc188c11d1bc6a0fba40f318a

This provider handles operations such as creating tables in our database when we boot the application.

Below where you initialize `DatabaseConfig`, we need to create a `PostgreSQLDatabaseConfig` and add it to the databases configuration. The Postgres configuration takes in a `username` argument. The value you pass in should be the result of running `whoami` in the terminal:

https://gist.github.com/calebkleveter/2b6a335f07ef0c89fa3805fb542796a1

Your `configure.swift` file should look like this now:

https://gist.github.com/calebkleveter/a2e985e3f28507eb102b115ad65b39e7

You now have PostgreSQL configured with your Vapor application!

---

# Models

Now that we are connected to a database, we will create a model that we can store in it.

Create a file by running `touch Sources/App/Models/User.swift` and regenerate your Xcode project.

Import Vapor, Foundation, and the appropriate Fluent package to the file. This will be `FluentPostgreSQL` or `FluentMySQL`.

I will be using the Postgres version of everything database specific in my examples, so make sure to change those to the correct database if you are using a different one.

Create a class called `User` that conforms to the protocol `Content`. This protocol conforms your model to `Codable` and allows it to be created from a request body and returned from a route handler. Make sure you define the class as `final`:

https://gist.github.com/calebkleveter/7708f3eed8708abbf77ec6a55d7c65de

We will want a few properties for our model such as `email`, `password`, `username`, etc., so let's add those:

https://gist.github.com/calebkleveter/cc38abf2e08b23e053b8eaeeadc82a8a

We need to conform to 2 protocols so we can store and query our users. They are `Model` and `Migration`. More specifically, we will conform to `<YOUR-DATABASE>UUIDModel` and `Migration`. We use the specialized version of the `Model` protocol to cut down on the amount of code to write.

Here is what the conformances will look like:

https://gist.github.com/calebkleveter/6d53e6e959ab72ec82d91e4b54b677f8

Pretty simple huh? Your `User.swift` file should look more or less like this now:

https://gist.github.com/calebkleveter/e5269a523dcc6e4ac9de49db62c5e613

The Fluent provider we added to our config can create tables for our models automatically, but it doesn't know about the models unless we add them to the `MigrationConfig`. Go to your `configure` function, and where you create and register the `MigrationConfig` to the app's services, add the `User` model to the config:

https://gist.github.com/calebkleveter/3c8a3f80f09ca104b9bf0ca2847f9337

Now run your app. The Fluent provider should create a `users` table in your database.

![Tables created!](https://github.com/calebkleveter/Tutorials/blob/master/persisting-data-in-vapor-3/TablesCreated.png?raw=true)

If you are familiar with security for the backend, you will know that storing passwords in plain text is a *bad idea!!!*. We will cover that issue in a later tutorial when we talk about authentication and authorization.

---

# Storing Data

Storing models in your database is incredibly simple. We are going to create a route that creates a `User` model from a request's body and saves the model to the database.

Go to your `routes.swift` file. In the `routes` function, we will register a new `POST`	 route with the router passed in:

https://gist.github.com/calebkleveter/9290413cf2e5a185d56eb0a73b29b2e9

Unlike the `GET` routes that we have seen before, for this route we passed in the `User` type in as the first parameter. This tells the router to decode the request's body to a `User` object and pass it into the route handler.

What we want to do is take that `User` model passed into the handler, save it to the database, and return that same user as JSON. All we have to do is add `return user.save(on: request)` to out handler, so our route looks like this:

https://gist.github.com/calebkleveter/8b4d321dc54650d2f983a35fb119dc02

To test this route, we will want to use an API testing tool such as [Postman](https://www.getpostman.com/). Set the URL to `http://localhost:8080/users`, the HTTP method to `POST`, and add a JSON object to the request's body that has all the `User` properties except for `id`:

![Test Create User Request](https://github.com/calebkleveter/Tutorials/blob/master/persisting-data-in-vapor-3/CreateUserRequest.png?raw=true)

When you send the request, you should get a response that looks something like this:

https://gist.github.com/calebkleveter/7736abbb3815e563661628fef0bdda76

If you look in your database, there will be the user we just created:

![User Stored in Database](https://github.com/calebkleveter/Tutorials/blob/master/persisting-data-in-vapor-3/StoredUser.png?raw=true)

---

Now we know how to connect a database to our Vapor application and make models that we can store in it. We will discuss model querying and routing in our next tutorial, so be sure not to miss it!

If you are interested in downloading the project, it is hosted [on GitHub](https://github.com/calebkleveter/chatter/tree/persisting-data-in-vapor3). If you ever run into any issues, or just want to chat with other Vapor users (AKA, droplets), pop over to the [Slack community](https://vapor.team/). We’d love to hear from you!

*Go to the next tutorial in this series, [here](https://theswiftwebdeveloper.com/diving-into-vapor-part-3-introduction-to-routing-and-fluent-in-vapor-3-221d209f1fec).*