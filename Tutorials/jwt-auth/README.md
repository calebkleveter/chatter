# Diving into Vapor, Part 6: JWT Authentication

**Note:** Since the last post, I added a `Tag` model to the project that connects the `Post` model. You can dig around the project and see exactly what I did. Have fun!

When interacting with a RESTful API, it is common to use authentication keys to get data that is specific to you. One way to handle this authentication is by using JWT, or JSON Web Tokens. Auth0 has a great website called [jwt.io](https://jwt.io/) that covers about everything you need to know about how JWT works. I highly recommend you check it out. In the mean time, I will show you how to implement JWT in Vapor.

## Installing the Packages

While the Vapor community has a [JWT package](https://github.com/vapor/jwt) you can install, but it doesn't have any direct integrations with the Vapor framework itself (this is so the package can remain agnostic). I recommend that you use Skelpo's [JWTVapor](https://github.com/skelpo/JWTVapor) and [JWTMiddleware](https://github.com/skelpo/JWTMiddleware) packages. These provide integration between the JWT and Vapor frameworks.

Lets install both of the JWT packages I mentioned before:

```swift
// dependencies:
.package(url: "https://github.com/skelpo/JWTVapor.git", from: "0.12.0"),
.package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.9.0")

// targets:
.target(name: "App", dependencies: [/* ... */ "JWTVapor", "JWTMiddleware"]
```

```bash
swift package update && vapor xcode -y
```

## The Payload

Create a `Payload.swift` file in the `Models/` directory. Import the `JWT` module and create a class that looks something like this:

https://gist.github.com/calebkleveter/50842656e7d238b29cdf96ad80dbcea1

You can add more values to this payload if you want, but these three are all we need. I'll walk you through each one:

- `id` This is the ID of the user that authenticated.
- `exp` The UNIX timestamp of the token's expiration time. After that timestamp, the token has to be refreshed (we will discuss how to do this later).
- `iat` The UNIX timestamp of when the token was created.

Now let's implement the `verify` method. This method is run by the JWT middleware to make sure the data in the token is valid. The `JWT` module has various `Claim` types that you can use to verify the payload's values. There isn't any validation for the `id` property, but we can check the `exp` and `iat` properties.

For the `exp` property, we will use the `ExpirationClaim` type to make sure the token hasn't expired yet. For the `iat` property, we will use the `NotBeforeClaim` type to make sure the token was created after the current time (yeah, it's not possible, but it helps prevent malformed JWTs from getting through).

https://gist.github.com/calebkleveter/e5b47cf08cf985ac2e703e7e211ecbb8