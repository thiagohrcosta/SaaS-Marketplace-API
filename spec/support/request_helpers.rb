module RequestHelpers
  def valid_headers(user)
    {
      "Authorization" => "Bearer #{user.magic_link_token}",
      "Content-Type" => "application/json"
    }
  end
end