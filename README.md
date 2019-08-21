[![Build Status](https://travis-ci.org/davidbrusius/bank.svg?branch=master)](https://travis-ci.org/davidbrusius/bank) [![SourceLevel](https://app.sourcelevel.io/github/davidbrusius/bank.svg)](https://app.sourcelevel.io/github/davidbrusius/bank)

# Bank

Simple banking API implementend using [Elixir](http://elixir-lang.org) and [Phoenix](https://phoenixframework.org/).

# Contributing

Dependencies:

  * Elixir 1.9.1
  * Erlang 22.0.7
  * Postgres 11

Setup the application:

  * Clone this repo `git clone git@github.com:davidbrusius/bank.git`
  * Access the repo directory `cd bank`
  * Install dependencies with `mix deps.get`
  * Create, migrate and add seed data to your database with `mix ecto.setup`

To start your Phoenix server run `mix phx.server`.

Now you can start sending requests to the API on `http://localhost:4000`.

You can use the users and accounts created by the seeds file (`priv/repo/seeds.exs`) to start making some requests to the API. Alternatively, you can also create your own users and accounts using the commands available in the seeds file.


# API Endpoints

🔐 **Authentication**

Requests to authenticated endpoints are authorized through a Bearer token that should be provided in the `Authorization` HTTP header. Check the [`/api/auth/token`](#post-apiauthtoken) endpoint for further details on how to generate Bearer tokens.


## POST /api/auth/token

Authenticates the user using `email` and `password` credentials and generates an auth token which can be used in subsequent calls to authenticated API endpoints.

### Parameters

Name       | Required | Type   | Description     |
-----------|----------|--------|-----------------|
`email`    | required | string | A user email    |
`password` | required | string | A user password |

### Response

**Status**: `201 Created`

**Body**:
```json
{
  "token":  "auth-token"
}
```

## GET /api/accounts/:number

🔐 **Authenticated**

Return informations about the account such as its balance and number.

### Path Parameters

Name        | Required | Type   | Description        |
------------|----------|--------|--------------------|
`number`    | required | string | The account number |

### Response

When account exists.

**Status**: `200 Success`

**Body**:
```json
{
  "account": {
    "balance": "R$ 520.00",
    "number": "1234"
  }
}
```

When account does not exist.

**Status**: `404 Not Found`

**Body**:
```json
{
  "error": {
    "message": "Unable to find account with number 1234."
  }
}
```

## POST /api/accounts/transfer

🔐 **Authenticated**

Transfer the given amount from source account to destination account.

### Parameters

Name                     | Required | Type   | Description                           |
-------------------------|----------|--------|---------------------------------------|
`source_account_number`  | required | string | Source account to withdraw amount     |
`dest_account_number`    | required | string | Destination account to deposit amount |
`amount`                 | required | float  | The amount to be transferred          |

### Response

When all transfer validation are met.

**Status**: `201 Created`

**Body**:
```json
{
  "message": "Successfully transferred amount to destination account.",
  "dest_account_number": "1235",
  "source_account_number": "1234",
  "amount": "R$100.00"
}
```

When a transfer validation like source account does not have enough funds to transfer fails.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "error": {
    "source_account": [
      "does not have enough funds to transfer"
    ]
  }
}
```
