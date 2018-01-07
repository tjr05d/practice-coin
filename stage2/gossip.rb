require 'sinatra'
require 'colorize'
require 'active_support/time'
require_relative 'client'
require_relative 'helpers'
require 'byebug'

PORT, PEER_PORT = ARGV.first(2)
set :port, PORT

STATE = ThreadSafe::Hash.new
update_state(PORT => nil)
update_state(PEER_PORT => nil)

MOVIES = File.readlines("movies.txt").map(&:chomp)
@favorite_movie = MOVIES.sample
@version_number = 0 
puts "My favorite movie, now and forever, is #{@favorite_movie.green}!"

update_state(PORT => [@favorite_movie, @version_number])

every(8.seconds) do
    puts "You know what,screw #{@favorite_movie.yellow}, it's so cliche"
    @favorite_movie = MOVIES.sample
    @version_number += 1 
    update_state(PORT => [@favorite_movie, @version_number])
    puts "My new favorite is #{@favorite_movie.green}"
end 

every(3.seconds) do
    STATE.dup.each_key do |peer_port|
        next if peer_port == PORT
        puts "Gossiping with #{peer_port}, gossip, gossip" 

        begin 
            their_state = Client.gossip(peer_port, JSON.dump(STATE))
            update_state(JSON.parse(their_state))
        rescue Faraday::ConnectionFailed => e 
            puts e 
            STATE.delete(peer_port)
        end 
    end 
    render_state
end 

post "/gossip" do
    their_state = params['state']
    update_state(JSON.load(their_state))
    JSON.dump(STATE)
end 