# RepoTracker

The goal of this project is to provide a way to keep track of an specific repository. Actually it only supports Github.

## Archtecture

As we're interacting with an external source through an unreliable way(internet) so to be able to provide durability and to have a way to retry flows that is failling for unknown reason we have used [Oban](https://hexdocs.pm/oban/Oban.html) as a processing library and divided the problem into three steps.
The first one is receiving the http request asking for track some repository so we schedule the Job that will be responsible for fetch the data and the one that will reply for a webhook later.
The fetch job will get the basic information about the Repository and schedule a fetch user job for the users that we don't have in our database to be able to gather more information about these one.
On the scheduled date(the default is one day after the request) a reply will be sent to the target webhook url.

## Running

The unique external dependency is a PostgreSQL database. The project comes with a simple docker-compose.yml with the things already configured.
To run a server:
``` elixir
>iex -S mix phx.server

[info] Running RepoTrackerWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[info] Access RepoTrackerWeb.Endpoint at http://localhost:4000
Interactive Elixir (1.14.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

To run the project tests
``` elixir
>mix ecto.setup
>mix test
```
