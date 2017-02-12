class API::V2::AddonResource < JSONAPI::Resource
  attributes :name,
             :latest_version_date,
             :description, :is_deprecated,
             :is_official, :is_cli_dependency,
             :is_hidden,
             :score, :is_wip, :is_fully_loaded,
             :ranking, :published_date,
             :repository_url,
             :license, :note,
             :has_invalid_github_repo,
             :last_month_downloads, :is_top_downloaded, :is_top_starred,
             :demo_url

  has_many :maintainers, class_name: 'Maintainer'
  has_many :versions, class_name: 'Version', relation_name: 'addon_versions'
  has_many :keywords, class_name: 'Keyword', relation_name: 'npm_keywords'
  has_many :github_users
  #TODO: Make has_one :review
  has_many :reviews
  has_many :categories
  has_one :github_stats
  has_one :readme

  paginator :offset

  DEFAULT_PAGE_SIZE = 977

  filter :name

  REQUIRE_ADMIN = ->(values, context) {
    if values.include?("true") && context[:current_user].nil?
      raise Forbidden
    end
    values
  }

  filter :in_category, apply: ->(records, category_id, _options) {
    Category.find(category_id.first).addons
  }

  filter :top, apply: ->(records, value, _options) {
    records.where('ranking is not null')
  }

  filter :hidden, verify: REQUIRE_ADMIN, default: 'false'

  filter :is_wip

  filter :not_categorized, verify: REQUIRE_ADMIN, apply: -> (records, value, _options) {
    records.includes(:categories).where(categories: { id: nil })
  }

  filter :not_reviewed, verify: REQUIRE_ADMIN, apply: -> (records, value, _options) {
    records.where("name NOT IN (?)", Review.select(:addon_name))
  }

  filter :needs_re_review, verify: REQUIRE_ADMIN, apply: -> (records, value, _options) {
    records.where("name in (?)", Review.select(:addon_name)).joins(:latest_addon_version).where("addon_versions.id NOT IN (?)", Review.select(:addon_version_id))
  }

  filter :recently_reviewed, apply: ->(records, value, _options) {
    limit = _options[:paginator] && _options[:paginator].limit != DEFAULT_PAGE_SIZE ? _options[:paginator].limit : 10
    Addon.joins(:addon_versions).where("addon_versions.id IN (?)", Review.order('created_at DESC').limit(limit).select('addon_version_id'))
  }

  def self.find(filters, options = {})
    the_only_filter_is_the_default = filters.keys == [:hidden] && filters[:hidden] == %w(false)
    has_invalid_limit = options[:pagination] ? options[:pagination].limit > 100 : true
    has_no_sort = options[:sort_criteria] ? [:sort_criteria].length == 0 : true
    raise Forbidden if the_only_filter_is_the_default && (has_invalid_limit && has_no_sort)
    super
  end

  def is_deprecated
    @model.deprecated
  end

  def is_deprecated=(value)
    @model.deprecated = value
  end

  def is_official
    @model.official
  end

  def is_official=(value)
    @model.official = value
  end

  def is_cli_dependency
    @model.cli_dependency
  end

  def is_cli_dependency=(value)
    @model.cli_dependency = value
  end

  def is_hidden
    @model.hidden
  end

  def is_hidden=(value)
    @model.hidden = value
  end

  def is_fully_loaded
    true
  end

  UPDATABLE_ATTRIBUTES = [
    :is_deprecated, :is_official, :is_cli_dependency,
    :is_hidden, :is_wip, :note, :has_invalid_github_repo,
  ]

  UPDATABLE_RELATIONSHIPS = [
    :categories
  ]

  def self.updatable_fields(context)
    return [] unless context[:current_user]
    UPDATABLE_ATTRIBUTES + UPDATABLE_RELATIONSHIPS
  end

  def self.creatable_fields(context)
    []
  end
end
