class HomeController < ApplicationController
  include ActionView::Helpers::DateHelper

  def index
  end

  def chart
    @start = Time.at(params[:start].to_i).to_datetime
    @interval = params[:interval].to_i
    render json: {
        title: @title,
        start: @start.to_i*1000,
        data: get_data(@start, @interval)
    }
  end

  def overview
    @devs = miner.devices
    @sum = miner.summary
    @ver = miner.version
    @speed = mhash_to_s(@devs.map { |dev| dev[:mhs_5s] }.reduce(:+))
    render layout: false, partial: 'home/overview', formats: [:html]
  end

  def devices
    # Get device json data
    @devs = miner.devices
    render layout: false, partial: 'devices', formats: [:html]
  end

  def pools
    @pools = miner.pools
    render layout: false, partial: 'pools', formats: [:html]
  end

  private
  def get_data(start_date, interval)
    # Select the data within range
    start = start_date.to_i
    start -= start % interval
    fin = DateTime.now.to_i
    fin -= fin % interval
    endy = Time.at(fin).to_datetime
    interval = interval.to_f
    data = DataPoint.range(Time.at(start).to_datetime, endy)

    elapsed = endy.to_i - start
    groups = Array.new(elapsed / interval.to_i) { [] }

    # Group the data by our interval
    data.each do |dp|
      utime = dp[:time] - start
      idx = (utime.to_f / interval).floor
      groups[idx-1] << dp[:value]
    end

    # Average and return as time, value pairs
    groups.map do |arr|
      arr.empty? ? 0 : arr.reduce(:+) / arr.length
    end
  end
end