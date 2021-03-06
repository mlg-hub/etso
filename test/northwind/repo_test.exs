defmodule Northwind.RepoTest do
  use ExUnit.Case
  alias Northwind.{Importer, Model, Repo}
  import Ecto.Query

  setup do
    repo_id = __MODULE__
    repo_start = {Northwind.Repo, :start_link, []}
    {:ok, _} = start_supervised(%{id: repo_id, start: repo_start})
    :ok = Importer.perform()
  end

  test "list" do
    Repo.all(Model.Employee)
  end

  test "Insert / Delete Employee" do
    changes = %{first_name: "Evadne", employee_id: 1024}
    changeset = Model.Employee.changeset(changes)
    {:ok, employee} = Repo.insert(changeset)
    Repo.delete(employee)
  end

  test "List all Employees Again" do
    Repo.all(Model.Employee)
  end

  test "Select with Bound ID" do
    Repo.get(Model.Employee, 2)
  end

  test "Where" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
    |> Repo.all()
  end

  test "Select Where" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
    |> select([x], x.last_name)
    |> Repo.all()
  end

  test "Select / Update" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales")
    |> Repo.all()
    |> List.first()
    |> Model.Employee.changeset(%{title: "SVP Sales"})
    |> Repo.update()
  end

  test "Assoc Traversal" do
    Model.Employee
    |> Repo.get(5)
    |> Ecto.assoc(:reports)
    |> Repo.all()
    |> List.first()
    |> Ecto.assoc(:manager)
    |> Repo.one()
    |> Ecto.assoc(:reports)
    |> Repo.all()
  end

  test "Promote to Customer" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
    |> Repo.one()
    |> Model.Employee.changeset(%{title: "Customer"})
    |> Repo.update()
  end

  test "Stream Employees" do
    Model.Employee
    |> Repo.stream()
    |> Enum.to_list()
  end

  test "Order / Shipper / Orders Preloading" do
    Model.Order
    |> Repo.all()
    |> Repo.preload(shipper: :orders)
  end
end
