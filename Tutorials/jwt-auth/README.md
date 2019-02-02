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