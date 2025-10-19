defmodule ArtMapsWeb.MuralControllerTest do
  use ArtMapsWeb.ConnCase

  alias ArtMaps.Murals

  @create_attrs %{
    description: "some description",
    title: "some title",
    latitude: 120.5,
    longitude: 120.5,
    image_url: "some image_url"
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    latitude: 456.7,
    longitude: 456.7,
    image_url: "some updated image_url"
  }
  @invalid_attrs %{description: nil, title: nil, latitude: nil, longitude: nil, image_url: nil}

  def fixture(:mural) do
    {:ok, mural} = Murals.create_mural(@create_attrs)
    mural
  end

  describe "index" do
    test "lists all murals", %{conn: conn} do
      conn = get(conn, ~p"/murals")
      assert html_response(conn, 200) =~ "Murals"
    end
  end

  describe "new mural" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/murals/new")
      assert html_response(conn, 200) =~ "New Mural"
    end
  end

  describe "create mural" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/murals", mural: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == "/murals/#{id}"

      conn = get(conn, ~p"/murals/#{id}")
      assert html_response(conn, 200) =~ "Mural Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/murals", mural: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Mural"
    end
  end

  describe "edit mural" do
    setup [:create_mural]

    test "renders form for editing chosen mural", %{conn: conn, mural: mural} do
      conn = get(conn, ~p"/murals/#{mural}/edit")
      assert html_response(conn, 200) =~ "Edit Mural"
    end
  end

  describe "update mural" do
    setup [:create_mural]

    test "redirects when data is valid", %{conn: conn, mural: mural} do
      conn = put(conn, ~p"/murals/#{mural}", mural: @update_attrs)
      assert redirected_to(conn) == ~p"/murals/#{mural}"

      conn = get(conn, ~p"/murals/#{mural}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, mural: mural} do
      conn = put(conn, ~p"/murals/#{mural}", mural: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Mural"
    end
  end

  describe "delete mural" do
    setup [:create_mural]

    test "deletes chosen mural", %{conn: conn, mural: mural} do
      conn = delete(conn, ~p"/murals/#{mural}")
      assert redirected_to(conn) == "/murals"

      assert_error_sent(404, fn ->
        get(conn, ~p"/murals/#{mural}")
      end)
    end
  end

  defp create_mural(_) do
    mural = fixture(:mural)
    {:ok, mural: mural}
  end
end
