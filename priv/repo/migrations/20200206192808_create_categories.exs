defmodule Blog.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :slug, :string
      add :status, :boolean, default: false, null: false

      add :category_id, references(:categories, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:categories, [:slug])
  end
end
