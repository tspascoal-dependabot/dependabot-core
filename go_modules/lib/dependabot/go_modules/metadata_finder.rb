# typed: true
# frozen_string_literal: true

require "dependabot/metadata_finders"
require "dependabot/metadata_finders/base"
require "dependabot/logger"
require "dependabot/go_modules/path_converter"

module Dependabot
  module GoModules
    class MetadataFinder < Dependabot::MetadataFinders::Base
      private

      def look_up_source
        url = Dependabot::GoModules::PathConverter.git_url_for_path(dependency.name)

        # log url and dependency name
        Dependabot.logger.info "== look_up_source #{dependency.name} = #{url}"

        Source.from_url(url) if url
      end
    end
  end
end

Dependabot::MetadataFinders
  .register("go_modules", Dependabot::GoModules::MetadataFinder)
