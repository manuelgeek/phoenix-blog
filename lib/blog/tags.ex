defmodule Blog.Tags do
  @moduledoc """
"""
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Blog.Repo

  alias Blog.Posts.Tag
  alias Blog.Helpers.Helper
  
  def list_tags do
    Repo.all(Tag)
  end

  def get_by_name!(name) do
    Repo.get_by!(Tag, name: name)
  end
  
  def get_by_name(name) do
    Repo.fetch_by(Tag, name: name)
  end
  
  def associate_tags(tag_string, post) do
    string_to_list(tag_string)
    |>  Enum.each(fn(s) ->
      s_tag = Helper.slugified_title(s)
      case get_by_name(s_tag) do
        {:ok, tag} ->
          assoc_tag(post, tag)
        {:error, :resource_not_found} ->
          {:ok, tag} = create_tag(%{name: s_tag})
          assoc_tag(post, tag)
      end
      
    end)


  end
  
  defp assoc_tag(post, tag) do
    post = Repo.preload(post, :tags)
    tags = post.tags ++ [tag]
                |> Enum.map(&Ecto.Changeset.change/1)
    post
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update!
  end
  
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end
  
  defp string_to_list(string) do
  string
  |> String.split(",")
  end

end
