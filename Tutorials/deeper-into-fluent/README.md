# Deeper into Fluent

In the [last tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-3-introduction-to-routing-and-fluent-in-vapor-3-221d209f1fec), we looked at the basics of Fluent queries (and routing, but that doesn't matter at this time). This time, we will dig a little deeper with queries and model relations.

*Make sure you run `vapor update -y` or `swift package update` before starting.*

## [Model Relations](https://docs.vapor.codes/3.0/fluent/relations/)

We are going to start with a [sibling](https://docs.vapor.codes/3.0/fluent/relations/#siblings), or many-to-many, relationship. The app we are building will be a simple social media app. One important part of any social media being able to follow people. To represent a follower/following connection, we would have a model that has two `User` IDs, one for the follower and one for the followed. Fluent has a protocol to help us build this kind of structure called `Pivot`. There are database type specific versions of this protocol, so use `PostgreSQLPivot` or `MySQLPivot` based on which database you are using.

We are going to call the pivot model `UserConnection`. That model looks like this:

https://gist.github.com/calebkleveter/a363cfb901020f46a47032fa0873b4dc

Everything but [lines 12 - 17](https://gist.github.com/calebkleveter/a363cfb901020f46a47032fa0873b4dc#file-userconnection-swift-L11-L17) are required by the `PostgreSQLPivot` protocol. We add the `rightID` and `leftID` properties so we can satisfy the `rightIDKey` and `leftIDKey` properties. The initializer takes in two `User` models and extracts the IDs to assign them to the `rightID` and `leftID` properties. If either ID is missing, an error is thrown.

Conform the `UserConnection` pivot to the `Migration` protocol: 

https://gist.github.com/calebkleveter/19a125473daefc420f240327fff38629

Then add it to the migration config in the global `configure(_:_:_:)` function:

https://gist.github.com/calebkleveter/af2ef7bb6127c9c3b3bbda2a185b314a

