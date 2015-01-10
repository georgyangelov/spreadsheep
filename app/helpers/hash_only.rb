class Hash
  def only(*keys)
    symbol_and_string_keys = keys + keys.map(&:to_s)
    slice(*symbol_and_string_keys).symbolize_keys
  end
end
