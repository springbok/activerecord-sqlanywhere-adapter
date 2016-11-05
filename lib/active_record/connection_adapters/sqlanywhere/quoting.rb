module ActiveRecord
  module ConnectionAdapters
    module SQLAnywhere
      module Quoting # :nodoc:

          # Applies quotations around column names in generated queries
        def quote_column_name(name) #:nodoc:
          # Remove backslashes and double quotes from column names
          name = name.to_s.gsub(/\\|"/, '')
          %Q("#{name}")
        end

        def _quote(value, column = nil)
          case value
            when Type::Binary::Data
              "'#{string_to_binary(value.to_s)}'"
            else
              super(value)
          end
        end

        def _type_cast(value)
          case value
            when Type::Binary::Data
              string_to_binary(value.to_s)
            else
              super(value)
          end
        end

        private

          # Handles the encoding of a binary object into SQL Anywhere
          # SQL Anywhere requires that binary values be encoded as \xHH, where HH is a hexadecimal number
          # This function encodes the binary string in this format
          def string_to_binary(value)
            value
            #"\\x" + value.unpack("H*")[0].scan(/../).join("\\x")
          end

          def binary_to_string(value)
            # This is causing issues when importing some documents including PDF docs
            # that have \\x46 in the document, the code below is replacing this with
            # the hex value of 46 which modifies the document content and makes it unreadable
            # and no longer useful. I'm not exactly sure why this is needed as I don't want my
            # binary data modified in any way
            #value.gsub(/\\x[0-9]{2}/) { |byte| byte[2..3].hex }
            value
          end

      end
    end
  end
end
