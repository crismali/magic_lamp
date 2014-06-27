require "rails_helper"

describe "MagicLamp Rake tasks" do
  describe "clean" do
    it "calls clear_fixtures" do
      expect(MagicLamp).to receive(:clear_fixtures)
      Rake::Task["magic_lamp:clean"].actions.first.call
    end

    it "depends on the environment task" do
      prereqs = Rake::Task["magic_lamp:clean"].all_prerequisite_tasks
      expect(prereqs).to include(Rake::Task["environment"])
    end
  end

  describe "create_fixtures" do
    it "calls load_lamp_files" do
      expect(MagicLamp).to receive(:load_lamp_files)
      Rake::Task["magic_lamp:create_fixtures"].actions.first.call
    end

    it "depends on the clean task" do
      prereqs = Rake::Task["magic_lamp:create_fixtures"].all_prerequisite_tasks
      expect(prereqs).to include(Rake::Task["magic_lamp:clean"])
    end
  end

  describe "magic_lamp" do
    it "depends on the create_fixtures task" do
      prereqs = Rake::Task["magic_lamp"].all_prerequisite_tasks
      expect(prereqs).to include(Rake::Task["magic_lamp:create_fixtures"])
    end
  end
end
