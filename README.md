# PGEx

This project is a WIP. It implements the [PostgreSQL's](http://www.postgresql.org/) [libpq](http://www.postgresql.org/docs/current/static/protocol.html) communication protocol between front-end and back-end in a pure [Elixir](http://elixir-lang.org/).

# Motivation

There are some Erlang libraries to connect to Postgres, I could use that libraries and create a wrapper, but I'd like to have fun with Elixir and improve my knowledge about Postgres client/server protocol, so why not implement the libpq using pure Elixir? ":)

## What is working now?

At this moment you can do something like this:

```elixir
 { :ok, conn } = PGEx.Connection.connect("postgresql://my_username:my_password@localhost:5432/my_database")

 { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as result")
 IO.inspect columns
 #=> ["result"]
 IO.inspect rows
 #=> [[1]]

 { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1+1 as a, 2+3 as b")
 IO.inspect columns
 #=> ["a","b"]
 IO.inspect rows
 #=> [[2,5]]

 { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as a, 2 as b, 3 as c, 4 as d")
 IO.inspect columns
 #=> ["a","b","c","d"]
 IO.inspect rows
 #=> [[1,2,3,4]]

 { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT relname,relkind FROM pg_class LIMIT 2")
 IO.inspect columns
 #=> ["relname","relkind"]
 IO.inspect rows
 #=> [ ["pg_statistic","r"], ["pg_type","r"] ]

 { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT '1' as result, 1 = 1 as bool1, 1 = 2 as bool2, 't' as fake, 1234 as number")
 IO.inspect columns
 #=> ["result","bool1","bool2","fake","number"]
 IO.inspect rows
 #=> [["1", true, false,"t",1234]]
```

## TODO

* application behaviour
* authentication behaviour
* non-blocking
* asynchronous notifications
* other types
* benchmarks
* everything else that is not working yet and should do... ":)

## License

Copyright 2013 Dickson S. Guedes.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
