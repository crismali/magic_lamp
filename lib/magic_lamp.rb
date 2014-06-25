module MagicLamp
  DEFAULT_PATH = "spec/magic_lamp"

  class << self
    attr_writer :path

    def path
      path = @path || DEFAULT_PATH
      Rails.root.join(path)
    end
  end
end
