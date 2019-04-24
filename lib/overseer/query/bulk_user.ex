defmodule Overseer.Query.BulkUser do
  @moduledoc "Bulk-user-related GraphQL queries"

  def bulk_invitation(phone_numbers) do
    {
      """
      mutation ($phoneNumbers: [String!]) {
        friendBulkInvite (input: {phoneNumbers: $phoneNumbers}) {
          successful
          result {
            phoneNumber
            user {
              id
            }
            result
            error
          }
        }
      }
      """,
      %{phoneNumbers: phone_numbers}
    }
  end
end
