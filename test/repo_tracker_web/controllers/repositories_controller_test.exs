defmodule RepoTrackerWeb.Controller.RepositoriesControllerTest do
  use RepoTrackerWeb.ConnCase, async: true

  test "renders 404.json", %{conn: conn} do
    data = %{
      "repo_name" => "handle-collision-strategies",
      "user_name" => "andrepaes",
      "target" => "https://webhook.site/95483c44-32b6-4c97-bb55-d15f9ab5270c"
    }

    assert %{"message" => "Your request is being processed"} ==
             conn
             |> post("/api/repositories/track", data)
             |> json_response(200)
  end
end
