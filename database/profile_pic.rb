class ProfileImage

  def self.save_profile_image(user_id, file_ext, file_data)
    path = "./public/img/profile_imgs/#{user_id}.#{file_ext}"
    if File.file? path
      File.open(path, "wb") do |f|
        f.write(file_data.read)
      end
    end
  end

end
