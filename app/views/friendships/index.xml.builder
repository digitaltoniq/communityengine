xml.instruct!
xml.RelationViewerData do 
  xml.Settings :appTitle=>"#{AppConfig.community_name} Friendships Browser", :WWWLinkTargetFrame=>"_blank", :startID=>"#{application_url}#{@user_slug}",
    :defaultRadius=>"170", :maxRadius=>"240", :contextRadius=>"130" do 
    xml.RelationTypes do 
      xml.DirectedRelation :color=>"0x999999", :lineSize=>"3"
    end
    xml.NodeTypes do 
      xml.Person
    end
  end
  
  xml.Nodes do
    @users.each do |user|
      imageUrl = (user.avatar_photo_url(:small).eql?('icon_missing_thumb.png') ? '/images/icon_missing_thumb.png' : user.avatar_photo_url(:small) )
      xml.Person :tags => "#{user.tags.collect{|t| t.name }.join(", ")}", :dataURL=>"friendships.xml?id=#{user.id}", 
      :id=>"#{application_url}#{user_slug}", :name=>"#{user}", :imageURL=>imageUrl, :URL=>"#{application_url}#{user_slug}" do
          xml.cdata!( truncate_words( strip_tags(user.description), 50, '...') )
      end
    end
  end
  
  xml.Relations do 
    @friendships.each do |friendship|
      xml.DirectedRelation :fromID=>"#{application_url}#{friendship.user_slug}", :toID=>"#{application_url}#{friendship.friend.login_slug}"
    end
  end

end
