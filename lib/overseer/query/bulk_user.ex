defmodule Overseer.Query.BulkUser do
  def bulk_invitation do
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
    """
  end
end
