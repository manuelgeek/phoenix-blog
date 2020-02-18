defmodule Blog.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :avatar, :string
      add :bio, :text
      add :fb, :string
      add :tw, :string

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:accounts, [:user_id])
  end
end
