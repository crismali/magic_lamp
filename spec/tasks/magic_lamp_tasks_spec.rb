require "rails_helper"

describe "MagicLamp Rake tasks" do
  describe "clean" do
    it "calls remove_tmp_directory" do
      expect(MagicLamp).to receive(:remove_tmp_directory)
      Rake::Task["magic_lamp:clean"].actions.first.call
    end

    it "depends on the environment task" do
      prereqs = Rake::Task["magic_lamp:clean"].all_prerequisite_tasks
      expect(prereqs).to include(Rake::Task["environment"])
    end
  end

  describe "create_fixtures" do
    it "calls create_fixture_files" do
      expect(MagicLamp).to receive(:create_fixture_files)
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
