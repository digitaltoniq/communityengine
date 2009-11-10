class State < ActiveRecord::Base
  has_many :metro_areas
  belongs_to :country

  class << self

    def us
      @us_states ||= Country.get(:us).states.sort { |a, b| a.name <=> b.name }
    end
  end
end
