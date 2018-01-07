require 'sinatra'
require 'colorize'

BALANCES = {
  'tim' => 1_000_000,
}

PASSWORDS = {
  'tim' => 'strand-ponoudi'
}

get "/balance" do
  user = params['user'].downcase
  puts BALANCES.to_s.yellow
  "#{user} has #{BALANCES[user]}"
end 

post "/users" do
  name = params['name'].downcase
  BALANCES[name] ||= 0 
  puts BALANCES.to_s.yellow
  "OK"
end 

post "/transfers" do
  from, to = params.values_at('from', 'to').map(&:downcase)
  amount = params['amount'].to_i
  #if user doesn't have enough money to transfer then raise error
  raise unless BALANCES[from] >= amount && BALANCES[from] && BALANCES[to]
  BALANCES[from] -= amount
  BALANCES[to] += amount
  puts BALANCES.to_s.yellow
  "OK"
end 