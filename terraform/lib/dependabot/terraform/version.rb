# typed: strong
# frozen_string_literal: true

require "dependabot/version"

# Terraform pre-release versions use 1.0.1-rc1 syntax, which Gem::Version
# converts into 1.0.1.pre.rc1. We override the `to_s` method to stop that
# alteration.
#
# See, for example, https://releases.hashicorp.com/terraform/

module Dependabot
  module Terraform
    class Version < Dependabot::Version
      extend T::Sig

      sig do
        override
          .overridable
          .params(
            version: T.any(
              String,
              Integer,
              Float,
              Gem::Version,
              NilClass
            )
          )
          .void
      end
      def initialize(version)
        @version_string = T.let(version.to_s, String)
        super
      end

      sig { override.returns(String) }
      def to_s
        @version_string
      end
    end
  end
end

Dependabot::Utils
  .register_version_class("terraform", Dependabot::Terraform::Version)
