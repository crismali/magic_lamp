# frozen_string_literal: true

require "rails_helper"

module MagicLamp
  describe LintController do
    routes { MagicLamp::Engine.routes }

    describe "#index" do
      context "no errors" do
        render_views
        before { get :index }
        it { is_expected.to render_template(:no_errors) }
      end

      context "config file errors" do
        context "file load error" do
          before do
            allow(MagicLamp).to receive(:load_config) do
              load Rails.root.join("error_specs", "config_file_load_error.rb")
            end
            get :index
          end

          context "views" do
            render_views
            it { is_expected.to render_template(:config_file_load_error) }
          end

          it "assigns config_file_load_error" do
            expect(assigns(:config_errors)[:config_file_load]).to match("RuntimeError: Nope")
          end
        end

        context "callback errors" do
          let!(:error_proc) { proc { raise "nope" } }

          before do
            expect_any_instance_of(MagicLamp::Configuration).to receive(:before_each_proc).and_return(error_proc)
            expect_any_instance_of(MagicLamp::Configuration).to receive(:after_each_proc).and_return(error_proc)
            get :index
          end

          context "views" do
            render_views
            it { is_expected.to render_template(:callback_errors) }
          end

          it "assigns config_file_load_error" do
            expect(assigns(:config_errors).keys).to match_array(%i[before_each after_each])
          end
        end
      end

      context "lamp file errors" do
        let!(:lamp_file_paths) do
          ["first_errored_lamp_file.rb", "second_errored_lamp_file.rb"].map do |file_name|
            Rails.root.join("error_specs", file_name).to_s
          end
        end

        before do
          allow(MagicLamp).to receive(:lamp_files).and_return(lamp_file_paths)
          get :index
        end

        context "views" do
          render_views
          it { is_expected.to render_template(:file_errors) }
        end

        it "assigns file errors" do
          expect(assigns(:file_errors).keys).to match_array(lamp_file_paths)
        end
      end

      context "fixture errors" do
        before do
          allow(MagicLamp).to receive(:lamp_files).and_return([Rails.root.join("error_specs", "broken_fixtures.rb").to_s])
          get :index
        end

        context "views" do
          render_views
          it { is_expected.to render_template(:fixture_errors) }
        end

        it "assigns fixture errors" do
          expect(assigns(:fixture_errors).keys).to match_array(["foo", "orders/bar"])
        end
      end
    end
  end
end
