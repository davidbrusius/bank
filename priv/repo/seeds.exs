# Users
{:ok, john} = Bank.Users.create(%{email: "john.doe@test.com", password: "123456"})
{:ok, jane} = Bank.Users.create(%{email: "jane.doe@test.com", password: "123456"})

# Accounts
{:ok, johns_account} = Bank.Accounts.create(john, %{number: "1234"})
{:ok, janes_account} = Bank.Accounts.create(jane, %{number: "1235"})

# Initial deposit
{:ok, _deposit} = Bank.Accounts.deposit(johns_account.number, 100)
{:ok, _deposit} = Bank.Accounts.deposit(janes_account.number, 500)
