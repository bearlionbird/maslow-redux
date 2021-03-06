module NeedHelper
  include ActiveSupport::Inflector
  include ActionView::Helpers::NumberHelper

  def format_need_goal(goal)
    return "" if goal.blank?

    words = goal.split(" ")
    words.first[0] = words.first[0].upcase
    words.join(" ")
  end

  # If no criteria present, insert a blank
  # one.
  def criteria_with_blank_value(criteria)
    criteria.present? ? criteria : [""]
  end

  def calculate_percentage(numerator, denominator)
    return unless numerator.present? and denominator.present?
    return if denominator == 0

    percent = numerator.to_f / denominator.to_f * 100.0

    # don't include the fractional part if the percentage is X.0%
    format = percent.modulo(1) < 0.1 ? "%.0f%%" : "%.1f%%"
    (format % percent)
  end

  def show_interactions_column?(need)
    [ need.yearly_user_contacts, need.yearly_site_views, need.yearly_need_views, need.yearly_searches ].select(&:present?).any?
  end

  def format_friendly_integer(number)
    if number >= 1000000
      "%.3g\m" % (number.to_f / 1000000)
    elsif number >= 1000
      "%.3g\k" % (number.to_f / 1000)
    else
      number.to_s
    end
  end

  def paginate_needs(needs)
    paginate needs
  end

  def canonical_need_goal(need)
    return unless need.canonical_need
    need.canonical_need.goal
  end

  def bookmark_icon(bookmarks = [], need_id)
    bookmarks.include?(need_id.to_s) ? 'bookmark-selected' : 'bookmark-unselected'
  end
end
