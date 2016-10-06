module ActiveRecord
  module ConnectionAdapters
    # PostgreSQL-specific extensions to column definitions in a table.
    class SQLAnywhereColumn < Column #:nodoc:

      protected
        # Handles the encoding of a binary object into SQL Anywhere
        # SQL Anywhere requires that binary values be encoded as \xHH, where HH is a hexadecimal number
        # This function encodes the binary string in this format
        def self.string_to_binary(value)
          "\\x" + value.unpack("H*")[0].scan(/../).join("\\x")
        end

        def self.binary_to_string(value)
          # This is causing issues when importing some documents including PDF docs
          # that have \\x46 in the document, the code below is replacing this with
          # the hex value of 46 which modifies the document content and makes it unreadable
          # and no longer useful. I'm not exactly sure why this is needed as I don't want my
          # binary data modified in any way
          #value.gsub(/\\x[0-9]{2}/) { |byte| byte[2..3].hex }
        end

    end
  end
end
