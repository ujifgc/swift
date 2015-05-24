require 'sequel/adapters/mysql'

FORCE_EXTERNAL_ENCODING = lambda{ |s| s.force_encoding(Encoding.default_external) }

[15, 249, 250, 251, 252, 253, 254].each do |mysql_h_enum_field_type|
  Sequel::MySQL::MYSQL_TYPES[mysql_h_enum_field_type] = FORCE_EXTERNAL_ENCODING
end
