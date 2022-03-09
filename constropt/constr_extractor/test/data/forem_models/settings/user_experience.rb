module Settings
  # Basic UX settings that can be overridden by individual user preferences.
  class UserExperience < Base
    self.table_name = :settings_user_experiences

    HEX_COLOR_REGEX = /\A#(\h{6}|\h{3})\z/
    FEED_STRATEGIES = %w[basic large_forem_experimental].freeze
    FEED_STYLES = %w[basic rich compact].freeze

    # The default font for all users that have not chosen a custom font yet
    setting :default_font, type: :string, default: "sans_serif"
    setting :feed_strategy, type: :string, default: "basic", validates: {
      inclusion: { in: FEED_STRATEGIES }
    }
    # basic (current default), rich (cover image on all posts), compact (more minimal)
    setting :feed_style, type: :string, default: "basic", validates: {
      inclusion: { in: FEED_STYLES }
    }
    setting :home_feed_minimum_score, type: :integer, default: 0
    setting :index_minimum_score, type: :integer, default: 0
    setting :primary_brand_color_hex, type: :string, default: "#3b49df", validates: {
      format: {
        with: HEX_COLOR_REGEX,
        message: proc { I18n.t("models.settings.user_experience.message") }
      },
      color_contrast: true
    }
    # a non-public forem will redirect all unauthenticated pages to the registration page.
    # a public forem could have more fine-grained authentication (listings ar private etc.) in future
    setting :public, type: :boolean, default: true
    setting :tag_feed_minimum_score, type: :integer, default: 0
    setting :default_locale, type: :string, default: "en"
    setting :display_in_directory, type: :boolean, default: true
  end
end
