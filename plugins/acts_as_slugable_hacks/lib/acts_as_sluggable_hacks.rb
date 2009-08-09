Multiup::Acts::Slugable::InstanceMethods.module_eval do

  # acts_as_slug needs source tp be an attribute, this hack allows methods too
  def read_attribute(attr_name)
    attr_name.to_sym == source_column.to_sym ? self.send(source_column.to_sym) : super
  end
  
end
