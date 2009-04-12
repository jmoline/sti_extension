# StiExtension
module StiExtension
  def is_extended_by(klass)
    class_eval <<-EOT
      has_one :#{klass.name.underscore}
    EOT
    inherited_columns = []
    klass.column_names.each do |att|
      unless ["id", "created_at", "updated_at"].include?(att)
        inherited_columns << att
        class_eval <<-EOT
          delegate :#{att.to_s}, :to => :#{klass.name.underscore.to_s}
          delegate :#{att.to_s}=, :to => :#{klass.name.underscore.to_s}
        EOT
      end
    end
    
    class_eval <<-EOT
      def initialize(params={})
        params ||= {}
        sub_params = {}
        #{inherited_columns.map {|att| "sub_params.merge!(:#{att.to_s} => params.delete(:#{att.to_s}))" }.join(';')}
        super
        self.send(:#{klass.name.underscore}=, #{klass}.new(sub_params))
      end
    EOT
  end
  
  #TODO: after_save callback & save method for subclass
end