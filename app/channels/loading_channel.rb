class LoadingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "loading_#{params[:atlas_id]}" if params[:atlas_id]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
