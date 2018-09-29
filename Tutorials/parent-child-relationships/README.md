# Diving into Vapor, Part 5: Parent-Child Relationships

In the [last tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-4-deeper-into-fluent-30d84e19f114), we created a sibling relationship for the `User` model to represent follower/following relationships between them. Now we will look at a new kind of database relationship call the 'Parent-Child' relationship. This is when a single `Parent` model owns any number of `Child` models, but a `Child` model can only be connected to a single `Parent` model.
