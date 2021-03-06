class SyncUserFollowsJob < ApplicationJob
  # Adding or deleting a job? Reflect the change in the QUEUES environment variable in docker-compose.yml and
  # docker-compose-production.yml.
  queue_as :sync_user_follows

  def perform(user, twitch_user)
    ActiveRecord::Base.transaction do
      current_followed_users = User.joins(:twitch).where(
        twitch_users: {twitch_id: twitch_user.followed_ids}
      )

      TwitchUserFollow.where(
        from_user: user,
        to_user:   (user.twitch_follows - current_followed_users)
      ).destroy_all

      TwitchUserFollow.import!((current_followed_users - user.twitch_follows).map do |u|
        TwitchUserFollow.new(from_user: user, to_user: u)
      end)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    twitch_user.update(follows_synced_at: Time.new.utc(1970))
    raise e
  end
end
