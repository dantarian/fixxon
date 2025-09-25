# Fixxon

This application can be run either using Devcontainers, or Devbox. Devbox is the preferred approach, but Devcontainers may work better if your development environment
already has a running Postgres instance.

Regardless of which you choose, the first thing to do is to run `cp example.env .env`, then update the `.env` file
to specify the username and password for the database, and for the admin user for the app.

## Devcontainers

- Update your `.env` file so that `POSTGRES_HOST` is set to `database`. Also, prefix each of the environment variables with `export` followed by a space.
- Open the project in your IDE using Devcontainers.

That's it! Now follow the instructions in [Next Steps](#next-steps).

## Devbox

- Install [Devbox](https://www.jetify.com/docs/devbox/installing_devbox/), and follow the instructions for integrating with your IDE.
- (First time only) Initialise the database by running `devbox run initdb`.
- Start the database by running `devbox services up -b`.
- (First time only) Set up database user by running `devbox run create-db-user`.
- Start a Devbox shell - either via your IDE, or with `devbox shell`. All the commands in [Next Steps](#next-steps) should be run in that shell.

## Next Steps

- Run `mix setup` to install and setup dependencies.
- Run the tests with `mix test`.
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
