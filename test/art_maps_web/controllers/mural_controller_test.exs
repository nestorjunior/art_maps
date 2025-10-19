defmodule ArtMapsWeb.MuralControllerTest do
  use ArtMapsWeb.ConnCase

  import ArtMaps.MuralsFixtures
  alias ArtMaps.Murals.Mural

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all murals", %{conn: conn} do
      conn = get(conn, ~p"/api/murals")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create mural" do
    test "renders mural when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/murals", mural: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/murals/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "image_url" => "some image_url",
               "latitude" => 120.5,
               "longitude" => 120.5,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/murals", mural: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update mural" do
    setup [:create_mural]

    test "renders mural when data is valid", %{conn: conn, mural: %Mural{id: id} = mural} do
      conn = put(conn, ~p"/api/murals/#{mural}", mural: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/murals/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "image_url" => "some updated image_url",
               "latitude" => 456.7,
               "longitude" => 456.7,
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, mural: mural} do
      conn = put(conn, ~p"/api/murals/#{mural}", mural: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete mural" do
    setup [:create_mural]

    test "deletes chosen mural", %{conn: conn, mural: mural} do
      conn = delete(conn, ~p"/api/murals/#{mural}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/murals/#{mural}")
      end
    end
  end

  defp create_mural(_) do
    mural = mural_fixture()

    %{mural: mural}
  end
end
