defmodule Blog.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string, :unique
      add :username, :string

      timestamps()
    end

    create unique_index(:users, [:username, :email])
  end
end
