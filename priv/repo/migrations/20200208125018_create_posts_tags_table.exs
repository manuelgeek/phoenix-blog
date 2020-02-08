defmodule Blog.Repo.Migrations.CreatePostsTagsTable do
  use Ecto.Migration

  def change do
    create table(:posts_tags, primary_key: false) do
      add :post_id, references(:posts)
      add :tag_id, references(:tags)
    end
  end
end
