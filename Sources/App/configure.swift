import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Configure custom backlog.
    app.http.server.configuration.backlog = 128
    // Disable address reuse.
    app.http.server.configuration.reuseAddress = false
    // Add 'Server: vapor' header to responses.
    app.http.server.configuration.serverName = "proactice"
    // Support HTTP pipelining.
    app.http.server.configuration.supportPipelining = true
    // Only support HTTP/2
    app.http.server.configuration.supportVersions = [.two]
    // Minimize packet delay.
    app.http.server.configuration.tcpNoDelay = true

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateTodo())

    app.views.use(.leaf)


    // register routes
    try routes(app)
}
