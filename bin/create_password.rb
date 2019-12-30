# frozen_string_literal: true

print 'Save password: '
password = gets.chomp
arr = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a + ['.', '/']
salt = ''
2.times { salt += arr[rand(arr.length)] }
cipher = password.crypt(salt)
puts "ADMIN_PASSWORD=#{cipher}"

print 'Check password: '
password = gets.chomp
if password.crypt(cipher) == cipher
  puts 'OK'
else
  puts 'NG'
end
