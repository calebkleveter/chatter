import FluentMySQL
import Vapor

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    try services.register(FluentMySQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    var middlewares = MiddlewareConfig()
    middlewares.use(DateMiddleware.self)
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    var databases = DatabaseConfig()
    databases.add(database: MySQLDatabase(hostname: "localhost", user: "root", password: nil, database: "chatter"), as: .mysql)
    services.register(databases)

    var migrations = MigrationConfig()
    services.register(migrations)
}
