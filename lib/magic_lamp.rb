require "fileutils"

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

    def create_tmp_directory
      FileUtils.mkdir_p(tmp_path)
    end

    def remove_tmp_directory
      FileUtils.rm_rf(tmp_path)
    end
  end
end
