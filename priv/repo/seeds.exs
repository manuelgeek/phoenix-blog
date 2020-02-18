# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#
alias Blog.Accounts

users = [
  %{email: "jane.doe@example.com", password: "password", name: "Jane Doe", username: "janedoe"},
  %{
    email: "john.smith@example.org",
    password: "password",
    name: "John Smith",
    username: "johnsmith"
  },
  %{
    email: "emashmagak@gmail.com",
    password: "secret",
    name: "ManuEl Geek",
    username: "manuelgeek"
  }
]

for user <- users do
  {:ok, new} = Blog.Accounts.create_user(user)
  Accounts.create_account(%{"user_id" => new.id, "avatar" => "/dist/img/clients/client-1.jpg"})
end
