require "opendmm/version"
require "opendmm/maker"

module OpenDMM
  def self.search(name)
    Maker.search(name)
  end
end