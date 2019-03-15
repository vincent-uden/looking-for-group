require 'net/http'
require 'awesome_print'


class RuneScapeApi
  @@BASE_URL     = 'https://secure.runescape.com'
  @@BASE_QUERY   = '/m=hiscore_oldschool/index_lite.ws?player='
  @@OFFLINE_MODE = false
  @@OFFLINE_STATS = []
  
  def self.set_offline(is_offline)
    @@OFFLINE_MODE = is_offline
    stats = File.readlines "stats.txt"
    @@OFFLINE_STATS = stats.map { |stat| eval(stat) }
  end

  def self.get_offline_stat(rsn)
    sum = 0
    rsn.each_byte do |b|
      sum += b
    end
    @@OFFLINE_STATS[sum % @@OFFLINE_STATS.length]
  end

  def self.get_stats(rsn)
    if @@OFFLINE_STATS
      return get_offline_stat rsn
    end
    uri = URI(@@BASE_URL + @@BASE_QUERY + rsn.to_s)
    response = Net::HTTP.get_response(uri)
    if response.code == "200"
      self.parse_stats(response.body)
    else
      return {
        attack: nil,
        defence: nil,
        strength: nil,
        hitpoints: nil,
        ranged: nil,
        prayer: nil,
        magic: nil,
        mining: nil,
        herblore: nil,
        thieving: nil,
        farming: nil
      }
    end

  end

  # Converts csv response from runescape.com to hash with only
  # relevant skills present
  def self.parse_stats(csv_stats)
    stats = csv_stats.split(/[\n,\,]/)
    stats.map! { |stat| stat.to_i }
    skills = []
    (0..(stats.length / 3) - 1).each do |i|
      skills << stats[i * 3 + 1]
    end

    skill_hash = {
      attack: skills[1],
      defence: skills[2],
      strength: skills[3],
      hitpoints: skills[4],
      ranged: skills[5],
      prayer: skills[6],
      magic: skills[7],
      mining: skills[15],
      herblore: skills[16],
      thieving: skills[18],
      farming: skills[20]
    }
  end

  def self.convert_username(rsn)
    if rsn[0] == ' '
      raise ArgumentError, 'Name cannot start with a space'
    elsif rsn[rsn.length - 1] == ' '
      raise ArgumentError, 'Name cannot end with a space'
    end
    output = ''
    rsn.split('').each do |c|
      # Alphanumeric
      if /[a-zA-Z0-9_\-]/ =~ c
        output += c
      elsif c == ' '
        output += '_'
      else
        raise ArgumentError, 'Name contains illegal character'
      end
    end
    return output
  end

end
