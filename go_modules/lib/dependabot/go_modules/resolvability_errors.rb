# typed: true
# frozen_string_literal: true

require "dependabot/logger"

module Dependabot
  module GoModules
    module ResolvabilityErrors
      GITHUB_REPO_REGEX = %r{github.com/[^:@]*}

      def self.handle(message, goprivate:)
        mod_path = message.scan(GITHUB_REPO_REGEX).last
        unless mod_path && message.include?("If this is a private repository")
          raise Dependabot::DependencyFileNotResolvable, message
        end

        Dependabot.logger.info "== ResolvabilityErrors.handle #{mod_path} = #{message}"

        # Module not found on github.com - query for _any_ version to know if it
        # doesn't exist (or is private) or we were just given a bad revision by this manifest
        SharedHelpers.in_a_temporary_directory do
          File.write("go.mod", "module dummy\n")

          mod_split = mod_path.split("/")
          repo_path = if mod_split.size > 3
                        mod_split[0..2].join("/")
                      else
                        mod_path
                      end

          env = { "GOPRIVATE" => goprivate }
          _, _, status = Open3.capture3(env, SharedHelpers.escape_command("go list -m -versions #{repo_path}"))
          raise Dependabot::DependencyFileNotResolvable, message if status.success?

          raise Dependabot::GitDependenciesNotReachable, [repo_path]
        end
      end
    end
  end
end
