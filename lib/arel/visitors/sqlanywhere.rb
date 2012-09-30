module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement o
        [
          "SELECT",
          (visit(o.offset) if o.offset),
          (visit(o.limit) if o.limit),
          o.cores.map { |x| visit_Arel_Nodes_SelectCore x }.join,
          ("ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?),
          (visit(o.lock) if o.lock),
        ].compact.join ' '
      end

      def visit_Arel_Nodes_Offset o
        "START AT #{visit(o.expr) + 1}"
      end

      def visit_Arel_Nodes_Limit o
        "TOP #{visit o.expr}"
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
