class Loader
  using Gemmy.patch("object/i/m")
  def self.run
    Dir.glob("./**/*.rb").sort_by { |x| x.count("/") }.each &m(:require)
  end
end
