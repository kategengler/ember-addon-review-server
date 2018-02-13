# frozen_string_literal: true

# == Schema Information
#
# Table name: ember_version_compatibilities
#
#  id             :integer          not null, primary key
#  test_result_id :integer
#  ember_version  :string
#  compatible     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class EmberVersionCompatibility < ApplicationRecord
  belongs_to :test_result
end
