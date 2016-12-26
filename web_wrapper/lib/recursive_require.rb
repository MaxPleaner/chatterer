class RecursiveRequire
  def self.init
    Dir.glob("./**/*.rb").sort_by { |x| x.count("/") }.each &method(:require)
  end
end
