require 'time'

class StarDate

  attr_accessor :stardate

  class << self

    # Based on 365.25 days/year
    
    def millisecond
      3.168808781402895e-11
    end
    
    def second
      3.168808781402895e-08
    end

    def minute
      1.901285268841737e-06
    end

    def hour
      0.00011407711613050422
    end

    def day
      0.0027378507871321013
    end

    def week
      0.019164955509924708
    end

    def fortnight
      0.038329911019849415
    end

    def month
      0.08333333333333333
    end

    def rename(filename, mode = :mtime)
      case mode
      when :mtime
        datetime = File.mtime filename
      when :ctime
        datetime = File.ctime filename
      else
        raise "Unknown mode: #{mode}"
      end
      File.rename filename, datetime.to_stardate.to_filename(filename)
    end

  end

  def initialize(t = Time.now)
    case t.class.to_s
    when "Float"
      @stardate = t
      return
    when "DateTime"
      datetime = t.to_time.utc
    when "Time"
      datetime = t.utc
    when "ActiveSupport::TimeWithZone"
      datetime = t.utc
    when "String"
      datetime = Time.parse(t).utc
    else
      raise "Unknown conversion: #{t.class}"
    end
    y0 = datetime.year
    t0 = Time.utc(y0).to_f
    t1 = Time.utc(y0 + 1).to_f
    @stardate = y0 + (datetime.to_f - t0)/(t1 - t0)
  end

  def inspect
    [
      to_s,
      ' [',
      to_rfc2822,
      ']'
    ].join
  end

  def to_datetime
    to_time.to_datetime
  end

  def to_dts
    to_time.utc.strftime("%Y%m%d_%H%M%SZ")
  end

  def to_f
    @stardate
  end

  def to_filename(filename)
    ext = File.extname filename
    [
      filename.chomp(ext),
      '-',
      to_s,
      ext
    ].join
  end

  def to_localdate
    to_time.to_date
  end

  # Round to the nearest second
  def to_rfc2822
    Time.at(to_time.to_f + 0.5).rfc2822
  end

  def to_s
    sprintf("%.15f", @stardate)
  end

  def to_time
    y0 = @stardate.to_i
    t0 = Time.utc(y0).to_f
    t1 = Time.utc(y0+1).to_f
    Time.at(t0 + (@stardate-y0)*(t1-t0))
  end

  def to_utcdate
    to_time.utc.to_date
  end

end

class DateTime

  def to_stardate
    StarDate.new self
  end

end

class Time

  def to_stardate
    StarDate.new self
  end

end
