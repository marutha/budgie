defmodule Budgie.Utils.UUIDGuard do
  @moduledoc """
  Lightweight utilities for validating UUIDs.

  - `is_uuid_format/1` is a guard-friendly check (fast: binary, length, and dash positions).
    Use it in `when` clauses and function heads.
  - `valid_uuid?/1` performs a full runtime validation (hex characters + dashes) using a regex.
  """

  # Guard: structural check (binary, 36 chars, dashes at 8,13,18,23)
  defguard is_uuid(uuid)
           when is_binary(uuid) and byte_size(uuid) == 36 and
                  binary_part(uuid, 8, 1) == "-" and
                  binary_part(uuid, 13, 1) == "-" and
                  binary_part(uuid, 18, 1) == "-" and
                  binary_part(uuid, 23, 1) == "-"

  @doc """
  Full runtime validation of a UUID string.

  Returns `true` if the string is a valid UUID (hex digits + dashes), otherwise `false`.
  """
  @spec valid_uuid?(any()) :: boolean()
  def valid_uuid?(uuid) when is_binary(uuid) do
    # RFC 4122 UUID format: 8-4-4-4-12 hex digits (case-insensitive)
    regex = ~r/^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$/
    Regex.match?(regex, uuid)
  end

  def valid_uuid?(_), do: false
end
