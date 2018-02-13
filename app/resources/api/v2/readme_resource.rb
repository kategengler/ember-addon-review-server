# frozen_string_literal: true

class API::V2::ReadmeResource < JSONAPI::Resource
  immutable
  attributes :contents
end
