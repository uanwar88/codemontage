class Project < ActiveRecord::Base
  belongs_to :organization
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :technologies, :causes

  attr_accessible :cause_list, :description, :github_repo, :help_url,
                  :install_url, :is_active, :is_approved, :name, :notes,
                  :organization_id, :technology_list, :url, :twitter
  validates_presence_of :name, :github_repo

  has_many :favorite_projects
  has_many :users, through: :favorite_projects
  has_many :featured_projects
  has_many :events, through: :featured_projects

  include FriendlyId
  friendly_id :name, use: :slugged

  scope :approved, where(is_approved: true)
  scope :active, approved.where(is_active: true)
  scope :featured, where('organization_id IS NOT NULL').active
  scope :with_technologies_and_causes, includes(:technologies, :causes)
  scope :with_organization, includes(:organization)

  def github_display
    "#{organization.github_org}/#{github_repo}"
  end

  def github_url
    "#{organization.github_url}/#{github_repo}"
  end

  def github_api_args
    { org_repo: github_display,
      repo: github_repo,
      day_begin: created_at,
      day_end: Time.now }
  end

  def github_pull_requests(args = github_api_args)
    Github.new.pull_requests_by_repo(args)
  end

  def github_commits(args = github_api_args)
    Github.new.commits_by_repo(args)
  end

  def github_issues(args = github_api_args)
    Github.new.issues_by_repo(args)
  end

  def github_forks(args = github_api_args)
    Github.new.forks_by_repo(args)
  end

  def related_projects
    organization.projects.where('id != ?', id)
  end

  def tasks_url
    "#{github_url}/issues"
  end
end
