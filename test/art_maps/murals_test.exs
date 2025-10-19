defmodule ArtMaps.MuralsTest do
  use ArtMaps.DataCase

  alias ArtMaps.Murals

  describe "murals" do
    alias ArtMaps.Murals.Mural

    import ArtMaps.MuralsFixtures

    @invalid_attrs %{description: nil, title: nil, latitude: nil, longitude: nil, image_url: nil}

    test "list_murals/0 returns all murals" do
      mural = mural_fixture()
      assert Murals.list_murals() == [mural]
    end

    test "get_mural!/1 returns the mural with given id" do
      mural = mural_fixture()
      assert Murals.get_mural!(mural.id) == mural
    end

    test "create_mural/1 with valid data creates a mural" do
      valid_attrs = %{description: "some description", title: "some title", latitude: 120.5, longitude: 120.5, image_url: "some image_url"}

      assert {:ok, %Mural{} = mural} = Murals.create_mural(valid_attrs)
      assert mural.description == "some description"
      assert mural.title == "some title"
      assert mural.latitude == 120.5
      assert mural.longitude == 120.5
      assert mural.image_url == "some image_url"
    end

    test "create_mural/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Murals.create_mural(@invalid_attrs)
    end

    test "update_mural/2 with valid data updates the mural" do
      mural = mural_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", latitude: 456.7, longitude: 456.7, image_url: "some updated image_url"}

      assert {:ok, %Mural{} = mural} = Murals.update_mural(mural, update_attrs)
      assert mural.description == "some updated description"
      assert mural.title == "some updated title"
      assert mural.latitude == 456.7
      assert mural.longitude == 456.7
      assert mural.image_url == "some updated image_url"
    end

    test "update_mural/2 with invalid data returns error changeset" do
      mural = mural_fixture()
      assert {:error, %Ecto.Changeset{}} = Murals.update_mural(mural, @invalid_attrs)
      assert mural == Murals.get_mural!(mural.id)
    end

    test "delete_mural/1 deletes the mural" do
      mural = mural_fixture()
      assert {:ok, %Mural{}} = Murals.delete_mural(mural)
      assert_raise Ecto.NoResultsError, fn -> Murals.get_mural!(mural.id) end
    end

    test "change_mural/1 returns a mural changeset" do
      mural = mural_fixture()
      assert %Ecto.Changeset{} = Murals.change_mural(mural)
    end
  end
end
