class PagesController < ApplicationController

  before_filter :only_admins, :only => ['stats']

  def banner
    @pack = Pack.find(params[:pack_id])
    render :partial => 'layouts/banner'
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def master_thesis
    page = params[:page] ? params[:page].to_i : 1

    render "master_thesis_#{page}.fr"
  end

  def stats
    @total_users   = User.registered.count
    @total_friends = User.not_registered.count
    @total_scores  = LevelUserLink.count
    @best_scores   = LevelUserLink.where(:best_level_user_score => true).count
    @distribution  = User.registered.group('total_won_levels').count
    @last_users    = User.registered.order('registered_at DESC').limit(20)
    @last_scores   = LevelUserLink.order('created_at DESC').limit(100)
    @jobs          = Delayed::Job.all

    @past_next_mailing_at = MailingService.users_to_mail_now(false).count
    @mails_by_week =
      User.registered.where(:mailing_unsubscribe => false).keep_if do |user|
        user.scores.where('created_at > ?', Time.now - MailingService::TIME_BEFORE_INACTIVE).any?
      end.count
  end
end
