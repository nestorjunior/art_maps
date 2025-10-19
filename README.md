

# Art Maps

Functional MVP for an interactive urban murals map.

## Backend
- Elixir + Phoenix
- RESTful API for urban murals
- PostgreSQL database

## How to run
1. Install dependencies: `mix deps.get`
2. Configure the database in `config/dev.exs`
3. Create the database: `mix ecto.create`
4. Run migrations: `mix ecto.migrate`
5. Start the server: `mix phx.server`

## API
- Endpoint: `/api/murals`
- Methods: GET, POST, PUT, DELETE

## Frontend
LiveView-based interactive map inspired by Google Maps, displaying urban murals.
