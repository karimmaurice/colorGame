module Api
    module V1
        class IosController < BaseController
            # skip_before_filter  :verify_authenticity_token
            skip_before_filter :restrict_access ,:only => [:configurations, :login, :create_device]

            def login
                email = params[:email]
                password = params[:password]
                if request.format != :json 
                    render :status=>406, :json=>{:success=>"0", :message=>"The request must be json" }
                    return
                end

                if email.nil? or password.nil?
                    render :status=>406,
                    :json=>{:success=>"0", :message => "Invalid Request Data" }
                    return
                end

                @@current_user = User.find_by_email(email.downcase)

                if @@current_user.nil?
                    team = Team.where('name=?', email).first
                    if team
                        if password != team.game.pass_code
                            render :status=>401, :json=>{:success=>"0", :message=> "Invalid user name or password" }
                            return
                        else
                            game = team.game
                            user = {}
                            user['type'] = "team"
                            user['team'] = team.name
                            phone = Phone.where('uuid=?', params[:device_uuid]).first
                            if phone
                                phone.game_id = game.id
                                phone.team_id = team.id
                                phone.save
                            else
                                p = Phone.create(:uuid => params[:device_uuid] , :token => params[:device_token], :game_id => game.id, :team_id => team.id)
                            end
                            userToken = params['device_uuid']
                        end
                    else
                        render :status=>401, :json=>{:success=>"0", :message=> "Invalid user name or password" }
                        return
                    end
                else
                    if !@@current_user.valid_password?(password)
                        render :status=>401, :json=>{:success=>"0", :message=>"Invalid email or password"}
                    else
                        @@current_user.ensure_authentication_token!
                        # update or create the APN
    					d = Device.find_by_uuid params[:device_uuid]
    					if d.nil?
    						d = Device.create(:uuid => params[:device_uuid]) if !params[:device_uuid].nil?
    					else
    						@@current_user.device = d
    					end
    					if !params[:device_token].nil? && !params[:device_token].empty?
    						d.uuid = params[:device_token]
    					end
    					if !d.nil? && d.valid? && d.save
    						@@current_user.device = d
    					end
                        @@current_user.update_attributes(:sign_in_count => @@current_user.sign_in_count + 1)
                        userToken = @@current_user.api_key.key.to_s
                        #game
                        game = Game.where('user_id=?', @@current_user.id).first
                        user = {}
                        user['name'] = @@current_user.name
                        user['type'] = "admin"
                        user['team'] = "0"
                        if !game
                            render :status=>401, :json=>{:success=>"0", :message=> "There is no game for this user" }
                            return
                        end
                        phone = Phone.where('uuid=?', params[:device_uuid]).first
                        if phone
                            phone.game_id = game.id
                            phone.team_id = 0
                            phone.save
                        else
                            p = Phone.create(:uuid => params[:device_uuid] , :token => params[:device_token], :game_id => game.id, :team_id => 0)
                        end
                    end
                end
                hash = get_info(game, user, "Login Successfull")
                hash[:token] = userToken
                #send
                render :status=>200, :json=>hash 
            end

            # Create the APN Device
            def create_device
                phone = Phone.where('uuid=?', params[:device_uuid]).first
                if phone
                    phone.token = params[:device_token]
                    phone.save
                else
                    phone = Phone.new
                    phone.uuid = params[:device_uuid]
                    phone.token = params[:device_token]
                    phone.save
                end
                render :status=>200, :json=>{:success=>"1", :message=>"Success"}
            end

            def scoreUpdate
                @@current_user = User.where('email=?', params[:email]).first
                if !@@current_user
                    render :status=>401, :json=>{:success=>"-1", :message=> "Session ended" } 
                    return
                end
                #game
                game = Game.where('user_id=?', @@current_user.id).first
                user = {}
                user['name'] = @@current_user.name
                user['type'] = "admin"
                user['team'] = "0"
                if !game
                    render :status=>401, :json=>{:success=>"0", :message=> "There is no game for this user" }
                    return
                end
                #update score
                locationChallange = LocationChallenge.where('game_id=? and challenge_id=?', game.id, params[:challangeID]).first
                #create event
                if locationChallange.team_id != params[:team]
                    event = Event.new
                    event.team_won = params[:team]
                    event.team_lost = 0
                    event.team_lost = locationChallange.team_id if locationChallange.team_id
                    event.challenge_id = params[:challangeID]
                    event.game_id = game.id
                    event.save
                    send_alert(event, params[:device_uuid])
                end
                #update score
                if locationChallange
                    locationChallange.team_id = params[:team] 
                    locationChallange.score = params[:score]
                    locationChallange.save
                end
                hash = get_info(game, user, "Update Successfull")
                #send
                render :status=>200, :json=>hash
            end

            def send_alert event, uuid
                #APNS.host = 'gateway.push.apple.com' 
                APNS.pem  = 'config/certs/apn_development.pem'
                APNS.port = 2195

                phones = Phone.where('game_id=?', event.game_id)
                phones.each do |p|
                    if p.token and p.uuid != uuid
                        if p.team_id == 0
                            APNS.send_notification(p.token, :alert => "", :badge => 1, :sound => '')
                        else
                            if p.team_id == event.team_won
                                APNS.send_notification(p.token, :alert => "Land Won", :badge => 1, :sound => 'default')
                            elsif p.team_id == event.team_lost
                                APNS.send_notification(p.token, :alert => "Land Lost", :badge => 1, :sound => 'default')
                            else
                                APNS.send_notification(p.token, :alert => "", :badge => 1, :sound => '')
                            end
                        end
                    end
                end
            end

            def get_info game, user, message
                #data
                map = {}
                map[:image] = game.map.image.url
                map[:overlay] = game.image.url
                #locations
                locations = []
                locationChallanges = LocationChallenge.where('game_id=?', game.id)
                locationChallanges.each do |l|
                    sample = {}
                    sample[:challange] = l.challenge_id.to_s
                    if l.team
                        sample[:team] = l.team_id.to_s
                        location_color = LocationColor.joins(:location).where('locations.map_id=? and location_colors.color=? and location_colors.location_id=?', game.map_id, l.team.color, l.location_id).first
                        sample[:image] = location_color.image.url
                    else
                        sample[:team] = "0"
                        sample[:image] = "-1"
                    end
                    locations.push(sample)
                end
                #challenges
                challangeArray = []
                challanges = Challenge.joins(locations: {map: :games}).where('games.id=?', game.id)
                challanges.each do |c|
                    sample = {}
                    sample[:id] = c.id.to_s
                    sample[:name] = c.name
                    sample[:playerCount] = c.player_count.to_s
                    sample[:points] = c.points.to_s
                    sample[:description] = c.description
                    sample[:image] = c.image.url
                    locationChallange = LocationChallenge.where('game_id=? and challenge_id=?', game.id, c.id).first
                    if locationChallange.team
                        sample[:winnerName] = locationChallange.team.name
                        sample[:winnerID] = locationChallange.team.id.to_s
                    else
                        sample[:winnerName] = "(none)"
                        sample[:winnerID] = "0"
                    end
                    if locationChallange.score
                        sample[:score] = locationChallange.score.to_s
                    else
                        sample[:score] = "0"
                    end
                    challangeArray.push(sample)
                end
                #news
                newsArray = []
                events = Event.where('game_id=?', game.id).order("created_at DESC")
                events.each do |e|
                    sample = {}
                    sample[:date] = e.created_at.to_s
                    sample[:team_won] = Team.find(e.team_won).name
                    if e.team_lost != 0
                        sample[:team_lost] = Team.find(e.team_lost).name
                    else
                        sample[:team_lost] = "none"
                    end
                    sample[:challange_id] = e.challenge_id.to_s
                    newsArray.push(sample)
                end
                #scores
                locationChallanges = LocationChallenge.where(game_id: game.id)
                teams = Team.where(game_id: game.id)
                scoreArray = []
                teams.each do |t|
                    score = 0
                    locationChallanges.each do |c|
                        score = score + c.challenge.points if c.team_id == t.id
                    end
                    sample = {}
                    sample[:id] = t.id.to_s
                    sample[:name] = t.name
                    sample[:color] = t.color
                    sample[:score] = score.to_s
                    scoreArray.push(sample)               
                end
                hash = {:success=>"1", :message=>message, :map=>map, :user=>user, :locations=>locations, :challanges=>challangeArray, :news=>newsArray, :scores=>scoreArray}
                return hash
            end
            
        end
    end
end