# Diving into Vapor, Part 5: Parent-Child Relationships

In the [last tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-4-deeper-into-fluent-30d84e19f114), we created a sibling relationship for the `User` model to represent follower/following relationships between them. Now we will look at a new kind of database relationship call the 'Parent-Child' relationship. This is when a single `Parent` model owns any number of `Child` models, but a `Child` model can only be connected to a single `Parent` model.

## Creating a Child

In the app we are creating, the 'parent' model will be `User` and the 'child' model will be a new `Post` model we are going to create. Start by creating a `Post.swift` file in your `Models/` directory and building the basic structure of the `Post` model:

https://gist.github.com/calebkleveter/c5fe46e889428d5b0e574a3f89f4d702

Now we need to think of what a post needs. There are many things you could add, such as images, polls, and other widgets, but that gets out of the scope of this tutorial, so we will only have 2 fields:

- `contents`: This is the text that people can read.
- `userID`: The ID of the `User` that owns the post.

We could have an array of tags, but you get performance and maintenance if you have a pivot between a `Tag` model and `Post` model, so we'll leave that out for now.

Your `Post` model should then look like this:

https://gist.github.com/calebkleveter/2a5dca49930bf812dc6a366da30b8fa7

You might have differences with your implementation. You might make `userID` mutable or have the initializer take in a `User` model and extract the ID from it. That's okay.



