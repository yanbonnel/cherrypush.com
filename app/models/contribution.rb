# frozen_string_literal: true

class Contribution < ApplicationRecord
  belongs_to :project

  validates :commit_sha, presence: true
  validates :commit_date, presence: true
  validates :author_name, presence: true
  validates :author_email, presence: true
  validates :metrics, presence: true

  def self.total_by_author(contributions)
    contributions
      .group_by { |contribution| [contribution.author_name, contribution.author_email] }
      .transform_values { |contributions| aggregate(contributions.map(&:metrics)) }
  end

  def self.aggregate(metrics_list)
    metrics_list.each_with_object({}) do |metrics, result|
      metrics.each do |name, value|
        result[name] ||= { addition: 0, deletion: 0 }
        kind = value.positive? ? :addition : :deletion
        result[name][kind] += value
      end
    end
  end
end
