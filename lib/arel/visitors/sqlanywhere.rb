module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement o
        [
          "SELECT",
          (visit(o.limit) if o.limit),
          (visit(Arel::Nodes::Limit.new(2147483647)) if o.limit == nil and o.offset),
          (visit(o.offset) if o.offset),
          o.cores.map { |x| visit_Arel_Nodes_SelectCore x }.join,
          ("ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?),
          (visit(o.lock) if o.lock),
        ].compact.join ' '
      end
      
      def visit_Arel_Nodes_SelectCore o
        str = ""

        str << " #{visit(o.top)}" if o.top
        str << " #{visit(o.set_quantifier)}" if o.set_quantifier

        unless o.projections.empty?
          str << SPACE
          len = o.projections.length - 1
          o.projections.each_with_index do |x, i|
            str << visit(x)
            str << COMMA unless len == i
          end
        end

        str << " FROM #{visit(o.source)}" if o.source && !o.source.empty?

        unless o.wheres.empty?
          str << WHERE
          len = o.wheres.length - 1
          o.wheres.each_with_index do |x, i|
            str << visit(x)
            str << AND unless len == i
          end
        end

        unless o.groups.empty?
          str << GROUP_BY
          len = o.groups.length - 1
          o.groups.each_with_index do |x, i|
            str << visit(x)
            str << COMMA unless len == i
          end
        end

        str << " #{visit(o.having)}" if o.having

        unless o.windows.empty?
          str << WINDOW
          len = o.windows.length - 1
          o.windows.each_with_index do |x, i|
            str << visit(x)
            str << COMMA unless len == i
          end
        end

        str
      end

      def visit_Arel_Nodes_Offset o
        "START AT (#{visit(o.expr) + 1})"
      end

      def visit_Arel_Nodes_Limit o
        "TOP (#{visit o.expr})"
      end
      
      def visit_Arel_Nodes_True o
        "1=1"
      end
      
      def visit_Arel_Nodes_False o
        "1=0"
      end

    end
  end
end

Arel::Visitors::VISITORS['sqlanywhere'] = Arel::Visitors::SQLAnywhere
