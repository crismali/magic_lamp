module MagicLamp
  MAGIC_LAMP = "magic_lamp"
  DEFAULT_PATH = ["spec", MAGIC_LAMP]
  TMP_PATH = ["tmp", MAGIC_LAMP]

  class << self
    attr_writer :path

    def path
      path = @path || DEFAULT_PATH
      Rails.root.join(*path)
    end

    def tmp_path
      Rails.root.join(*TMP_PATH)
    end
  end
end
