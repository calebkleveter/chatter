# Diving into Vapor, Part 5: Parent-Child Relationships

In the [last tutorial](https://theswiftwebdeveloper.com/diving-into-vapor-part-4-deeper-into-fluent-30d84e19f114), we created a sibling relationship for the `User` model to represent follower/following relationships between them. Now we will look at a new kind of database relationship call the 'Parent-Child' relationship. This is when a single `Parent` model owns any number of `Child` models, but a `Child` model can only be connected to a single `Parent` model.

## Creating a Child

In the app we are creating, the 'parent' model will be `User` and the 'child' model will be a new `Post` model. Start by creating a `Post.swift` file in your `Models/` directory and building the basic structure of the `Post` model:

https://gist.github.com/calebkleveter/c5fe46e889428d5b0e574a3f89f4d702

Now we need to think of what a post needs. There are many things you could add, such as images, polls, and other widgets, but that gets out of the scope of this tutorial, so we will have only 2 fields:

- `contents`: This is the text that people can read.
- `userID`: The ID of the `User` that owns the post.

We could have an array of tags, but you get better performance and maintenance if you have a pivot between a `Tag` model and `Post` model, so we'll leave that out for now.

Your `Post` model should then look like this:

https://gist.github.com/calebkleveter/2a5dca49930bf812dc6a366da30b8fa7

You might have differences with your implementation. You might make `userID` mutable or have the initializer take in a `User` model and extract the ID from it. That's okay.

Don't forgot to add your `Post` model to the migrations config:

https://gist.github.com/calebkleveter/2e63cb9fac74efa2ec9383da996eb927

At this point the relationship is ready. All we are going to do now is add helper property to the `User` model so we can easily get its child `Post` models:

https://gist.github.com/calebkleveter/c197185b7a944534026536ae43a186b1

## CRUD and Parent-Child Relationships

Now that the `Post` model is setup, we can create API endpoints for it. We can start out with the controller looking like this:

https://gist.github.com/calebkleveter/b418507fcb6b0be23f574e7767d6a07b

Notice that the `posts` router group is not `/posts`, but `/users/{user}/posts`. This is because a `Post` model cannot be independent of a `User` parent, so we want to show that in the API.

**Read**

We'll start with a basic `GET` route that fetches all the posts belonging to a `User`. We do this by getting the `User` model from the request's parameters and calling `.posts` on it. This property lets you create a `QueryBuilder` that automatically filters the children for parent's ID. We create the `QueryBuilder` and call `.all()` on it:

https://gist.github.com/calebkleveter/27aacec265163cff7279b4ee4f0781d8

**Create**

Creating a `Post` model will be a bit more complex on our side because of the way we are structuring the API. We already have the `User` ID in the request's parameters, so we don't want to require it in the request's body, which would happen if we decode `Post`. Instead we are going to create a new struct called `PostBody` that only has a `content` property. We can use this struct to create a new `Post` instance once we get a `User` ID. I added a helper method to the `PostBody` struct for this:

https://gist.github.com/calebkleveter/2f8d4cfe2ef9c791c91c6b424a12a00f

Now that we can decode the request body, we can create the route handler. To create the `Post` model, we need to get the `User` model ID from the request parameters. We could just get the `User` model, but that requires an extra database query we don't want to have to make. Instead, we will get the raw parameter value, and convert it to a UUID. This won't verify that the `User` ID passed in is valid, but we can fix that later by adding a foreign-key constraint to the `Post` model's migration.

After we get the UUID, we can convert the `PostBody` to a `Post` and save it:

https://gist.github.com/calebkleveter/444a464bd10370112911a03e89758b41

**Update**

Unlike Twitter, we'll let people edit their posts 😄. First, we decoding the request's body to a `PostBody` instance; then we will get `User` passed in to the request's parameters. The `User`'s posts can then by filtered by their ID, using the ID which was also passed into the request's parameters. We can then update the `Post`'s in the query using the decoded `PostBody.content` property. Since we are filtering by ID, we can guarantee there will be 0 or 1 result, so we call `.first()` and unwrap it, throwing an `Abort(.notFound)` if we get `nil`:

https://gist.github.com/calebkleveter/50f992e3563c59d13c3a65e8901fc3f8

**Delete**

To delete a post, we will get the `Post` ID and `User` from the request parameters and filter the `User`'s posts with the ID. We can then call `.delete()` on the query and transform it to an `HTTPStatus.noContent`:

https://gist.github.com/calebkleveter/5c860066caf494f54f5e461f89be4b6c


Finish up by registering your `PostController` router in your `routes.swift` file:

https://gist.github.com/calebkleveter/6d2ea4aef752646a9ee8d6ba2eb3bcba

## Foreign-Key Constraints

I said we would add a foreign-key constraint to the `Post` model so the `userID` passed in is always valid. Create a custom migration for the `Post` model like we did for the `User` model, but instead of adding `UNIQUE` constraints to our properties, we will add a reference between the `Post.userID` property and the `User.id` property, like this:

https://gist.github.com/calebkleveter/283d941ae7e02f1f32ab4275230d31cb

Now the database will always check to make sure the `userID` value is valid.