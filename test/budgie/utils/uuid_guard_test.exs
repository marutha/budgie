defmodule Budgie.Utils.UUIDGuardText do
  alias Ecto
  use Budgie.DataCase

  import Budgie.Utils.UUIDGuard
  describe "utils uuid guard test" do
    test "is_uuid failure" do
      assert false == is_uuid("something")
    end

    test "is_uuid success" do
      assert true == is_uuid(Ecto.UUID.generate())
    end

    test "valid_uuid? failure" do
      assert false == valid_uuid?("something")
    end

    test "valid_uuid? success" do
      assert true == valid_uuid?(Ecto.UUID.generate())
    end

    test "valid_uuid? non binary failure" do
      assert false == valid_uuid?(true)
    end
  end
end
