require 'pry-byebug'

def count_down(x)
  p "#{x}..."
  return true if x <= 0
  count_down(x - 1)
end

byebug
bomb = { sound: 'BOOM' }
count_down(5)
p bomb[:sound]


# help - shows byebug commands
# next - runs next line of code in current frame
# step - runs next line, enters sub frame
# continue - run till reaching the next breakpoint / end of program
# finish - run till end of frame
# quit - exit byebug
# break 4 - create break point at line 4
# break 4 if x == 1 - create break point at line 4, if x==1
# list - show surrounding 10 lines of code
# display x - adds a var to display list
# display shows all listed vars & their vals
