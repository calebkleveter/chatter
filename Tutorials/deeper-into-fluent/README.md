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



