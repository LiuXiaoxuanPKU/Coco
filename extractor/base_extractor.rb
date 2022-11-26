class Extractor
    def initialize(db_schema)
        @db_schema = db_schema
    end

    def validate_constraint(table_name, c)
        case c.field_name
        when String
            return @db_schema[table_name].include?c.field_name
        when Array
            sub_array = true
            c.field_name.each{|f| sub_array &&= @db_schema[table_name].include?f}
            return sub_array
        else
            puts "[Error] Invalid field type #{c.field_name.class}, #{c}"
            return false
        end
    end

    def filter_validate_constraints(node, constraints)
        filtered_constraints = constraints
        if @db_schema.key? node.table
            filtered_constraints = constraints.select{|c| validate_constraint(node.table, c)}
        else
            puts "[Warning] Schema does not have table #{node.table}"
        end
        return filtered_constraints
    end

    def set_constraints(node, constraints)
        node.constraints += constraints
    end
end