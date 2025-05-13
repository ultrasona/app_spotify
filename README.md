# AppSpotify
AppSpotify is a REST API build with [Phoenix](https://www.phoenixframework.org/) (Elixir) with wich you can get the list of one artist's albums.


## Prerequisites


The setups steps expect following tools installed on the system:
-   [Elixir](https://elixir-lang.org/) >= 1.14

-   [Erlang/OTP](https://www.erlang.org/) >= 25

-   [Phoenix](https://www.phoenixframework.org/)  >= 1.7

-   [Docker](https://www.docker.com/) & Docker Compose

## Install

### Clone the repository
With https:
```
git clone https://github.com/ultrasona/app_spotify.git
```
Or ssh:
```
git@github.com:ultrasona/app_spotify.git
```

### Start project ecosystem
The project include a `docker-compose.yml` file that contains definition for PostgreSQL. You can start it easily using:
```
docker compose up
```

### Setup project environment

- Run `mix setup` to install and setup dependencies
- Creates a `.env` file based on the `.env.expl` file and to forget to add the real credential instead of the place holders

### How to run
The web server:
```
mix phx.server
```

Tests:
```
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
mix test
```

## Call the api
You can now call the route!
### GET /api/albums

#### URL
`GET http://localhost:4000/api/albums?artist_name=Otyken`

#### Parameters

| Param | Type | Required | Description |
| :---        |    :----:   |    :----:   |      ---: |
| `artist_name` | String | ✅  | Artist's name |


#### 200 Response
```
[
  {
    "name": "Phenomenon",
    "release_date": "2023-02-24"
  },
  {
    "name": "Kykakacha",
    "release_date": "2021-06-17"
  },
  {
    "name": "Lord of Honey",
    "release_date": "2019-03-22"
  }
]
```

#### Error example
For a 401
```
{
  "error": "unauthorized"
}
```

## Documentation
To get the documentation run:
```
mix docs
```
Wich will generate the documentation inside the folder `/doc`. You'll then be able to open it through the `item.html` file.

