module MagicLamp
  class TestController < ApplicationController
    def index
      render text: "foo"
    end
  end
end
