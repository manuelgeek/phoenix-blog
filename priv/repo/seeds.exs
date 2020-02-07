# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

users = [
  %{email: "jane.doe@example.com", password: "password", name: "Jane Doe", username: "janedoe"},
  %{email: "john.smith@example.org", password: "password", name: "John Smith", username: "johnsmith"},
  %{email: "emashmagak@gmail.com", password: "secret", name: "ManuEl Geek", username: "manuelgeek"},
]

for user <- users do
  {:ok, _} = Blog.Accounts.create_user(user)
end
