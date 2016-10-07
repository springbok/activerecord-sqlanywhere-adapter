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

        # Handles special quoting of binary columns. Binary columns will be treated as strings inside of ActiveRecord.
        # ActiveRecord requires that any strings it inserts into databases must escape the backslash (\).
        # Since in the binary case, the (\x) is significant to SQL Anywhere, it cannot be escaped.
        def quote(value, column = nil)
          case value
            when String, ActiveSupport::Multibyte::Chars
              value_S = value.to_s
              if column && column.type == :binary && column.class.respond_to?(:string_to_binary)
                "'#{column.class.string_to_binary(value_S)}'"
              else
                 super(value, column)
              end
            when TrueClass
              1
            when FalseClass
              0
            else
              super(value, column)
          end
        end

        def _type_cast(value)
          case value
            when Type::Boolean
              value ? 1 : 0
            when Type::Decimal
              value.to_s
            when Date
              value.to_s
            when DateTime, Time
              value.to_time.getutc.strftime("%Y-%m-%d %H:%M:%S")
            when Integer
              value.to_i
            else
              super
          end
        end

      end
    end
  end
end
