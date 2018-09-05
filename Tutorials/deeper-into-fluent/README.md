# Deeper into Fluent

In the [last tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-3-introduction-to-routing-and-fluent-in-vapor-3-221d209f1fec), we looked at the basics of Fluent queries (and routing, but that doesn't matter at this time). This time, we will dig a little deeper with queries and model relations.

*Make sure you run `vapor update -y` or `swift package update` before starting.*

## [Model Relations](https://docs.vapor.codes/3.0/fluent/relations/)

We are going to start with a [sibling](https://docs.vapor.codes/3.0/fluent/relations/#siblings), or many-to-many, relationship. The app we are building will be a simple social media app. One important part of any social media platform is being able to follow people. To represent a follower/following connection, we would have a model that has two `User` IDs, one for the follower and one for the followed. Fluent has a protocol to help us build this kind of structure called `Pivot`. There are database type specific versions of this protocol, so use `PostgreSQLPivot` or `MySQLPivot` based on which database you are using.

We are going to call the pivot model `UserConnection`. That model looks like this:

https://gist.github.com/calebkleveter/a363cfb901020f46a47032fa0873b4dc

Everything but [lines 12 - 17](https://gist.github.com/calebkleveter/a363cfb901020f46a47032fa0873b4dc#file-userconnection-swift-L11-L17) are required by the `PostgreSQLPivot` protocol. We add the `rightID` and `leftID` properties so we can satisfy the `rightIDKey` and `leftIDKey` properties. The initializer takes in two `User` models and extracts the IDs to assign them to the `rightID` and `leftID` properties. If either ID is missing, an error is thrown.

Conform the `UserConnection` pivot to the `Migration` protocol: 

https://gist.github.com/calebkleveter/19a125473daefc420f240327fff38629

Then add it to the migration config in the global `configure(_:_:_:)` function:

https://gist.github.com/calebkleveter/af2ef7bb6127c9c3b3bbda2a185b314a

Next, we will add a couple of helper properties to the `User` model so we can easily get and add followers/following users.

First is the `following` property. This property will get all the users that a single user follows. I am going to put this property in a `User` extension below the `UserConnection` model.

The property will look something like this:

https://gist.github.com/calebkleveter/160d863d8a2713be31038b8470489193

Usually when you use the `.siblings` method, you can just call `self.siblings()` and all the generics stuff is figured out for you. Because we are using the same type for both the left and right properties of the pivot, we need to specify how they are related and which model is the base model.

The other computed property we want is for getting a user's followers. This will be the same as the previous property, but we will switch the key-paths around:

https://gist.github.com/calebkleveter/40419ac191f68a7346eba45247d7f3d4

We will also add two methods to the `User` model. One for following and another for un-following another user.

The first method, for following a user, looks like this:

https://gist.github.com/calebkleveter/26c3ae03f9e25b05cce02a675bdd9546

We take in a user to follow and a `DatabaseConnectable` object to save the new pivot with. We wrap the body of the method in a `Future.flatMap` so the method doesn't need to throw. We create a `UserConnection` pivot with `self` as the base user and the user passed in as the foreign user. We save the pivot, then return the current user and followed user in a tuple.

To unfollow a user, we use the `Siblings.detach` method with the `.following` computed property. The signature of the method is almost the same:

https://gist.github.com/calebkleveter/6cacaabb3d7497ca374d6c291aaff1a9

You should now have the following extension in your `UserConnection.swift` file:

https://gist.github.com/calebkleveter/371e0731e3c24b5f28ff2e7847e33a62


## [Query it Over Again](https://docs.vapor.codes/3.0/fluent/querying/)

We will now put our pivot to use by adding some more routes to the `UserController`. The first two routes will be simple, getting the user's followers and the user's he/she is following. We have already discussed in previous tutorials what you need to make these routes, so give it a shot before looking at my code below!

https://gist.github.com/calebkleveter/7a1709f9f23d9b2a8445556bb86382e7

We are going to add two more route to the `UserController`. One for following a user and another for un-following a user.

To follow a user, we are going to use a `POST` route (because we are creating a new pivot) with the path `{user}/follow`.

https://gist.github.com/calebkleveter/623b45444a6fa812d9d0f7bf47c181a3

The handler just takes in a request. We get the user that will follow from the request's parameters and the user *to* follow from the request's body, with the `follow` key. After we find the user to follow, we create a new `UserConnection` pivot with the `User.follow(user:on:)` method. We then convert the tuple returned by that method to a dictionary and return it.

To un-follow a user, we are going to make a `DELETE` route with the path `{user}/un-follow`. The handler will be very similar to the one for following another user:

https://gist.github.com/calebkleveter/3f25d98a7f116920569278047b37e2d4

As with the previous handler, we get the current user and the user being followed, but then we call `User.unfollow(user:on:)`. We then return the HTTP status 204 (No Content).

We will add one more route to the `UserController` to search for users by their name. This will get a `GET` route at `users/search`. The name to search by will be passed in using a query string. The handler looks like this:

https://gist.github.com/calebkleveter/794b1a50b1dfbcc964e8a29b24d27ac9

First we get the `name` value from the request's query strings. Then we have to find the `User` models that match it. We do this using the `=~` operator. This operator requires that the beginning of the string matches the value passed in, so "hello" would match "hello world". You need to import the `FluentSQL` module to use this operator, because it is SQL specific.

We put the filters in an `or` group because if a user has a username of `Jonny` but their first name is `Steve`, you would never be able to find that user in the search.

## [Migrating the ID](https://docs.vapor.codes/3.0/fluent/migrations/)


We have been using the `username` property of the `User` model as the model's ID up until now, but that is actually a bad idea. An ID should never change for a model, but some users will want to change their username from time to time. We are going to modify the `User` model to have a `UUID` as its ID, but keep the `username` property unique.

First, add a `var id: UUID?` property to the `User` model and make the `username` property non-optional. Then replace the `User: Model` extension to be either `PostgreSQLUUIDModel` or `MySQLUUIDModel`, depending on the database you are using:

https://gist.github.com/calebkleveter/bb565870c9b3cb6635fc1d49e0a6e32c

This will break our `UserConnection` implementation. You will need to change the ID property types to `UUID` also:

https://gist.github.com/calebkleveter/8e8c48d0179b6a19e584d3de2bb58c1e

Now we are going to create a custom migration for the `User` model. A migration is basically instructions that Fluent uses to generate the model's table in the database. There is a default implementation for this, which is why we didn't need to do this ourselves before.

https://gist.github.com/calebkleveter/cd18971cbcf3288a1eb29121c0a7d444

The `Database.create` method creates a table in the database for the model passed in (`self`), using the `SchemaCreator` passed in as a blue print for the table. The `addProperties(to:)` method uses the `init(from:)` decoder initializer to get a reflection of the model and create columns for the model's properties. That is what the migration does by default.

We added two more instructions to the migration to mark both the `username` and `email` columns as `UNIQUE`. This means the no two users can share the same username or email.





